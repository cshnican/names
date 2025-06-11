library(gridExtra)
library(ggplot2)
library(ggpubr)
library(purrr)

# generating Figure 2 in the main paper, which is a combination of figures from different files
load('Data/fig_proportion_relative_to_top.RData')
load('Data/top_3_english.RData')
pdf('imgs/figure2.pdf', width = 10, height=10)
ggarrange(ag2, p_eng, nrow=2, labels = c('a)', 'b)'))
dev.off()



