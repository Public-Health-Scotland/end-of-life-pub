completeness_workaround <- function() {

  temp = tempfile(fileext = ".xlsx")
  dataURL <- "https://publichealthscotland.scot/publications/scottish-morbidity-records-smr-completeness-estimates/?10:39:40"
  dataURL <- "https://beta.isdscotland.org/media/9508/smr_estimates.xlsx?10:39:40"
  download.file(dataURL, destfile=temp, mode='wb')
  
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
  year <- year - round(year, -2)
  
  # prepare table for SMR01
  quarters_smr01 <- readxl::read_excel(temp, range = "Q30:T47") %>% 
    rename(Q1 = glue("Apr'{year-1}","-Jun'{year-1}"),
           Q2 = glue("Jul'{year-1}","-Sep'{year-1}"),
           Q3 = glue("Oct'{year-1}","-Dec'{year-1}"),
           Q4 = glue("Jan'{year}","-Mar'{year}"))
  
  
  annual_smr01 <- readxl::read_excel(temp, range = "N52:N69")%>% 
    rename(All = glue("Apr'{year-1}","-Mar'{year}"))
  
  
  completeness_smr01 <- cbind(hb_name, quarters_smr01, annual_smr01)%>% 
    filter (board != "State Hospital")%>% 
    arrange(match(board, c(filter(., str_detect(board, "NHS")) %>% 
                             pull(board) %>% 
                             sort(),
                           "Golden Jubilee", "Scotland")))
  
  
  write_rds(completeness_smr01, here("data", "extracts", glue("{pub_date}_completeness_smr01.rds")))
  
  # prepare table for SMR01 GLS
  quarters_smr01_gls <- readxl::read_excel(temp, range = "AC30:AF47") %>% 
    rename(Q1 = glue("Apr'{year-1}","-Jun'{year-1}"),
           Q2 = glue("Jul'{year-1}","-Sep'{year-1}"),
           Q3 = glue("Oct'{year-1}","-Dec'{year-1}"),
           Q4 = glue("Jan'{year}","-Mar'{year}"))
  
  
  annual_smr01_gls <- readxl::read_excel(temp, range = "Z52:Z69")%>% 
    rename(All = glue("Apr'{year-1}","-Mar'{year}"))
  
  
  completeness_smr01_gls <- cbind(hb_name, quarters_smr01_gls, annual_smr01_gls)%>% 
    filter (board != "State Hospital")%>% 
    arrange(match(board, c(filter(., str_detect(board, "NHS")) %>% 
                             pull(board) %>% 
                             sort(),
                           "Golden Jubilee", "Scotland")))
  
  
  write_rds(completeness_smr01_gls, here("data", "extracts", glue("{pub_date}_completeness_smr01_gls.rds")))
  
  # prepare table for SMR04
  quarters_smr04 <- readxl::read_excel(temp, range = "Y30:AB47") %>% 
    rename(Q1 = glue("Apr'{year-1}","-Jun'{year-1}"),
           Q2 = glue("Jul'{year-1}","-Sep'{year-1}"),
           Q3 = glue("Oct'{year-1}","-Dec'{year-1}"),
           Q4 = glue("Jan'{year}","-Mar'{year}"))
  
  
  annual_smr04 <- readxl::read_excel(temp, range = "V52:V69")%>% 
    rename(All = glue("Apr'{year-1}","-Mar'{year}"))
  
  
  completeness_smr04 <- cbind(hb_name, quarters_smr04, annual_smr04)%>% 
    filter (board != "State Hospital")%>% 
    arrange(match(board, c(filter(., str_detect(board, "NHS")) %>% 
                             pull(board) %>% 
                             sort(),
                           "Golden Jubilee", "Scotland")))
  
  
  write_rds(completeness_smr04, here("data", "extracts", glue("{pub_date}_completeness_smr04.rds")))
  
  
  rm(hb_name, quarters_smr01, annual_smr01, quarters_smr01_gls, annual_smr01_gls, quarters_smr04, annual_smr04)
  
}


