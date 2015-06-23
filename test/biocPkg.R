library(XML)
biocURL<-'http://bioconductor.org/packages/3.2/bioc/'
biocPackets <- readHTMLTable(biocURL)[[1]]
head(biocPackets)

pkgURL<-'http://bioconductor.org/packages/3.2/bioc/html/a4.html'
pkg <- readHTMLTable(pkgURL)
sapply(pkg, class)

Maintainer<-unlist(strsplit(as.character(biocPackets$Maintainer),','))
sort(table(Maintainer))
