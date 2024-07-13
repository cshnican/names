library(tidyverse)

#######
eng = read_csv("Data/english-names-pop.csv") %>%
  select(year:Male) %>%
  gather(Gender, value, -year, -population) %>%
  filter(is.na(value) == F)

p_eng <- ggplot(eng, aes(x=population/1e6, y=value, colour=Gender, group=Gender, label=year)) + geom_point() + geom_line() +
  xlab("Population (millions)") + ylab("Proportion of top 3 English names") +
  theme_bw(12) +
  theme(legend.position = "bottom") + 
  ylim(0, 1) +
  scale_colour_manual(values=c("darkgray", "black")) %>% print()


pdf('imgs/english_top3.pdf', width = 5, height=4)
p_eng
dev.off()


save(p_eng, file='Data/top_3_english.RData')
#############