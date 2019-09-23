#########################################################################
# Name of file - calculate_qom.R
# Data release - End of Life Publication
# Original Authors - Alice Byers
# Orginal Date - September 2019
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Function to calculate QoM measure.
#
# Approximate run time - xx minutes
#########################################################################


calculate_qom <- function(deaths, hosp_los, setting){
  
  if(!(setting %in% c("hosp", "comm"))){
    stop("The setting argument must be either 'hosp' or 'comm'.")
  }
  
  qom <- ((hosp_los / deaths) / 182.5) * 100
  
  janitor::round_half_up(
    if_else(setting == "hosp",
            qom,
            100 - qom),
  1)
  
}


### END OF SCRIPT ###