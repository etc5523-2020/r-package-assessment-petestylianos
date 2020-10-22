#' Add Custom Theme Plot
#'
#' This function add a custom theme to the server's plots to maintain consistency among figures.
#'
#'
#' @author Panagiotis Stylianos
#'
#' @param p A ggplot2 object
#'
#' @export
#'
#'



my_theme <- function(p) {

  p +
    ggplot2::theme_classic() +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = "#bad2e3"),
      plot.background = ggplot2::element_rect(fill = "#bad2e3"),
      plot.title.position = "plot",
      plot.title = ggplot2::element_text(size = 26, color = "navy",face = "bold", margin = ggplot2::unit(c(0, 0, 0.6, 0), "cm")),
      legend.background = ggplot2::element_rect(fill = "#bad2e3"),
      strip.text = ggplot2::element_text(size = 20),
      axis.text = ggplot2::element_text(size = 15),
      panel.spacing = ggplot2::unit(2, "lines"),
      plot.caption = ggplot2::element_text(size = 18, color = "#1f78b4"),
      plot.subtitle = ggplot2::element_text(size = 23, color = "#1f78b4", face = "italic", margin = ggplot2::unit(c(0, 0, 1, 0), "cm") ),
      axis.title.x   = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_text(size = 20, color = "black"),
      axis.line.x = ggplot2::element_line(linetype = "dashed", size = 2),
      axis.line.y = ggplot2::element_line(linetype = "dashed", size = 2),
      axis.text.x = ggplot2::element_text(size = 19, color = "black"),
      axis.text.y = ggplot2::element_text(size = 19, color = "black")
    )

}
