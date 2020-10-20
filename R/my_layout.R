#' Custom Layout for Shiny's App Ui
#'
#' Adds a custom sidebarLayout consisting of a sidebar panel
#' and a main panel to the Ui when called.
#'
#'
#' The purpose of this function is to automatically add a custom layout used in all
#' tabs of the app to remove code duplication and avoid errors.
#'
#'@author Panagiotis Stylianos
#'
#'
#' @param id The input id of the select Input that will get passed on to the apps'
#' server.
#' @param x A column from a dataframe or tibble that contains country names.
#'
#' @param output The servers output that you want to get displayed
#'
#' @param input_option Opional argument to add another select input option for the user.
#' Defaults to NULL.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' my_layout(id = "country_cases",
#' x = coronavirus$country,
#' output = plotOutput(),
#' input_option = NULL
#' )
#' }
#'
#'
my_layout <-  function(id, x, output, input_option = NULL)
{
  shiny::sidebarLayout(
    shiny::sidebarPanel(width = 2,
                 countryInput(id= id , x = x),
                 input_option
    ),
    shiny::mainPanel(
      spinner(output = output),
      width = 10
    )
  )
}

