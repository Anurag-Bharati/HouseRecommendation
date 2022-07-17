# HELPER FUNCTIONS ----
normalize <- function(x)((x-min(x))/(max(x)-min(x)))
# Overview of missing value in percentage (col wise)
naCols <-  function (df) sapply(df, function(x) sum(x=="" | is.na(x))/nrow(df) * 100)
# Overview of missing value in percentage (row wise)
naRows <-  function (df, show=10, rtn=F){
  a <- df %>% apply(1, function(x) sum(x==""| is.na(x))/ncol(df) * 100)
  if (!rtn) return(a %>% sort(., decreasing = T) %>% head(show))
  else return(a)
}
percentDuplicate <- function(x){
  c <- count(x)
  dc <- count(distinct(x))
  return (as.numeric((c - dc)/c*100))
  rn(c, dc)
}
getFloodOddsFromString <- function(x) {
  if(x=="High") return(3.3)
  else if(x=="Medium") return(2.15)
  else if(x=="Low") return(0.55)
  else if(x=="Very Low") return(0.1)
  else return(0)
}
getFloodOddsFromNumber <- function(x) {
  if(x>=3.3) return("High")
  else if(x>=2.15 & x<3.3) return("Medium")
  else if(x>=0.55 & x<2.15) return("Low")
  else if(x>=0.1 & x<0.55) return("Very Low")
  else return("None")
}