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

layout<-data.frame(attribute=c('name', 'padding', 'concentric', 'startAngle'),
                   value=c('concentric', 30, 'function(){ return this.degree(); }',
                           '3/2 * Math.PI'),
                   type=c('char','number','JS', 'JS'),
                   stringsAsFactors=F)

layoutOptions<-function(layout_df){
  layout<-lapply(1:nrow(layout_df), function(x){
    with(layout_df[x,], {
      if(type == 'JS'){
        JS(value)
      }else if(type == 'number'){
        as.numeric(value)
      }else if(type == 'bool'){
        as.logical(value)
      }else{
        value
      }
    })
  })
  names(layout)<-layout_df$attribute
  layout
}

layout<-layoutOptions(layout)
jsonedit(layout)
jsonedit(layout_concentric)

layout_concentric<-list(
  name='concentric',
  #fit= TRUE, 
  padding= 30,
  #startAngle= JS('3/2 * Math.PI'), 
  #counterclockwise= 'false', 
  #minNodeSpacing= 10, 
#  boundingBox= undefined, 
  #avoidOverlap= TRUE, 
  #height= undefined, 
  #width= undefined, 
  concentric= JS('function(){ return this.degree(); }')
  #levelWidth= JS('function(nodes){ return nodes.maxDegree() / 4; }'),
  #animate= FALSE, 
  #animationDuration= 500
  #ready= undefined,
  #stop= undefined 
)

style=list(
  list(selector='node',
       style=list(#content='data(desc)',
                  'background-color'='red',
                  content=JS('function(ele){return ele.data("desc")}')
                  )
                  )
  )


style<-data.frame(
  selector=c('node','node', 'node', 'edge', 'edge', 'core', ':selected', '.faded', '.faded'),
  style=c('width','shape', 'content', 'width', 'target-arrow-shape', 'active-bg-color', 'background-color', 'opacity', 'text-opacity'),
  value=c('function( ele ){ return ele.data("size") }','triangle', 'id', 'p,1,10,10,50', 'triangle', 'green', 'black', 0.25, 0),
  mapper=c('function',NA, 'data', 'mapData', NA, NA, NA, NA, NA),
  stringsAsFactors=F
  )



style<-styleOptions(style)
jsonedit(style)

edges<-data.frame(source=c(1:2,'kk'), target=c(2:1,1), p=1:3)
nodes<-data.frame(id=c(1:2,'nk','kk'), desc=c('a','b','nk','kk'),
                  parent=c('nk','nk',NA,NA), size=1:4*10, grabbable=T,
                  renderedPosition=F, x=1:4*10, y=1:4*10,
                  stringsAsFactors=F)

#
elements<-elementsOptions(edges, nodes, grabbable=F, classes='fwef')
jsonedit(elements)
jsonedit(style)

ready<-JS("
function ready(){
    window.cy = this;

    cy.elements().unselectify();

    cy.on('tap', 'node', function(e){
      var node = e.cyTarget;
      var neighborhood = node.neighborhood().add(node);

      cy.elements().addClass('faded');
      neighborhood.removeClass('faded');
    });

    cy.on('tap', function(e){
      if( e.cyTarget === cy ){
        cy.elements().removeClass('faded');
      }
    });
}")

a<-CytoscapeWidget(elements=elements,layout=layout,style=style,ready=ready)
a
saveWidget(a,'test.html')
