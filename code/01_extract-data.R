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

smra_connect <- 
  suppressWarnings(
     dbConnect(odbc(), 
               dsn = "SMRA",
               uid = .rs.askForPassword("SMRA Username:"),
               pwd = .rs.askForPassword("SMRA Password:")))


### 3 - Deaths extract

deaths_query <- 
  
  glue("select link_no, date_of_death, postcode, ",
       
       "case when age between 0 and 54 then '0-54' ",
       "when age between 55 and 64 then '55-64' ",
       "when age between 65 and 74 then '65-74' ",
       "when age between 75 and 84 then '75-84' ",
       "when age >= 85 then '85+' ",
       "else 'null' ",
       "end age_grp, ",
       
       "case when sex = '1' then 'Male' ",
       "when sex = '2' then 'Female' ",
       "else 'null' ",
       "end sex, ",
       
       "to_char(date_of_death, 'Q') as quarter, ",
       "extract(year from date_of_death) as year ",
       
       "from analysis.gro_deaths_c ",
       
       "where {{fn left(underlying_cause_of_death, 3)}} not in ",
       "({paste0(shQuote(external, type = 'sh'), collapse = ',')}) ",
       
       "and (date_of_death between ",
       "to_date({shQuote(start_date, type = 'sh')}, 'yyyy-mm-dd') ",
       "and to_date({shQuote(end_date, type = 'sh')}, 'yyyy-mm-dd'))"
  )

deaths <- as_tibble(dbGetQuery(smra_connect, deaths_query)) %>% 
  clean_names()


### 4 - SMR01 extract

smr01_query <- 
  
  glue(
    "select s.link_no, s.gls_cis_marker, s.cis_marker, ",
    "s.admission_date, s.discharge_date, d.date_of_death ",
    
    "from analysis.smr01_pi s, analysis.gro_deaths_c d ",
    
    "where s.link_no = d.link_no ",
    
    "and s.inpatient_daycase_identifier = 'I' ",
    
    "and s.discharge_date between ",
    "to_date({shQuote(smr_start_date, type = 'sh')}, 'yyyy-mm-dd') ",
    "and to_date({shQuote(end_date, type = 'sh')}, 'yyyy-mm-dd') ",
    
    "and {{fn left(d.underlying_cause_of_death, 3)}} not in ",
    "({paste0(shQuote(external, type = 'sh'), collapse = ',')}) ",
    
    "and (d.date_of_death between ",
    "to_date({shQuote(start_date, type = 'sh')}, 'yyyy-mm-dd') ",
    "and to_date({shQuote(end_date, type = 'sh')}, 'yyyy-mm-dd'))"
    
  )

smr01 <- as_tibble(dbGetQuery(smra_connect, smr01_query)) %>% 
  clean_names()


### 5 - SMR50 extract

smr50_query <- 
  
  glue(
    "select s.link_no, s.gls_cis_marker, ",
    "s.admission_date, s.discharge_date, d.date_of_death ",
    
    "from analysis.smr01_1e_pi s, analysis.gro_deaths_c d ",
    
    "where s.link_no = d.link_no ",
    
    "and s.inpatient_daycase_identifier = 'I' ",
    
    "and s.discharge_date between ",
    "to_date({shQuote(smr_start_date, type = 'sh')}, 'yyyy-mm-dd') ",
    "and to_date({shQuote(end_date, type = 'sh')}, 'yyyy-mm-dd') ",
    
    "and {{fn left(d.underlying_cause_of_death, 3)}} not in ",
    "({paste0(shQuote(external, type = 'sh'), collapse = ',')}) ",
    
    "and (d.date_of_death between ",
    "to_date({shQuote(start_date, type = 'sh')}, 'yyyy-mm-dd') ",
    "and to_date({shQuote(end_date, type = 'sh')}, 'yyyy-mm-dd'))"
    
  )

smr50 <- as_tibble(dbGetQuery(smra_connect, smr50_query)) %>% 
  clean_names()


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