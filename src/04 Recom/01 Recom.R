CleanHousePrice <- read_csv("./data/clean/CleanHousePrices.csv", show_col_types = F)
CleanBandwidth <- read_csv("./data/clean/CleanBandwidth.csv", show_col_types = F)
CleanCrimeCount <- read_csv("./data/clean/CleanCrimeType.csv", show_col_types = F)
CleanSchool <- read_csv("./data/clean/CleanSchool.csv", show_col_types = F)
CleanFloodRisk<- read_csv("./data/clean/CleanFloodRisk.csv", show_col_types = F)


# Classifications of Crimes | Severity: 1A = 0.1B = 0.01C

# A = Drug ,Violence and Sexual offence, Arson, Robbery, weapon 
# B = Shoplifting, Other Theft, Shoplifting, Burglary, vehicle crime, , theft from person, other crime, bicycle theft
# C = Antisocial Behavior,  Public order, 

Crime <- CleanCrimeCount %>% 
  select(-LSOA, -LLSOA, -Date,-Ward, -District, -County) %>% 
  group_by(PCD) %>% 
  summarise_all(sum) %>% ungroup() %>% 
  select(PostcodePrefix = PCD, everything())

ClassACrime <- Crime %>% select(PostcodePrefix,a=3,b=4,c=7,d=12,e=14) %>% 
  group_by(PostcodePrefix) %>% 
  rowwise() %>% transmute(ClassACrime = sum(c(a,b,c,d,e)))

ClassBCrime <- Crime %>% select(PostcodePrefix,a=6,b=8,c=9,d=10, e=11, f=13,g=15) %>% 
  group_by(PostcodePrefix) %>% 
  rowwise() %>% transmute(ClassBCrime = sum(c(a,b,c,d,e,f,g))) %>% ungroup()

ClassCCrime <- Crime %>% select(PostcodePrefix,a=2,b=5) %>% 
  group_by(PostcodePrefix) %>% 
  rowwise() %>% transmute(ClassCCrime = sum(c(a,b))) %>% ungroup()

PreCrimeScore = ClassACrime %>% 
  inner_join(ClassBCrime, by="PostcodePrefix") %>% 
  inner_join(ClassCCrime, by="PostcodePrefix")
  
MidCrimeScore = PreCrimeScore %>% 
  mutate(a = round(ClassACrime/sum(PreCrimeScore$ClassACrime)*100*100, 6)) %>% 
  mutate(b = round(ClassBCrime/sum(PreCrimeScore$ClassBCrime)*100*10, 6)) %>% 
  mutate(c = round(ClassCCrime/sum(PreCrimeScore$ClassCCrime)*100*1, 6)) %>% 
  group_by(PostcodePrefix) %>% rowwise() %>%
  transmute(Score = mean(c(a,b,c))) 

PostCrimeScore = MidCrimeScore %>% 
  transmute(Score = 10 - (Score-min(MidCrimeScore$Score))/(max(MidCrimeScore$Score)-min(MidCrimeScore$Score)) * 10) %>% 
  transmute(Score = round(Score,2)) %>%
  left_join(Town %>% 
              group_by(PostcodePrefix,Town, District, County) %>% 
              summarise(County=str_to_title(County)) %>% ungroup() %>%
              distinct(), by="PostcodePrefix") %>% ungroup()

LeftOutTown <- PostCrimeScore %>% filter(is.na(Town)) %>% 
  select(PostcodePrefix, Score) %>%
  left_join(MinGeoCode %>% 
              select(PostcodePrefix=PCD,Town=Ward, District, County) %>%
              group_by(PostcodePrefix,Town, District, County) %>%
              summarise(County=str_to_title(County)) %>% ungroup() %>% distinct(),by="PostcodePrefix")

