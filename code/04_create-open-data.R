#########################################################################
# Name of file - 03_create-open-data.R
# Data release - End of Life Publication
# Original Authors - Alice Byers
# Orginal Date - October 2019
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Create data files for upload to open data platform.
#
# Approximate run time - xx minutes
#########################################################################


### 1 - Setup environment and load functions ----

source(here::here("code", "00_setup-environment.R"))
source(here::here("functions", "summarise_data.R"))


### 2 - Read in basefile ----

basefile <- read_rds(here("data", "basefiles", 
                          glue("{pub_date}_base-file.rds")))


### 3 - Scotland/Health Board file ----

hb <- 
  
  basefile %>%
  summarise_data(hb = "S29000003",
                 
                 include_years = "all",
                 format_numbers = FALSE) %>%
  
  bind_rows(
    basefile %>%
      summarise_data(hb = hbcode,
                     include_years = "all",
                     format_numbers = FALSE)
  ) %>%
  
  # Add qualifier code; p = provisional, d = dervied/aggregate
  mutate(dataset_qf = 
           if_else(pub_type == "provisional" & 
                     fy == max(.$fy),
                   if_else(hb == "S29000003",
                           "p,d",
                           "p"),
                   "")
  ) %>%
  
  # Reorder variables
  select(fy, hb, dataset_qf, everything()) %>%
  
  # Rename variables in camel case
  rename(FinancialYear = fy,
         HB2014 = hb,
         PercentageSpentInHomeCommunity = qom,
         PercentageSpentInHospital = qom_hosp,
         NumberOfDeaths = deaths,
         AverageDaysInCommunity = comm,
         AverageDaysInHospital = hosp,
         DatasetQF = dataset_qf)


#### 4 - HSCP file ----

hscp <-
  
  basefile %>% 
  summarise_data(hscp = hscpcode,
                 include_years = "all",
                 format_numbers = FALSE) %>%
  mutate(dataset_qf = if_else(pub_type == "provisional" & 
                                fy == max(.$fy),
                              "p", "")) %>%
  
  # Reorder variables
  select(fy, hscp, dataset_qf, everything()) %>%
  
  # Rename variables in camel case
  rename(FinancialYear = fy,
         HSCP = hscp,
         PercentageSpentInHomeCommunity = qom,
         PercentageSpentInHospital = qom_hosp,
         NumberOfDeaths = deaths,
         AverageDaysInCommunity = comm,
         AverageDaysInHospital = hosp,
         DatasetQF = dataset_qf)


#### 5 - Council Area file ----

ca <-
  
  basefile %>% 
  summarise_data(ca = cacode,
                 include_years = "all",
                 format_numbers = FALSE) %>%
  mutate(dataset_qf = if_else(pub_type == "provisional" & 
                                fy == max(.$fy),
                              "p", "")) %>%
  
  # Reorder variables
  select(fy, ca, dataset_qf, everything()) %>%
  
  # Rename variables in camel case
  rename(FinancialYear = fy,
         CA = ca,
         PercentageSpentInHomeCommunity = qom,
         PercentageSpentInHospital = qom_hosp,
         NumberOfDeaths = deaths,
         AverageDaysInCommunity = comm,
         AverageDaysInHospital = hosp,
         DatasetQF = dataset_qf)


#### 6 - Age/Sex file ----

agesex <-
  
  basefile %>% 
  summarise_data(age = age_grp,
                 sex = sex,
                 include_years = "all",
                 format_numbers = FALSE) %>%
  mutate(dataset_qf = if_else(pub_type == "provisional" & 
                                fy == max(.$fy),
                              "p", "")) %>%
  
  # Reorder variables
  select(fy, age, sex, dataset_qf, everything()) %>%
  
  # Rename variables in camel case
  rename(FinancialYear = fy,
         AgeGroup = age,
         Sex = sex,
         PercentageSpentInHomeCommunity = qom,
         PercentageSpentInHospital = qom_hosp,
         NumberOfDeaths = deaths,
         AverageDaysInCommunity = comm,
         AverageDaysInHospital = hosp,
         DatasetQF = dataset_qf)


#### 7 - Deprivation file ----

simd <-
  
  basefile %>%
  summarise_data(simd,
                 include_years = "all",
                 format_numbers = FALSE) %>%
  
  mutate(dataset_qf = if_else(pub_type == "provisional" & 
                                fy == max(.$fy),
                              "p", "")) %>%
  
  # Reorder variables
  select(fy, simd, dataset_qf, everything()) %>%
  
  # Rename variables in camel case
  rename(FinancialYear = fy,
         SIMD = simd,
         PercentageSpentInHomeCommunity = qom,
         PercentageSpentInHospital = qom_hosp,
         NumberOfDeaths = deaths,
         AverageDaysInCommunity = comm,
         AverageDaysInHospital = hosp,
         DatasetQF = dataset_qf)
  
# Do we want to include top 15% in this file?
# How would this be marked as not technically derived?


#### 8 - Urban Rural file ----

rurality <-
  
  basefile %>%
  summarise_data(ur = urban_rural,
                 include_years = "all",
                 format_numbers = FALSE) %>%
  
  mutate(dataset_qf = if_else(pub_type == "provisional" & 
                                fy == max(.$fy),
                              "p", "")) %>%
  
  # Reorder variables
  select(fy, ur, dataset_qf, everything()) %>%
  
  # Rename variables in camel case
  rename(FinancialYear = fy,
         UrbanRural6Fold = ur,
         PercentageSpentInHomeCommunity = qom,
         PercentageSpentInHospital = qom_hosp,
         NumberOfDeaths = deaths,
         AverageDaysInCommunity = comm,
         AverageDaysInHospital = hosp,
         DatasetQF = dataset_qf)


#### 9 - Save files ----

# Create new folder for publication date
if(!(pub_date %in% fs::dir_ls(here::here("data", "open-data")))){
  fs::dir_create(paste0(here::here("data", "open-data", pub_date)))
}

write_csv(hb, here("data", "open-data", pub_date, "last-six-months-of-life_health-board.csv"))
write_csv(hscp, here("data", "open-data", pub_date, "last-six-months-of-life_hscp.csv"))
write_csv(ca, here("data", "open-data", pub_date, "last-six-months-of-life_council-area.csv"))
write_csv(agesex, here("data", "open-data", pub_date, "last-six-months-of-life_age-sex.csv"))
write_csv(simd, here("data", "open-data", pub_date, "last-six-months-of-life_deprivation.csv"))
write_csv(rurality, here("data", "open-data", pub_date, "last-six-months-of-life_rurality.csv"))


### END OF SCRIPT ###