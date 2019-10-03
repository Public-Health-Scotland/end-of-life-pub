#########################################################################
# Name of file - 03_create-excel-tables.R
# Data release - End of Life Publication
# Original Authors - Alice Byers
# Orginal Date - October 2019
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Restructure data and populate excel table template.
#
# Approximate run time - xx minutes
#########################################################################


### 1 - Setup environment and load functions ----

source(here::here("code", "00_setup-environment.R"))
source(here::here("functions", "summarise_data.R"))
source(here::here("functions", "calculate_qom.R"))


### 2 - Read in basefile ----

basefile <- read_rds(here("data", "basefiles", 
                          glue("{pub_date}_base-file.rds")))


### 3 - Restructure for QoM table ----

# columns: fy, category, category_split, qom, qom_hosp, deaths, comm
# category: hb, Scotland, age/sex, ca, hscp, simd 15, simd quintile, 
# urban rural 2, urban rural 6

excel_data <-
  
  bind_rows(
  
    # Scotland 
    basefile %>%
    group_by(fy, 
             category = "Scotland", 
             category_split = "Scotland") %>% 
    summarise(qom = 
                calculate_qom(sum(los), sum(deaths), setting = "comm"),
              qom_hosp = 
                calculate_qom(sum(los), sum(deaths), setting = "hosp"),
              deaths = sum(deaths),
              comm = round_half_up(182.5 * (qom / 100))
    ),
    
    # Health Board
    basefile %>%
      group_by(fy, 
               category = "hb", 
               category_split = hb) %>% 
      summarise(qom = 
                  calculate_qom(sum(los), sum(deaths), setting = "comm"),
                qom_hosp = 
                  calculate_qom(sum(los), sum(deaths), setting = "hosp"),
                deaths = sum(deaths),
                comm = round_half_up(182.5 * (qom / 100))
      )
  )
  
### END OF SCRIPT ###

