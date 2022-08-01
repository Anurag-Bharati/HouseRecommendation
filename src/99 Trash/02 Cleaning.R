# HELPER FUNCTIONS ----
percentDuplicate <- function(x){
  c <- count(x)
  dc <- count(distinct(x))
  return (as.numeric((c - dc)/c*100))
  rn(c, dc)
}
normalize <- function(x)(x-min(x)/(max(x)-min(x)))
# Overview of missing value in percentage (col wise)
naCols <-  function (df) sapply(df, function(x) sum(x=="" | is.na(x))/nrow(df) * 100)
# Overview of missing value in percentage (row wise)
naRows <-  function (df, show=10, rtn=F){
  a <- df %>% apply(1, function(x) sum(x==""| is.na(x))/ncol(df) * 100)
  if (!rtn) return(a %>% sort(., decreasing = T) %>% head(show))
  else return(a)
}
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

# CLEANING HOUSE PRICES | REDUCTION: 2733738 obs ---- 

HousePrices = house_price_2021 %>%
  add_row(house_price_2020) %>%
  add_row(house_price_2019) %>% 
  mutate(X1=NULL, X5=NULL, X6=NULL, X7=NULL, X8=NULL, X9=NULL, X10=NULL, X11=NULL, X15=NULL, X16=NULL) %>% 
  mutate(X3 = paste(year(X3),month(X3),sep = "-")) %>% mutate(X3 = ym(X3)) %>% 
  set_names(c("Price", "Year","Postcode", "Town", "District", "Country")) %>% 
  mutate(Country = as.factor(Country), District=as.factor(District), Town=as.factor(Town)) %>% 
  filter(Country %in% c("GREATER MANCHESTER", "MERSEYSIDE")) %>% 
  mutate(PostcodePrefix = str_split(Postcode," ",2,TRUE)[,1])

TownPrices = HousePrices %>%
  group_by(PostcodePrefix, Town, Country) %>% 
  summarise(Price = mean(Price),
            Town= names(which.max(table(Town))),
            Country= names(which.max(table(Country))),)

# Check for duplicates
percentDuplicate(HousePrices)
# Outcome: ~3.63% of observation is duplicate
# Action: Removing duplicates using dplyr distinct
HousePrices <- HousePrices %>% distinct()

naCols(HousePrices)
# Outcome: In variable Postcode, ~0.226% of value is N/A 
# Action: Removing N/A value in Variable Postcode
HousePrices <- HousePrices %>% filter(Postcode == "" | Postcode != is.na(Postcode))

naRows(HousePrices)
# Outcome: Max missing values per observation percentage is 9.09%
# Action: Since the missing % ain't no significant, we shall skip :)

# CLEANING BANDWIDTH ----
Bandwidth = bandwidth_2018 %>% 
  select(., c(-8,-9,-10,-11,-16:-31)) %>% 
  filter(postcode_space %in% HousePrices$Postcode) %>% 
  select(Postcode = postcode_space, everything())

colnames(Bandwidth)

naCols(Bandwidth)
# Outcome: Max missing values per variable percentage is 0%
# Action: No action needed

naRows(Bandwidth)
# Outcome: Since 4 of the observation lacks over 70% of its attribute
# Action: Removing observation missing >= 70% of its attribute
Bandwidth <-Bandwidth[naRows(Bandwidth, rtn=T)<70,]
# Outcome: 0% missing in each var (cols) and observation(rows)

# Check for duplicates
percentDuplicate(Bandwidth)


# CLEANING POPN GROWTH RATE (PGR) ----
# Using data from https://datacommons.org/place/country/GBR
# For 2021 PGR https://macrotrends.net/countries/GBR/united-kingdom/population-growth-rate 
# Could use wiki https://en.wikipedia.org/wiki/Demography_of_the_United_Kingdom
PGR <- growth_rate %>% 
  set_names(c("Year", "PGR")) %>% 
  add_row(Year = 2021, PGR = 0.330400742481219) %>% 
  filter(Year > 2011) %>% 
  arrange(Year)

# CLEANING POPULATION ----

# Check for duplicates
percentDuplicate(population_2011)

