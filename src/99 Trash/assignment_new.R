if(!"tidyverse" %in% (.packages())){library(tidyverse)} else {print("Tidyverse has already been loaded.")}
if(!"scales" %in% (.packages())){library(scales)} else {print("Scale has already been loaded.")}
if(!"lubridate" %in% (.packages())){library(lubridate)} else {print("Lubridate has already been loaded.")}
if(!"ggthemes" %in% (.packages())){library(ggthemes)} else {print("Ggtheme has already been loaded.")}
if(!"ragg" %in% (.packages())){library(ragg)} else {print("Ragg has already been loaded.")}

# DEPENDENCIES ----
# install.packages("tidyverse")
# install.packages("ggthemes")
# install.packages("scales")
# install.packages("ragg")

# Misc Function ----
clean_unused <- function() {
  if (exists("house_price_2021")) {rm(house_price_2021, envir=.GlobalEnv)}
  if (exists("house_price_2020")) {rm(house_price_2020, envir=.GlobalEnv)}
  if (exists("house_price_2019")) {rm(house_price_2019, envir=.GlobalEnv)}
  if (exists("bandwidth_2018")) {rm(bandwidth_2018, envir=.GlobalEnv)}
  if (exists("population_2011")) {rm(population_2011, envir=.GlobalEnv)}
  if (exists("growth_rate")) {rm(growth_rate, envir=.GlobalEnv)}
  if (exists("PGR")) {rm(PGR, envir=.GlobalEnv)}
  #  filters for cleaning
  if (exists("missing_hp")) {rm(missing_hp, envir=.GlobalEnv)}
  if (exists("missing_bandwidth")) {rm(missing_bandwidth, envir=.GlobalEnv)}
  if (exists("missing_Popn")) {rm(missing_Popn, envir=.GlobalEnv)}
  # Garbage collect 
  gc()
}
# Useful Function ----
percentDuplicate <- function(x)(as.numeric((count(x) - count(distinct(x))) /count(x)*100))
normalize <- function(x)(x-min(x)/(max(x)-min(x)))
naRows <-  function (df, show=10, rtn=F){
  a <- df %>% apply(1, function(x) sum(x==""| is.na(x)) / ncol(df) * 100)
  if (!rtn) return(a %>% sort(., decreasing = T) %>% head(show))
  else return(a)
}
naCols <-  function (df) sapply(df, function(x) sum(x=="" | is.na(x))/nrow(df))
?sapply

# Import And Clean ----

# Read CSV
house_price_2021 <- read_csv("./dirty/pp-2021.csv", col_names = FALSE, show_col_types = FALSE)
house_price_2020 <- read_csv("./dirty/pp-2020.csv", col_names = FALSE, show_col_types = FALSE)
house_price_2019 <- read_csv("./dirty/pp-2019.csv", col_names = FALSE, show_col_types = FALSE)
bandwidth_2018 <- read_csv("./dirty/broadband_speed_201805.csv", show_col_types = FALSE)
population_2011 <- read_csv("./dirty/population_2011.csv", show_col_types = FALSE)
growth_rate <- read_csv("./raw/pgr_uk.csv", show_col_types = FALSE)

HousePrices = house_price_2021 %>%
  add_row(house_price_2020) %>%
  add_row(house_price_2019) %>% distinct() %>% 
  mutate(X5=NULL, X6=NULL, X7=NULL, X9=NULL, X11=NULL, X15=NULL, X16=NULL) %>% 
  mutate(X3 = paste(year(X3),month(X3),sep = "-")) %>% mutate(X3 = ym(X3)) %>% 
  set_names(c("ID", "Price", "Year","Postcode","PAON", "Street", "Town/City", "District", "Country")) %>% 
  mutate(Country = factor(Country), District=factor(District)) %>% 
  filter(Country %in% c("GREATER MANCHESTER", "MERSEYSIDE")) %>% 
  separate(Postcode, c("CodeHead", "CodeTail"),remove = F)

HousePrices %>% 
  filter(Country=="GREATER MANCHESTER") %>% 
  group_by(Year) %>% 
  summarise(mean = mean(Price)) %>% 
  ggplot(aes(x=Year, y=log(mean)))+ geom_point() + geom_smooth(method = loess, formula = y ~ x) + theme_fivethirtyeight()

