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
      ),
    
    # Council Area
    basefile %>%
      group_by(fy, 
               category = "ca", 
               category_split = ca) %>% 
      summarise(qom = 
                  calculate_qom(sum(los), sum(deaths), setting = "comm"),
                qom_hosp = 
                  calculate_qom(sum(los), sum(deaths), setting = "hosp"),
                deaths = sum(deaths),
                comm = round_half_up(182.5 * (qom / 100))
      ),
    
    # HSCP
    basefile %>%
      group_by(fy, 
               category = "hscp", 
               category_split = hscp) %>% 
      summarise(qom = 
                  calculate_qom(sum(los), sum(deaths), setting = "comm"),
                qom_hosp = 
                  calculate_qom(sum(los), sum(deaths), setting = "hosp"),
                deaths = sum(deaths),
                comm = round_half_up(182.5 * (qom / 100))
      ),
    
    # Age/Sex
    basefile %>%
      filter(!is.na(sex)) %>% 
      group_by(fy, 
               category = "age/sex", 
               category_split = paste(age_grp, sex)) %>% 
      summarise(qom = 
                  calculate_qom(sum(los), sum(deaths), setting = "comm"),
                qom_hosp = 
                  calculate_qom(sum(los), sum(deaths), setting = "hosp"),
                deaths = sum(deaths),
                comm = round_half_up(182.5 * (qom / 100))
      ),
    
    # All Ages/Sex
    basefile %>%
      filter(!is.na(sex)) %>%
      group_by(fy, 
               category = "age/sex", 
               category_split = paste("All Ages", sex)) %>% 
      summarise(qom = 
                  calculate_qom(sum(los), sum(deaths), setting = "comm"),
                qom_hosp = 
                  calculate_qom(sum(los), sum(deaths), setting = "hosp"),
                deaths = sum(deaths),
                comm = round_half_up(182.5 * (qom / 100))
      ),
    
    # Age/All Sex
    basefile %>%
      group_by(fy, 
               category = "age/sex", 
               category_split = paste(age_grp, "Both")) %>% 
      summarise(qom = 
                  calculate_qom(sum(los), sum(deaths), setting = "comm"),
                qom_hosp = 
                  calculate_qom(sum(los), sum(deaths), setting = "hosp"),
                deaths = sum(deaths),
                comm = round_half_up(182.5 * (qom / 100))
      ),
    
    # SIMD 
    basefile %>%
      group_by(fy, 
               category = "simd quintile", 
               category_split = simd) %>% 
      summarise(qom = 
                  calculate_qom(sum(los), sum(deaths), setting = "comm"),
                qom_hosp = 
                  calculate_qom(sum(los), sum(deaths), setting = "hosp"),
                deaths = sum(deaths),
                comm = round_half_up(182.5 * (qom / 100))
      ),
    
    # SIMD Top 15%
    basefile %>%
      group_by(fy, 
               category = "simd 15", 
               category_split = simd_15) %>% 
      summarise(qom = 
                  calculate_qom(sum(los), sum(deaths), setting = "comm"),
                qom_hosp = 
                  calculate_qom(sum(los), sum(deaths), setting = "hosp"),
                deaths = sum(deaths),
                comm = round_half_up(182.5 * (qom / 100))
      ),
    
    # Urban Rural 6 fold
    basefile %>%
      group_by(fy, 
               category = "urban rural 6", 
               category_split = urban_rural) %>% 
      summarise(qom = 
                  calculate_qom(sum(los), sum(deaths), setting = "comm"),
                qom_hosp = 
                  calculate_qom(sum(los), sum(deaths), setting = "hosp"),
                deaths = sum(deaths),
                comm = round_half_up(182.5 * (qom / 100))
      ),
    
    # Urban Rural 2 fold
    basefile %>%
      group_by(fy, 
               category = "urban rural 2", 
               category_split = urban_rural_2) %>% 
      summarise(qom = 
                  calculate_qom(sum(los), sum(deaths), setting = "comm"),
                qom_hosp = 
                  calculate_qom(sum(los), sum(deaths), setting = "hosp"),
                deaths = sum(deaths),
                comm = round_half_up(182.5 * (qom / 100))
      )
    
  )
  
### END OF SCRIPT ###

