#' @title Multicollinearity reduction via Variance Inflation Factor
#'
#' @description Selects predictors that are not linear combinations of other predictors by using computing their variance inflation factors (VIF). Allows the user to define an order of preference for the selection of predictors. \strong{Warning}: variables in `preference.order` not in `colnames(x)`, and non-numeric columns are removed silently from `x` and `preference.order`. The same happens with rows having NA values ([na.omit()] is applied). The function issues a warning if zero-variance columns are found.
#' @usage
#' auto_vif(
#'   x = NULL,
#'   preference.order = NULL,
#'   vif.threshold = 5,
#'   verbose = TRUE
#' )
#' @param x A data frame with predictors or the result of [auto_cor()]. Default: `NULL`.
#' @param preference.order a character vector with columns names of x ordered by the user preference, Default: `NULL`.
#' @param vif.threshold Numeric between 2.5 and 10 defining the selection threshold for the VIF analysis. Higher numbers result in a more relaxed variable selection. Default: 5.
#' @param verbose Logical. if `TRUE`, describes the function operations to the user. Default:: `TRUE`
#' @return List with three slots:
#' \itemize{
#'   \item `vif`: data frame with the names of the selected variables and their respective VIF scores.
#'   \item `selected.variables`: character vector with the names of the selected variables.
#'   \item `selected.variables.df`: data frame with the selected variables.
#'  }
#' @details
#'This function has two modes of operation:
#' \itemize{
#' \item 1. When the argument `preference.order` is `NULL`, the function removes on each iteration the variable with the highest VIF until all VIF values are lower than `vif.threshold`.
#' \item 2. When `preference.order` is provided, the variables are selected by giving them priority according to their order in `preference.order`. If there are variables not in `preference.order`, these are selected as in option 1. Once both groups of variables have been processed, all variables are put together and selected by giving priority to the ones in `preference.order`. This method preserves the variables desired by the user as much as possible.
#' }
#'  Can be chained together with [auto_cor()] through pipes, see the examples below.
#' @seealso [auto_cor()]
#' @examples
#' if(interactive()){
#'
#'#loading data
#'data(plant_richness_df)
#'
#'#on a data frame
#'out <- auto_vif(x = plant_richness_df[, 5:21])
#'
#'#getting out the vif data frame
#'out$vif
#'
#'#getting the names of the selected variables
#'out$selected.variables
#'
#'#getting the data frame of selected variables
#'out$selected.variables.df
#'
#'#on the result of auto_cor
#'out <- auto_cor(x = plant_richness_df[, 5:21])
#'out <- auto_vif(x = out)
#'
#'#with pipes
#'out <- plant_richness_df[, 5:21] %>%
#'  auto_cor() %>%
#'  auto_vif()
#'
#' }
#' @rdname auto_vif
#' @importFrom magrittr `%>%`
#' @importFrom stats cor
#' @export
auto_vif <- function(
  x = NULL,
  preference.order = NULL,
  vif.threshold = 5,
  verbose = TRUE
){

  if(inherits(x, "variable_selection") == TRUE){
    x <- x$selected.variables.df
  }

  #coercing to data frame
  #coerce to data frame if tibble
  if(inherits(x, "tbl_df") | inherits(x, "tbl")){
    x <- as.data.frame(x)
  }

  #removing non-numeric and zero variance columns
  #removing NA
  x <- na.omit(x)


  #finding and removing non-numeric columns
  non.numeric.columns <- colnames(x)[!sapply(x, is.numeric)]
  if(length(non.numeric.columns) > 0){
    warning(
      "These columns are non-numeric and will be removed: ",
      paste(
        non.numeric.columns,
        collapse = ", "
      )
    )
    x <- x[, !(colnames(x) %in% non.numeric.columns)]
  }

  #finding zero variance columns
  zero.variance.columns <- colnames(x)[round(apply(x, 2, var), 4) == 0]
  if(length(zero.variance.columns) > 0){
    warning(
      "These columns have zero variance and might cause issues: ",
      paste(
        zero.variance.columns,
        collapse = ", "
      )
    )
  }

  #AND preference.order IS NOT PROVIDED
  if(is.null(preference.order)){

    #OPTION 3: SELECT BY MAX VIF
    output.list <- .select_by_max_vif(
      x = x,
      vif.threshold = vif.threshold,
      verbose = verbose
    )

  } else {

    #OPTION 2: preference.order IS PROVIDED

    #getting only preference.order in colnames(x)
    preference.order <- preference.order[preference.order %in% colnames(x)]

    #selecting by preference
    output.list <- .select_by_preference(
      x = x,
      preference.order = preference.order,
      vif.threshold = vif.threshold,
      verbose = verbose
    )

    #if there are variables not in of preference.order
    if(sum(preference.order %in% colnames(x)) != ncol(x)){

      #selecting by max vif (variables not in preference.order)
      output.list.by.max.vif <- .select_by_max_vif(
        x = x[, !(colnames(x) %in% preference.order)],
        vif.threshold = vif.threshold,
        verbose = verbose
      )

      #merging selected.vars
      selected.vars <- c(
        output.list$selected.variables,
        output.list.by.max.vif$selected.variables
      )

      #vif by preference again
      output.list <- .select_by_preference(
        x = x,
        preference.order = selected.vars,
        vif.threshold = vif.threshold,
        verbose = verbose
      )

    }

  }

  #message
  if(verbose == TRUE){
    removed.vars <- setdiff(colnames(x), output.list$selected.variables)
    if(length(removed.vars) != 0){
      message(
        paste0(
          "[auto_vif()]: Removed variables: ",
          paste0(
            removed.vars,
            collapse = ", "
          )
        )
      )
    } else {
      message("[auto_vif()]: Variables are not collinear.")
    }
  }

  #adding class
  class(output.list) <- "variable_selection"

  #returning output
  output.list

}



