#########################################################################
# Name of file - 04_create-excel-tables.R
# Data release - End of Life Publication
# Original Authors - Alice Byers
# Orginal Date - October 2019
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Restructure data and populate excel table template.
#
# Approximate run time - xx minutes
#########################################################################


### 1 - Setup environment and load functions ----

source(here::here("code", "00_setup-environment.R"))
source(here::here("functions", "summarise_data.R"))


### 2 - Create link to main report

link <- pub_date_link

names(link) <- "See Appendix 2 of the full report for more information."
class(link) <- "hyperlink"


### 3 - Read in basefile ----

basefile <- read_rds(here("data", "basefiles", 
                          glue("{pub_date}_base-file.rds")))


### 4 - Restructure for QoM table ----

# columns: fy, category, category_split, qom, qom_hosp, deaths, comm
# category: hb, Scotland, age/sex, ca, hscp, simd 15, simd quintile, 
# urban rural 2, urban rural 6

excel_data <-
  
  bind_rows(
  
    # Scotland 
    basefile %>%
      summarise_data(category = "Scotland",
                     category_split = "Scotland",
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Health Board
    basefile %>%
      summarise_data(category = "hb", 
                     category_split = hb,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Council Area
    basefile %>%
      summarise_data(category = "ca", 
                     category_split = ca,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # HSCP
    basefile %>%
      summarise_data(category = "hscp", 
                     category_split = hscp,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Age/Sex
    basefile %>%
      filter(!is.na(sex)) %>% 
      summarise_data(category = "age/sex", 
                     category_split = paste(age_grp, sex),
                     include_years = "all",
                     format_numbers = FALSE),
    
    # All Ages/Sex
    basefile %>%
      filter(!is.na(sex)) %>%
      summarise_data(category = "age/sex", 
                     category_split = paste("All Ages", sex),
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Age/All Sex
    basefile %>%
      summarise_data(category = "age/sex", 
                     category_split = paste(age_grp, "Both"),
                     include_years = "all",
                     format_numbers = FALSE),
    
    # All Ages/All Sex
    basefile %>%
      summarise_data(category = "age/sex",
                     category_split = paste("All Ages", "Both"),
                     include_years = "all",
                     format_numbers = FALSE),
    
    # SIMD 
    basefile %>%
      summarise_data(category = "simd quintile", 
                     category_split = simd,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # SIMD Top 15%
    basefile %>%
      summarise_data(category = "simd 15", 
                     category_split = simd_15,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Urban Rural 6 fold
    basefile %>%
      summarise_data(category = "urban rural 6", 
                     category_split = urban_rural,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Urban Rural 2 fold
    basefile %>%
      summarise_data(category = "urban rural 2", 
                     category_split = urban_rural_2,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Methodology Comparison
    basefile %>%
      mutate(los = los_old) %>%
      summarise_data(category = "comparison",
                     category_split = "old",
                     include_years = "all",
                     format_numbers = FALSE)
      
  )


### 5 - Write data to excel workbooks ----

figures <- loadWorkbook(here("reference-files", "figures-template.xlsx"))
  
writeData(figures,
          "data",
          excel_data %>% select(-(deaths:hosp)),
          startCol = 2)

writeData(figures,
          "calculation",
          pub_type,
          startRow = 13,
          startCol = "B")

setRowHeights(figures,
              "Notes",
              rows = 18,
              heights = case_when(
                pub_type == "provisional" ~ 40,
                pub_type == "update" ~ 15
              ))

insertImage(figures,
            "Figure 2",
            here("markdown", "figures", "figure-2.png"),
            width = 10, height = 12, 
            units = "cm", dpi = 600,
            startCol = 2,
            startRow = 7)

writeData(figures, 
          "Notes", 
          startRow = 19,
          startCol = 3,
          x = link)

sheetVisibility(figures)[15:16] <- "hidden"

saveWorkbook(figures,
             here("output", glue("{pub_date}_figures.xlsx")),
             overwrite = TRUE)

qom <- loadWorkbook(here("reference-files", "qom-template.xlsx"))
  
writeData(qom, 
          "data",
          excel_data %>% select(-(qom_hosp:hosp)),
          startCol = 2)

writeData(qom,
          "calculation",
          pub_type,
          startRow = 13,
          startCol = "E")

setRowHeights(qom,
              "Notes",
              rows = 15,
              heights = case_when(
                pub_type == "provisional" ~ 40,
                pub_type == "update" ~ 15 
              ))

writeData(qom,
          "Notes", 
          startRow = 16,
          startCol = 3,
          x = link)

sheetVisibility(qom)[13:14] <- "hidden"

saveWorkbook(qom,
             here("output", glue("{pub_date}_qom.xlsx")),
             overwrite = TRUE)
  

### END OF SCRIPT ###