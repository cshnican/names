library(tidyverse)
library(xtable)

korea = read_csv('Data/Korea/korea_2015_hanja.csv') %>%
  filter(`성씨, 본관별`!='전국')
vietnamese_american = read_csv('Data/Vietnam (US 2010)/vietnamese_american_data.csv')
vietnamese_american$asian.count = vietnamese_american$count * vietnamese_american$pctapi/100
krank = rev(sort(korea$`2015`))
vietrank = rev(sort(vietnamese_american$asian.count))
taiwan = read_csv('Data/Chinese_name_data/taiwan_2018.csv')

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
                          "Taiwan (2018 Census)",
                          "Beith (1700-1800)", "Govan (1700-1800)", "Dingwall (1700-1800)", "Earlston (1700-1800)",
                          "Northern England (1701-1800)",
                          "Finland pre-1800", "Finland post-1900",
                          "Delaware (1910-2010)", "California (1910-2010)", "All USA (1910-2010)"),
              `name count` = c(length(unique(korea$`성씨, 본관별`)),
                                length(unique(vietnamese_american$name)),
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
              
              `population` = c(51069000, # Statistics Korea, Korean Census 2015, https://kostat.go.kr/board.es?mid=a20107020000&bid=11739&tag=&act=view&list_no=420179&ref_bid=&keyField=&keyWord=&nPage=1
                               1548449, # US Census Bureau, Vietnamese American population 2010, https://www.census.gov/content/dam/Census/library/publications/2012/dec/c2010br-11.pdf
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
    `name count` = sum(sum.d$`name count`[sum.d$region %in% c('Dingwall (1700-1800)', 'Earlston (1700-1800)', 'Govan (1700-1800)', 'Beith (1700-1800)')]),
    `sample` = sum(sum.d$`sample`[sum.d$region %in% c('Dingwall (1700-1800)', 'Earlston (1700-1800)', 'Govan (1700-1800)', 'Beith (1700-1800)')]),
    `population` = sum(sum.d$`population`[sum.d$region %in% c('Dingwall (1700-1800)', 'Earlston (1700-1800)', 'Govan (1700-1800)', 'Beith (1700-1800)')]),
    `cut-offs` = 1
  ))  

range=nrow(all_us_1910_2010)


d = tibble(`Korea (2015 Census)`=krank[1:range], `Vietnamese-American (2010 Census)`=vietrank[1:range],
           `Taiwan (2018 Census)`=taiwan$Number[1:range],
           `Beith (1700-1800)`=beith$X4[1:range], `Dingwall (1700-1800)`=dingwall$X4[1:range], 
           `Govan (1700-1800)`=govan$X4[1:range], `Earlston (1700-1800)`=earlstone$X4[1:range],
           `California (1910-2010)`=ca$n[1:range], `Delaware (1910-2010)`= de$n[1:range],
           `All USA (1910-2010)` = all_us_1910_2010$freq[1:range] %>% sort() %>% rev(),
           `Northern England (1701-1800)` = nengland$X2[1:range],
           `Finland post-1900` = fins_post1900$name_count[1:range],
           `Finland pre-1800` = fins_pre1800$name_count[1:range])


# ====================
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
                                            "Taiwan (2018 Census)",
                                            "Earlston (1700-1800)", "Govan (1700-1800)", "Dingwall (1700-1800)", "Beith (1700-1800)",
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
                                 "Taiwan (2018 Census)" = "#96E072",
                                 "Earlston (1700-1800)" = "orange", "Govan (1700-1800)" = "darkorange",
                                 "Dingwall (1700-1800)" = "sienna", "Beith (1700-1800)" = "#BF360C",
                                 "Northern England (1701-1800)" = "#B45F06",
                                 "Finland post-1900" = "darkgray",
                                 "Finland pre-1800" = "gray",
                                 "California (1910-2010)" = "red",
                                 "Delaware (1910-2010)" = "pink"))


save(ag2, file='Data/fig_proportion_relative_to_top.RData')
ggsave("imgs/proportion_relative_to_top.png", plot=ag2, width=10, height=6)

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










