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

### Geospatial package install
# The below code must be run every time a session is opened
# Required to create figure 2 on 03_create-figures

# Set environment variables to point to installations of geospatial libraries ----

## Amend 'LD_LIBRARY_PATH' ----

# Get the existing value of 'LD_LIBRARY_PATH'
old_ld_path <- Sys.getenv("LD_LIBRARY_PATH") 

# Append paths to GDAL and PROJ to 'LD_LIBRARY_PATH'
Sys.setenv(LD_LIBRARY_PATH = paste(old_ld_path,
                                   "/usr/gdal34/lib",
                                   "/usr/proj81/lib",
                                   sep = ":"))

rm(old_ld_path)

## Specify additional proj path in which pkg-config should look for .pc files ----

Sys.setenv("PKG_CONFIG_PATH" = "/usr/proj81/lib/pkgconfig")

## Specify the path to GDAL data ----

Sys.setenv("GDAL_DATA" = "/usr/gdal34/share/gdal")

# List of geospatial packages that will be installed
geo_pkgs <- c("leaflet", "rgdal", "raster", "sp", "terra", "sf")

# List of geospatial package dependencies
geo_deps <- unique(
  unlist(tools::package_dependencies(packages = geo_pkgs,
                                     recursive = TRUE)))

# Remove geospatial packages and their dependencies
pkgs_to_remove <- unique(unlist(c(geo_pkgs, geo_deps)))
remove.packages(pkgs_to_remove)

# Remove 'parallelly' if it is already installed
remove.packages("parallelly")

# Install the 'parallelly' package
install.packages("parallelly")

# Identify number of CPUs available
ncpus <- as.numeric(parallelly::availableCores())

# Get list of geospatial package dependencies that can be installed as binaries
geo_deps_bin <- sort(setdiff(geo_deps, geo_pkgs))

# Remove packages that are already installed from the list of geospatial package dependencies
geo_deps_bin <- sort(setdiff(geo_deps_bin, as.data.frame(installed.packages())$Package))

# Install these as binaries
install.packages(pkgs = geo_deps_bin,
                 repos = c("https://ppm.publichealthscotland.org/all-r/__linux__/centos7/latest"),
                 Ncpus = ncpus)

geo_config_args <- c("--with-gdal-config=/usr/gdal34/bin/gdal-config",
                     "--with-proj-include=/usr/proj81/include",
                     "--with-proj-lib=/usr/proj81/lib",
                     "--with-geos-config=/usr/geos310/bin/geos-config")

# Install the {sf} package
install.packages("sf",
                 configure.args = geo_config_args,
                 INSTALL_opts = "--no-test-load",
                 repos = c("https://ppm.publichealthscotland.org/all-r/latest"),
                 Ncpus = ncpus)

# Install the {terra} package
install.packages("terra",
                 configure.args = geo_config_args,
                 INSTALL_opts = "--no-test-load",
                 repos = c("https://ppm.publichealthscotland.org/all-r/latest"),
                 Ncpus = ncpus)

# Install the {sp} package
install.packages("sp",
                 configure.args = geo_config_args,
                 INSTALL_opts = "--no-test-load",
                 repos = c("https://ppm.publichealthscotland.org/all-r/latest"),
                 Ncpus = ncpus)

# Install the {raster} package
install.packages("https://ppm.publichealthscotland.org/all-r/latest/src/contrib/Archive/raster/raster_2.5-8.tar.gz",
                 repos = NULL,
                 type = "source",
                 configure.args = geo_config_args,
                 INSTALL_opts = "--no-test-load",
                 Ncpus = ncpus)

# Install the {rgdal} package
install.packages("https://ppm.publichealthscotland.org/all-r/latest/src/contrib/Archive/rgdal/rgdal_1.5-25.tar.gz",
                 repos = NULL,
                 type = "source",
                 configure.args = geo_config_args,
                 INSTALL_opts = "--no-test-load",
                 Ncpus = ncpus)

# Install the {leaflet} package
install.packages("leaflet",
                 repos = c("https://ppm.publichealthscotland.org/all-r/__linux__/centos7/latest"),
                 Ncpus = ncpus)

dyn.load("/usr/gdal34/lib/libgdal.so")
dyn.load("/usr/geos310/lib64/libgeos_c.so", local = FALSE)

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
pub_date <- ymd(20231003)

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
                "postcode_2023_1_simd2020v2.rds")) %>%
  
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
                "HSCP Localities_DZ11_Lookup_20220630.rds")) %>%
  
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