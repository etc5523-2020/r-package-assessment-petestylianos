## code to prepare `covid19_data` dataset goes here

# Reqired libraries

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


# Run this command if you want to get the most up to date data about daily data.

# coronavirus::update_dataset()

# Apple city data
covid19_data <- tidycovid19::download_apple_mtr_data(type = "country_city", cached = TRUE)


usethis::use_data(covid19_data, overwrite = TRUE)
