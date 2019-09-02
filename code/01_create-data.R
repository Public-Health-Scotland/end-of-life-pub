#########################################################################
# Name of file - 01_create-data.R
# Data release - End of Life Publication
# Original Authors - Alice Byers
# Orginal Date - September 2019
#
# Written/run on - RStudio Server
# Version of R - 3.2.3
#
# Description - Create base file.
#
# Approximate run time - xx minutes
#########################################################################


### 1 - Setup environment and load functions ----

source(here::here("code", "00_setup-environment.R"))
source(here::here("functions", "sql_queries.R"))


### 2 - Open SMRA Connection ----

smra_connect <- 
  suppressWarnings(
    dbConnect(odbc(), 
              dsn = "SMRA",
              uid = .rs.askForPassword("SMRA Username:"),
              pwd = .rs.askForPassword("SMRA Password:")))


### 3 - Extract data ----


deaths <- 
  as_tibble(dbGetQuery(smra_connect, 
                       deaths_query(start_date,
                                    end_date,
                                    external))) %>% 
  clean_names()


smr01 <- 
  
  as_tibble(dbGetQuery(smra_connect, 
                       smr01_query(start_date,
                                   end_date,
                                   smr_start_date,
                                   external,
                                   gls = FALSE))) %>% 
  
  bind_rows(as_tibble(dbGetQuery(smra_connect, 
                                 smr01_query(start_date,
                                             end_date,
                                             smr_start_date,
                                             external,
                                             gls = TRUE)))) %>%
  
  clean_names()


smr04 <- 
  as_tibble(dbGetQuery(smra_connect, 
                       smr04_query(start_date,
                                   end_date,
                                   smr_start_date,
                                   external))) %>% 
  clean_names()


### END OF SCRIPT ###