library(XML)
biocURL<-'http://bioconductor.org/packages/3.2/bioc/'
biocPackets <- readHTMLTable(biocURL)[[1]]
head(biocPackets)

pkgURL<-'http://bioconductor.org/packages/3.2/bioc/html/a4.html'
pkg <- readHTMLTable(pkgURL)
sapply(pkg, class)

Maintainer<-unlist(strsplit(as.character(biocPackets$Maintainer),','))
sort(table(Maintainer))

pkgs<-lapply(biocPackets$Package[1:3], function(pkg){
  message(pkg)
  pkgURL<-sprintf("http://bioconductor.org/packages/3.2/bioc/html/%s.html", pkg)
  pkg<-readHTMLTable(pkgURL)
  pkg[[3]]
})

save(pkgs, file='pkgs.RData')
