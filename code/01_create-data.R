#########################################################################
# Name of file - 01_create-data.R
# Data release - End of Life Publication
# Original Authors - Alice Byers
# Orginal Date - September 2019
#
# Written/run on - RStudio Server
# Version of R - 3.2.3
#
# Description - Create base file.
#
# Approximate run time - xx minutes
#########################################################################


### 1 - Setup environment and load functions ----

source(here::here("code", "00_setup-environment.R"))
source(here::here("functions", "sql_queries.R"))


### 2 - Open SMRA Connection ----

smra_connect <- 
  suppressWarnings(
    dbConnect(odbc(), 
              dsn = "SMRA",
              uid = .rs.askForPassword("SMRA Username:"),
              pwd = .rs.askForPassword("SMRA Password:")))


### 3 - Extract data ----

deaths <- 
  as_tibble(dbGetQuery(smra_connect, 
                       deaths_query(extract_start = start_date,
                                    extract_end = end_date,
                                    external_causes = external))) %>% 
  clean_names()


smr01 <- 
  
  as_tibble(dbGetQuery(smra_connect, 
                       smr01_query(extract_start = start_date,
                                   extract_end = end_date,
                                   extract_start_smr = smr_start_date,
                                   external_causes = external,
                                   gls = FALSE))) %>% 
  
  bind_rows(as_tibble(dbGetQuery(smra_connect, 
                                 smr01_query(extract_start = start_date,
                                             extract_end = end_date,
                                             extract_start_smr = smr_start_date,
                                             external_causes = external,
                                             gls = TRUE)))) %>%
  
  clean_names()


smr04 <- 
  as_tibble(dbGetQuery(smra_connect, 
                       smr04_query(extract_start = start_date,
                                   extract_end = end_date,
                                   extract_start_smr = smr_start_date,
                                   external_causes = external))) %>% 
  clean_names()


### 4 - Aggregate SMR data to CIS level and join ----

smr01 %<>%
  group_by(link_no, gls_cis_marker) %>%
  summarise(admission_date = min(admission_date),
            discharge_date = max(discharge_date),
            date_of_death  = max(date_of_death)) %>%
  ungroup() %>%
  select(-gls_cis_marker)

smr04 %<>%
  
  # Use date of death as proxy where discharge date is missing
  mutate(discharge_date = if_else(is.na(discharge_date), 
                                  date_of_death, 
                                  discharge_date)) %>%
  
  group_by(link_no, cis_marker) %>%
  summarise(admission_date = min(admission_date),
            discharge_date = max(discharge_date),
            date_of_death  = max(date_of_death)) %>%
  ungroup() %>%
  select(-cis_marker)
  
smr <-
  bind_rows(smr01, smr04)


### END OF SCRIPT ###