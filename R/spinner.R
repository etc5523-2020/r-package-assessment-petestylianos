#' Custom Spinner
#'
#' Adds a spinner with custom layout to indicate that an output is loading
#'
#' @param output The servers output that you want to get displayed
#' @export
#'
#' @import shinycssloaders

spinner <- function(output) {

  shinycssloaders::withSpinner(
    output,
    color = "cyan",
    type = 2,
    color.background = "#9fb6cd",
    size = 1)
}
