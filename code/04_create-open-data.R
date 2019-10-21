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


### 3 - Restructure for open data platform ----



### END OF SCRIPT ###