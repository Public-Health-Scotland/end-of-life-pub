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


### 2 - Define Whether Running on Server or Locally ----

# Comment out as appropriate
platform <- c("server")
# platform <- c("local")


# Define root directory for stats server based on whether script is running 
# locally or on server
filepath <- dplyr::if_else(platform == "server",
                           "/conf/",
                           "//stats/")


### 3 - Extract dates ----

# Define the dates that the data are extracted from and to

# Start date for SMRA extract
start_date <- lubridate::ymd(20091001)

# End date for SMRA extract
end_date   <- lubridate::ymd(20190331)

# Start date for deaths extract
deaths_start_date <- lubridate::ymd(20100401)


### 4 - Define list of external causes of death codes

external <-  c(paste0("V", 0, 1:9), paste0("V", 10:99),
               paste0("W", 20:99),
               paste0("X", 0, 0:9), paste0("X", 10:99),
               paste0("Y", 0, 0:9), paste0("Y", 10:84))


### END OF SCRIPT ###