#' @export
.vif_to_df <- function(x){

  #defining global variable
  vif <- NULL

  #turns vif output into tidy df
  df <-
    data.frame(
      diag(solve(cor(x))),
      stringsAsFactors = FALSE
    ) %>%
    dplyr::rename(vif = 1) %>%
    tibble::rownames_to_column(var = "variable") %>%
    dplyr::arrange(dplyr::desc(vif))

  df
}


#' @export
.select_by_max_vif <- function(x, vif.threshold, verbose){

  #global variables
  vif <- variable <- NULL

  #initializing selected vars
  selected.variables <- colnames(x)

  #computes vif
  repeat {

    #computes vif
    vif.df <- .vif_to_df(x = x[, selected.variables])

    if(max(vif.df$vif) > vif.threshold){

      #selects variables with vif lower than 5
      var.to.remove <-
        vif.df %>%
        dplyr::filter(vif > vif.threshold) %>%
        dplyr::filter(vif == max(vif)) %>%
        dplyr::slice(1) %>%
        dplyr::select(variable) %>%
        as.character()

      #updates select.cols
      selected.variables <- selected.variables[selected.variables != var.to.remove]

    } else {
      break
    }

  } #end of repeat

  #final vif.df
  vif.df <- .vif_to_df(x = x[, selected.variables])

  #output list
  output.list <- list()
  output.list$vif <- vif.df
  output.list$selected.variables <- selected.variables
  output.list$selected.variables.df <- x[, selected.variables]

  output.list

}


#' @export
.select_by_preference <- function(
  x,
  preference.order,
  vif.threshold,
  verbose
){

  #subsets to the variables already available in x
  preference.order <- preference.order[preference.order %in% colnames(x)]

  #initiating selected vars
  selected.variables <- preference.order[1]

  #iterates through preference order
  for(i in 2:length(preference.order)){

    #new.var
    new.var <- preference.order[i]

    #computes vif
    vif.df <- .vif_to_df(x = x[, c(selected.variables, new.var)])

    #if vif of new.var lower than vif.threshold, keep it
    if(max(vif.df$vif) <= vif.threshold){

      selected.variables <- c(selected.variables, new.var)

    } else {

      next

    }

  }

  #final vif.df
  vif.df <- .vif_to_df(x = x[, selected.variables])

  #output list
  output.list <- list()
  output.list$vif <- vif.df[, c("variable", "vif")]
  output.list$selected.variables <- selected.variables
  output.list$selected.variables.df <- x[, selected.variables]

  output.list

}

