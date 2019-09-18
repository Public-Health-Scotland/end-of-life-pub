#########################################################################
# Name of file - summarise_data.R
# Data release - End of Life Publication
# Original Authors - Alice Byers
# Orginal Date - September 2019
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Function to aggregate data and calculate QoM measure.
#
# Approximate run time - xx minutes
#########################################################################


summarise_data <- function(data, split_by1, split_by2, trend = FALSE){
  
  if(trend == FALSE){data %<>% filter(fy == max(fy))}
  
  data %>%
    
    group_by(fy, {{split_by1}}, {{split_by2}}) %>%
    
    summarise(deaths = sum(deaths),
              qom    = 100 - (((sum(los) / deaths) / 182.5) * 100),
              comm   = 182.5 * (qom / 100)) %>%
    
    mutate(qom  = round_half_up(qom, 1),
           comm = round_half_up(comm, 0))
  
}


### END OF SCRIPT ###