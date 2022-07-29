# CRIME

CrimeTypeCount %>% select(Date,District,Type=Robbery) %>% 
  mutate(Date=str_split(Date,"-",3,TRUE)[,1]) %>% 
  filter(Date==2019) %>% 
  group_by(District) %>% 
  summarise(top=1.2, min=min(Type), mean = mean(Type)) %>% 
  gather(min, mean, -District) %>% 
  spread(District, mean) %>% 
  arrange(desc(min))%>% 
  mutate(min=NULL) %>% 
  radarchart(pfcol = scales::alpha("tomato", 0.6),
             pcol = scales::alpha("tomato", 0.9),
             axistype = 1, caxislabels = seq(0, 1.2,0.30),
             cglcol= "grey", axislabcol = "darkgrey", 
             plwd=6, cglty = 1,
             title = "Average Robbery crime in a month by Town in 2019") 

CrimeTypeCount %>% select(Date,District,Type=Robbery) %>% 
  mutate(Date=str_split(Date,"-",3,TRUE)[,1]) %>% 
  filter(Date==2019) %>% 
  group_by(District) %>% 
  summarise(top=28, min=min(Type), max = max(Type)) %>% 
  gather(min, max, -District) %>% 
  spread(District, max) %>% 
  arrange(desc(min))%>% 
  mutate(min=NULL) %>% 
  radarchart(pfcol = scales::alpha("tomato", 0.6),
             pcol = scales::alpha("tomato", 0.9),
             axistype = 1, caxislabels = seq(0, 28,7),
             cglcol= "grey", axislabcol = "darkgrey", 
             plwd=6, cglty = 1,
             title = "Max Robbery crime cases in a month by Town in 2019") 


# TODO Crime Type in % w/ stack Towns 