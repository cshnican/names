# Cross-cultural structures of personal name systems reflect general communicative principles
Michael Ramscar, Sihan Chen, Richard Futrell, Kyle Mahowald

This Github repository contains the data, the analysis script, and the figures in the paper.

## A description of the repository content
Note: as mentioned in the paper, we call the element in a personal that goes first *prefix-name* and the element that goes second *byname*. For example, in the name *John Smith*, *John* is the prefix-name and *Smith* is the byname. In the name *Li Xiaoping*, *Li* is the prefix-name and *Xiaoping* is the byname.

### Scripts
To reproduce all the main figures, run `prediction1.R`, `prediction2.R`, `prediction3.R` first, and then run `plot_merged_figs.R`
- `prediction1.R`: code for the first analysis 
- `prediction2.R`: code for the second analysis, generating Figure 3
- `prediction3.R`: code for the third analysis
- `plot_merged_figs.R`: code to generate multi-panel figures (Figure 2 and Figure 4)


### Data
This folder contains the data in our analysis:
- `Chinese (US 2010)`: containing the file `chinese_american_data.csv`, a subset of Chinese-American bynames pulled from the US 2010 Census
- `Chinese_name_data`: a folder containing the raw files related to Chinese names
    - `chinese_surnames_400.csv`: a list of 400 most common prefix-names in Mainland China. The data is taken from [Wikipedia](https://en.wikipedia.org/wiki/List_of_common_Chinese_surnames#Surname_list). 
    - `taiwan_2018.csv`: a list of 500 most common Taiwanese prefix-names. The data is manually extracted from the 2018 population census conducted by the Taiwanese Ministry of Interior ([link](https://www.ris.gov.tw/documents/data/5/2/107namestat.pdf). See Table 57, pp.282-304).
    - `taiwan_givenname.csv`; a list of 100 most common Taiwanese men bynames and 100 most common Taiwanese women bynames. The data is manually extracted from the 2018 population census conducted by the Taiwanese Ministry of Interior ([link](https://www.ris.gov.tw/documents/data/5/2/107namestat.pdf). See Table 51).
- `Korea`: a folder containing the raw files related to Korean names
    - `korea_2015_hanja`: a list of Korean prefix-names with a population greater than 5. The data is taken from the 2015 population census data published by Korean Statistical Information Service ([link](https://kosis.kr/statHtml/statHtml.do?orgId=101&tblId=DT_1IN15SD&conn_path=I2))
- `Scotland`: prefix-names from four pre-modern Scottish parishes for the period between 1700-1800, extracted by Alice Crook (2012) from the National Records of Scotland (https://www.nrscotland.gov.uk/). This data is contained as an appendix of Crook's MPhil Thesis work [Crook, Alice Louise (2012) Personal naming patterns in Scotland, 1700 - 1800: a comparative study of the parishes of Beith, Dingwall, Earlston, and Govan. MPhil(R) thesis]. The thesis is publically available [here](https://theses.gla.ac.uk/4190/1/2012crookmphil.pdf)
    - `2012crookmphil.pdf`: a copy of Crook's thesis
    - `beith.csv`, `beith.xlsx`: prefix-name distribution in Beith
    - `dingwall.csv`, `dingwall.xlsx`: prefix-name distribution in Dingwall
    - `earlstone.csv`, `earlstone.xlsx`: prefix-name distribution in Earlstone
    - `govan.csv`, `govan.xlsx`: prefix-name distribution in Govan
    - `scot_source_info.txt`: a .txt file summarizing the content above
- `US_census_all`: US baby name data, a dataset published by the Social Security Administration. The dataset is downloaded from [here](https://www.ssa.gov/oact/babynames/limits.html) (see `State-specific data`).
    - `AK.txt`, ..., `WY.txt`: the data in each state and DC
    - `StateReadMe.pdf`: a pdf describing the dataset
- `Vietnam (US 2010)`: containing the file `vietnamese_american_data.csv`, a subset of Vietnamese-American bynames pulled from the US 2010 Census
- `us_census_name_2010`: a folder containing the byname data from the 2020 US Census, downloaded from the US Census Bureau ([link](https://www.census.gov/topics/population/genealogy/data/2010_surnames.html))
    - the file used in this study is `./surnames_appearing_more_than_100_times/Names_2010Census.csv`.
- `us_population_change`: containing the file `population_change_data.csv`, a dataset containing the population census data in each state (plus DC and Puerto Rico) every 10 years. The dataset is downloaded from [here](https://www2.census.gov/programs-surveys/decennial/2020/data/apportionment/population-change-data-table.xlsx)
- `CA.txt`, `DE.txt`: copies of the same two files from the `us_census_all` folder - baby name data from California (the most populous US state) and Delaware (one of the least populous US states)
- `downsampled_scinames.csv` (not available): a list of 2550 scientist names from the national academy of 6 countries (we sampled 425 names from each)
    - 425 names from the National Academy of Sciences (USA) [link](https://en.wikipedia.org/wiki/List_of_members_of_the_National_Academy_of_Sciences)
    - 425 names from the Chinese Academy of Sciences [link](https://en.wikipedia.org/wiki/List_of_members_of_the_Chinese_Academy_of_Sciences)
    - 425 names from the French Academy of Sciences [link](https://en.wikipedia.org/wiki/Category:Members_of_the_French_Academy_of_Sciences)
    - 425 names from the Finnish Academy of Science and Letters [link](https://acadsci.fi/jasenet/kotimaiset-jasenet/)
    - 425 names from the Russian Academy of Sciences [link](https://www.ras.ru)
    - 425 names from the Korean National Academy of Science [link](http://www.nas.go.kr/page/567dff03-b5f6-43e2-8131-bf67bdc9d530) 
- `english-names-pop.csv`: the population of England between 1801 and 1901 and the portion of population having the 3 most popular prefix-names in each gender.
    - the population data is taken from (populationdata.org.uk)[populationdata.org.uk]
    - the prefix-name data is taken from Table 1 in Douglas A Galbi. ‘Long-term trends in personal given name frequencies in the UK’. Available at SSRN 366240 (2002). 
- `etunimitilasto-2023-08-01-dvv.csv`, `etunimitilasto-2023-08-01-dvv.xlsx`: Finnish prefix-name data in 2023, downloaded from the Population Information System [link](https://www.avoindata.fi/data/fi/dataset/none/resource/08c89936-a230-42e9-a9fc-288632e234f5) (Notice: at the time of the analysis, the latest version was 2023-08-01. The dataset may have been updated now.)
- `exp3plots.RData`, `fig_population_relative_to_top.RData`, `plots_from_byname_analysis.RData`: RData files generated by R scripts, in order to make multi-panel figures.
- `northern_england.csv`: names from two pre-modern English counties for the period between 1700 and 1800. Extracted from George Bell’s parish marriage register transcriptions for Northumberland and Durham between 1701 and 1800 [link](https://www.galbithink.org/names/ncumb.txt)
- `plot_dupes_helper.csv`: scientist names indexed in different styles, as an illustration (Figure 4b).
- `sukunimitilasto-2023-08-01-dvv.csv`, `sukunimitilasto-2023-08-01-dvv.xlsx`: Finnish byname data in 2023, downloaded from the Population Information System [link](https://www.avoindata.fi/data/fi/dataset/none/resource/957d19a5-b87a-4c4d-8595-49c22d9d3c58?inner_span=True) (Notice: at the time of the analysis, the latest version was 2023-08-01. The dataset may have been updated now.)


