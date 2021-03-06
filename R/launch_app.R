#' Launches the covidExplorer Shiny App
#'
#' This function deploys a shiny app that allows users to interactively
#' browse data regarding the spread of COVID-19 in various countries.
#'
#' @author Panagiotis Stylianos
#'
#' @param ui a .R script that contains the user interface of the shiny app
#' @param server a .R script that contains the app's server
#'
#' @import shiny
#' @export
#'
launch_app <- function(ui, server) {


  shiny::runApp(appDir = system.file("app", package = "covidExplorer"))
}
