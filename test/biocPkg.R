library(XML)
library(parallel)
library(reshape2)
library(plyr)
biocURL<-'http://bioconductor.org/packages/3.2/bioc/'
biocPackets <- readHTMLTable(biocURL)[[1]]
#head(biocPackets)

#pkgURL<-'http://bioconductor.org/packages/3.2/bioc/html/a4.html'
#pkg <- readHTMLTable(pkgURL)
#sapply(pkg, class)

#Maintainer<-unlist(strsplit(as.character(biocPackets$Maintainer),','))
#sort(table(Maintainer))

pkgs<-mclapply(biocPackets$Package[1:500], function(pkg){
  message(pkg)
  pkgURL<-sprintf("http://bioconductor.org/packages/3.2/bioc/html/%s.html", pkg)
  df<-try(readHTMLTable(pkgURL, header=F, stringsAsFactors = FALSE, which=3),TRUE)
  df$Package<-as.character(pkg)
  df
})

pkgs_df<-do.call(rbind, pkgs)
pkgs_df$V2[pkgs_df$V2 == ""]<-NA

pkgs_df<-dcast(pkgs_df, Package ~ V1, value.var = 'V2')

pkgs_list<-dlply(pkgs_df, .(Package), function(df){
  df_list<-as.list(df)
  df_list<-df_list[!is.na(df_list)]
  lapply(df_list, function(v){
    if(length(grep(",", v)) > 0){
      unlist(strsplit(v, split=', '))
    }else{
      v
    }
  })
})

#save(biocPackets, pkgs, pkgs_df, pkgs_list, file='pkgs.RData')
load('pkgs.RData')

biocViews<-sort(table(unlist(strsplit(gsub(" ","",pkgs_df$biocViews),','))))
barplot(biocViews[biocViews>50], las=2, horiz=T)

getEdges<-function(pkgs_list, column){
  edges<-do.call(rbind,
          lapply(pkgs_list, function(pkg){
            targets<-gsub("\\(.*\\)", "", pkg[[column]])
            if(length(targets)>0){
              data.frame(source=pkg$Package,
                         target=targets,
                         type=column)
            }
          })
  )
  rownames(edges)<-NULL
  edges
}

edges_types<-names(pkgs_df)[c(5:9,12:14)]
edges<-lapply(edges_types, getEdges, pkgs_list=pkgs_list)
edges<-do.call(rbind, edges)

nodesFilter<-function(biocViews){
  idx<-grep(biocViews, pkgs_df$biocViews)
  pkgs_df$Package[idx]
}

nodesFilter('Microarray')

edges<-subset(edges, !(target %in% c('methods','R','R ', 'Biobase',
                                     'BiocGenerics', 'a4Base', 'AnnotationDbi')))

edges<-subset(edges,
              target %in% setdiff(nodesFilter('KEGG'), c('R', 'R ', 'methods')) | 
              source %in% setdiff(nodesFilter('KEGG'), c('R','R ', 'methods')) )


Maintainer_pairs_idx<-grep(", ", biocPackets$Maintainer)
Maintainer<-strsplit(as.character(biocPackets$Maintainer[Maintainer_pairs_idx]),', ')
Maintainer<-lapply(Maintainer, function(x){
  t(combn(x, 2))
})
Maintainer<-do.call(rbind, Maintainer)
colnames(Maintainer)<-c('source', 'target')
Maintainer<-as.data.frame(Maintainer)
Maintainer<-Maintainer %>%
  group_by(source, target) %>%
  summarise(count=n())

elements<-elementsOptions(Maintainer)
layout<-data.frame(attribute=c('name', 'padding', 'maxSimulationTime'),
                   value=c('spread', 30, 5000),
                   type=c('char','number', 'number'),
                   stringsAsFactors=F)
layout<-layoutOptions(layout)
style<-data.frame(
  selector=c('node', 'edge', 'edge', ':selected', '.faded', '.faded'),
  style=c('content', 'target-arrow-shape', 'width', 'background-color', 'opacity', 'text-opacity'),
  value=c('id', 'triangle', 'count',  'black', 0.25, 0),
  mapper=c('data', NA,'data', 'mapData', NA, NA),
  stringsAsFactors=F
)

style<-styleOptions(style)
a<-CytoscapeWidget(elements=elements,layout=layout,style=style,ready=ready, motionBlur=F, wheelSensitivity=0.1, textureOnViewport=T, hideEdgesOnViewport=T, hideLabelsOnViewport=T)
saveWidget(a,'test.html',selfcontained=F)
