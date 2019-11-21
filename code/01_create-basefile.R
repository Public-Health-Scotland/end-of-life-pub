#########################################################################
# Name of file - 01_create-basefile.R
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

source(here::here("code", "smra_connect.R"))


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
                                   external_causes = external,
                                   gls = FALSE))) %>% 
  
  bind_rows(as_tibble(dbGetQuery(smra_connect, 
                                 smr01_query(extract_start = start_date,
                                             extract_end = end_date,
                                             external_causes = external,
                                             gls = TRUE)))) %>%
  
  clean_names()


smr04 <- 
  as_tibble(dbGetQuery(smra_connect, 
                       smr04_query(extract_start = start_date,
                                   extract_end = end_date,
                                   external_causes = external))) %>% 
  clean_names()


### 4 - Save data extracts ----

write_rds(deaths, 
          here("data", "extracts", glue("{pub_date}_deaths.rds")),
          compress = "gz")
write_rds(smr01,
          here("data", "extracts", glue("{pub_date}_smr01.rds")),
          compress = "gz")
write_rds(smr04,
          here("data", "extracts", glue("{pub_date}_smr04.rds")),
          compress = "gz")


### 5 - Aggregate SMR data to CIS level ----

smr01 %<>%
  group_by(link_no) %>%
  arrange(admission_date) %>%
  mutate(index = c(0, cumsum(lead(ch_flag) != ch_flag | 
                               lead(gls_cis_marker) != gls_cis_marker)[-n()])) %>%
  filter(ch_flag == 0) %>%
  group_by(link_no, index) %>%
  summarise(admission_date = min(admission_date),
            discharge_date = max(discharge_date),
            date_of_death = max(date_of_death)) %>%
  ungroup() %>%
  select(-index)

smr04 %<>%
  group_by(link_no) %>%
  arrange(admission_date) %>%
  mutate(index = c(0, cumsum(lead(ch_flag) != ch_flag | 
                               lead(cis_marker) != cis_marker)[-n()])) %>%
  filter(ch_flag == 0) %>%
  group_by(link_no, index) %>%
  summarise(admission_date = min(admission_date),
            discharge_date = max(discharge_date),
            date_of_death = max(date_of_death)) %>%
  ungroup() %>%
  select(-index)


### 6 - Join SMR01/50 and SMR04 data ----

smr <-
  
  bind_rows(smr01 %>% mutate(recid = "01"), 
            smr04 %>% mutate(recid = "04")) %>%
  
  # Aggregate where SMR01 and SMR04 stays overlap
  group_by(link_no) %>%
  arrange(admission_date) %>%
  mutate(index = c(0, cumsum(as.numeric(lead(admission_date)) >
                               cummax(as.numeric(discharge_date)))[-n()])) %>%
  group_by(link_no, index) %>%
  summarise(admission_date = min(admission_date),
            discharge_date = max(discharge_date),
            date_of_death  = max(date_of_death)) %>%
  ungroup() %>%
  select(-index)


### 7 - Calculate measure ----

smr %<>%
  
  # Calculate date six months before death
  mutate(six_months = date_of_death - days(183)) %>%
  
  # For stays spanning this date, fix admission date to six months before death
  mutate(admission_date = if_else(admission_date < six_months & 
                                    discharge_date >= six_months,
                                  six_months,
                                  admission_date)) %>%
  
  # Select only stays within last six months of life
  filter(admission_date >= six_months) %>%
  
  # Remove records where admission date is after date of death
  filter(admission_date <= date_of_death) %>%
  
  # Where discharge date is after date of death, fix to date of death
  mutate(discharge_date = if_else(discharge_date > date_of_death,
                                  date_of_death,
                                  discharge_date)) %>%
  
  # Calculate length of stay
  mutate(los = time_length(interval(admission_date, discharge_date),
               "days")) %>%

  # Aggregate to patient level
  group_by(link_no) %>%
  summarise(los = sum(los)) %>%
  ungroup() %>%
  
  # Recode 183 LOS to 182.5 (exact six months)
  mutate(los = if_else(los == 183, 182.5, los))


### 8 - Match on lookup files to deaths

deaths %<>%
  
  left_join(postcode(), by = c("postcode" = "pc7")) %>%
  left_join(simd(), by = c("postcode" = "pc7")) %>%
  left_join(locality(), by = "data_zone2011")


### 9 - Create final file

final <-
  
  left_join(deaths, smr, by = "link_no") %>%
  
  group_by(fy, quarter, hb, hbcode, ca, cacode, hscp, hscpcode,
           ca2018, hscp2018, locality, simd, simd_15, sex, age_grp, 
           urban_rural, urban_rural_2) %>%
  
  summarise(los = sum(los, na.rm = TRUE),
            deaths = n()) %>%
  
  ungroup()


write_rds(final, 
          here("data", "basefiles", glue("{pub_date}_base-file.rds")),
          compress = "gz")
  

### END OF SCRIPT ###