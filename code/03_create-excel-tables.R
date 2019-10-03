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
      summarise_data(category = "Scotland",
                     category_split = "Scotland"),
    
    # Health Board
    basefile %>%
      summarise_data(category = "hb", 
                     category_split = hb),
    
    # Council Area
    basefile %>%
      summarise_data(category = "ca", 
                     category_split = ca),
    
    # HSCP
    basefile %>%
      summarise_data(category = "hscp", 
                     category_split = hscp),
    
    # Age/Sex
    basefile %>%
      filter(!is.na(sex)) %>% 
      summarise_data(category = "age/sex", 
                     category_split = paste(age_grp, sex)),
    
    # All Ages/Sex
    basefile %>%
      filter(!is.na(sex)) %>%
      summarise_data(category = "age/sex", 
                     category_split = paste("All Ages", sex)),
    
    # Age/All Sex
    basefile %>%
      summarise_data(category = "age/sex", 
                     category_split = paste(age_grp, "Both")),
    
    # SIMD 
    basefile %>%
      summarise_data(category = "simd quintile", 
                     category_split = simd),
    
    # SIMD Top 15%
    basefile %>%
      summarise_data(category = "simd 15", 
                     category_split = simd_15),
    
    # Urban Rural 6 fold
    basefile %>%
      summarise_data(category = "urban rural 6", 
                     category_split = urban_rural),
    
    # Urban Rural 2 fold
    basefile %>%
      summarise_data(category = "urban rural 2", 
                     category_split = urban_rural_2)
    
  )
  
### END OF SCRIPT ###

