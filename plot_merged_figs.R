library(gridExtra)
library(ggplot2)
library(ggpubr)

# generating Figure 2 in the main paper, which is a combination of figures from different files
load('Data/fig_proportion_relative_to_top.RData')
load('Data/top_3_english.RData')
pdf('imgs/figure2.pdf', width = 10, height=10)
ggarrange(ag2, p_eng, nrow=2, labels = c('a)', 'b)'))
dev.off()

# generating Figure 4 in the main paper, which is a combination of figures from different files

load('Data/exp3plots.RData')
load('Data/plots_from_byname_analysis.RData')

pdf('imgs/figure4.pdf', width=15, height=20)
ggarrange(plot_prefix_name_vs_byname, 
  ggarrange(p1, p2, ncol=2, labels = c('b)', 'c)')), 
  p3,
  nrow=3, 
  labels = c('a)', '', 'd)'))  
dev.off()

