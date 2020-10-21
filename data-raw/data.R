# This script produces all the datasets and objects required in the app's server.
# The covidExplorer::launch_app() function sources this script and runs it before deploying the app
# to update all datasets.


library(classInt)
library(coronavirus)
library(COVID19)
library(DT)
library(leaflet)
library(ggthemes)
library(glue)
library(htmlwidgets)
library(maps)
library(patchwork)
library(plotly)
library(RColorBrewer)
library(scales)
library(shiny)
library(shinycssloaders)
library(shinydashboard)
library(shinydashboardPlus)
library(shinythemes)
library(shinyWidgets)
library(stringr)
library(tidycovid19)
library(tidytext)
library(tidyverse)
library(twitteR)



# Get latest data
coronavirus::update_dataset()

# Apple city-level data
covid <- tidycovid19::download_apple_mtr_data(type = "country_city", cached = TRUE)

# All data from tidycovid19 package in a country level
covid_all <- tidycovid19::download_merged_data(cached = TRUE)

# merge the above datasets to have both the city and the country name
covid_city <- inner_join(covid, covid_all, by = c("iso3c", "date")) %>%
  select(c(date, country, city, driving, walking, transit ))


# Data related to measures per country from the tidycovid19 package
cases_covid <- tidycovid19::download_acaps_npi_data(cached = TRUE)


# Covid Measures table
covid_measures <- covid_all %>%
  select(c(date, country, soc_dist, lockdown, mov_rest, pub_health, gov_soc_econ )) %>%
  pivot_longer(cols = -c(date, country),  names_to = "measure", values_to = "effect")


covid_measures$measure <- as.factor(covid_measures$measure)

levels(covid_measures$measure) <- c("Governance and socio-economic measures" ,
                                    "Lockdown",
                                    "Movement restrictions",
                                    "Public health measures",
                                    "Social distancing"
)



## Calculate country stats
country_stats <- covid_all %>%
  select(date, country, deaths, confirmed, recovered, population) %>%
  filter(date == max(date) - 1) %>%
  group_by(country) %>%
  summarise(total_deaths = sum(deaths, na.rm = T),
            total_infected = sum(confirmed, na.rm = T),
            total_recovered = sum(recovered, na.rm = T),
            total_active = total_infected - total_deaths - total_recovered,
            death_rate = total_deaths/total_infected *100,
            infected_rate = total_infected/sum(population, na.rm = T) * 100)

## Calculate global stats
global_stats <- covid_all %>%
  select(date, country, deaths, confirmed, recovered, population) %>%
  filter(date == max(date) - 1) %>%
  summarise(total_deaths = sum(deaths, na.rm = T),
            total_infected = sum(confirmed, na.rm = T),
            total_recovered = sum(recovered, na.rm = T),
            total_active = total_infected - total_deaths - total_recovered,
            death_rate = total_deaths/total_infected,
            infected_rate = total_infected/sum(population, na.rm = T))



# Data to produce the leaflet map

corona_map <- coronavirus %>%
  filter(type == "confirmed") %>%
  group_by(country) %>%
  mutate(total_cases = sum(cases)) %>%
  as_tibble() %>%
  distinct(country, total_cases, lat, long)

corona_map <- corona_map %>%
  rename(lng = long) %>%
  na.omit()


# obtain coordiantes

mapCountry<- maps::map("world", fill = TRUE, plot = FALSE)



corona_map$country <- gsub(corona_map$country, pattern = "US", replacement = "USA")

total_cases <- corona_map$total_cases[match(mapCountry$names, corona_map$country)]

pal_fun <- colorQuantile("YlOrRd", NULL, n = 7)

breaks_qt <- classIntervals(corona_map$total_cases, n = 8, style = "fixed",
                            fixedBreaks = c(min(corona_map$total_cases), 10^4,  10^5, 5 * 10 ^ 5, 10^6, 2 * 10^6, 4 * 10^6, max(corona_map$total_cases)))
values <- c(9, 10^4,  10^5, 5 * 10 ^ 5, 10^6, 2 * 10^6, 4 * 10^6, max(corona_map$total_cases))

interval <- values[values >9 & values < 7000000]


# javascript to enable click event in the Measures Tab

js <- c(
  "function(el, x){",
  "  el.on('plotly_legendclick', function(evtData) {",
  "    Shiny.setInputValue('trace', evtData.data[evtData.curveNumber].name);",
  "  });",
  "}")

