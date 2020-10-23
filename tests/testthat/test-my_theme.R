test_that("output is ggplot2 object", {
library(ggplot2)
  df <- data.frame(x = 1:10, y =1:10)

 fig <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
   ggplot2::geom_line()

 testthat::expect_true(ggplot2::is.ggplot(my_theme(fig)))

})
