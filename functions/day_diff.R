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
  
  days_x <- 182.5 * (x / 100)
  days_y <- 182.5 * (y / 100)
  
  Mod(days_x - days_y) %>%
    janitor::round_half_up(0) %>%
    english::as.english()
  
}


### END OF SCRIPT ###