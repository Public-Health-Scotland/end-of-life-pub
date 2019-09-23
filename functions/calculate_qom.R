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


calculate_qom <- function(data, setting){
  
  if(!(setting %in% c("hosp", "comm"))){
    stop("The setting argument must be either 'hosp' or 'comm'.")
  }
  
  if(!("los" %in% names(data))){
    stop("The given data must include variable named 'los'.")
  }
  
  if(!("deaths" %in% names(data))){
    stop("The given data must include variable named 'deaths'.")
  }
  
  los <- sum(data$los)
  deaths <- sum(data$deaths)
  
  if_else(setting == "hosp",
          ((los / deaths) / 182.5) * 100,
          100 - ((los / deaths) / 182.5) * 100) %>%
    
  janitor::round_half_up(1)
  
}


### END OF SCRIPT ###