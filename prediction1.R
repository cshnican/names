library(tidyverse)
library(xtable)

#korea = read_csv("Data/Korea/ korea.csv", col_names = NA)
korea = read_csv('Data/Korea/korea_2015_hanja.csv') %>%
  filter(`성씨, 본관별`!='전국')
# vietnam = read_csv("Data/Vietnam (US 2000)/viet usa 2000.csv")
vietnamese_american = read_csv('Data/Vietnam (US 2010)/vietnamese_american_data.csv')
vietnamese_american$asian.count = vietnamese_american$count * vietnamese_american$pctapi/100
krank = rev(sort(korea$`2015`))
vietrank = rev(sort(vietnamese_american$asian.count))
#china_mainland_400 = read_csv('Data/Chinese_name_data/chinese_surnames_400.csv')
chinese_american = read_csv('Data/Chinese (US 2010)/chinese_american_data.csv')
chinese_american$asian.count = chinese_american$count * chinese_american$pctapi/100
abcrank = rev(sort(chinese_american$asian.count))
taiwan = read_csv('Data/Chinese_name_data/taiwan_2018.csv')
#plot(krank, vietrank)
#cor(krank, vietrank)
#summary(lm(krank ~ vietrank))

###############################################
beith = read_csv("Data/Scotland/beith.csv", col_names = NA)
dingwall = read_csv("Data/Scotland/dingwall.csv", col_names = NA)
govan = read_csv("Data/Scotland/govan.csv", col_names = NA)
earlstone = read_csv("Data/Scotland/earlstone.csv", col_names = NA)
nengland = read_csv("Data/northern_england.csv", col_names = NA)
################################################
ca = read_csv("Data/CA.TXT", col_names=F) %>%
  filter(X3 >= 1910 & X3<=2010) %>%
  group_by(X4) %>%
  summarise(n=sum(X5)) %>%
  arrange(-n)

de = read_csv("Data/DE.TXT", col_names=F) %>%
  filter(X3 >= 1910 & X3<=2010) %>%
  group_by(X4) %>%
  summarise(n=sum(X5)) %>%
  arrange(-n)

fins = read_csv("Data/finnish_data_selected.csv")
fins_post1900 = filter(fins, birth_year > 1900) %>%
  group_by(child_first_nameN) %>%
  summarise(name_count=n()) %>%
  arrange(-name_count)

fins_pre1800 = filter(fins, birth_year < 1800) %>%
  group_by(child_first_nameN) %>%
  summarise(name_count=n()) %>%
  arrange(-name_count)

###################################################
# read in all data from US States, 1900-2000
pth <- 'Data/US_census_all'
us_states <- list.files(pth, "*.TXT")

read_files <- function(filename){
  d <- read.csv(paste0(pth, '/', filename), header = FALSE)
  colnames(d) = c('state', 'gender', 'year', 'name', 'frequency')
  return(d)
}

all_us_1910_2010 <- lapply(us_states, read_files) %>% bind_rows() %>%
  filter(year >= 1910 & year <=2010) %>%
  group_by(name) %>% 
  summarize(freq = sum(frequency))

