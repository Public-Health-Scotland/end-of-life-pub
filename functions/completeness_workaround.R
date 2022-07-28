completeness_workaround <- function() {

  temp = tempfile(fileext = ".xlsx")
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
  
  
  quarters <- readxl::read_excel(temp, range = "Q30:T47") %>% 
    rename(Q1 = glue("Apr'{year-1}","-Jun'{year-1}"),
           Q2 = glue("Jul'{year-1}","-Sep'{year-1}"),
           Q3 = glue("Oct'{year-1}","-Dec'{year-1}"),
           Q4 = glue("Jan'{year}","-Mar'{year}"))
  
  
  annual <- readxl::read_excel(temp, range = "N52:N69")%>% 
    rename(All = glue("Apr'{year-1}","-Mar'{year}"))
  
  
  completeness <- cbind(hb_name, quarters, annual)%>% 
    filter (board != "State Hospital")%>% 
    arrange(match(board, c(filter(., str_detect(board, "NHS")) %>% 
                             pull(board) %>% 
                             sort(),
                           "Golden Jubilee", "Scotland")))
  
  
  write_rds(completeness, here("data", "extracts", glue("{pub_date}_completeness.rds")))
  
  rm(hb_name, quarters, annual)
  
}


