#########################################################################
# Name of file - 00_setup-environment.R
# Data release - End of Life Publication
# Original Authors - Alice Byers
# Orginal Date - August 2019
#
# Written/run on - RStudio Server
# Version of R - 3.2.3
#
# Description - Sets up environment required for running publication RAP. 
# This is the only file which should require updating everytime 
# the process is run.
#
# Approximate run time - 60 minutes
#########################################################################


### 1 - Load packages ----
# If any of the below packages don't run, install will be required using install.packages("")

library(odbc)          # For accessing SMRA
library(dplyr)         # For data manipulation in the "tidy" way
library(readr)         # For reading in csv files
library(janitor)       # For 'cleaning' variable names
library(magrittr)      # For %<>% operator
library(lubridate)     # For dates
library(tidyr)         # For data manipulation in the "tidy" way
library(stringr)       # For string manipulation and matching
library(here)          # For the here() function
library(glue)          # For working with strings
library(fs)            # For creating new file directories
library(ggplot2)       # For producing charts/figures
library(english)       # For converting numbers to words
library(forcats)       # For dealing with factors
library(purrr)         # For functional programming
library(rgeos)         # For reading shapefiles
library(rgdal)         # For reading shapefiles
library(maptools)      # For working with shapefiles
library(broom)         # For tidying shapefile
library(openxlsx)      # For writing to excel workbook
library(lemon)         # To add tick marks to facet plots
library(rmarkdown)     # To render/knit Rmd files
library(tidylog)       # For printing results of some dplyr functions
library(flextable)     # For formatting markdown tables for word
library(officer)       # For formatting markdown tables for word
library(caTools)       # For runnung knit markdown

### 2 - Define Whether Running on Server or Locally ----

if (sessionInfo()$platform %in% c("x86_64-redhat-linux-gnu (64-bit)",
                                  "x86_64-pc-linux-gnu (64-bit)")) {
  platform <- "server"
} else {
  platform <- "locally"
}

# Define root directory for stats server based on whether script is running 
# locally or on server
filepath <- dplyr::if_else(platform == "server",
                           "/conf/linkage/output/",
                           "//stats/cl-out/")


### 3 - Define dates ----

#### UPDATE THIS SECTION ####

# End date
end_date   <- ymd(20230331)

# Date of publication
pub_date <- ymd(20231010)

# Date of last publication
last_pub_date <- ymd(20221004)

# Provisional/Update
# pub_type <- "provisional"
pub_type <- "update"

#############################

# Start date
start_date <- ymd(glue("{year(end_date) - 10}0401"))

# Date of next publication
next_pub_date <- 
  if_else(month(pub_date) == 5,
          paste("October", year(pub_date)),
          paste("May", year(pub_date) + 1))

# Publication date in format for beta website link
pub_date_link <- 
  glue("https://beta.isdscotland.org/find-publications-and-data/",
       "health-and-social-care/social-and-community-care/percentage-",
       "of-end-of-life-spent-at-home-or-in-a-community-setting/",
       "{day(pub_date)}-{format(pub_date, '%b-%Y')}")


### 4 - Create folders ----

if(!fs::is_dir(here::here("data"))){
  fs::dir_create(paste0(here::here("data", c("basefiles", 
                                             "extracts",
                                             "open-data"))))
}

if(!fs::is_dir(here::here("output"))){
  fs::dir_create(here::here("output"))
}

if(!fs::is_dir(here::here("markdown", "figures"))){
  fs::dir_create(here::here("markdown", "figures"))
}

if(!fs::is_dir(here::here("data", "open-data", pub_date))){
  fs::dir_create(here::here("data", "open-data", pub_date))
}


### 5 - Define list of external and fall causes of death codes ----

external <- c(paste0("V", 0, 1:9), paste0("V", 10:99),
              paste0("W", 20:99),
              paste0("X", 0, 0:9), paste0("X", 10:99),
              paste0("Y", 0, 0:9), paste0("Y", 10:84))

falls    <- c(paste0("W", 0, 0:9), paste0("W", 10:19))


### 6 - Define list of care homes to class as community ----

care_homes <- c("A240V", "F821V", "G105V", "G518V", "G203V", "G315V", 
                "G424V", "G541V", "G557V", "H239V", "L112V", "L213V", 
                "L215V", "L330V", "L365V", "N465R", "N498V", "S312R", 
                "S327V", "T315S", "T337V", "Y121V")


### 7 - Read in lookup files ----
# Read in postcode, SIMD and locality lookup files, keep only relevant variables
# Rename specific varibales for future matching
# Latest postcode file taken from folder using max()

postcode <- function(version =""){
  
  fs::dir_ls(glue("{filepath}lookups/Unicode/Geography/",
                  "Scottish Postcode Directory/"),
             regexp = glue("{version}.rds$")) %>%
    
  #Read in the most up to date lookup version
  max() %>%
    
  read_rds() %>%
  
  clean_names() %>%
  
  select(pc7, ca2019, ca2019name, ca2018, hb2019, hb2019name,
         hscp2019, hscp2019name, hscp2018, ur6_2020_name, 
         ur2_2020_name, datazone2011) %>%
    
  rename(hb = hb2019name,
         hbcode = hb2019,
         hscp = hscp2019name,
         hscpcode = hscp2019,
         ca = ca2019name,
         cacode = ca2019,
         urban_rural = ur6_2020_name,
         urban_rural_2 = ur2_2020_name)

}
            
simd     <- function(){
  
  read_rds(glue("{filepath}lookups/Unicode/Deprivation/",
                "postcode_2023_2_simd2020v2.rds")) %>%
  
  clean_names() %>%
  
  select(pc7, simd2020v2_sc_quintile, simd2020v2tp15) %>%
    
  rename(simd = simd2020v2_sc_quintile,
         simd_15 = simd2020v2tp15) %>%
    
  mutate(
    simd = case_when(
      simd == 1 ~ "1 - Most Deprived",
      simd == 5 ~ "5 - Least Deprived",
      TRUE ~ as.character(simd)
    ),
    simd_15 = case_when(
      simd_15 == 1 ~ "15% most deprived",
      simd_15 == 0 ~ "Other 85%"
    )
  )
  
}

locality <- function(){
  
  read_rds(glue("{filepath}lookups/Unicode/Geography/HSCP Locality/",
                "HSCP Localities_DZ11_Lookup_20230804.rds")) %>%
  
  clean_names() %>%
  
  select(datazone2011, hscp_locality) %>%
    
  rename(locality = hscp_locality)

}

shapefile <- function(){
  
 readOGR(glue("{filepath}lookups/Unicode/Geography/Shapefiles/",
               "Health Board 2019/"),
         "SG_NHS_HealthBoards_2019")
  
}



### END OF SCRIPT ###