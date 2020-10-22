
server <- function(input, output, session) {


  # This script produces all the datasets and objects required in the app's server.
  # The covidExplorer::launch_app() function sources this script and runs it before deploying the app
  # to update all datasets.



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








  output$city <-  renderPlot({

    if (input$country != "United States") {
      covid_city %>%
        dplyr::filter(country == input$country) %>%
        pivot_longer(cols = c("driving", "walking","transit"), names_to = "index", values_to = "value") %>%
        ggplot(aes(date, value, color = factor(index))) +
        geom_line(lwd = 1.3) +
        theme(
          legend.position = "bottom",
          legend.title = element_blank(),
          legend.text =  element_text(size = 21)
        ) +

        guides(colour = guide_legend(override.aes = list(size=4))) +
        scale_x_date(labels = date_format("%B"), breaks='2 month') +
        labs(
          title = "Apple Mobility Reports",
          subtitle = "Notice for some countries the significant increase in walking in contrast to the use of public transport.\n",
          caption = "Data reflect requests for directions in Apple Maps",
          x = "Date",
          y = "Index",
          color = "Index"
        ) +
        scale_color_colorblind(name = "Index",  labels = c("Driving", "Walking", "Transit")) +
        facet_wrap(~city)

    }

    else {

      covid_city %>%
        dplyr::filter(country == input$country) %>%
        filter(city %in% c("New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia", "San Antonio", "Dallas")) %>%
        pivot_longer(cols = c("driving", "walking","transit"), names_to = "index", values_to = "value") %>%
        ggplot(aes(date, value, color = factor(index))) +
        geom_line(lwd = 1.3) +
        theme(
          legend.position = "bottom",
          legend.title = element_blank(),
          legend.text =  element_text(size = 21)
        ) +
        guides(colour = guide_legend(override.aes = list(size=4))) +
        scale_x_date(labels = date_format("%B"), breaks='2 month') +
        labs(
          title = "Apple Mobility Reports",
          subtitle = "Notice for some countries the significant increase in walking in contrast to the use of public transport.\n",
          caption = "Data reflect requests for directions in Apple Maps",
          x = "Date",
          y = "Index",
          color = "Index"
        ) +
        scale_color_colorblind(name = "Index",  labels = c("Driving", "Walking", "Transit")) +
        facet_wrap(~city)





    }



  })



  output$measure <- renderPlotly({
    p <- ggplotly(source = "all_measures",
                  covid_measures %>%
                    filter(country == input$meas_country) %>%
                    ggplot(aes(date, effect, color = measure)) +
                    geom_point(size = 2)  +
                    scale_color_colorblind() +
                    theme_classic() +
                    theme(
                      panel.background = element_rect(fill = "#bad2e3"),
                      plot.background = element_rect(fill = "#bad2e3"),
                      plot.title.position = "plot",
                      plot.title = element_text(size = 16, color = "navy",face = "normal", margin = unit(c(0, 0, 0.6, 0), "cm")),
                      legend.background = element_rect(fill = "#bad2e3"),
                      strip.text = element_text(size = 14),
                      axis.title = element_text( size = 15, face = "bold" ),
                      panel.spacing = unit(2, "lines"),
                      axis.title.x   = element_blank(),
                      axis.title.y = element_text(size = 14, color = "black"),
                      axis.line.x = element_line(linetype = "dashed", size = 2),
                      axis.line.y = element_line(linetype = "dashed", size = 2),
                      axis.text.x = element_text(size = 11, color = "black"),
                      axis.text.y = element_text(size = 19, color = "black"),
                      strip.background = element_rect(
                        color="grey91", fill="#9fb6cd", size=1.5, linetype="solid"),
                      legend.position = "bottom",
                      legend.title = element_blank(),
                      legend.text =  element_text(size = 15)
                    ) +
                    guides(colour = guide_legend(override.aes = list(size=4))) +
                    scale_x_date(labels = date_format("%B"), breaks='2 month') +
                    scale_color_colorblind(name = "Index",  labels = c("Social-Economic", "Lockdown", "Movement Restrictions", "Public Health", "Social Distancing")) +
                    labs(
                      title = "Number of Measures by Category and when they were taken",
                      subtitle = "Each time the line moves upwards a new measure was taken, whereas\n each time the line moves downwards an old measure was uplifted.",
                      caption = "Data from covid_all19 package",
                      x = "Date",
                      y = "Number of measures",
                      color = "Measure"
                    )
    )




    p %>% onRender(js)

  })


  output$legendItem <- renderText({
    d <- input$trace
    if (is.null(d)) paste("Click one of the choices found at the legend of the above figure to select a category" ) else paste ("You have selected:", d)
  })

  output$restrictions <- renderPlotly({

    d <- input$trace
    if (is.null(d)) return(NULL)


    cases_covid %>%
      filter(category == d,
             country == input$meas_country) %>%
      plot_ly(x = ~date_implemented,
              y = ~measure,
              color = ~log_type,
              type = 'scatter', mode = 'markers', colors = c("darkred", "darkblue"),
              size = 1, symbol = ~log_type, symbols = c("circle-x", "diamond-wide"),
              hoverinfo = 'text',
              text = ~paste('</br> Comment: ', comments)) %>%
      layout(paper_bgcolor='#bad2e3',
             plot_bgcolor="#bad2e3",
             title = "Occurence of Measures by Category",
             xaxis = list(title = "Implementation Date"),
             yaxis = list(title = ""),
             titlefont = list(
               size = 30,
               color = 'navy'),
             font = list(
               size = 20),
             margin = 10
      )
  })








  output$google <- renderPlot({
    covid_all %>%
      select(c("country","date"), contains("gcmr")) %>%
      filter(country == input$google_country) %>%
      pivot_longer(cols = contains("gcmr"), names_to = "index", values_to = "score") %>%
      mutate(index = str_replace(string = index, pattern = c("gcmr"), replacement = "")) %>%
      mutate(index = str_replace(string = index, pattern = c("_"), replacement = " ")) %>%
      mutate(index = str_replace(string = index, pattern = c("_"), replacement = "-")) %>%
      mutate(index = str_to_title(index)) %>%
      ggplot(aes(date, score, color = index)) +
      geom_line(lwd = 1.3) +
      geom_smooth(color = "red", lty = "dashed", lwd = 1.2) +
      theme_classic() +
      theme(
        panel.background = element_rect(fill = "#bad2e3"),
        plot.background = element_rect(fill = "#bad2e3"),
        plot.title.position = "plot",
        plot.title = element_text(size = 26, color = "navy",face = "bold", margin = unit(c(0, 0, 0.6, 0), "cm")),
        legend.background = element_rect(fill = "#bad2e3"),
        strip.text = element_text(size = 20),
        axis.text = element_text(size = 15),
        axis.title = element_text( size = 16, face = "bold" ),
        panel.spacing = unit(2, "lines"),
        plot.caption = element_text(size = 18, color = "#1f78b4"),
        plot.subtitle = element_text(size = 23, color = "#1f78b4", face = "italic", margin = unit(c(0, 0, 1, 0), "cm") ),
        axis.title.x   = element_blank(),
        axis.title.y = element_text(size = 20, color = "black"),
        axis.line.x = element_line(linetype = "dashed", size = 2),
        axis.line.y = element_line(linetype = "dashed", size = 2),
        axis.text.x = element_text(size = 19, color = "black"),
        axis.text.y = element_text(size = 19, color = "black"),
        strip.text.x = element_text(
          size = 21, color = "navy", face = "bold.italic"),
        strip.background = element_rect(
          color="grey91", fill="#9fb6cd", size=1.5, linetype="solid"),
        legend.position = "bottom",
        legend.title = element_blank(),
        legend.text =  element_text(size = 21)
      ) +
      guides(colour = guide_legend(override.aes = list(size=4))) +
      scale_color_colorblind(name = "Index",  labels = c("Grocery-Pharmacy", "Parks", "Residential", "Retail-Recreation", "Transit-Stations", "Workplaces")) +
      scale_x_date(labels = date_format("%B"), breaks='2 month') +
      labs(
        title = "Google Analytics",
        subtitle = "The graph shows movement trends over time by geography, across different categories of places.",
        caption = "Data from Google's Community Mobile Reports",
        x = "Date",
        y = "Index",
        color = ""
      ) +
      facet_wrap(~index)
  })






  output$stats <- renderPlot({

    if (input$scale == "Logarithmic") {


      case <-   covid_all %>%
        filter(country == input$case_country) %>%
        select(date, deaths, confirmed, recovered,population, lockdown) %>%
        mutate(new_deaths = c(diff(c(deaths,0))),
               new_cases = c(diff(c(confirmed,0))),
               new_recovered = c(diff(c(recovered,0))),
               death_rate = new_deaths/(confirmed + recovered) * 100,
               infection_rate = new_cases/population * 100) %>%
        pivot_longer(cols = contains("new"), names_to = "index", values_to = "value") %>%
        ggplot(aes(date, value,  fill = index)) +
        geom_col() +
        theme(
          panel.background = element_rect(fill = "#bad2e3"),
          plot.background = element_rect(fill = "#bad2e3"),
          plot.title.position = "plot",
          plot.title = element_text(size = 22, color = "navy",face = "bold", margin = unit(c(0, 0, 0.6, 0), "cm")),
          legend.background = element_rect(fill = "#bad2e3"),
          strip.text = element_text(size = 20),
          axis.text = element_text(size = 15),
          axis.title = element_text( size = 16, face = "bold" ),
          panel.spacing = unit(2, "lines"),
          plot.caption = element_text(size = 12, color = "#1f78b4"),
          plot.subtitle = element_text(size = 23, color = "darkcyan", face = "italic"),
          axis.title.x   = element_text(size = 20, color = "black"),
          axis.title.y = element_text(size = 20, color = "black"),
          axis.text.x = element_text(size = 19, color = "black"),
          axis.text.y = element_text(size = 19, color = "black"),
          legend.position = "bottom",
          legend.text =  element_text(size = 13),
          axis.line.x = element_blank(),
          axis.line.y = element_blank()
        ) +
        scale_x_date(labels = date_format("%B"), breaks='2 month') +
        scale_y_log10() +
        scale_fill_colorblind("",  labels = c("New Cases", "New Deaths", "New Recovered")) +
        labs(
          title = "Daily Change in Cases by Category",
          caption = "Data might contain missing values for some countries",
          x = "Date",
          y = "Number(log10)",
          fill = ""
        )
    }

    else {

      case <-   covid_all %>%
        filter(country == input$case_country) %>%
        select(date, deaths, confirmed, recovered,population, lockdown) %>%
        mutate(new_deaths = c(diff(c(deaths,0))),
               new_cases = c(diff(c(confirmed,0))),
               new_recovered = c(diff(c(recovered,0))),
               death_rate = new_deaths/(confirmed + recovered) * 100,
               infection_rate = new_cases/population * 100) %>%
        pivot_longer(cols = contains("new"), names_to = "index", values_to = "value") %>%
        ggplot(aes(date, value,  fill = index)) +
        geom_col() +
        theme(
          panel.background = element_rect(fill = "#bad2e3"),
          plot.background = element_rect(fill = "#bad2e3"),
          plot.title.position = "plot",
          plot.title = element_text(size = 22, color = "navy",face = "bold", margin = unit(c(0, 0, 0.6, 0), "cm")),
          legend.background = element_rect(fill = "#bad2e3"),
          strip.text = element_text(size = 20),
          axis.text = element_text(size = 15),
          axis.title = element_text( size = 16, face = "bold" ),
          panel.spacing = unit(2, "lines"),
          plot.caption = element_text(size = 12, color = "#1f78b4"),
          plot.subtitle = element_text(size = 23, color = "darkcyan", face = "italic"),
          axis.title.x   = element_text(size = 20, color = "black"),
          axis.title.y = element_text(size = 20, color = "black"),
          axis.text.x = element_text(size = 19, color = "black"),
          axis.text.y = element_text(size = 19, color = "black"),
          legend.position = "bottom",
          legend.text =  element_text(size = 13),
          axis.line.x = element_blank(),
          axis.line.y = element_blank()
        ) +
        scale_x_date(labels = date_format("%B"), breaks='2 month') +
        scale_fill_colorblind("",  labels = c("New Cases", "New Deaths", "New Recovered")) +
        labs(
          title = "Daily Change in Cases by Category",
          caption = "Data might contain missing values for some countries",
          x = "Cases",
          y = "",
          fill = ""
        )


    }






    # I will use this to create a death_rate line graph
    death <-   covid_all %>%
      filter(country == input$case_country) %>%
      select(date, deaths, confirmed, recovered,population, lockdown) %>%
      mutate(new_deaths = c(diff(c(deaths,0))),
             new_cases = c(diff(c(confirmed,0))),
             new_recovered = c(diff(c(recovered,0))),
             death_rate = new_deaths/(confirmed + recovered)*100,
             infection_rate = new_cases/population*100) %>%
      #pivot_longer(cols = contains("rate"), names_to = "index", values_to = "rate") %>%
      ggplot(aes(date, death_rate)) +
      geom_line(color = "#1f78b4") +
      theme(
        panel.background = element_rect(fill = "#bad2e3"),
        plot.background = element_rect(fill = "#bad2e3"),
        plot.title.position = "plot",
        plot.title = element_text(size = 22, color = "navy",face = "bold", margin = unit(c(0, 0, 0.6, 0), "cm")),
        legend.background = element_rect(fill = "#9fb6cd"),
        strip.text = element_text(size = 20),
        axis.text = element_text(size = 15),
        axis.title = element_text( size = 16, face = "bold" ),
        panel.spacing = unit(2, "lines"),
        plot.caption = element_text(size = 12, color = "#1f78b4"),
        plot.subtitle = element_text(size = 23, color = "darkcyan", face = "italic"),
        axis.title.x   = element_text(size = 20, color = "black"),
        axis.title.y = element_text(size = 20, color = "black"),
        axis.text.x = element_text(size = 19, color = "black"),
        axis.text.y = element_text(size = 19, color = "black"),
        legend.position = "bottom",
        legend.title = element_text(size = 17, color = "navy", face = "bold"),
        legend.text =  element_text(size = 13),
        axis.line.x = element_blank(),
        axis.line.y = element_blank()
      ) +
      scale_x_date(labels = date_format("%B"), breaks='2 month') +
      labs(
        title = "Death Rate",
        x = "",
        y = "Death Rate(in %)"
      )



    case + death
  })


  # tweet_table  <- eventReactive(input$go, {
  #
  #   query <- searchTwitter(paste(input$hastag,"", "exclude:retweets"), n = 100)
  #
  #   tweets <- tibble(map_df(query, as.data.frame)) %>%
  #     select(text, favoriteCount, retweetCount )
  #
  #   tweets
  #
  #   })
  #
  # tweet_graph  <- eventReactive(input$go, {
  #   tweets2 <- tibble(map_df(query, as.data.frame)) %>%
  #     select(text)
  #
  #   tweets2
  # })


  output$tweet_sent <- renderPlot({

    query <- searchTwitter(paste(input$hastag,"", "exclude:retweets"), n = 100)

    tweets <- tibble(map_df(query, as.data.frame)) %>%
      select(text)


    tokens <- tweets %>%
      unnest_tokens(
        output = word,
        input = text,
        token = "words" # default option
      )

    stopwords_smart <- get_stopwords(source = "smart")


    sentiments_bing <- get_sentiments("nrc")


    tokens %>%
      anti_join(stopwords_smart) %>%
      inner_join(sentiments_bing) %>%
      count(sentiment, word, sort = TRUE) %>%
      arrange(desc(n)) %>%
      group_by(sentiment) %>%
      top_n(10) %>%
      ungroup() %>%
      ggplot(aes(fct_reorder(word, n), n, fill = sentiment)) + geom_col() +
      coord_flip() +
      facet_wrap(~sentiment, scales = "free") + theme_minimal() +
      labs(
        title = "Sentiments in user reviews",
        x = "" ) +
      theme(
        panel.background = element_rect(fill = "#bad2e3"),
        plot.background = element_rect(fill = "#bad2e3"),
        plot.title.position = "plot",
        plot.title = element_text(size = 26, color = "navy",face = "bold", margin = unit(c(0, 0, 0.6, 0), "cm")),
        legend.background = element_rect(fill = "#bad2e3"),
        strip.text = element_text(size = 20),
        axis.text = element_text(size = 11),
        axis.title = element_text( size = 16, face = "bold" ),
        panel.spacing = unit(2, "lines"),
        plot.caption = element_text(size = 18, color = "#1f78b4"),
        plot.subtitle = element_text(size = 23, color = "#1f78b4", face = "italic", margin = unit(c(0, 0, 1, 0), "cm") ),
        axis.title.x   = element_blank(),
        axis.title.y = element_text(size = 20, color = "black"),
        axis.line.x = element_line(linetype = "dashed", size = 2),
        axis.line.y = element_line(linetype = "dashed", size = 2),
        axis.text.x = element_text(size = 13, color = "black"),
        axis.text.y = element_text(size = 9, color = "black"),
        strip.text.x = element_text(
          size = 15, color = "navy", face = "bold.italic"),
        strip.background = element_rect(
          color="grey91", fill="#9fb6cd", size=1.5, linetype="solid"),
        legend.position = "none",
      )
  })

  output$emotions <- renderPlot({


    query <- searchTwitter(paste(input$hastag,"", "exclude:retweets"), n = 100)

    tweets <- tibble(map_df(query, as.data.frame)) %>%
      select(text)


    tokens <- tweets %>%
      unnest_tokens(
        output = word,
        input = text,
        token = "words" # default option
      )

    stopwords_smart <- get_stopwords(source = "smart")


    sentiments_bing <- get_sentiments("nrc")

    sentiments <- tokens %>%
      anti_join(stopwords_smart) %>%
      inner_join(sentiments_bing) %>%
      count(sentiment, word, sort = TRUE) %>%
      arrange(desc(n)) %>%
      group_by(sentiment) %>%
      top_n(10) %>%
      ungroup()

    emotions <- sentiments %>%
      group_by(sentiment) %>%
      summarise(appearence = sum(n)) %>%
      ungroup() %>%
      mutate(emotion_index = appearence/sum(appearence)) %>%
      arrange(desc(emotion_index))


    emotions  %>%
      ggplot(aes(sentiment, appearence, fill = sentiment, label = paste(round(emotion_index,2),"%"))) +
      geom_col() +
      geom_label(size =8, color = "black", label.size = 0.5) +
      scale_fill_discrete(type = c("orange", "purple", "darkred", "darkgreen",
                                   "grey", "pink", "blue"))  +
      labs(
        title = "Emotions observed in user reviews",
        y = "Number of appearences"
      ) +
      theme(
        panel.background = element_rect(fill = "#bad2e3"),
        plot.background = element_rect(fill = "#bad2e3"),
        plot.title.position = "plot",
        plot.title = element_text(size = 26, color = "navy",face = "bold", margin = unit(c(0, 0, 0.6, 0), "cm")),
        legend.background = element_rect(fill = "#bad2e3"),
        strip.text = element_text(size = 20),
        axis.text = element_text(size = 15),
        axis.title = element_text( size = 16, face = "bold" ),
        panel.spacing = unit(2, "lines"),
        plot.caption = element_text(size = 18, color = "#1f78b4"),
        plot.subtitle = element_text(size = 23, color = "#1f78b4", face = "italic", margin = unit(c(0, 0, 1, 0), "cm") ),
        axis.title.x   = element_blank(),
        axis.title.y = element_text(size = 20, color = "black"),
        axis.line.x = element_line(linetype = "dashed", size = 2),
        axis.line.y = element_line(linetype = "dashed", size = 2),
        axis.text.x = element_text(size = 19, color = "black"),
        axis.text.y = element_text(size = 19, color = "black"),
        strip.text.x = element_text(
          size = 21, color = "navy", face = "bold.italic"),
        strip.background = element_rect(
          color="grey91", fill="#9fb6cd", size=1.5, linetype="solid"),
        legend.position = "none"
      )


  })


  output$group_emotions <- renderPlot({


    query <- searchTwitter(paste(input$hastag,"", "exclude:retweets"), n = 100)

    tweets <- tibble(map_df(query, as.data.frame)) %>%
      select(text)


    tokens <- tweets %>%
      unnest_tokens(
        output = word,
        input = text,
        token = "words" # default option
      )

    stopwords_smart <- get_stopwords(source = "smart")


    sentiments_bing <- get_sentiments("nrc")

    sentiments <- tokens %>%
      anti_join(stopwords_smart) %>%
      inner_join(sentiments_bing) %>%
      count(sentiment, word, sort = TRUE) %>%
      arrange(desc(n)) %>%
      group_by(sentiment) %>%
      top_n(10) %>%
      ungroup()

    emotions <- sentiments %>%
      group_by(sentiment) %>%
      summarise(appearence = sum(n)) %>%
      ungroup() %>%
      mutate(emotion_index = appearence/sum(appearence)) %>%
      arrange(desc(emotion_index))

    encouraging <- emotions %>%
      filter(sentiment %in% c("positive", "trust", "joy")) %>%
      summarise(emotion = sum(emotion_index)) %>%
      pull(emotion)

    anxious <- emotions %>%
      filter(sentiment %in% c("surprise", "aticipation", "fear")) %>%
      summarise(emotion = sum(emotion_index)) %>%
      pull(emotion)

    unpleasant <- emotions %>%
      filter(sentiment %in% c("anger", "disgust", "sadness", "negative")) %>%
      summarise(emotion = sum(emotion_index)) %>%
      pull(emotion)


    emotions_group <- tibble(encouraging,
                             anxious,
                             unpleasant) %>%
      pivot_longer(cols = 1:3, names_to = "emotion", values_to = "value")

    emotions_group  %>%
      ggplot(aes(emotion, value, fill = emotion, label = paste(round(value,2),"%"))) +
      geom_col() +
      geom_label(size =12, color = "black", label.size = 0.5) +
      scale_fill_discrete(type = c("orange", "darkgreen", "darkred")) +
      labs(
        title = "Grouped Emotions observed in user reviews",
        y = "Frequence of appearence"
      ) +
      theme(
        panel.background = element_rect(fill = "#bad2e3"),
        plot.background = element_rect(fill = "#bad2e3"),
        plot.title.position = "plot",
        text = element_text(size = 16),
      ) +
      theme(
        panel.background = element_rect(fill = "#bad2e3"),
        plot.background = element_rect(fill = "#bad2e3"),
        plot.title.position = "plot",
        plot.title = element_text(size = 26, color = "navy",face = "bold", margin = unit(c(0, 0, 0.6, 0), "cm")),
        legend.background = element_rect(fill = "#bad2e3"),
        strip.text = element_text(size = 20),
        axis.text = element_text(size = 15),
        axis.title = element_text( size = 16, face = "bold" ),
        panel.spacing = unit(2, "lines"),
        plot.caption = element_text(size = 18, color = "#1f78b4"),
        plot.subtitle = element_text(size = 23, color = "#1f78b4", face = "italic", margin = unit(c(0, 0, 1, 0), "cm") ),
        axis.title.x   = element_blank(),
        axis.title.y = element_text(size = 20, color = "black"),
        axis.line.x = element_line(linetype = "dashed", size = 2),
        axis.line.y = element_line(linetype = "dashed", size = 2),
        axis.text.x = element_text(size = 19, color = "black"),
        axis.text.y = element_text(size = 19, color = "black"),
        strip.text.x = element_text(
          size = 21, color = "navy", face = "bold.italic"),
        strip.background = element_rect(
          color="grey91", fill="#9fb6cd", size=1.5, linetype="solid"),
        legend.position = "none"
      )





  })

  output$tweets <- renderDT({


    query <- searchTwitter(paste(input$hastag,"", "exclude:retweets"), n = 100)

    tweets <- tibble(map_df(query, as.data.frame))

    tweets %>%
      select(text, favoriteCount, retweetCount )




  })

  output$country_stats <- DT::renderDataTable(
    datatable(
      country_stats %>%
        mutate(death_rate = death_rate/100,
               infected_rate = infected_rate/100) %>%
        dplyr::arrange(desc(total_deaths)),
      rownames = FALSE,
      colnames = c("Country","Total Deaths", "Total Infected", "Total Recovered", "Total Active", "Death Rate", "Infected Rate")
    ) %>%
      formatStyle(
        columns = names(country_stats),
        backgroundColor = "#bad2e3",
        color = "#4c4c4c",
        fontWeight = "bold",
        `font-size` = '18px'

      ) %>%
      formatCurrency(columns = c("total_deaths", "total_recovered", "total_active", "total_infected"),  currency = "", interval = 3, mark = ",") %>%
      formatPercentage(c("death_rate", "infected_rate"), 2)

  )


  output$global <- DT::renderDataTable(
    datatable(
      global_stats,
      options = list(searching = FALSE, bSort=FALSE, lengthChange = FALSE, bPaginate = FALSE, bInfo = FALSE),
      rownames = FALSE,
      colnames = c("Total Deaths", "Total Infected", "Total Recovered", "Total Active", "Death Rate", "Infected Rate")
    ) %>%
      formatStyle(
        columns = names(global_stats),
        backgroundColor = "#bad2e3",
        color = "#4c4c4c",
        fontWeight = "bold",
        `font-size` = '18px'
      ) %>%
      formatPercentage(c("death_rate", "infected_rate"), 3) %>%
      formatCurrency(columns = c("total_deaths", "total_recovered", "total_active", "total_infected"),  currency = "", interval = 3, mark = ",")
  )


  total_cases <- corona_map$total_cases[match(mapCountry$names, corona_map$country)]

  pal_fun <- colorQuantile("YlOrRd", NULL, n = 7)

  breaks_qt <- classIntervals(corona_map$total_cases, n = 8, style = "fixed",
                              fixedBreaks = c(min(corona_map$total_cases), 10^4,  10^5, 5 * 10 ^ 5, 10^6, 2 * 10^6, 4 * 10^6, max(corona_map$total_cases))
  )

  values <- c(9, 10^4,  10^5, 5 * 10 ^ 5, 10^6, 2 * 10^6, 4 * 10^6, max(corona_map$total_cases))

  interval <- values[values >9 & values < 7000000]



  output$map <- renderLeaflet(


    leaflet(mapCountry) %>% # create a blank canvas
      addProviderTiles("NASAGIBS.ViirsEarthAtNight2012") %>%
      addPolygons( # draw polygons on top of the base map (tile)
        stroke = FALSE,
        smoothFactor = 0.2,
        fillOpacity = 1,
        color = ~pal_fun(total_cases) # use the rate of each state to find the correct color
      ) %>%
      addCircles(lng = corona_map$lng, lat = corona_map$lat,
                 radius = (corona_map$total_cases)/10,
                 layerId = corona_map$country,
                 weight = log(corona_map$total_cases), stroke = T,  fillColor = "white", color = "black", fillOpacity = 3,
                 label = paste("Total confirmed cases to this date in", corona_map$country, ":", corona_map$total_cases),
                 labelOptions = labelOptions(noHide = F, textsize = "15px"),
                 popupOptions = corona_map$country,) %>%
      addLegend("bottomleft",
                colors = brewer.pal(8, "YlOrRd"),
                labels =c(paste("Min cases =", values[1]), paste("up to", format(interval,scientific = T)), paste("Max cases =", values[8])),
                values = corona_map$total_cases,
                title = "Confirmed Cases",
                opacity = 0.5) %>%
      fitBounds(lng1 = min(corona_map$lng),
                lat1 = min(corona_map$lat),
                lng2 = max(corona_map$lng),
                lat2 = max(corona_map$lat))


  )

  session$onSessionEnded(stopApp)




  output$gif <- renderImage({

    list(src = "www/instructions.gif",
         contentType = 'image/gif',
         width = 700,
         height = 500,
         alt = "This is alternate text")
  }, deleteFile = FALSE)

}






