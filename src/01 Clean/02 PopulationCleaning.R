# READ DATA ----
population_2011 <- read_csv("./data/raw/population_2011.csv", show_col_types = FALSE)
growth_rate <- read_csv("./data/raw/misc/pgr_uk.csv", show_col_types = FALSE)

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
  mutate(Population19=as.integer(Population19),
         Population20=as.integer(Population20),
         Population21=as.integer(Population21)) %>% 
  select(postcode_min,Population19,Population20,Population21)

naCols(Population)
# Outcome: Max missing values per variable percentage is 0%
# Action: No action needed

naRows(Population)
# Outcome: Missing values per observation percentage is 0%
# Action:  No action needed

percentDuplicate(Population)
# Outcome: No Duplicates Action: None

write_csv(Population, "./data/clean/CleanPopulation.csv")

# REMOVE TEMP ----
if (exists("population_2011")) {rm(population_2011, envir=.GlobalEnv)}
if (exists("growth_rate")) {rm(growth_rate, envir=.GlobalEnv)}
if (exists("PGR")) {rm(PGR, envir=.GlobalEnv)}
