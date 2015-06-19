devtools::install()
library(CytoscapeWidget)
library(listviewer)

elements=list(
  nodes=list(
    list(data=list(
      id='foo')
         ),
    list(data=list(
      id='bar')
    )
    ),
  edges=list(
    list(data=list(
      id='f2b', source='foo', target='bar')
      ),
    list(data=list(
      id='b2f', source='bar', target='foo')
    )
    )
  )
layout=list(
  name='preset',
  padding=30)

style=list(
  list(selector='node',
       style=list(#content='data(desc)',
                  'background-color'='red',
                  content=JS('function(ele){return ele.data("desc")}')
                  )
                  )
  )


style<-data.frame(
  selector=c('node','node', 'node', 'edge', 'edge', 'core', ':selected'),
  style=c('width','shape', 'content', 'width', 'target-arrow-shape', 'active-bg-color', 'background-color'),
  value=c('function( ele ){ return ele.data("size") }','triangle', 'id', 'p,1,10,10,50', 'triangle', 'green', 'black'),
  mapper=c('function',NA, 'data', 'mapData', NA, NA, NA),
  stringsAsFactors=F
  )



style<-styleOptions(style)
jsonedit(style)

edges<-data.frame(source=c(1:2,'kk'), target=c(2:1,1), p=1:3)
nodes<-data.frame(id=c(1:2,'nk','kk'), desc=c('a','b','nk','kk'),
                  parent=c('nk','nk',NA,NA), size=1:4*10, grabbable=T,
                  renderedPosition=T, x=1:4*10, y=1:4*10)

#
elements<-elementsOptions(edges, nodes, grabbable=F, classes='fwef')
jsonedit(elements)
jsonedit(style)

a<-CytoscapeWidget(elements=elements,layout=layout,style=style)
a
saveWidget(a,'test.html')
