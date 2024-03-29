#' @title Prints cross-validation results
#' @description Prints the results of an spatial cross-validation performed with [rf_evaluate()].
#' @param model A model resulting from [rf_evaluate()].
#' @return A table printed to the standard output.
#' @seealso [plot_evaluation()], [get_evaluation()]
#' @examples
#' if(interactive()){
#'
#' #loading example data
#' data(plant_richness_df)
#' data(distance_matrix)
#'
#' #fitting random forest model
#' rf.model <- rf(
#'   data = plant_richness_df,
#'   dependent.variable.name = "richness_species_vascular",
#'   predictor.variable.names = colnames(plant_richness_df)[5:21],
#'   distance.matrix = distance_matrix,
#'   distance.thresholds = 0,
#'   n.cores = 1,
#'   verbose = FALSE
#' )
#'
#' #evaluation with spatial cross-validation
#' rf.model <- rf_evaluate(
#'   model = rf.model,
#'   xy = plant_richness_df[, c("x", "y")],
#'   n.cores = 1
#' )
#'
#' #checking evaluation results
#' print_evaluation(rf.model)
#'
#' }
#' @rdname print_evaluation
#' @export
print_evaluation <- function(model){

  #stop if no evaluation slot
  if(!inherits(model, "rf_evaluate")){
    stop("Object 'x' does not have an 'evaluation' slot.")
  }

  metric <- NULL
  median_absolute_deviation <- NULL

    x <- model$evaluation$aggregated %>%
      dplyr::filter(
        model == "Testing"
      ) %>%
      dplyr::select(
        metric,
        median,
        median_absolute_deviation,
        min,
        max
      ) %>%
      dplyr::mutate(
        median = round(median, 3),
        median_absolute_deviation = round(median_absolute_deviation, 3),
        min = round(min, 3),
        max = round(max, 3)
      ) %>%
      dplyr::rename(
        Metric = metric,
        Median = median,
        MAD = median_absolute_deviation,
        Minimum = min,
        Maximum = max
      )

    x <- x[,colSums(is.na(x)) < nrow(x)]

    x <- na.omit(x)

  #printing output
  cat("\n")
  cat("Spatial evaluation \n")
  cat("  - Training fraction:             ", model$evaluation$training.fraction, "\n", sep="")
  cat("  - Spatial folds:                 ", length(model$evaluation$spatial.folds), "\n\n", sep="")
  print(x, row.names = FALSE)

}
