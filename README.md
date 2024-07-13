# Cross-cultural structures of personal name systems reflect general communicative principles
Michael Ramscar, Sihan Chen, Richard Futrell, Kyle Mahowald

This Github repository contains the data, the analysis script, and the figures in the paper.

## A description of the repository content
Note: as mentioned in the paper, we call the element in a personal that goes first *prefix-name* and the element that goes second *byname*. For example, in the name *John Smith*, *John* is the prefix-name and *Smith* is the byname. In the name *Li Xiaoping*, *Li* is the prefix-name and *Xiaoping* is the byname.

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

