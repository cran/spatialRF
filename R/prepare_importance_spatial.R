#' @title Prepares variable importance objects for spatial models
#' @description Prepares variable importance data frames and plots for models fitted with [rf_spatial()].
#' @param model An importance data frame with spatial predictors, or a model fitted with [rf_spatial()].
#' @return A list with importance data frames in different formats depending on whether the model was fitted with [rf()] or [rf_repeat()].
#' @examples
#' if(interactive()){
#'
#'  #loading example data
#'  data(distance_matrix)
#'  data(plant_richness_df)
#'
#'  #fittind spatial model
#'  model <- rf_spatial(
#'    data = plant_richness_df,
#'    dependent.variable.name = "richness_species_vascular",
#'    predictor.variable.names = colnames(plant_richness_df)[5:21],
#'    distance.matrix = distance_matrix,
#'    distance.thresholds =  0,
#'    n.cores = 1
#'  )
#'
#'  #preparing the importance data frame
#'  importance <- prepare_importance_spatial(model)
#'  names(importance)
#'
#' }
#' @rdname prepare_importance_spatial
#' @importFrom stats median
#' @export
prepare_importance_spatial <- function(model){

  importance <- NULL
  variable <- NULL

  #getting importance df
  if(inherits(model, "rf_spatial") == FALSE){
    stop("This function requires a model fitted with rf_spatial()")
  }
  importance.df <- model$importance$per.variable

  #spatial predictors only
  spatial.predictors <- importance.df[grepl(
    "spatial_predictor",
    importance.df$variable
  ),]
  spatial.predictors$variable <- "spatial_predictors"

  #non-spatial predictors
  non.spatial.predictors <- importance.df[!grepl(
    "spatial_predictor",
    importance.df$variable
  ),]

  #joining for plot
  importance.plot.df <- rbind(
    spatial.predictors,
    non.spatial.predictors
  )

  #aggregating spatial predictors
  #min, max, median and mean of the spatial predictors
  spatial.predictors.stats <- data.frame(
    variable = c(
      "spatial_predictors (max)",
      "spatial_predictors (min)",
      "spatial_predictors (median)",
      "spatial_predictors (quantile 0.25)",
      "spatial_predictors (quantile 0.75)"
    ),
    importance = c(
      max(spatial.predictors$importance),
      min(spatial.predictors$importance),
      median(spatial.predictors$importance),
      quantile(spatial.predictors$importanc, probs = 0.25),
      quantile(spatial.predictors$importanc, probs = 0.75)
    )
  )

  #formatting importance.df
  importance.df <- rbind(
    non.spatial.predictors,
    spatial.predictors.stats
  ) %>%
    dplyr::arrange(dplyr::desc(importance))

  #preparing out list
  out.list <- list()

  #common slots
  out.list$per.variable <- model$importance$per.variable
  out.list$per.variable.plot <- plot_importance(
    model$importance$per.variable,
    verbose = FALSE
    )
  out.list$spatial.predictors <- importance.plot.df
  out.list$spatial.predictors.plot <- plot_importance(
    importance.plot.df,
    verbose = FALSE
  )
  out.list$spatial.predictors.stats <- importance.df
  out.list$spatial.predictors.stats.plot <- plot_importance(
    importance.df,
    verbose = FALSE
  )

  #returning the list
  out.list

}
