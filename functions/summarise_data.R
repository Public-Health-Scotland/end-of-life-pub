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


summarise_data <- function(data, ..., 
                           include_years = c("last", "first", "all")){
  
  include_years <- match.arg(include_years)
  
  if(include_years == "first"){data %<>% filter(fy == min(fy))}
  if(include_years == "last"){data %<>% filter(fy == max(fy))}
  
  data %>%
    
    group_by(fy, ...) %>%
    
    summarise(qom = calculate_qom(sum(los), sum(deaths), setting = "comm"),
              qom_hosp = calculate_qom(sum(los), sum(deaths), setting = "hosp"),
              deaths = sum(deaths),
              comm = round_half_up(182.5 * (qom / 100))) %>%
    
    ungroup()
  
}


### END OF SCRIPT ###