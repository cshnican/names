library(tidyverse)

#######
eng = read_csv("Data/english-names-pop.csv") %>%
  select(year:Male) %>%
  gather(Gender, value, -year, -population) %>%
  filter(is.na(value) == F)

p_eng <- ggplot(eng, aes(x=population/1e6, y=value, label=year)) + 
  geom_point(aes(colour=Gender, group=Gender)) + 
  geom_line(aes(colour=Gender, group=Gender)) +
  geom_text(data=eng %>% filter(Gender == 'Female' & population < 22.5 | Gender == 'Male' & population > 22.5),
            aes(label=year), nudge_y=0.08) +
  xlab("Population (millions)") + ylab("Proportion of top 3 English names") +
  theme_bw(12) +
  theme(legend.position = "bottom") + 
  ylim(0, 1) +
  scale_colour_manual(values=c("darkgray", "black")) 


pdf('imgs/english_top3.pdf', width = 5, height=4)
p_eng
dev.off()


save(p_eng, file='Data/top_3_english.RData')
#############