###################################################
# summary data
sum.d = tibble(region = c("Korea (2015 Census)", "Vietnamese-American (2010 Census)", 
                          #"China Mainland", 
                          "Chinese-American (2010 Census)", "Taiwan (2018 Census)",
                          "Beith (1700-1800)", "Govan (1700-1800)", "Dingwall (1700-1800)", "Earlstone (1700-1800)",
                          "Northern England (1701-1800)",
                          "Finland pre-1800", "Finland post-1900",
                          "Delaware (1910-2010)", "California (1910-2010)", "All USA (1910-2010)"),
              `name count` = c(length(unique(korea$`성씨, 본관별`)),
                                length(unique(vietnamese_american$name)),
                                #length(unique(china_mainland_400$prefix_name)),
                                length(unique(chinese_american$name)),
                                length(unique(taiwan$`Name`)),
                                length(unique(beith$X1)),
                                length(unique(govan$X1)),
                                length(unique(dingwall$X1)),
                                length(unique(earlstone$X1)),
                                length(unique(nengland$X1)),
                                length(unique(fins_pre1800$child_first_nameN)),
                                length(unique(fins_post1900$child_first_nameN)),
                               length(unique(de$X4)),
                               length(unique(ca$X4)),
                               length(unique(all_us_1910_2010$name))
                               
              ),
               `sample` = c(sum(korea$`2015`, na.rm=T),
                                round(sum(vietnamese_american$asian.count, na.rm=T)),
                                #sum(china_mainland_400$number*10000, na.rm=T),
                                round(sum(chinese_american$asian.count, na.rm=T)),
                                sum(taiwan$Number, na.rm=T),
                                sum(beith$X4, na.rm=T),
                                sum(govan$X4, na.rm=T),
                                sum(dingwall$X4, na.rm=T),
                                sum(earlstone$X4, na.rm=T),
                                sum(nengland$X2, na.rm=T),
                                sum(fins_pre1800$name_count, na.rm=T),
                                sum(fins_post1900$name_count, na.rm=T),
                                sum(de$n, na.rm=T),
                                sum(ca$n, na.rm=T),
                                sum(all_us_1910_2010$freq, na.rm = T)),
              `cut-offs` = c(5,
                             100,
                             #80000,
                             100,
                             135,
                             1,
                             1,
                             1,
                             1,
                             1,
                             1,
                             1,
                             5,
                             5,
                             5),
              
              `population` = c(51069000, # Statistics Korea, Korean Census 2015, https://kostat.go.kr/board.es?mid=a20107020000&bid=11739&tag=&act=view&list_no=420178&ref_bid=&keyField=&keyWord=&nPage=1
                               1548449, # US Census Bureau, Vietnamese American population 2010, https://www.census.gov/content/dam/Census/library/publications/2012/dec/c2010br-11.pdf
                               3347229, # US Census Bureau, Chinese American population 2010, https://www.census.gov/content/dam/Census/library/publications/2012/dec/c2010br-11.pdf
                               23572049, # Taiwan Dept of Household Registration, January 2018, https://www.ris.gov.tw/app/portal/346 
                               sum(beith$X4, na.rm=T), # since the cut-off is 1, the sample size is the true population
                               sum(govan$X4, na.rm=T),
                               sum(dingwall$X4, na.rm=T),
                               sum(earlstone$X4, na.rm=T),
                               sum(nengland$X2, na.rm=T),
                               sum(fins_pre1800$name_count, na.rm=T),
                               sum(fins_post1900$name_count, na.rm=T),
                               897934, # US Census Bureau, Delaware population 2010, https://www.census.gov/geographies/reference-files/2010/geo/state-local-geo-guides-2010/delaware.html
                               37253956, # US Census Bureau, California population 2010, https://www.census.gov/geographies/reference-files/2010/geo/state-local-geo-guides-2010/california.html
                               308745538 # US Census Bureau, US population 2010, https://www.census.gov/newsroom/releases/archives/2010_census/cb10-cn93.html
                               )
) 


sum.d <- sum.d %>%
  rbind(tibble(
    region = 'Scottish (1700-1800)',
    `name count` = sum(sum.d$`name count`[sum.d$region %in% c('Dingwall (1700-1800)', 'Earlstone (1700-1800)', 'Govan (1700-1800)', 'Beith (1700-1800)')]),
    `sample` = sum(sum.d$`sample`[sum.d$region %in% c('Dingwall (1700-1800)', 'Earlstone (1700-1800)', 'Govan (1700-1800)', 'Beith (1700-1800)')]),
    `population` = sum(sum.d$`population`[sum.d$region %in% c('Dingwall (1700-1800)', 'Earlstone (1700-1800)', 'Govan (1700-1800)', 'Beith (1700-1800)')]),
    `cut-offs` = 1
  ))  
# sum.d %>%
#   mutate(sample = as.character(sample)) %>%
#   xtable() %>%
#   print(include.rownames=FALSE, digits=0) 

