#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#' @export
#' @import htmltools
#' @export
#' library(htmltools)

CytoscapeWidget <- function(..., width = NULL, height = NULL) {
  
  getLayoutDepends<-function(layout_name){
    layoutPath <- system.file('htmlwidgets', 'cytoscape.js-2.4.1', 'layouts', package = 'CytoscapeWidget')
    no_depend_layout<-c('null', 'random', 'preset', 'grid', 'circle', 'concentric', 'breadthfirst', 'cose')
    depend_layout<-c('arbor', 'cola', 'dagre', 'spread', 'springy')
    layout.js<-list(
      arbor=list(
        name='arbor',
        version='0.91',
        scripts='arbor.js'
      ),
      cola=list(
        name='cola',
        version='3',
        scripts='cola.v3.min.js'
      ),
      dagre=list(
        name='dagre',
        version='2.4.1',
        scripts='dagre.js'
      ),
      spread=list(
        name='spread',
        version='2.4.1',
        scripts=c('foograph.js', 'rhill-voronoi-core.js')
      ),
      springy=list(
        name='springy',
        version='2.4.1',
        scripts='springy.js')
    )
    
    
    if(layout_name %in% depend_layout){
      layout_depends<-layout.js[[layout_name]]
      layout_depends<-with(layout_depends,
                      htmltools::htmlDependency(name=name,
                                                version=version,
                                                src=layoutPath,
                                                script=scripts)
      )
    }else if(layout_name %in% no_depend_layout){
      layout_depends<-NULL
    }else{
      stop("undefine layout")
    }
    layout_depends
  }
  
  

  # forward options using x
  options = list(
    ...
  )
  
  if(!is.null(options[['layout']])){
    layout_depends<-getLayoutDepends(options[['layout']][['name']])
  }else{
    layout_depends<-NULL
  }

  # create widget
  htmlwidgets::createWidget(
    name = 'CytoscapeWidget',
    options,
    width = width,
    height = height,
    dependencies = layout_depends,
    package = 'CytoscapeWidget'
  )
}

elementsOptions<-function(edges, nodes=NULL, ...){
  df2list<-function(df, ...){
    row2list<-function(x, ...){
      buildList<-function(df, x, columns){
        
        checkPosition<-function(columns){
          position_name<-NULL
          coordinate<-NULL
          if('renderedPosition' %in% columns){
            coordinate<-list(x=df[x, ]$x, y=df[x, ]$y)
            position_name<-ifelse(df[x, 'renderedPosition'], 
                                  'renderedPosition', 
                                  'position')
          }
          list(name=position_name, coordinate=coordinate)
        }
        
        position<-checkPosition(columns)
        #make sure class still dataframe
        columns<-setdiff(columns, position$name)
        df<-subset(df[x,], select=columns)
        df_list<-as.list(df)
        df_list<-df_list[!is.na(df_list)]
        if(!is.null(position$name)){
          df_list[[position$name]]<-position$coordinate
        }
        df_list
      }
      
      df_list<-list(...)
      if(length(attribute_names)!=0){
        #dataframe settings overrides  ...
        df_list[attribute_names]<-NULL
        attribute_list<-buildList(df, x, attribute_names)
        df_list<-c(df_list, attribute_list)
      }
      
      df_list[['data']]<-buildList(df, x, data_names)
      df_list
    }
    
    attribute_names<-c('classes', 'grabbable', 'locked', 'selectable',
                       'selected', 'renderedPosition')
    attribute_names<-intersect(attribute_names, names(df))
    data_names<-setdiff(names(df), c(attribute_names,'x','y'))
    lapply(1:nrow(df), row2list, ...)
  }
  
  checkNodesParent<-function(){
    sameNumber<-with(nodes,sum(as.character(id)==as.character(parent), na.rm=T))
    if(sameNumber > 0){
      stop("nodes id and parents should not the same")
    }
  }
  
  checkNodesPosition<-function(){
    xyNumber<-sum(c('x' ,'y') %in% names(nodes))
    if(xyNumber != 2){
      stop("fix position without x, y")
    }
  }
  
  if(is.null(nodes)){
    nodes<-as.character(unique(c(edges$source, edges$target)))
    nodesOptions<-lapply(nodes, function(x){list(data=list(id=x))})
  }else{
    if(!is.null(nodes$parent)){
      checkNodesParent()
    }
    if(!is.null(nodes$renderedPosition)){
      checkNodesPosition()
    }
    nodesOptions<-df2list(nodes, ...)
  }
  
  list(edges=df2list(edges),
       nodes=nodesOptions)
}

styleOptions<-function(style_df){
  buildElementStyle<-function(element){
    buildMapper<-function(x){
      with(selected_df[x,], {
        if(is.na(mapper)){
          value
        }else if(mapper=='function'){
          JS(value)
        }else{
          sprintf("%s(%s)",mapper,value)
        }
      })
    }
    
    selected_df<-subset(style_df, selector==element)
    style<-lapply(1:nrow(selected_df), buildMapper)
    names(style)<-selected_df$style
    list(selector=element, style=style)
  }
  
  selectors<-unique(as.character(style_df$selector))
  lapply(selectors, buildElementStyle)
  
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
