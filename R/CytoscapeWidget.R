#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
CytoscapeWidget <- function(options, width = NULL, height = NULL) {

  # forward options using x
  x = list(
    options = options
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'CytoscapeWidget',
    x,
    width = width,
    height = height,
    package = 'CytoscapeWidget'
  )
}

#' Widget output function for use in Shiny
#'
#' @export
CytoscapeWidgetOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'CytoscapeWidget', width, height, package = 'CytoscapeWidget')
}

#' Widget render function for use in Shiny
#'
#' @export
renderCytoscapeWidget <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, CytoscapeWidgetOutput, env, quoted = TRUE)
}
