library(XML)
biocURL<-'http://bioconductor.org/packages/3.2/bioc/'
biocPackets <- readHTMLTable(biocURL)[[1]]
#head(biocPackets)

#pkgURL<-'http://bioconductor.org/packages/3.2/bioc/html/a4.html'
#pkg <- readHTMLTable(pkgURL)
#sapply(pkg, class)

#Maintainer<-unlist(strsplit(as.character(biocPackets$Maintainer),','))
#sort(table(Maintainer))

pkgs<-lapply(biocPackets$Package[1:2], function(pkg){
  message(pkg)
  pkgURL<-sprintf("http://bioconductor.org/packages/3.2/bioc/html/%s.html", pkg)
  df<-readHTMLTable(pkgURL, header=F, stringsAsFactors = FALSE, which=3)
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
      unlist(strsplit(gsub(" ", "", v), split=','))
    }else{
      v
    }
  })
})

save(biocPackets, pkgs, pkgs_df, pkgs_list, file='pkgs.RData')
