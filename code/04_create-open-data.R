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
  summarise_data(hb = "S92000003",
                 hb_qf = "d",
                 include_years = "all",
                 format_numbers = FALSE) %>%
  
  bind_rows(
    basefile %>%
      summarise_data(hb = hbcode,
                     hb_qf = "",
                     include_years = "all",
                     format_numbers = FALSE)
  ) %>%
  
  # Add qualifier code; p = provisional, d = dervied/aggregate
  mutate(fy_qf = 
           if_else(pub_type == "provisional" & 
                     fy == max(.$fy),
                   "p", "")
  ) %>%
  
  # Reorder variables
  select(fy, fy_qf, hb, hb_qf, everything()) %>%
  
  # Rename variables in camel case
  rename(FinancialYear = fy,
         FinancialYearQF = fy_qf,
         HBR2014 = hb,
         HBR2014QF = hb_qf,
         PercentageSpentInHomeCommunity = qom,
         PercentageSpentInHospital = qom_hosp,
         NumberOfDeaths = deaths,
         TotalLengthOfStay = los,
         AverageDaysInCommunity = comm,
         AverageDaysInHospital = hosp)


#### 4 - HSCP file ----

hscp <-
  
  basefile %>% 
  summarise_data(hscp = hscpcode,
                 include_years = "all",
                 format_numbers = FALSE) %>%
  
  mutate(fy_qf = if_else(pub_type == "provisional" & 
                           fy == max(.$fy),
                           "p", "")) %>%
  
  # Reorder variables
  select(fy, fy_qf, hscp, everything()) %>%
  
  # Rename variables in camel case
  rename(FinancialYear = fy,
         FinancialYearQF = fy_qf,
         HSCP2016 = hscp,
         PercentageSpentInHomeCommunity = qom,
         PercentageSpentInHospital = qom_hosp,
         NumberOfDeaths = deaths,
         TotalLengthOfStay = los,
         AverageDaysInCommunity = comm,
         AverageDaysInHospital = hosp)


#### 5 - Council Area file ----

ca <-
  
  basefile %>% 
  summarise_data(ca = cacode,
                 include_years = "all",
                 format_numbers = FALSE) %>%
  
  mutate(fy_qf = if_else(pub_type == "provisional" & 
                                fy == max(.$fy),
                              "p", "")) %>%
  
  # Reorder variables
  select(fy, fy_qf, ca, everything()) %>%
  
  # Rename variables in camel case
  rename(FinancialYear = fy,
         FinancialYearQF = fy_qf,
         CA2011 = ca,
         PercentageSpentInHomeCommunity = qom,
         PercentageSpentInHospital = qom_hosp,
         NumberOfDeaths = deaths,
         TotalLengthOfStay = los,
         AverageDaysInCommunity = comm,
         AverageDaysInHospital = hosp)


#### 6 - Age/Sex file ----

agesex <-
  
  basefile %>% 
  summarise_data(age = age_grp,
                 sex = sex,
                 include_years = "all",
                 format_numbers = FALSE) %>%
  
  mutate(fy_qf = if_else(pub_type == "provisional" & 
                                fy == max(.$fy),
                              "p", "")) %>%
  
  mutate(age = case_when(
    str_detect(age, "-") ~ paste(age, "years"),
    str_detect(age, "\\+") ~ paste(age, "years and over")
  )) %>%
  
  mutate(sex = replace_na(sex, "Missing")) %>%
  
  # Reorder variables
  select(fy, fy_qf, age, sex, everything()) %>%
  
  # Rename variables in camel case
  rename(FinancialYear = fy,
         FinancialYearQF = fy_qf,
         AgeGroup = age,
         Sex = sex,
         PercentageSpentInHomeCommunity = qom,
         PercentageSpentInHospital = qom_hosp,
         NumberOfDeaths = deaths,
         TotalLengthOfStay = los,
         AverageDaysInCommunity = comm,
         AverageDaysInHospital = hosp)


#### 7 - Deprivation file ----

simd <-
  
  basefile %>%
  summarise_data(simd,
                 include_years = "all",
                 format_numbers = FALSE) %>%
  
  mutate(fy_qf = if_else(pub_type == "provisional" & 
                                fy == max(.$fy),
                              "p", "")) %>%
  
  mutate(simd = substr(simd, 1, 1)) %>%
  
  # Reorder variables
  select(fy, fy_qf, simd, everything()) %>%
  
  # Rename variables in camel case
  rename(FinancialYear = fy,
         FinancialYearQF = fy_qf,
         SIMD = simd,
         PercentageSpentInHomeCommunity = qom,
         PercentageSpentInHospital = qom_hosp,
         NumberOfDeaths = deaths,
         TotalLengthOfStay = los,
         AverageDaysInCommunity = comm,
         AverageDaysInHospital = hosp)
  

#### 8 - Urban Rural file ----

rurality <-
  
  basefile %>%
  summarise_data(ur = urban_rural,
                 include_years = "all",
                 format_numbers = FALSE) %>%
  
  mutate(fy_qf = if_else(pub_type == "provisional" & 
                                fy == max(.$fy),
                              "p", "")) %>%
  
  # Reorder variables
  select(fy, fy_qf, ur, everything()) %>%
  
  # Rename variables in camel case
  rename(FinancialYear = fy,
         FinancialYearQF = fy_qf,
         UrbanRural6Fold = ur,
         PercentageSpentInHomeCommunity = qom,
         PercentageSpentInHospital = qom_hosp,
         NumberOfDeaths = deaths,
         TotalLengthOfStay = los,
         AverageDaysInCommunity = comm,
         AverageDaysInHospital = hosp)


#### 9 - Save files ----

write_csv(hb, 
          here("data", "open-data", pub_date, 
               glue("{today()}_last-six-months-of-life_health-board.csv")))
write_csv(hscp, 
          here("data", "open-data", pub_date, 
               glue("{today()}_last-six-months-of-life_hscp.csv")))
write_csv(ca, 
          here("data", "open-data", pub_date, 
               glue("{today()}_last-six-months-of-life_council-area.csv")))
write_csv(agesex, 
          here("data", "open-data", pub_date, 
               glue("{today()}_last-six-months-of-life_age-sex.csv")))
write_csv(simd, 
          here("data", "open-data", pub_date, 
               glue("{today()}_last-six-months-of-life_deprivation.csv")))
write_csv(rurality, 
          here("data", "open-data", pub_date, 
               glue("{today()}_last-six-months-of-life_rurality.csv")))


### END OF SCRIPT ###