# d = tibble(Korean=krank, `Vietnamese-American`=vietrank,
#            `China-Mainland` = china_mainland_400$number[1:50],
#            `Chinese-American`=abcrank,
#            Taiwan=taiwan$Number[1:50],
#            Beith=beith$X4[1:50], Dingwall=dingwall$X4[1:50], 
#            Govan=govan$X4[1:50], Earlstone=earlstone$X4[1:50],
#            CA=ca$n[1:50], DE= de$n[1:50],
#            `Northern England` = nengland$X2[1:50],
#            FinnsPost1900 = fins_post1900$name_count[1:50],
#            FinnsPre1800 = fins_pre1800$name_count[1:50])
range=nrow(all_us_1910_2010)


d = tibble(`Korea (2015 Census)`=krank[1:range], `Vietnamese-American (2010 Census)`=vietrank[1:range],
           #`China-Mainland` = china_mainland_400$number[1:range],
           `Chinese-American (2010 Census)`=abcrank[1:range],
           `Taiwan (2018 Census)`=taiwan$Number[1:range],
           `Beith (1700-1800)`=beith$X4[1:range], `Dingwall (1700-1800)`=dingwall$X4[1:range], 
           `Govan (1700-1800)`=govan$X4[1:range], `Earlstone (1700-1800)`=earlstone$X4[1:range],
           `California (1910-2010)`=ca$n[1:range], `Delaware (1910-2010)`= de$n[1:range],
           `All USA (1910-2010)` = all_us_1910_2010$freq[1:range] %>% sort() %>% rev(),
           `Northern England (1701-1800)` = nengland$X2[1:range],
           `Finland post-1900` = fins_post1900$name_count[1:range],
           `Finland pre-1800` = fins_pre1800$name_count[1:range])


###################################################
# SI plot pairwise

d$`Scottish (1700-1800)` = rowSums(d[, c("Dingwall (1700-1800)", "Govan (1700-1800)", "Beith (1700-1800)", "Earlstone (1700-1800)")], na.rm = TRUE)
ggplot(d, aes(x=`Korea (2015 Census)`, y=`Vietnamese-American (2010 Census)`)) + geom_point() + 
  theme_classic(12) + 
  geom_smooth(method=lm, se=F) + scale_x_log10() + scale_y_log10()

d.g = d %>%
  gather(variable, value) %>%
  filter(variable %in% c("Northern England (1701-1800)",
                            "Scottish (1700-1800)",
                            "Korea (2015 Census)",
                            "Vietnamese-American (2010 Census)",
                            #"China-Mainland",
                            "Chinese-American (2010 Census)",
                            "Taiwan (2018 Census)",
                            "California (1910-2010)"
                         )) %>%
  distinct() %>% filter(value != 0) %>%
  group_by(variable) %>%
  mutate(r= rank(-value)) 
d.g2 = rename(d.g, variable2 = variable, value2=value)
d.g3 = left_join(d.g, d.g2) 
d.g3 = mutate(d.g3, value = log10(value),
               value2=log10(value2))

for (i in unique(d.g3$variable)) {
p = ggplot(filter(d.g3, variable == i,
              variable2 != i, r != 1), aes(x=value, y=value2)) + geom_point() + 
  theme_bw(12) + 
  facet_grid(variable ~ variable2) + #, scales = "free")  +
  xlab("Log frequency") + ylab("Log frequency")
pdf(paste0("imgs/pairwise_", i, ".pdf"), width=6, height=3)
print(p)
dev.off()
# ggsave(paste0("imgs/", i, ".png"), width=6, height=3)
}


d.g = d %>%
  gather(variable, value) %>%
  filter(variable %in% c("Beith (1700-1800)",
                         "Dingwall (1700-1800)",
                         "Earlstone (1700-1800)",
                         "Govan (1700-1800)")) %>%
  group_by(variable) %>%
  mutate(r= rank(-value)) 
d.g2 = rename(d.g, variable2 = variable, value2=value)
d.g3 = left_join(d.g, d.g2) 
d.g3 = mutate(d.g3, value = log10(value),
              value2=log10(value2))

