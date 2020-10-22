#' Adds Specific Number of Break Lines in Shiny Ui
#'
#' The function takes as an input a number and adds that many break lines
#' in the Shiny ui.
#'
#' @param  n A non-negative nmeric value
#'
#' @source ![]("https://stackoverflow.com/questions/46559251/how-to-add-multiple-line-breaks-conveniently-in-shiny")
#'
#' @export
#'
#'
#' @import htmltools
#'
#' @examples
#' \dontrun{
#' mainPanel(
#' plotOutput("plot1"),
#' n_br(4),
#' plotOutput("plot3")
#' )
#' }
#'
n_br <- function(n) {
  htmltools::HTML(strrep(htmltools::br(), n))
}