CrimeScore = PostCrimeScore %>% filter(!is.na(Town)) %>% 
  ungroup() %>% 
  add_row(LeftOutTown) %>% 
  mutate(Town = as.factor(Town), District = as.factor(District)) %>% 
  select(PostcodePrefix,CrimeScore = Score, everything())

# Since data of crime in Manchester was from 2019 only
#crime_manchester %>% select(Month) %>% mutate(Month = substr(Month,1,4)) %>%  distinct %>% count
#crime_merseyside  %>% select(Month) %>% mutate(Month = substr(Month,1,4)) %>%  distinct %>% count
# Factor = 1/4 = ~0.25

# CrimeManRatio = CrimeManObs/(CrimeManObs+CrimeMerObs)
# CrimeMerRatio = CrimeMerObs/(CrimeManObs+CrimeMerObs)
  
# Check if valid
sum(PreCrimeScore[,2:4]) == sum(Crime[,2:ncol(Crime)])

# Bandwidth
PostBandwidth <- CleanBandwidth %>%
  group_by(PostcodePrefix) %>%
  summarise(Download = mean(AvgDownload))

Bandwidth <- PostBandwidth %>%
  mutate(BandwidthScore = round((Download-min(PostBandwidth$Download))/(max(PostBandwidth$Download)-min(PostBandwidth$Download)) * 10, 2)) %>%
  mutate(BandwidthScore = ifelse(BandwidthScore<0.01, 0.01, BandwidthScore))

# School
PostSchool <- CleanSchool %>%
  separate(Postcode, into=c("PostcodePrefix", "S")) %>%
  select(PostcodePrefix, Score) %>%
  group_by(PostcodePrefix) %>%
  summarise(SchoolScore = mean(Score))

School <- PostSchool %>%
  mutate(SchoolNScore = round((SchoolScore-min(PostSchool$SchoolScore))/(max(PostSchool$SchoolScore)-min(PostSchool$SchoolScore)) * 10, 2))

PostFlood <- CleanFloodRisk %>%
  group_by(PostcodePrefix) %>%
  summarise(FloodScore = mean(avgOdd))

# Flood Risk
Flood <- PostFlood %>%
  mutate(FloodNScore = round(10 - (FloodScore-min(PostFlood$FloodScore))/(max(PostFlood$FloodScore)-min(PostFlood$FloodScore)) * 10, 2))

# House Price
HP <- CleanHousePrice %>%
  group_by(PostcodePrefix, District, County) %>%
  summarise(Price = mean(Price)) %>% ungroup() %>%
  mutate(County=str_to_title(County))

HPS = HP %>%
  mutate(PriceScore = round(10 - (Price-min(HP$Price))/(max(HP$Price)-min(HP$Price)) * 10, 2))

Rank = HPS %>%
  left_join(CrimeScore , by=c("PostcodePrefix"="PostcodePrefix", "District"="District", "County"="County")) %>%
  left_join(Bandwidth, by=c("PostcodePrefix"="PostcodePrefix")) %>%
  left_join(School, by=c("PostcodePrefix"="PostcodePrefix")) %>%
  left_join(Flood, by=c("PostcodePrefix"="PostcodePrefix")) %>%
  mutate(CrimeScore = ifelse(County=="Greater Manchester", CrimeScore/1.5, CrimeScore)) %>%  # Adjusting, Since data of crime in Manchester was from 2019 only
  rowwise() %>%
  mutate(OverallScore = mean(c(BandwidthScore,SchoolNScore, PriceScore, CrimeScore, FloodNScore), na.rm=T))

RankScoreOnly = Rank %>%
  select( -Price, -SchoolScore, -Download, -FloodScore, -District, -PostcodePrefix) %>%
  na.omit() %>% group_by(Town,County) %>%
  summarise_all(mean) %>% filter(!(Town=="Wigan" & County=="Merseyside")) %>%  ungroup() %>%
  arrange(desc(OverallScore)) %>%
  mutate(Rank = row_number()) %>%
  select(Rank,Town,County, everything())
