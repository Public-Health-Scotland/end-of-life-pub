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

# Join SMR01, SMR50 and SMR04 data
smr <-
  bind_rows(smr01, smr04)


### 5 - Calculate measure ----

smr %<>%
  
  # Calculate date six months before death
  mutate(six_months = date_of_death - days(183)) %>%
  
  # For stays spanning this date, fix admission date to six months before death
  mutate(admission_date = if_else(admission_date < six_months & discharge_date >= six_months,
                                  six_months,
                                  admission_date)) %>%
  
  # Select only stays within last six months of life
  filter(admission_date >= six_months) %>%
  
  # Remove records where admission date is after date of death
  filter(admission_date <= date_of_death) %>%
  
  # Where dis date is after date of death, fix to date of death
  mutate(discharge_date = if_else(discharge_date > date_of_death,
                                  date_of_death,
                                  discharge_date)) %>%
  
  # Calculate length of stay
  mutate(los = time_length(interval(admission_date,
                                    discharge_date),
                           "days")) %>%

  # Aggregate to patient level
  group_by(link_no) %>%
  summarise(los = sum(los))


### END OF SCRIPT ###