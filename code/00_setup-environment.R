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


### 3 - Create data and figures folders ----

if(!("data" %in% fs::dir_ls(here::here()))){
  fs::dir_create(paste0(here::here("data", c("basefiles", "extracts"))))
}

if(!("markdown/figures" %in% fs::dir_ls(here::here("markdown")))){
  fs::dir_create(here::here("markdown", "figures"))
}


### 3 - Extract dates ----

# Define the dates that the data are extracted from and to

# Start date
start_date <- lubridate::ymd(20100401)

# End date
end_date   <- lubridate::ymd(20190331)

# Date of publication
pub_date <- lubridate::ymd(20191008)


### 4 - Define list of external causes of death codes ----

external <-  c(paste0("V", 0, 1:9), paste0("V", 10:99),
               paste0("W", 20:99),
               paste0("X", 0, 0:9), paste0("X", 10:99),
               paste0("Y", 0, 0:9), paste0("Y", 10:84))


### 5 - Read in lookup files ----

postcode <- function(){
  
  read_rds(glue("{filepath}lookups/Unicode/Geography/",
                "Scottish Postcode Directory/",
                "Scottish_Postcode_Directory_2019_2.rds")) %>%
  
  clean_names() %>%
  
  select(pc7, ca2019, ca2019name, ca2018, hb2019, hb2019name,
         hscp2019, hscp2019name, hscp2018, ur6_2016, 
         data_zone2011)

}
            
simd     <- function(){
  
  read_rds(glue("{filepath}lookups/Unicode/Deprivation/",
                "postcode_2019_2_simd2016.rds")) %>%
  
  clean_names() %>%
  
  select(pc7, simd2016_sc_quintile, simd2016tp15)
  
}

locality <- function(){
  
  read_rds(glue("{filepath}lookups/Unicode/Geography/HSCP Locality/",
                "HSCP Localities_DZ11_Lookup_20180903.rds")) %>%
  
  clean_names() %>%
  
  select(data_zone2011, hscp_locality)

}

### END OF SCRIPT ###