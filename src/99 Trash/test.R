# TEST AND PRACTICE ----
library(tidyverse)
library(nycflights13)
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes( size=I(5), stroke=I(2)),color = "white")  +
  geom_point(mapping = aes( size=I(4),color = drv))

mpg
?geom_point
?stat_bin

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "dodge")

bar <- ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = cut, fill = cut), 
    show.legend = FALSE,
    width = 1
  ) + 
  theme(aspect.ratio = 1) +
  labs(x = NULL, y = NULL)

bar + coord_flip()
bar + coord_polar()

# transmute() returns added cols only
# mutate() returns all + added



# GRAMMER OF GRAPHICS ----
 # ggplot(data = <DATA>) + 
 #  <GEOM_FUNCTION>(
 #    mapping = aes(<MAPPINGS>),
 #    stat = <STAT>, 
 #    position = <POSITION>
 #  ) +
 #  <COORDINATE_FUNCTION> +
 #  <FACET_FUNCTION> 
  

