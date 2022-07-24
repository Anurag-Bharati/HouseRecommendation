# READ DATA ----

schoolInfo19 <- read.csv("./data/raw/school dataset 14-19/2018-2019/england_spine.csv")
schoolInfo18 <- read.csv("./data/raw/school dataset 14-19/2017-2018/england_spine.csv")
schoolInfo17 <- read.csv("./data/raw/school dataset 14-19/2016-2017/england_spine.csv")
schoolInfo16 <- read.csv("./data/raw/school dataset 14-19/2015-2016/england_spine.csv")
Region <- read.csv("./data/raw/school dataset 14-19/meta/la_and_region_codes_meta.csv")
ks4Performance16 <- read.csv("./data/raw/school dataset 14-19/2015-2016/england_ks4provisional.csv")
ks4Performance17 <- read.csv("./data/raw/school dataset 14-19/2016-2017/england_ks4provisional.csv")
ks4Performance18 <- read.csv("./data/raw/school dataset 14-19/2017-2018/england_ks4provisional.csv")
ks4Performance19 <- read.csv("./data/raw/school dataset 14-19/2018-2019/england_ks4provisional.csv")

# CLEAN DATA ----

KS4Performance19 = ks4Performance19 %>% 
  select(URN,LEA, Score = ATT8SCR) %>% 
  left_join(Region, by="LEA") %>% 
  filter(!is.na(URN) & str_detect(REGION.NAME, "North West")) %>% 
  mutate(Year= "2019-01-01") %>% 
  select(-LEA, -LA.Name) %>% 
  distinct
KS4Performance18 = ks4Performance18 %>% 
  select(URN,LEA, Score = ATT8SCR) %>% 
  left_join(Region, by="LEA") %>% 
  filter(!is.na(URN) & str_detect(REGION.NAME, "North West")) %>% 
  mutate(Year= "2018-01-01") %>% 
  select(-LEA, -LA.Name) %>% 
  distinct
KS4Performance17 = ks4Performance17 %>% 
  select(URN,LEA, Score = ATT8SCR) %>% 
  left_join(Region, by="LEA") %>% 
  filter(!is.na(URN) & str_detect(REGION.NAME, "North West")) %>% 
  mutate(Year= "2017-01-01") %>% 
  select(-LEA, -LA.Name) %>% 
  distinct
KS4Performance16 = ks4Performance16 %>% 
  select(URN,LEA, Score = ATT8SCR) %>% 
  left_join(Region, by="LEA") %>% 
  filter(!is.na(URN) & str_detect(REGION.NAME, "North West")) %>% 
  mutate(Year= "2016-01-01") %>% 
  select(-LEA, -LA.Name) %>% 
  distinct

SchInfo19 = schoolInfo19 %>%
  filter(!(URN %in% c("", " ")| is.na(URN))) %>% 
  filter(SCHSTATUS=="Open") %>% 
  select(URN,SCHNAME,TOWN,POSTCODE,GENDER)
SchInfo18 = schoolInfo18 %>%
  filter(!(URN %in% c("", " ")| is.na(URN))) %>% 
  filter(ICLOSE != 1) %>%
  select(URN,SCHNAME,TOWN,POSTCODE,GENDER)
SchInfo17 = schoolInfo17 %>%
  filter(!(URN %in% c("", " ")| is.na(URN))) %>% 
  filter(ICLOSE != 1) %>%
  select(URN,SCHNAME,TOWN,POSTCODE,GENDER)
SchInfo16 = schoolInfo16 %>%
  filter(!(URN %in% c("", " ")| is.na(URN))) %>% 
  filter(ICLOSE != 1) %>%
  select(URN,SCHNAME,TOWN,POSTCODE,GENDER)

SchInfo = SchInfo19 %>% 
  add_row(SchInfo18) %>% 
  add_row(SchInfo17) %>% 
  add_row(SchInfo16) %>% 
  filter(!(POSTCODE %in% c("", " ")| is.na(POSTCODE))) %>% 
  distinct

KS4Performance = KS4Performance19 %>% 
  add_row(KS4Performance18) %>% 
  add_row(KS4Performance17) %>%
  add_row(KS4Performance16) %>%
  filter(!(Score %in% c(""," ","NE", "SUPP", "NaN") | is.na(Score))) %>% 
  mutate(Year = year(Year), Score = as.numeric(Score)) %>% 
  na.omit

# STANDALONE DF ----

School <- SchInfo %>% 
  left_join(KS4Performance, by="URN") %>%
  select(Postcode=POSTCODE, SCHNAME, TOWN, Score,Year) %>% 
  mutate(PostcodePrefix = str_split(Postcode," ",2,TRUE)[,1]) %>% 
  inner_join(.,RelevantPCD, by = c("PostcodePrefix"="Postal District Code")) %>%
  mutate(TOWN = ifelse(TOWN == "" & Postcode=="M12 4WB", "Manchester", TOWN)) %>% 
  mutate(TOWN = as.factor(TOWN)) %>% 
  mutate(Score=as.numeric(Score)) %>% 
  group_by(Postcode,Year,SCHNAME,TOWN, District, County) %>% 
  summarise(Score = mean(Score, na.rm=T)) %>% na.omit

naCols(KS4Performance)
naRows(KS4Performance)
naCols(SchInfo)
naRows(SchInfo)

write_csv(School, "./data/clean/CleanSchool.csv")


# REMOVE TEMP ----
rm(ks4Performance16,ks4Performance17, ks4Performance18, ks4Performance19)
rm(KS4Performance16,KS4Performance17, KS4Performance18, KS4Performance19)
rm(schoolInfo19, schoolInfo18, schoolInfo17, schoolInfo16)
rm(SchInfo19, SchInfo18, SchInfo17, SchInfo16)
if (exists("Region")) {rm(Region, envir=.GlobalEnv)}
if (exists("SchInfo")) {rm(SchInfo, envir=.GlobalEnv)}
