# https://getthedata.com/open-flood-risk-by-postcode
flood_risk <- read_csv("./raw/open_flood_risk_by_postcode.csv", show_col_types = F, col_names=F)

getOdds <- function(x) {
  if(x=="High") return(3.3)
  else if(x=="Medium") return(2.15)
  else if(x=="Low") return(0.55)
  else if(x=="Very Low") return(0.1)
  else return(0)
}

fromOdds <- function(x) {
  if(x==3.3) return("High")
  else if(x==2.15) return("Medium")
  else if(x==0.55) return("Low")
  else if(x==0.1) return("Very Low")
  else return("None")
}

FloodRisk = flood_risk %>% 
  select(X1, X3) %>% distinct %>% 
  set_names("Postcode", "Likelihood") %>% 
  mutate("OddsInYear" = sapply(Likelihood, getOdds)) %>% 
  select("Postcode", "OddsInYear")

test <- HousePrices %>% 
  left_join(FloodRisk, by= "Postcode")