# Adding all sub post code to one + Formula https://pages.uoregon.edu/rgp/PPPM613/class8a.htm
Population = population_2011 %>%  
  set_names(c("Postcode", "Population11")) %>% distinct() %>% 
  mutate(postcode_min = str_split(Postcode," ",2,TRUE)[,1]) %>%
  group_by(postcode_min) %>%
  summarise_at(vars(Population11),list(Population11 = sum)) %>%
  mutate(Population12=(Population11*PGR$PGR[1]*0.01)+Population11) %>% 
  mutate(Population13=(Population12*PGR$PGR[2]*0.01)+Population12) %>% 
  mutate(Population14=(Population13*PGR$PGR[3]*0.01)+Population13) %>% 
  mutate(Population15=(Population14*PGR$PGR[4]*0.01)+Population14) %>% 
  mutate(Population16=(Population15*PGR$PGR[5]*0.01)+Population15) %>% 
  mutate(Population17=(Population16*PGR$PGR[6]*0.01)+Population16) %>% 
  mutate(Population18=(Population17*PGR$PGR[7]*0.01)+Population17) %>% 
  mutate(Population19=(Population18*PGR$PGR[8]*0.01)+Population18) %>% 
  mutate(Population20=(Population19*PGR$PGR[9]*0.01)+Population19) %>% 
  mutate(Population21=(Population20*PGR$PGR[10]*0.01)+Population20) %>% 
  mutate(Population19=as.integer(Population19),Population20=as.integer(Population20),
         Population21=as.integer(Population21)) %>% 
  select(postcode_min,Population19,Population20,Population21)

naCols(Population)
# Outcome: Max missing values per variable percentage is 0%
# Action: No action needed

naRows(Population)
# Outcome: Missing values per observation percentage is 0%
# Action:  No action needed

percentDuplicate(geocodes)
# Outcome: No Duplicates Action: None

#  CLEANING GEO CODES ----


GeoCode <- geocodes %>% select(Postcode = pcds,  LSOA = lsoa11cd) %>% filter(!is.na(LSOA))
HousePrices <- HousePrices %>% inner_join(GeoCode, by=("Postcode")) 
HousePrices <- HousePrices %>% select(Postcode, LSOA, MSOA, everything())

# CLEANING CRIME ----
Crime = crime_merseyside %>% 
  add_row(crime_manchester) %>% 
  select(Date = Month, Department = `Falls within`, LSOA=`LSOA code`, Location, Type=`Crime type` ) %>%
  mutate(Date=ym(Date), Type=as_factor(Type))

CrimeTypeCount = Crime %>% 
  group_by(LSOA) %>% 
  pivot_wider(names_from = Type, values_from = Type, values_fn = length, values_fill = 0) %>%
  summarise_at(.vars = colnames(.[,5:18]), .funs = sum)

# Verify: To prove that the crime count is equally distributed across its type
sum(CrimeTypeCount[,3:16]) == nrow(Crime)
# Output : True 

CrimeTypeCount %>% ggplot(aes(x=Drugs, color=LSOA)) +geom_bar()+ dark_mode(theme_fivethirtyeight())+myTheme
# U -> 63795171 (bad)
# A -> 595563 (ideal)

naCols(Crime)
# Outcome: Max missing values per variable percentage is 0%
# Action: No action needed
naRows(Crime)
# Outcome: Missing values per observation percentage is 0%
# Action:  No action needed

# CLEANING FLOOD RISK

FloodRisk = flood_risk %>% 
  select(X1, X3) %>% distinct %>% 
  set_names("Postcode", "Likelihood") %>% 
  mutate("OddsInYear" = sapply(Likelihood, getOdds)) %>% 
  mutate(PostcodePrefix = str_split(Postcode," ",2,TRUE)[,1]) %>%
  group_by(PostcodePrefix) %>%
  summarize(avgOdd = mean(OddsInYear)) %>% 
  select(PostcodePrefix, avgOdd)


# MERGE DO AT LAST
HousePrices <- HousePrices %>% 
  left_join(FloodRisk, by= "PostcodePrefix")

PostcodeFilter <- HousePrices %>% select(Postcode)


clean_unused()
