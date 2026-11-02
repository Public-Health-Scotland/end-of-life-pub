completeness_workaround_html<- function() {
  
  temp = "/conf/irf/18-End-of-Life/Publication/Sissi/end-of-life-pub/data/extracts/2026-08-11-smr_estimates.xlsx"
  
  hb_name <- readxl::read_excel(temp, range = "B30:B47") %>% 
    rename(board = ...1 )
  hb_name %<>% 
    mutate(board = recode(board,
                          "Ayrshire & Arran" = "NHS Ayrshire and Arran",
                          "Borders" = "NHS Borders",
                          "Golden Jubilee" = "Golden Jubilee",  
                          "Fife" = "NHS Fife",
                          "Greater Glasgow & Clyde" = "NHS Greater Glasgow and Clyde",
                          "Highland" = "NHS Highland",
                          "Lanarkshire" = "NHS Lanarkshire",
                          "Grampian" = "NHS Grampian",
                          "Orkney" = "NHS Orkney",
                          "Lothian" = "NHS Lothian",
                          "Tayside" = "NHS Tayside",
                          "Forth Valley" = "NHS Forth Valley",
                          "Western Isles" = "NHS Western Isles",
                          "Dumfries & Galloway" = "NHS Dumfries and Galloway",
                          "Shetland" = "NHS Shetland",
                          "All NHS Boards" = "Scotland")
    )
  
  year <- as.numeric(year(end_date))
  #year <- year - round(year, -2)
  
  # prepare table for SMR01
  quarters_smr01 <- readxl::read_excel(temp, range = "P30:S47") %>% 
    rename(Q1 = glue::glue("Apr-Jun {year - 1}"),
           Q2 = glue::glue("Jul-Sep {year - 1}"),
           Q3 = glue::glue("Oct-Dec {year - 1}"),
           Q4 = glue::glue("Jan-Mar {year}"))
  
  
  year_short <- year %% 100
  annual_smr01 <- readxl::read_excel(temp, range = "N52:N69")%>% 
    rename(All = glue("Apr'{year_short-1}","-Mar'{year_short}"))
  
  
  completeness_smr01 <- cbind(hb_name, quarters_smr01, annual_smr01)%>% 
    filter (board != "State Hospital")%>% 
    arrange(match(board, c(filter(., str_detect(board, "NHS")) %>% 
                             pull(board) %>% 
                             sort(),
                           "Golden Jubilee", "Scotland")))
  
  
  write_rds(completeness_smr01, here("data", "extracts", glue("{pub_date}_completeness_smr01.rds")))
  
  # prepare table for SMR01 GLS
  quarters_smr01_gls <- readxl::read_excel(temp, range = "AH30:AK47") %>% 
    rename(Q1 = glue::glue("Apr-Jun {year - 1}"),
           Q2 = glue::glue("Jul-Sep {year - 1}"),
           Q3 = glue::glue("Oct-Dec {year - 1}"),
           Q4 = glue::glue("Jan-Mar {year}"))
  
  
  annual_smr01_gls <- readxl::read_excel(temp, range = "Z52:Z69")%>% 
    rename(All = glue("Apr'{year_short-1}","-Mar'{year_short}"))
  
  
  completeness_smr01_gls <- cbind(hb_name, quarters_smr01_gls, annual_smr01_gls)%>% 
    filter (board != "State Hospital")%>% 
    arrange(match(board, c(filter(., str_detect(board, "NHS")) %>% 
                             pull(board) %>% 
                             sort(),
                           "Golden Jubilee", "Scotland")))
  
  
  write_rds(completeness_smr01_gls, here("data", "extracts", glue("{pub_date}_completeness_smr01_gls.rds")))
  
  # prepare table for SMR04
  quarters_smr04 <- readxl::read_excel(temp, range = "AB30:AE47") %>% 
    rename(Q1 = glue::glue("Apr-Jun {year - 1}"),
           Q2 = glue::glue("Jul-Sep {year - 1}"),
           Q3 = glue::glue("Oct-Dec {year - 1}"),
           Q4 = glue::glue("Jan-Mar {year}"))
  
  
  annual_smr04 <- readxl::read_excel(temp, range = "V52:V69")%>% 
    rename(All = glue("Apr'{year_short-1}","-Mar'{year_short}"))
  
  
  completeness_smr04 <- cbind(hb_name, quarters_smr04, annual_smr04)%>% 
    filter (board != "State Hospital")%>% 
    arrange(match(board, c(filter(., str_detect(board, "NHS")) %>% 
                             pull(board) %>% 
                             sort(),
                           "Golden Jubilee", "Scotland")))
  
  
  write_rds(completeness_smr04, here("data", "extracts", glue("{pub_date}_completeness_smr04.rds")))
  
  
  rm(hb_name, quarters_smr01, annual_smr01, quarters_smr01_gls, annual_smr01_gls, quarters_smr04, annual_smr04)
  
}



