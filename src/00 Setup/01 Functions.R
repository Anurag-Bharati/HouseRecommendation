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