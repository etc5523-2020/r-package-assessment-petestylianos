#' spinner
#'
#'
#'
#'
#' @export

spinner <- function(output) {

  shinycssloaders::withSpinner(
    output,
    color = "cyan",
    type = 2,
    color.background = "#9fb6cd",
    size = 1)
}
