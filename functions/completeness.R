completeness <- function(end_date, level = c("board", "scotland")) {
  
  level <- match.arg(level)

  if (format(end_date, "%d %B") != "31 March") {
    stop("The end date must be 31 March")
  }
  
  if(class(end_date) != "Date") {
    stop("The end date must be provided in date format")
  }
  
  lookup <- ckanr::ckan_fetch(paste0("https://www.opendata.nhs.scot/dataset/",
                                     "9f942fdb-e59e-44f5-b534-d6e17229cc7b/",
                                     "resource/",
                                     "652ff726-e676-4a20-abda-435b98dd7bdc/",
                                     "download/geography_codes_and_labels_",
                                     "hb2014_01042019.csv")) %>%
    janitor::clean_names() %>%
    dplyr::filter(hb2014qf != "x") %>%
    dplyr::select(hb2014, hb2014name)
  
  comp <- ckanr::ckan_fetch(paste0("https://www.opendata.nhs.scot/dataset/",
                                   "110c4981-bbcc-4dcb-b558-5230ffd92e81/",
                                   "resource/",
                                   "daf55fd2-457f-4845-9af1-5d154cc0b19c/",
                                   "download/financialyr.csv")) %>%
    janitor::clean_names() %>%
    dplyr::filter(smr_type == "SMR01",
                  readr::parse_number(financial_year) == 
                    lubridate::year(end_date) - 1) %>%
    dplyr::left_join(lookup, by = "hb2014") %>%
    dplyr::rename(board = hb2014name) %>%
    dplyr::mutate(board = replace(board,
                                  hb2014 == "S92000003",
                                  "Scotland")) %>%
    tidyr::drop_na(board)
  
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
