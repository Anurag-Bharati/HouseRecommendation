KS4Performance = ks4Performance %>% 
  select(URN,LEA, Score = ATT8SCR) %>% 
  left_join(Region, by="LEA") %>% 
  filter(!is.na(URN) & str_detect(REGION.NAME, "North West")) %>% 
  select(-LEA, -LA.Name) %>% 
  distinct

School <- schoolInfo %>% 
  left_join(KS4Performance, by="URN") %>% 
  filter(SCHSTATUS=="Open") %>% 
  filter(!(Score %in% c("","NE", "SUPP") | is.na(Score))) %>% 
  select(Postcode=POSTCODE, SCHNAME, TOWN, GENDER, Score,Region = REGION.NAME) %>% 
  mutate(PostcodePrefix = str_split(Postcode," ",2,TRUE)[,1]) %>% 
  left_join(PostcodeFilter, by="Postcode") %>% 
  mutate(Score=as.numeric(Score)) %>% 
  group_by(PostcodePrefix) %>% 
  summarise(MeanScore = mean(Score))

SchoolSummary = School %>% 
  mutate(PostcodePrefix= str_split(PostcodePrefix, "[0-9]",n = 2, simplify = T)[,1]) %>% 
  group_by(PostcodePrefix) %>% 
  summarise(MeanScore = mean(MeanScore))

a <- HousePrices %>% 
  group_by(PostcodePrefix) %>% 
  summarise(Price = mean(Price, na.rm=T)) %>% 
  left_join(School, by="PostcodePrefix") %>% 
  na.omit()