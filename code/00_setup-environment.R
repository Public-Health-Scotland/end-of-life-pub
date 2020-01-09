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
# Approximate run time - xx minutes
#########################################################################


### 1 - Load packages ----

library(odbc)          # For accessing SMRA
library(dplyr)         # For data manipulation in the "tidy" way
library(readr)         # For reading in csv files
library(janitor)       # For 'cleaning' variable names
library(magrittr)      # For %<>% operator
library(lubridate)     # For dates
library(tidylog)       # For printing results of some dplyr functions
library(tidyr)         # For data manipulation in the "tidy" way
library(stringr)       # For string manipulation and matching
library(here)          # For the here() function
library(glue)          # For working with strings
library(fs)            # For creating new file directories
library(ggplot2)       # For producing charts/figures
library(english)       # For converting numbers to words
library(forcats)       # For dealing with factors
library(purrr)         # For functional programming
library(rgdal)         # For reading shapefiles
library(broom)         # For tidying shapefile
library(openxlsx)      # For writing to excel workbook
library(lemon)         # To add tick marks to facet plots
library(rmarkdown)     # To render/knit Rmd files


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


### 3 - Extract dates ----

# Define the dates that the data are extracted from and to

# Start date
start_date <- lubridate::ymd(20100401)

# End date
end_date   <- lubridate::ymd(20190331)

# Date of publication
pub_date <- lubridate::ymd(20200528)

# Date of last publication
last_pub_date <- lubridate::ymd(20191008)

# Date of next publication
next_pub_date <- 
  if_else(month(pub_date) == 5,
          paste("October", year(pub_date)),
          paste("May", year(pub_date) + 1))

# Provisional/Update
pub_type <- "provisional"
# pub_type <- "update"


### 4 - Create folders ----

if(!("data" %in% fs::dir_ls(here::here()))){
  fs::dir_create(paste0(here::here("data", c("basefiles", 
                                             "extracts",
                                             "open-data"))))
}

if(!("output" %in% fs::dir_ls(here::here()))){
  fs::dir_create(here::here("output"))
}

if(!("markdown/figures" %in% fs::dir_ls(here::here("markdown")))){
  fs::dir_create(here::here("markdown", "figures"))
}

if(!(pub_date %in% fs::dir_ls(here::here("data", "open-data")))){
  fs::dir_create(paste0(here::here("data", "open-data", pub_date)))
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

postcode <- function(){
  
  fs::dir_ls(glue("{filepath}lookups/Unicode/Geography/",
                  "Scottish Postcode Directory/"),
             regexp = ".rds$") %>%
  
  read_rds() %>%
  
  clean_names() %>%
  
  select(pc7, ca2019, ca2019name, ca2018, hb2019, hb2019name,
         hscp2019, hscp2019name, hscp2018, ur6_2016_name, 
         ur2_2016_name, data_zone2011) %>%
    
  rename(hb = hb2019name,
         hbcode = hb2019,
         hscp = hscp2019name,
         hscpcode = hscp2019,
         ca = ca2019name,
         cacode = ca2019,
         urban_rural = ur6_2016_name,
         urban_rural_2 = ur2_2016_name)

}
            
simd     <- function(){
  
  read_rds(glue("{filepath}lookups/Unicode/Deprivation/",
                "postcode_2019_2_simd2016.rds")) %>%
  
  clean_names() %>%
  
  select(pc7, simd2016_sc_quintile, simd2016tp15) %>%
    
  rename(simd = simd2016_sc_quintile,
         simd_15 = simd2016tp15) %>%
    
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
                "HSCP Localities_DZ11_Lookup_20191612.rds")) %>%
  
  clean_names() %>%
  
  select(data_zone2011, hscp_locality) %>%
    
  rename(locality = hscp_locality)

}

shapefile <- function(){
  
 readOGR(glue("{filepath}lookups/Unicode/Geography/Shapefiles/",
               "Health Board 2019/"),
         "SG_NHS_HealthBoards_2019")
  
}


### END OF SCRIPT ###
