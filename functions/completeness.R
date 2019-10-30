completeness <- function(end_date, lookup, level = c("board", "scotland")) {
  
  level <- match.arg(level)
  
  if (!format(end_date, "%B %Y") != "31 March") {
    stop("The end date must be 31 March")
  }
  
  if(class(end_date) != "Date") {
    stop("The end date must be provided in date format")
  }
  
  comp <- ckanr::ckan_fetch(paste0("https://www.opendata.nhs.scot/dataset/",
                                   "110c4981-bbcc-4dcb-b558-5230ffd92e81/",
                                   "resource/",
                                   "daf55fd2-457f-4845-9af1-5d154cc0b19c/",
                                   "download/financialyr.csv")) %>%
    janitor::clean_names() %>%
    dplyr::filter(smr_type == "SMR01",
                  readr::parse_number(financial_year) == 
                    lubridate::year(end_date) - 1) %>%
    dplyr::left_join(
      dplyr::select(lookup %>%
                      
                      # The regex is to guard against the variable name being 
                      # changed in the lookup
                      # The as.character is to strip attributes from the lookup 
                      # variable so a warning message doesn't appear after the 
                      # join
                      dplyr::mutate_at(dplyr::vars(
                        dplyr::matches("^hb[_a-z0-9]*2014$")), 
                        as.character) %>%
                      janitor::clean_names(), 
                    board = description, 
                    hb2014 = dplyr::matches("^hb[_a-z0-9]*2014$")),
      by = "hb2014") %>%
    dplyr::mutate(board = replace(board,
                                  hb2014 == "S92000003",
                                  "Scotland")) %>%
    tidyr::drop_na(board) %>%
    dplyr::mutate(board = trimws(gsub("NHS", "", board)))
  
  if (level == "board") {
    
    comp %<>%
      dplyr::filter(board != "Scotland",
                    completeness < 0.95) %>%
      dplyr::mutate(completeness = paste0("(", 
                                          scales::percent(completeness, 
                                                          accuracy = 1),
                                          ")")) %>%
      tidyr::unite(var, board, completeness, sep = " ") %>%
      dplyr::pull(var)
    
    if (length(comp) == 0) {
      return(capture.output(
        cat("All NHS board have SMR01 completeness of 95% and", 
            "above for",
            paste0(lubridate::year(end_date) - 1,
                   "/",
                   format(end_date, "%y")))))
    } else {
      return(capture.output(
        cat("All NHS board have SMR01 completeness of 95% and",
            "above for",
            paste0(lubridate::year(end_date) - 1,
                   "/",
                   format(end_date, "%y")),
            "with the exception of",
            glue::glue_collapse(sort(comp), 
                                sep = ", ", 
                                last = " and "))))
      
    }
    
  }
  
  if (level == "scotland") {
    comp %<>%
      dplyr::filter(board == "Scotland") %>%
      dplyr::mutate(completeness = scales::percent(completeness,
                                                   accuracy = 1)) %>%
      dplyr::pull(completeness)
    
    return(comp)
  }
}
