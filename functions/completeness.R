completeness <- function(end_date) {
  
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
  
  qtr <- ckanr::ckan_fetch(paste0("https://www.opendata.nhs.scot/dataset/",
                                  "110c4981-bbcc-4dcb-b558-5230ffd92e81/",
                                  "resource/03cf3cb7-41cc-4984-bff6-",
                                  "bbccd5957679/download/quarters.csv")) %>%
    janitor::clean_names() %>%
    dplyr::mutate(quarter = case_when(
      str_detect(quarter, "Q1") ~ str_replace(quarter, "Q1", "Q4"),
      str_detect(quarter, "Q2") ~ str_replace(quarter, "Q2", "Q1"),
      str_detect(quarter, "Q3") ~ str_replace(quarter, "Q3", "Q2"),
      str_detect(quarter, "Q4") ~ str_replace(quarter, "Q4", "Q3")
    )) %>%
    dplyr::mutate(quarter = 
                    if_else(substr(quarter, 5, 6) == "Q4",
                            paste0(parse_number(quarter) - 1, "Q4"),
                            quarter)) %>%
    dplyr::filter(smr_type == "SMR01",
                  readr::parse_number(quarter) == 
                    lubridate::year(end_date) - 1) %>%
    dplyr::left_join(lookup, by = "hb2014") %>%
    dplyr::rename(board = hb2014name) %>%
    dplyr::mutate(board = replace(board,
                                  hb2014 == "S92000003",
                                  "Scotland")) %>%
    tidyr::drop_na(board) %>%
    dplyr::select(board, quarter, completeness) %>%
    tidyr::pivot_wider(names_from = quarter, values_from = completeness)
  
  fy <- ckanr::ckan_fetch(paste0("https://www.opendata.nhs.scot/dataset/",
                               "110c4981-bbcc-4dcb-b558-5230ffd92e81/",
                               "resource/daf55fd2-457f-4845-9af1-5d154cc0b19c",
                               "/download/financialyr.csv")) %>%
    janitor::clean_names() %>%
    dplyr::filter(smr_type == "SMR01",
                  readr::parse_number(financial_year) == 
                    lubridate::year(end_date) - 1) %>%
    dplyr::left_join(lookup, by = "hb2014") %>%
    dplyr::rename(board = hb2014name) %>%
    dplyr::mutate(board = replace(board,
                                  hb2014 == "S92000003",
                                  "Scotland")) %>%
    tidyr::drop_na(board) %>%
    dplyr::select(board, financial_year, completeness) %>%
    dplyr::mutate(financial_year = "All") %>%
    tidyr::pivot_wider(names_from = financial_year, values_from = completeness)
  
  left_join(qtr, fy) %>%
    arrange(board) %>%
    rename_at(vars(contains("Q")),
              ~ substr(., 5, 6))

}
