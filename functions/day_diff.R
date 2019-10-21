#########################################################################
# Name of file - day_diff.R
# Data release - End of Life Publication
# Original Authors - Alice Byers
# Orginal Date - September 2019
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Function to calculate difference in days between two
#               QoM figures.
#
# Approximate run time - xx minutes
#########################################################################


day_diff <- function(x, y){
  
  days_x <- 182.5 * (as.double(x) / 100)
  days_y <- 182.5 * (as.double(y) / 100)
  
  day_diff <-
    Mod(days_x - days_y) %>%
    janitor::round_half_up(0)
  
  if(day_diff < 10){
    day_diff <- as.character(english::as.english(day_diff))
  }

  return(day_diff)
  
}


### END OF SCRIPT ###