HousePrices %>% 
  filter(Country=="MERSEYSIDE") %>% 
  group_by(Year) %>% 
  summarise(mean = mean(Price)) %>% 
  ggplot(aes(x=Year, y=log(mean)))+ geom_point() + geom_smooth(method = loess, formula = y ~ x) + theme_fivethirtyeight()

# Overview of missing item in % (col wise)
naCols(HousePrices)
# Outcome: In variable Postcode, ~0.226% of value is N/A so deleting N/A's
HousePrices <- HousePrices %>% 
  filter(Postcode == "" | Postcode != is.na(Postcode))

# Overview of missing item in % (row wise)
naRows(HousePrices)
# Max missing observation percentage is 9.09% so no further process required

Bandwidth = bandwidth_2018 %>% 
  select(., c(-8,-9,-10,-11,-16:-31)) %>% 
  filter(postcode_space %in% HousePrices$Postcode)

naCols(Bandwidth)
naRows(Bandwidth)
# Outcome: Since 4 of the observation lacks over 70% of its data, we remove them
Bandwidth <-Bandwidth[naRows(Bandwidth, rtn=T)<70,]
# Outcome: 0% missing in each var (cols) and observation(rows

# Using data from https://datacommons.org/place/country/GBR
# For 2021 PGR https://macrotrends.net/countries/GBR/united-kingdom/population-growth-rate 
# Could use wiki https://en.wikipedia.org/wiki/Demography_of_the_United_Kingdom
PGR <- growth_rate %>% 
  set_names(c("Year", "PGR")) %>% 
  add_row(Year = 2021, PGR = 0.330400742481219) %>% 
  filter(Year > 2011) %>% 
  arrange(Year)

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

# Overview of missing item in % (col wise)
naCols(Population)
# Overview of missing item in % (row wise)
naRows(Population)
# Outcome: 0% missing in each var (cols) and observation(rows)
scl <- read_csv("./Ref/liverpoolSchool.csv")

Schools = schools %>% 
  select(PCODE,School=SCHNAME,Score17 = CA_SCORE_TLEV_17,Score18 = CA_SCORE_TLEV_18,Score19 = CA_SCORE_TLEV, Status=ICLOSE) %>%
  filter(Status==0) %>% 
  filter(!((Score19 %in% c("NE", "SUPP") | is.na(Score19)) &
             (Score18 %in% c("NE", "SUPP") | is.na(Score18)) &
             (Score17 %in% c("NE", "SUPP") | is.na(Score17)))) %>%
  mutate(Score19=as.numeric(ifelse(Score19 %in% c("NE", "SUPP", "NA"), NA, Score19))) %>% 
  mutate(Score18=as.numeric(ifelse(Score18 %in% c("NE", "SUPP", "NA"), NA, Score18))) %>% 
  mutate(Score17=as.numeric(ifelse(Score17 %in% c("NE", "SUPP", "NA"), NA, Score17))) %>% 
  add_column(Schools %>% select(Score19, Score18,Score17) %>% 
               transmute(MeanScore = round(rowMeans(.,na.rm=TRUE),4))) %>%
  select(-Status) %>% 
  distinct






# VISULIZE ----

euro <- dollar_format(prefix = "\u20ac ", big.mark = ",")

# Housing Count By District Plot

ggplot(HousePrices) + geom_bar(mapping = aes(x=District, fill=Country), width=I(0.8),  position = "dodge") + 
  labs(title = "No. of housing by District",
       subtitle = "How many per District ?") +
  theme_fivethirtyeight() +
  scale_fill_brewer(palette = "Accent")
  
# Mean Housing Price By District Plot
# Data Prep
HP_AVG <- HousePrices %>% 
  group_by(District, `Town/City`) %>% 
  summarize(mean_price = mean(Price))

# Plot
ggplot(HP_AVG, aes(x = District,  y = mean_price)) +
  geom_bar(stat = "identity", aes(fill = `Town/City`)) +
  coord_flip() + scale_y_continuous(labels = euro) +
  labs(title = "Mean Housing Prices by District from 2019-2021",
       subtitle = "How do house prices differ ?") +
  scale_fill_discrete(name = "Town") + 
  theme(legend.position="bottom", 
        legend.direction = "horizontal",
        legend.justification ="center",
        legend.key.height = unit(0.4, 'cm'),
        legend.key.width = unit(0.4, 'cm'),
        legend.box.just = "center")

# Misc ----
# Remove unused
clean_unused()