pdf("imgs/figure6.pdf", width=7, height=8)
ggplot(d.g3, aes(x=value, y=value2)) + geom_point() + 
  theme_bw(12) + 
  #geom_smooth(method=lm, se=F) + 
  scale_x_log10() + scale_y_log10() + 
  facet_grid(variable ~ variable2, scales = "free") +
  xlab("Log frequency") + ylab("Log frequency") 
dev.off()

# ggsave("imgs/scottish_pairwise.png", width=7, height=8)
###################################################


d.sum = gather(d, Locale, value) %>%
  filter(value!=0) %>%
  group_by(Locale) %>%
  mutate(count=value,
          value=value/max(value),
         r = 1:n())

ag2 = ggplot(d.sum %>% 
               filter(r<=100 , !Locale %in% c('All USA (1910-2010)', 'Scottish (1700-1800)')) %>%
               mutate(
                 Locale = factor(Locale,
                                 levels = c("California (1910-2010)", "Delaware (1910-2010)", 
                                            "Vietnamese-American (2010 Census)", "Korea (2015 Census)",
                                            #"China-Mainland", 
                                            "Chinese-American (2010 Census)", "Taiwan (2018 Census)",
                                            "Earlstone (1700-1800)", "Govan (1700-1800)", "Dingwall (1700-1800)", "Beith (1700-1800)",
                                            "Northern England (1701-1800)",
                                            "Finland pre-1800", "Finland post-1900"))
               ), 
             aes(x=r, y=value, group=Locale, colour=Locale)) + 
  geom_line() + 
  geom_point(size=1) +
  ylab("Proportion Relative to Top Name") +
  xlab("Name rank") +
  theme_classic(18) + 
  scale_y_log10() +
  scale_colour_manual(values = c("Vietnamese-American (2010 Census)" =  "#003566", "Korea (2015 Census)" = "#4CC9F0",
                                 #"China-Mainland" = "#134611", 
                                 "Chinese-American (2010 Census)" = '#3DA35D',
                                 "Taiwan (2018 Census)" = "#96E072",
                                 "Earlstone (1700-1800)" = "orange", "Govan (1700-1800)" = "darkorange",
                                 "Dingwall (1700-1800)" = "sienna", "Beith (1700-1800)" = "#BF360C",
                                 "Northern England (1701-1800)" = "#B45F06",
                                 "Finland post-1900" = "darkgray",
                                 "Finland pre-1800" = "gray",
                                 "California (1910-2010)" = "red",
                                 "Delaware (1910-2010)" = "pink"))

pdf('imgs/proportion_relative_to_top.pdf', width=10, height=6)
ag2
dev.off()

save(ag2, file='Data/fig_proportion_relative_to_top.RData')
  # ggsave("imgs/proportion_relative_to_top.png", width=8, height=4)

# get entropies
ents = group_by(d.sum, Locale) %>%
  mutate(locale.sum = sum(value),
         prob = value/locale.sum) %>%
  summarise(ent=-sum(prob*log2(prob)))


# estimating the higher end of the entropy: assuming the rest of the population has their unique prefix-name

ents_higher_bound <- d.sum %>% 
  left_join(sum.d %>%
              mutate(sample = as.numeric(sample)), by = c('Locale'='region')) %>%
  group_by(Locale, population, sample) %>%
  mutate(prob_population = count/population) %>%
  summarise(ent1 = -sum(prob_population*log2(prob_population))) %>%
  mutate(ent_higher_bound = ent1 + (population-sample)*(log2(population)/population)) %>% ungroup()
  


ents %>% 
  left_join(sum.d %>%
              mutate(sample = as.character(sample)), by = c('Locale'='region')) %>% 
  left_join(ents_higher_bound %>% dplyr::select(Locale, ent_higher_bound), by='Locale') %>%
  mutate(`name entropy` = ent,
         `name entropy higher estimate` = ent_higher_bound) %>%
  dplyr::select(Locale, `name count`, `cut-offs`, sample, `name entropy`, `name entropy higher estimate`) %>%
  arrange(-`name entropy higher estimate`) %>%
  rename(`higher bound (bits)` =`name entropy higher estimate`,
         `lower bound (bits)` = `name entropy`) %>%
  xtable() %>%
  print(include.rownames=FALSE, digits=0)










