#' @importFrom dplyr group_by mutate ungroup select one_of n
#' @export
data_plot.estimateContrasts <- function(x, data = NULL, ...){
  .data_plot_estimateContrasts(x, data)
}





#' @keywords internal
.data_plot_estimateContrasts <- function(x, means = NULL, ...){

  if (is.null(means)) {
    warning("Please provide the estimated means data obtained via 'estimate_means()'.")
    means <- data.frame(x_name = unique(c(x$Level1, x$Level2)), Mean = 0)
    x_name <- "x_name"
  } else{
    x_name <- names(means)[1]
  }

  y_name <- c("Median", "Mean", "MAP")[c("Median", "Mean", "MAP") %in% names(means)][1]
  dataplot <- .data_Contrasts_and_Means(x, means, x_name = x_name, y_name = y_name)

  attr(dataplot, "info") <- list(
    "xlab" = x_name,
    "ylab" = y_name,
    "title" = paste0("Estimated ", y_name, "s and Contrasts")
  )

  class(dataplot) <- c("data_plot", "estimateContrasts", class(dataplot))
  dataplot
}






#' @keywords internal
.data_Contrasts_and_Means <- function(contrasts, means, x_name, y_name){

  polygons <- contrasts
  polygons$group <- 1:nrow(polygons)

  data_means <- means
  data_means$x <- data_means[, x_name]
  data_means$y <- data_means[, y_name]
  data_means$Level2 <- data_means$Level1 <- data_means[, x_name]
  data_means$Mean2 <- data_means$Mean1 <- data_means[, y_name]
  data_means$ymin <- data_means$CI_low
  data_means$ymax <- data_means$CI_high

  polygons <- merge(polygons, data_means[c("Level1", "Mean1")], by = "Level1")
  polygons <- merge(polygons, data_means[c("Level2", "Mean2")], by = "Level2")

  polygons <- rbind(
    cbind(polygons, data.frame("x" = polygons$Level1, "y" = polygons$Mean1)),
    cbind(polygons, data.frame("x" = polygons$Level2, "y" = polygons$Mean1 - polygons$CI_low)),
    cbind(polygons, data.frame("x" = polygons$Level2, "y" = polygons$Mean1 - polygons$CI_high)))

  list(geom_polygon = polygons,
       geom_pointrange = data_means)

}





# Plot --------------------------------------------------------------------
#' @importFrom rlang .data
#' @export
plot.estimateContrasts <- function(x, data = NULL, ...){
  if (!"data_plot" %in% class(x)) {
    x <- data_plot(x, data = data)
  }

  p <- ggplot() +
    geom_polygon(
      data = x$geom_polygon,
      aes(x = .data$x, y = .data$y, group = .data$group),
      alpha = 0.1
    ) +
    geom_pointrange(
      data = x$geom_pointrange,
      aes(x = .data$x, y = .data$y, ymax = .data$ymax, ymin = .data$ymin),
      color = "black"
    ) +
    add_plot_attributes(x)

  p
}
