# READ DATA ----
# SOURCE: https://getthedata.com/open-flood-risk-by-postcode
flood_risk <- read_csv("./data/raw/misc/open_flood_risk_by_postcode.csv", show_col_types = F, col_names=F)

# STANDALONE DF ----
FloodRisk = flood_risk %>% 
  select(X1, X3) %>% distinct %>% 
  set_names("Postcode", "Likelihood") %>% 
  mutate("OddsInYear" = sapply(Likelihood, getFloodOddsFromString)) %>% 
  mutate(PostcodePrefix = str_split(Postcode," ",2,TRUE)[,1]) %>%
  group_by(PostcodePrefix) %>%
  summarize(avgOdd = mean(OddsInYear)) %>% ungroup %>% 
  inner_join(RelevantPCD, by=c("PostcodePrefix"="Postal District Code")) %>%
  select(PostcodePrefix, avgOdd, everything())

write_csv(FloodRisk, "./data/clean/CleanFloodRisk.csv")

# REMOVE TEMP ----
if (exists("flood_risk")) {rm(flood_risk, envir=.GlobalEnv)}

