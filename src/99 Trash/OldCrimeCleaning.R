Geocode <- geocodes %>%
  select(Postcode = pcds,  LSOA = lsoa11cd, District=ladnm) %>%
  filter(!is.na(LSOA)&!is.na(Postcode)) %>%
  filter(District %in% ReleventPCD$District) %>% 
  separate(Postcode, into=c("PostcodePrefix", "Suffix"), sep = " ", remove = T) %>% 
  select(District, LSOA) %>%
  # mutate(PostcodePrefix= str_split(PostcodePrefix, "[0-9]",n = 2, simplify = T)[,1]) %>% 
  distinct