#' Custom Country Select Input
#'
#' Creates a Shiny Select Input with custom label style to select a country from
#' a columns dataset.
#'
#' The purpose of this function is to provide a quick reference for a common
#' Shiny Shiny Select Input function that appears multiple times in the app's ui.
#'
#' @author Panagiotis Stylianos
#'
#' @param id The input id of the select Input that will get passed on to the apps'
#' server.
#' @param x A column from a dataframe or tibble that contains country names.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' countryInput(id = "country_cases", x = coronavirus$country)
#' }
#'
#'
#'
#'
#'
countryInput <- function(id, x) {

  shiny::selectInput(inputId = id,
              label = htmltools::h4("Select Country", style = "color:navy"),
              choices = sort(unique(x)),
              selected = "Australia")
}
