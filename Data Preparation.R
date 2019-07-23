##################################################################
## Name of File: End of Life All Activity                       ##
## Original Authors : Federico Centoni/Alice Byers              ##
## Originally written: November 2018                            ##                      
## Latest Update Date: 23/07/2019.                              ##
## Written/run on : R Studio Server                             ##
## R version:                                                   ##
## Package version:                                             ##
## Description: Outputs All Activity file to the patient level  ##
##              for use in EOL publication                      ##
##################################################################



###################################
## SECTION 1 - HOUSEKEEPING      ##
###################################

install.packages("readxl")
install.packages("here")
install.packages("readr")
install.packages("dplyr")
install.packages("tidyr")
install.packages("odbc")
install.packages("janitor")

## 1. Load packages ##

library(odbc)      # for accessing SMRA
library(dplyr)     # functions for 'tidy' data wrangling
library(haven)     # read and write spss files
library(lubridate) # functions for use with dates
library(magrittr)  # for %<>% operator
library(tidyverse)
library(janitor)   
library(tictoc)


## 2. Define dates ##

extract_date <- "_extracted_22072019"

start_date        <- "2009-10-01"  # start date for SMR01 and SMR50 extracts
end_date          <- "2018-03-31"  # end date for SMR01 and SMR50 extracts
deaths_start_date <- "2010-04-01"  # start date for deaths extract

## 3. Set filepaths ##

# Output filepath
output <- "/PHI_conf/irf/EOL_Publication/Data preparation/RAP/Data Preparation/"

# Lookup filepaths
pc_lookup   <- "/conf/linkage/output/lookups/Unicode/Geography/
                Scottish Postcode Directory/
                Scottish_Postcode_Directory_2019_1.5.sav"
simd_lookup <- "/conf/linkage/output/lookups/Unicode/Deprivation/
                postcode_2019_1.5_simd2016.sav"
locality    <- "/isdsf00d03/cl-out/lookups/Unicode/Geography/HSCP Locality/
                HSCP Localities_DZ11_Lookup_20180903.sav"

# SMRA connection
SMRA <- suppressWarnings(dbConnect(odbc(), dsn = "SMRA",
                                   uid = .rs.askForPassword("SMRA Username:"),
                                   pwd = .rs.askForPassword("SMRA Password:")))

## 4. Define external causes of death ##

external <- c(paste0("V", 0, 1:9), paste0("V", 10:99),
              paste0("W", 20:99),
              paste0("X", 0, 0:9), paste0("X", 10:99),
              paste0("Y", 0, 0:9), paste0("Y", 10:84))



######################################
## SECTION 2 - Data extraction      ##
######################################



## 1. SMR01 extract ##
Query_SMR01 <- paste0("select link_no, gls_cis_marker, admission_date, 
                       discharge_date, sex, ",
                      "inpatient_daycase_identifier from SMR01_PI ",
                      "where discharge_date >= {d '", start_date, "'} 
                       AND discharge_date <= {d '", end_date, "'} ",
                      "ORDER BY link_no, cis_marker, admission_date, 
                       discharge_date, admission, discharge, uri")

data_01 <- as_tibble(dbGetQuery(SMRA, Query_SMR01)) %>%
           mutate(recid = "SMR01") %>% clean_names()


## 2. SMR50 extract ##
Query_SMR50 <- paste0("select link_no, gls_cis_marker, admission_date, 
                       discharge_date, sex, ",
                      "inpatient_daycase_identifier from ANALYSIS.SMR01_1E_PI ",
                      "where discharge_date >= {d '", start_date, "'} 
                       AND discharge_date <= {d '", end_date, "'} ",
                      "ORDER BY link_no, cis_marker, admission_date, 
                       discharge_date, admission, discharge, uri")

data_50  <- as_tibble(dbGetQuery(SMRA, Query_SMR50)) %>%
            mutate(recid = "SMR50") %>% clean_names()


## 3. SMR04 extract ##
Query_SMR04 <- paste("select link_no, cis_marker, admission_date, 
                      discharge_date, sex,",
                     "management_of_patient from ANALYSIS.SMR04_PI ",
                     "WHERE management_of_patient IN ('1', '3', '5', '7', 'A')",
                     "ORDER BY link_no, cis_marker, admission_date, 
                      discharge_date, admission, discharge, uri")

data_04 <- as_tibble(dbGetQuery(SMRA, Query_SMR04)) 
data_04 %<>% filter(DISCHARGE_DATE >= "2009-10-01" & 
                    DISCHARGE_DATE < "2018-03-31") %>% drop_na() %>%
                    mutate(recid = "SMR04") %>% clean_names()


## 4. Deaths extract ##
Query_Deaths <- paste0("select link_no, date_of_death, institution, sex, ",
                       "underlying_cause_of_death, cause_of_death_code_0, ",
                       "cause_of_death_code_1, cause_of_death_code_2, ",
                       "cause_of_death_code_3, cause_of_death_code_4, ",
                       "cause_of_death_code_5, cause_of_death_code_6, ",
                       "cause_of_death_code_7, cause_of_death_code_8, ",
                       "cause_of_death_code_9 ",
                       "from ANALYSIS.GRO_DEATHS_C ",
                       "where date_of_death >= {d '", deaths_start_date, "'}")

data_deaths  <- as_tibble(dbGetQuery(SMRA, Query_Deaths)) %>%
                mutate(recid = "Deaths") %>% clean_names()


#######################################
## SECTION 3 - Data preparation      ##
#######################################


# 1. Create SMR activity file (SMR01_50)

smr01_50 <- rbind(data_01,data_50) %>% 
  
# 2. Select only inpatient_day case
  
filter(inpatient_daycase_identifier == "I") %>% 
  
# 3. Aggregate to CIS level. Record first admission and last discharge dates.
  
group_by(link_no,gls_cis_marker) %>% 
                                 summarise(admission_date = min(admission_date), 
                                 discharge_date = max(discharge_date)) %>% 
                                 ungroup() 

### Duplicates Removal ###

#### SMR01_50 ####

# Aggregate to link_no and gls_cis_marker to get rid of duplicated rows. 
smr01_50_final <- smr01_50 %>% group_by(link_no, gls_cis_marker) 
                            
#### SMR04 ####

# Aggregate to link_no and gls_cis_marker to get rid of duplicated rows. 
smr04_final <- data_04 %>% group_by(link_no, cis_marker)
                               
                  
             
                         



