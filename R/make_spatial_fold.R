#' @title Makes one training and one testing spatial folds
#' @description Used internally by [make_spatial_folds()] and [rf_evaluate()]. Uses the coordinates of a point `xy.i` to generate two spatially independent data folds from the data frame `xy`. It does so by growing a rectangular buffer from `xy.i` until a number of records defined by `training.fraction` is inside the buffer. The indices of these records are then stored as "training" in the output list. The indices of the remaining records outside of the buffer are stored as "testing". These training and testing records can be then used to evaluate a model on independent data via cross-validation.
#' @param data Data frame with a response variable and a set of predictors. Default: `NULL`
#' @param dependent.variable.name Character string with the name of the response variable. Must be in the column names of `data`. Default: `NULL`
#' @param xy.i One row data frame with at least three columns: "x" (longitude), "y" (latitude), and "id" (integer, id of the record). Can be a row of `xy`. Default: `NULL`.
#' @param xy A data frame with at least three columns: "x" (longitude), "y" (latitude), and "id" (integer, index of the record). Default: `NULL`.
#' @param distance.step.x Numeric, distance step used during the growth in the x axis of the buffers defining the training folds. Default: `NULL` (1/1000th the range of the x coordinates).
#' @param distance.step.y Numeric, distance step used during the growth in the y axis of the buffers defining the training folds. Default: `NULL` (1/1000th the range of the y coordinates).
#' @param training.fraction Numeric, fraction of the data to be included in the training fold, Default: `0.8`.
#' @return A list with two slots named `training` and `testing` with the former having the indices of the training records selected from `xy`, and the latter having the indices of the testing records.
#' @seealso [make_spatial_folds()], [rf_evaluate()]
#' @examples
#' if(interactive()){
#'
#'  #loading example data
#'  data(plant_richness_df)
#'
#'  #getting case coordinates
#'  xy <- plant_richness_df[, 1:3]
#'  colnames(xy) <- c("id", "x", "y")
#'
#'  #building a spatial fold centered in the first pair of coordinates
#'  out <- make_spatial_fold(
#'    xy.i = xy[1, ],
#'    xy = xy,
#'    training.fraction = 0.6
#'  )
#'
#'  #indices of the training and testing folds
#'  out$training
#'  out$testing
#'
#'  #plotting the data
#'  plot(xy[ c("x", "y")], type = "n", xlab = "", ylab = "")
#'  #plots training points
#'  points(xy[out$training, c("x", "y")], col = "red4", pch = 15)
#'  #plots testing points
#'  points(xy[out$testing, c("x", "y")], col = "blue4", pch = 15)
#'  #plots xy.i
#'  points(xy[1, c("x", "y")], col = "black", pch = 15, cex = 2)
#'
#' }
#' @rdname make_spatial_fold
#' @export
make_spatial_fold <- function(
  data = NULL,
  dependent.variable.name = NULL,
  xy.i = NULL,
  xy = NULL,
  distance.step.x = NULL,
  distance.step.y = NULL,
  training.fraction = 0.8
){

  if(sum(c("id", "x", "y") %in% colnames(xy.i)) != 3){
    stop("xy.i must contain the column names 'id', 'x', and 'y'.")
  }
  if(sum(c("id", "x", "y") %in% colnames(xy)) != 3){
    stop("xy must contain the column names 'id', 'x', and 'y'.")
  }
  if(training.fraction >= 1){
    stop("training.fraction should be a number between 0.1 and 0.9")
  }

  #initiating distance.step.x
  if(is.null(distance.step.x)){

    #range of x coordinates
    x.range <- range(xy$x)

    #getting the 1%
    distance.step.x <- (max(x.range) - min(x.range)) / 1000

  } else {

    #in case it comes from raster::res()
    if(length(distance.step.x) > 1){
      distance.step.x <- distance.step.x[1]
    }

  }

  #initiating distance.step.x
  if(is.null(distance.step.y)){

    #range of x coordinates
    y.range <- range(xy$y)

    #getting the 1%
    distance.step.y <- (max(y.range) - min(y.range)) / 1000

  } else {

    #in case it comes from raster::res()
    if(length(distance.step.y) > 1){
      distance.step.y <- distance.step.y[1]
    }

  }

  #getting details of xy.i
  xy.i.x <- xy.i[1, "x"]
  xy.i.y <- xy.i[1, "y"]

  #finding out if data is binary
  is.binary <- FALSE
  if(!is.null(data) & !is.null(dependent.variable.name)){
    is.binary <- is_binary(
      data = data,
      dependent.variable.name = dependent.variable.name
    )
  }

  #number of records to select
  if(is.binary == TRUE){
    records.to.select <- floor(training.fraction * sum(data[, dependent.variable.name]))
  } else {
    records.to.select <- floor(training.fraction * nrow(xy))
  }

  #generating first buffer
  old.buffer.x.min <- xy.i.x - distance.step.x
  old.buffer.x.max <- xy.i.x + distance.step.x
  old.buffer.y.min <- xy.i.y - distance.step.y
  old.buffer.y.max <- xy.i.y + distance.step.y

  #select first batch of presences
  records.selected <- xy[
    xy$x >= old.buffer.x.min &
    xy$x <= old.buffer.x.max &
    xy$y >= old.buffer.y.min &
    xy$y <= old.buffer.y.max, ]

  #growing buffer
  while(nrow(records.selected) < records.to.select){

    #new buffer
    new.buffer.x.min <- old.buffer.x.min - distance.step.x
    new.buffer.x.max <- old.buffer.x.max + distance.step.x
    new.buffer.y.min <- old.buffer.y.min - distance.step.y
    new.buffer.y.max <- old.buffer.y.max + distance.step.y

    #number of selected presences
    records.selected <- xy[
      xy$x >= new.buffer.x.min &
      xy$x <= new.buffer.x.max &
      xy$y >= new.buffer.y.min &
      xy$y <= new.buffer.y.max, ]

    #subset ones if it's binary
    if(is.binary == TRUE){
      records.selected <- records.selected[data[data$id %in% records.selected$id, dependent.variable.name] == 1, ]
    }

    #resetting old.buffer
    old.buffer.x.min <- new.buffer.x.min
    old.buffer.x.max <- new.buffer.x.max
    old.buffer.y.min <- new.buffer.y.min
    old.buffer.y.max <- new.buffer.y.max

  }

  #select from xy.all if response is binary
  #selecting ones if binary
  if(is.binary == TRUE){
    records.selected <- xy[
      xy$x >= new.buffer.x.min &
        xy$x <= new.buffer.x.max &
        xy$y >= new.buffer.y.min &
        xy$y <= new.buffer.y.max, ]
  }

  #out list
  out.list <- list()
  out.list$training <- records.selected$id
  out.list$testing <- setdiff(xy$id, records.selected$id)

  out.list

}
