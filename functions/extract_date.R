#########################################################################
# Name of file - extract_date.R
# Data release - End of Life Publication
# Original Authors - Alice Byers
# Orginal Date - October 2019
#
# Written/run on - RStudio Server
# Version of R - 3.2.3
#
# Description - Functions for extracting data.
#
# Approximate run time - xx minutes
#########################################################################


extract_date <- function(pub_date){
  
  if(!(paste0(pub_date, "_base-file.rds") %in% 
       dir(here("data", "basefiles"))))
    stop("A basefile for this publication date does not exist in data/basefiles.")
  
  file.mtime(
    here("data", "basefiles", paste0(pub_date, "_base-file.rds"))
  ) %>%
    
  format("%d %B %Y")
  
}

### END OF SCRIPT ###