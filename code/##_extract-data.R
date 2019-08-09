#########################################################################
# Name of file - ##_extract-data.R
# Data release - End of Life Publication
# Original Authors - Alice Byers
# Orginal Date - August 2019
#
# Written/run on - RStudio Server
# Version of R - 3.2.3
#
# Description - Extract data from SMRA.
#
# Approximate run time - xx minutes
#########################################################################


### 1 - Load environment file and functions ----

source(here::here("code", "00_setup-environment.R"))


### 2 - Open SMRA Connection

SMRA_connect <- 
  suppressWarnings(
     dbConnect(odbc(), 
               dsn = "SMRA",
               uid = .rs.askForPassword("SMRA Username:"),
               pwd = .rs.askForPassword("SMRA Password:")))


### 3 - Deaths extract

deaths <- 
  
  tbl(SMRA_connect,
      dbplyr::in_schema("ANALYSIS", "GRO_DEATHS_C")) %>%
  
  select(LINK_NO, DATE_OF_DEATH, AGE, SEX, POSTCODE) %>%
  filter(DATE_OF_DEATH >= To_date(deaths_start_date, "YYYY-MM-DD")) %>%
  collect() %>%
  clean_names()

  
  