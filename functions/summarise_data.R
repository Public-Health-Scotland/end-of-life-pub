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
    
    summarise(qom = ((sum(los) / sum(deaths)) / 182.5) * 100,
              qom_hosp = 100 - ((sum(los) / sum(deaths)) / 182.5) * 100,
              deaths = sum(deaths),
              comm = round_half_up(182.5 * (qom / 100)),
              hosp = round_half_up(182.5 * (qom_hosp / 100))) %>%
    
    ungroup() %>%
    
    mutate_at(vars(qom, qom_hosp), ~ sprintf("%.1f", round_half_up(., 1))) %>%
    mutate(deaths = format(deaths, big.mark = ","))
    
}


### END OF SCRIPT ###