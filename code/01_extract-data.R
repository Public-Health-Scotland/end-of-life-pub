#########################################################################
# Name of file - 01_extract-data.R
# Data release - End of Life Publication
# Original Authors - Alice Byers
# Orginal Date - August 2019
#
# Written/run on - RStudio Server
# Version of R - 3.2.3
#
# Description - Extract data from SMRA.
#
# Approximate run time - xx minutes
#########################################################################


### 1 - Load environment file and functions ----

source(here::here("code", "00_setup-environment.R"))


### 2 - Open SMRA Connection

SMRA_connect <- 
  suppressWarnings(
     dbConnect(odbc(), 
               dsn = "SMRA",
               uid = .rs.askForPassword("SMRA Username:"),
               pwd = .rs.askForPassword("SMRA Password:")))


### 3 - Deaths query

deaths <- 
  
  tbl(SMRA_connect,
      dbplyr::in_schema("ANALYSIS", "GRO_DEATHS_C")) %>%
  
  filter(DATE_OF_DEATH >= To_date(start_date, "YYYY-MM-DD") &
         DATE_OF_DEATH <= To_date(end_date, "YYYY-MM-DD")) %>%
  
  filter(!(UNDERLYING_CAUSE_OF_DEATH %in% external)) %>%
  
  select(LINK_NO, DATE_OF_DEATH, AGE, SEX, POSTCODE)


### 4 - SMR01 query

smr01 <-
  
  tbl(SMRA_connect, 
      dbplyr::in_schema("ANALYSIS", "SMR01_PI")) %>%
  
  filter(ADMISSION_DATE >= To_date(smr_start_date, "YYYY-MM-DD") &
         DISCHARGE_DATE <= To_date(end_date,   "YYYY-MM-DD")) %>%
  
  filter(INPATIENT_DAYCASE_IDENTIFIER == "I") %>%
  
  arrange(LINK_NO, GLS_CIS_MARKER, CIS_MARKER, ADMISSION_DATE, 
          DISCHARGE_DATE, ADMISSION, DISCHARGE, URI) %>% 
  
  inner_join(deaths, by = "LINK_NO") %>%
  
  select(LINK_NO, GLS_CIS_MARKER, CIS_MARKER, 
         ADMISSION_DATE, DISCHARGE_DATE, DATE_OF_DEATH)


### 5 - SMR50 query

smr50 <-
  
  tbl(SMRA_connect, 
      dbplyr::in_schema("ANALYSIS", "SMR01_1E_PI")) %>%
  
  filter(ADMISSION_DATE >= To_date(smr_start_date, "YYYY-MM-DD") &
         DISCHARGE_DATE <= To_date(end_date,   "YYYY-MM-DD")) %>%
  
  filter(INPATIENT_DAYCASE_IDENTIFIER == "I") %>%
  
  arrange(LINK_NO, GLS_CIS_MARKER, ADMISSION_DATE, 
          DISCHARGE_DATE, ADMISSION, DISCHARGE, URI) %>% 
  
  inner_join(deaths, by = "LINK_NO") %>%
  
  select(LINK_NO, GLS_CIS_MARKER, ADMISSION_DATE, 
         DISCHARGE_DATE, DATE_OF_DEATH)


### 6 - SMR04 query

smr04 <-
  
  tbl(SMRA_connect, 
      dbplyr::in_schema("ANALYSIS", "SMR04_PI")) %>%
  
  filter(ADMISSION_DATE >= To_date(smr_start_date, "YYYY-MM-DD") &
         (DISCHARGE_DATE <= To_date(end_date,   "YYYY-MM-DD") |
            is.na(DISCHARGE_DATE))) %>%
  
  filter(MANAGEMENT_OF_PATIENT %in% c("1", "3", "5", "7", "A")) %>%
  
  arrange(LINK_NO, CIS_MARKER, ADMISSION_DATE, 
          DISCHARGE_DATE, ADMISSION, DISCHARGE, URI) %>% 
  
  inner_join(deaths, by = "LINK_NO") %>%
  
  select(LINK_NO, CIS_MARKER, ADMISSION_DATE, 
         DISCHARGE_DATE, DATE_OF_DEATH)


### 5 - Extract data
  
smr01  %<>% collect() %>% clean_names()
smr50  %<>% collect() %>% clean_names()
smr04  %<>% collect() %>% clean_names()
deaths %<>% collect() %>% clean_names()


### END OF SCRIPT ###