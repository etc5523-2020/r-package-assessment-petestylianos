source("data.R")
ui <- fluidPage(
  titlePanel(windowTitle = "Covid Analytics",
             title = fluidRow(
               HTML('<span style="color:black;
                 font-size: 40px; font-weight:bold;r">COVID Analytics<span>
                 '),
               align = "center")
  ),

  theme = shinythemes::shinytheme(theme = "paper"),
  shinyWidgets::setBackgroundColor(
    color = c("grey", "white", "grey"),
    gradient = "radial",
    direction = c("top", "left")
  ),

  navbarPage(footer =  HTML('<span style="color:black;font-size: 20px; font-weight:bold;"><a href="https://cwd.numbat.space/" target="_blank">ETC5523: Communicating with Data</a><span>'),
             tags$style(HTML("
        .navbar { background-color: #bad2e3;}
        .navbar-default .navbar-nav > li > a {color:navy;}
        table.dataTable  {color:black; font-size:18px; background-color:#ffecef}
                  ")),
        tabPanel("Cases by Country", icon = icon("globe"),
                 HTML('<span style="color:navy;font-size: 25px; font-weight:bold;">
                                Choropleth map colored by number of total cases.<br><span>'),
                 tags$div(
                   "Hover over points to see the popup with the number of total cases.", style = "color:black;font-size: 20px;font-weight:normal;"

                 ),
                 withSpinner(leafletOutput("map", height = "800px"), color = "cyan", type = 2,color.background = "#9fb6cd", size = 1),
                 br(),
                 HTML('<span style="color:navy;font-size: 25px; font-weight:bold;">
                              Worldwide Statistics.<br><span>'),
                 br(),
                 DT::dataTableOutput("global"),
                 br(),
                 br(),
                 HTML('<span style="color:navy;font-size: 25px; font-weight:bold;">
                                Aggregated data per country.<br><span>'),
                 HTML('<span style="color:black;font-size: 20px; font-weight:normal;">
                           Death Rate was calculated as the percentage of total deaths among total cases. <br>
                           Infected Rate was calculated as the percentage of infected citizens divided by the population of the country.<br><span>'),

                 br(),
                 withSpinner(DT::dataTableOutput("country_stats"),color = "cyan", type = 2,color.background = "#9fb6cd", size = 1),
                 br(),
                 HTML('<span style="color:black;font-size: 20px; font-weight:normal;">
                           The first figures shows the daily change in cases in logarithmic or identity scale based on the user input. <br>
                           The second figure illustrates how the death rate of the virus progresses by country.<br>
                           Use the select input to change the country and the slider to select if you want to see the first figure in logarithmic or identity scale.
                           If an error appears it means that there are not enough data for this country. I did not remove these countries in case a future update of the package includes them.  <span>'),
                 br(),
                 br(),
                 sidebarLayout(position = "left",
                               sidebarPanel(width = 2,

                                            selectInput("case_country", h4("Select Country", style = "color:navy"), selected = "Australia",width = "200px", choices = sort(unique(covid_all$country))),
                                            sliderTextInput("scale", label = h4("Select Scale", style = "color:navy"), choices = c("Logarithmic", "Identity"), selected = "Identity",width = "200px")



                               ),
                               mainPanel(plotOutput("stats",  height = "600px"), width = 10
                               )
                 )),

        tabPanel("Apple Analytics", icon = icon("apple"),
                 br(),
                 tags$div(
                   "The below figure illustrates changes in requests for directions in Apple Maps for driving, walking or transit in big cities.", br(),
                   "Select your country of choice to reveal how COVID-19 impacted citizens preferable method of commuting.", br(),
                   "If an error appears it means that there are not enough data for this country. I haven't removed these countries in case a future update of the report includes them.", br(),
                   "The base of the index is a normal pre pandemic period.",  style = "color:black;font-size: 20px;font-weight:normal;"

                 ),
                 br(),
                 sidebarLayout(
                   sidebarPanel(width = 2,
                                selectInput("country", label = h4("Select country", style = "color:navy" ), choices = sort(unique(covid_city$country)), selected = "Australia")
                   ),

                   mainPanel(
                     withSpinner(plotOutput("city", height = "750px"), color = "cyan", type = 2,color.background = "#9fb6cd", size = 1), width = 10)
                 )
        ),

        tabPanel("Google Analytics", icon = icon("google") ,
                 br(),
                 tags$div(
                   "This figure shows the change in visits of common places by country. The base of the index is a normal pre pandemic period.", br(),
                   "If an error appears it means that there are not enough data for this country. I haven't removed these countries in case a future update of the report includes them.", br(),
                   "Based on the data we can explore how citizens are reacting to measures and if they are being implemented correctly.", style = "color:black;font-size: 20px;font-weight:normal;"

                 ),
                 br(),
                 sidebarLayout(
                   sidebarPanel(width = 2,
                                selectInput("google_country", label = h4("Select country", style = "color:navy" ), choices = sort(unique(covid_all$country)), selected = "Australia")
                   ),

                   mainPanel(
                     withSpinner(plotOutput("google",height = "750px"),color = "cyan", type = 2,color.background = "#9fb6cd", size = 1), width = 10)
                 )

        ),
        tabPanel("Measures", icon = icon("book"),
                 tags$blockquote(
                   tags$div(
                     tags$p("This tab provides detailed information about the number of measures across different categories that countries took to prevent the spread of COVID19.", style = "color:black"),
                     tags$p("Use the dropdown arrow found in the sidebar to update the country option. For the second figure to appear click on one of the categories at the legend of the first figure.", style = "color:black"),
                     tags$p("The figures provide valuable insight to which countries have been more active in dealing with the pandemic. Also, using the data from the Cases By Country
                                 tab explore if countries that took more measures reprted a lower number of cases. ", style = "color:black"),
                     tags$p("The data that was used to produce these figures can be found in the", tags$a(href="https://joachim-gassen.github.io/covid_all19/", "covid_all19"), "package.", "To find out more visit", tags$a(href="https://www.acaps.org/covid19-government-measures-dataset", "acaps"), ".", style = "color:black"),
                     style = "font-size: 20px;font-weight:normal;"

                   )
                 ),
                 hr(),
                 br(),

                 tags$div(
                   tags$p("This figure tracks the number of measures taken by country in five different categories over time.", br(),
                          "When the slope of the lines becomes negative it indicates that a particular measure of the category was uplifted.",br(),
                          "Also a slow incrase in the number of measures after a long period of uplifts is a strong indicator that probably more measures will follow.",br(),
                          "Comparing this graphs with the total cases per country can help us understand which particualr measures are more effective to confine the contamination.",br(),
                          "Use the sidebar to find out which countries have been more lenient or strict regarding their policies and in which measure category are focusing their efforts.",
                          style = "color:black;font-size: 20px;font-weight:normal;")
                 ),
                 br(),

                 sidebarLayout(
                   sidebarPanel(width = 2,
                                selectInput("meas_country", label = h4("Select Country",style = "color:navy"), choices = unique(covid_all$country), selected = "Australia"),
                                br(),
                                br(),
                   ),
                   mainPanel(
                     withSpinner(plotlyOutput("measure", height = "600px"), color = "cyan", type = 2,color.background = "#9fb6cd", size = 1), width = 10)),
                 hr(),
                 br(),
                 br(),

                 tags$div(
                   "The below figure visualizes the occurence of measures by category.", br(),
                   "Hover over the symbols to gain insight about the measure.", style = "color:black;font-size: 20px;font-weight:normal;"

                 ),
                 br(),
                 span(textOutput("legendItem"), style = "color:navy;font-size: 25px;font-weight:bold;"),
                 br(),
                 tags$div(
                   "Follow the Instructions on this gif to activate the second figure", style = "color:purple;font-size: 23px;font-weight:bold;"
                 ),
                 imageOutput("gif", width = "100px", height = "100px"),

                 fluidPage(
                   fluidRow(
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     withSpinner(plotlyOutput("restrictions",height = "800px"),color = "cyan", type = 2,color.background = "#9fb6cd", size = 1)
                   )
                 )
        ),

        tabPanel("Tweets",  icon = icon("twitter"),
                 HTML('<img src="https://cdn.pixabay.com/photo/2014/12/16/12/59/login-570317_1280.jpg" alt="Under construction" style="width:1000px;height:400px;">
                 '),
                 tags$div(
                   'This tab allows you to scrape data from', tags$a(href="https://twitter.com/Petestyl","Twitter."),
                   "However if you want to run this app locally on your computer some work from your part is required.
                    Otherwise, if you are running the app from", tags$a( href="https://www.shinyapps.io", "shinyapps.io"),
                   "there is no need to perform any tasks. However, there might be a limit on the number of Tweets you can scrape.", br(),
                   "To find a comprehensive list of the tasks you need to perform please look at the: Authenticate Twitter Account section on the navigation bar.",
                   style = "color:black;font-size: 20px;font-weight:normal;"),
                 br(),
                 tags$div(
                   "Use the select input option to choose a hastag and look at the 100 most recent Tweets. Make sure to include the # ", br(),
                   "The following graph summarizes a sentiment analysis of the latest Tweets, classifying the words used in them
                   based on the emotion they are conveying.", br(), "Approximate running time ~ 30s", style = "color:black;font-size: 20px;font-weight:normal;"

                 ),
                 sidebarLayout(
                   sidebarPanel(width = 2,
                                textInput("hastag", label = "Select hastag", value  = "#coronavirus"),
                                actionButton("go", label = h6("Search Twitter", style = "color:navy"))
                   ),
                   mainPanel(
                     withSpinner(plotOutput("tweet_sent", height = "900px", width = "1300px"),color = "cyan", type = 2,color.background = "#9fb6cd", size = 1),
                     br(),
                     tags$div("In this figure you can find a summary on which emotios appeared more frequently on users Tweets.", style = "color:black;font-size: 20px;font-weight:normal;"
                     ),
                     withSpinner(plotOutput("emotions", height = "900px", width = "1300px"), color = "cyan", type = 2,color.background = "#9fb6cd", size = 1),
                     br(),
                     tags$div(
                       "Finally, we can group the above emotions in three distinct groups and measure their relative frequency.",style = "color:black;font-size: 20px;font-weight:normal;"
                     ),
                     withSpinner(plotOutput("group_emotions", height = "900px", width = "1300px"),color = "cyan", type = 2,color.background = "#9fb6cd", size = 1),
                     br(),
                     tags$div(
                       "Tweets Table", style = "color:navy;font-size: 24px;font-weight:bold;"
                     ),
                     withSpinner(DT::DTOutput("tweets"),color = "cyan", type = 2,color.background = "#9fb6cd", size = 1),
                   )
                 )
        ),

        tabPanel("About", icon = icon("info"),
                 fluidPage(tags$image(src = "https://cdn.pixabay.com/photo/2020/02/24/18/56/mask-4877097__340.png"),
                           fluidRow(   tags$style(HTML("
a:link {
  color: red;
  background-color: transparent;
  text-decoration: none;
}

a:visited {
  color: brown;
  background-color: transparent;
  text-decoration: none;
}

a:hover {
  color: green;
  background-color: transparent;
  text-decoration: wavy;
}

                  ")) ,
HTML('<span style="color:black;font-size: 20px; font-weight:normal;">
                                 The purpose of this app is to help users compare data related to COVID19 among countries.<br>
                                 It was created as part of an assignment for unit ETC5523: Communicating with Data; a core unit in the master of <a href="https://www.monash.edu/business/master-of-business-analytics" target="_blank">Business Analytics</a> at <a href="https://www.monash.edu" target="_blank"> Monash University</a>. <br>
                                 The purpose of the assignment was to develop a Shiny app, as so all data and conclusions found in the app should be treated with cautious.<br>
                                <br> Use the app by clicking on the different panels of the nagivation bar found at the top. The contents of the panels are the following:<br>
                              <br>  A. Cases by Country: Includes a Choropleth map in which countries are shaded in proportion to the total cases of COVID-19 in that country.
                              Also, the panel cosists of two Tables that provide statistics related to COVID-19 on both global and country level. The former table is interactive, allowing users to search for their country of choice.
                              Finally, in the bottom of the panel you can find two interactive figures that visualize the growrh in cases of COVID-19 and the death rate of the virus over time by country. <br>
                              <br>  B. Apple Analytics: Select a country from the select input option and explore data from <a href ="https://covid19.apple.com/mobility" target="_blank"">Apple Mobility Trend Reports</a> for various cities in the world to reveal interesting citizen movement patterns for driving, walking and transit. <br>
                              <br>  C. Google Analytics: Select a country from the select input option and explore data from <a href ="https://www.google.com/covid19/mobility/" target="_blank">Google Mobility Trend Reports</a> for various countries to reveal changes in visits to places compared to a baseline period before the pandemic.<br>
                              <br>  D. Measures: Two interactive figures can be found in this tab. Both of them track measures taken by goverments to prevent the spread of COVID-19.
                              The first figure tracks the number of measures authorities have taken by country across five different categories over time. The second figure provides extensive details about the measures and their implementation.
                              Note that in order to access the second figure you need to click on the legend of the first one in order to select the catgory of your interest.<br>
                              <br>  E. Tweets: This tab is a working project so it is not finaliszed yet. However, you can still select a hastag and search Twitter for the latest 100 tweets. Also, plots illustating a sentiment analysis are included. <br>
                              <br>  F. About: Current tab, with instruction on how to run the app and details of the creator.<br>
                              <br>  G. Authenticate Twitter Account: Instructions about how to set up a Twitter account and get  access to your personal and private key. <br>
                                  <br> Data used in this app come from the following R packages:<br>
                                  1. <a href="https://cran.r-project.org/web/packages/coronavirus/index.html" target="_blank">Coronavirus</a><br>
                                  2. <a href="https://github.com/joachim-gassen/covid_all19" target="_blank">covid_all19</a><br>
                                  3. <a href="https://github.com/covid19datahub/COVID19" target="_blank">COVID-19</a><br>

                                 <br> Data sources related to useful pieces of code used in this app are listed below:<br>
                                  a. <a href="https://rstudio.github.io/DT/functions.html" target="_blank">Data Table helper functions</a><br>
                                  b. <a href="https://stackoverflow.com/questions/37573643/shiny-data-table-removing-column-header-and-sorting-altogether" target="_blank">Customizing Datatable(remove search option)</a><br>
                                  c. <a href="https://doyouevendata.github.io/Beautifying-plotly-graphs-in-R/" target="_blank">Beautifying plotly graphs in R.</a><br>
                                  d. <a href="https://shiny.rstudio.com/articles/tag-glossary.html"target="_blank">Shiny HTML Tags Glossary</a><br>
                                  e. <a href="https://stackoverflow.com/questions/52335837/event-when-clicking-a-name-in-the-legend-of-a-plotlys-graph-in-r-shiny" target="_blank">Trigger PLotly Event from Legend click</a><br>
                                 <br>
                                 The creator of this app is Panagiotis Stylianos. <br> Feel free to check my personal
                                <a href="https://panagiotis-stylianos.netlify.app/" target="_blank">website</a> and follow me on
                                <a href="https://twitter.com/Petestyl" target="_blank">Twitter.</a><span><br>
                                Code can be found in this GitHub
                                <a href="https://github.com/etc5523-2020/shiny-assessment-petestylianos" target="_blank">repository</a>. <span><br>
                                     '),
br()




                           )

                 )

        ),
tabPanel("Authenticate Twitter Account",  icon = icon("user-circle"),

         tags$div(
           "To be able to search Twitter on your RSudio you need to be able to run the following commands:", br(),

           br(), "api_key <- 'YOUR API KEY' " , br(),
           br(), "api_secret <- 'YOUR API SECRET'", br(),
           br(), "access_token <- 'YOUR ACCESS TOKEN'", br(),
           br(), "access_token_secret <- 'YOUR ACCESS TOKEN SECRET'", br(),
           br(), "setup_twitter_oauth(api_key,api_secret)",br(),
           br(), "To obtain this tokens and keys you need to log in to Twitter with your account, or create one if necessary.
          Then you need to setup an application: click on “My Applications” and then click on “Create new application”.", br(),
          "Almost thre, fill in the blank boxes and a new screen will appear with your private keys and token.", br(),
          "The final step is to install twitteR from GitHub using the devtools package and run the first 5 commands at the beginning of the section.",
          "For further instruction check:", tags$a(href = "http://thinktostart.com/twitter-authentification-with-r/", "Twitter Authentication with R"),
          ",", tags$a(href="https://www.rdocumentation.org/packages/vosonSML/versions/0.29.10/topics/Authenticate.twitter", "Authenticate.twitter"),
          "and", tags$a(href="https://www.r-bloggers.com/2016/01/twitter-authentication-with-r/", "Twitter Authentication with R"), ".",
          style = "color:navy;font-size: 24px;font-weight:normal;"
         )
)


  )


)
