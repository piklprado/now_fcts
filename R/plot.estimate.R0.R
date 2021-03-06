#' Funcao para plot do R efetivo
#'
#' @param x df.re
#' @param ... ...
#'
#' @export
#'
plot.estimate.R0 <- function(x, ...) { # df com r efetivo
    df.re <- x
    leg.y <- paste0("N", "\u00fa", "mero de reprodu", "\u00e7",  "\u00e3", "o da epidemia")
    plot <- df.re %>%
        mutate(data = as.Date(data)) %>%
        ggplot(aes(x = data, y = Mean.R)) +
        geom_ribbon(aes(ymin = Quantile.0.025.R, ymax = Quantile.0.975.R), fill = "lightgrey") +
        geom_line(size = 1.25, colour = RColorBrewer::brewer.pal(4, "Dark2")[3]) +
        scale_x_date(date_labels = "%d/%b", name = "") +
        ylim(min(c(0.8, min(df.re$Quantile.0.025.R))), max(df.re$Quantile.0.975.R)) +
        geom_hline(yintercept = 1, linetype = "dashed", col = "red", size = 1) +
        ylab(leg.y) +
        plot.formatos
    plot
}
