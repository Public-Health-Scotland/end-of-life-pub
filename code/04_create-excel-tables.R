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
# Create link to the main report on PHS website

link <- pub_date_link

names(link) <- "See Appendix 2 of the full report for more information."
class(link) <- "hyperlink"


### 3 - Read in basefile ----
# Read in basefile as data set to be used for creating excel tables

basefile <- read_rds(here("data", "basefiles", 
                          glue("{pub_date}_base-file.rds")))


### 4 - Restructure for QoM table ----

# Restructure basefile into multiple different excel outputs to populate the qom table
# columns: fy, category, category_split, qom, qom_hosp, deaths, comm
# category: hb, Scotland, age/sex, ca, hscp, simd 15, simd quintile, 
# urban rural 2, urban rural 6

excel_data <-
  
  bind_rows(
  
    # Scotland level outputs for all financial years
    basefile %>%
      summarise_data(category = "Scotland",
                     category_split = "Scotland",
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Health Board output for all financial years, health board name the category split
    basefile %>%
      summarise_data(category = "hb", 
                     category_split = hb,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Council Area output for all financial years, council area name the category split
    basefile %>%
      summarise_data(category = "ca", 
                     category_split = ca,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # HSCP output with the HSCP names the category split, for all financial years
    basefile %>%
      summarise_data(category = "hscp", 
                     category_split = hscp,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Age/Sex output with a combination of the age group and sex as the category split, for all financial years
    basefile %>%
      filter(!is.na(sex)) %>% 
      summarise_data(category = "age/sex", 
                     category_split = paste(age_grp, sex),
                     include_years = "all",
                     format_numbers = FALSE),
    
    # All Ages/Sex output with age groups combined to 'All ages' and sex defined as the category split for all financial years
    basefile %>%
      filter(!is.na(sex)) %>%
      summarise_data(category = "age/sex", 
                     category_split = paste("All Ages", sex),
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Age/All Sex output with the patient sex combined to 'Both' to have age group and both as category split, for all financial years
    basefile %>%
      summarise_data(category = "age/sex", 
                     category_split = paste(age_grp, "Both"),
                     include_years = "all",
                     format_numbers = FALSE),
    
    # All Ages/All Sex output with age groups combined to 'All ages' and gendr combined to 'Both' with All ages/Both as the category split
    basefile %>%
      summarise_data(category = "age/sex",
                     category_split = paste("All Ages", "Both"),
                     include_years = "all",
                     format_numbers = FALSE),
    
    # SIMD quintile as the category, with SIMD 1-5 as the category split for all financial years
    basefile %>%
      summarise_data(category = "simd quintile", 
                     category_split = simd,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # SIMD Top 15% as the category with the top 15% most deprived and other 85% as the category split for all financial years
    basefile %>%
      summarise_data(category = "simd 15", 
                     category_split = simd_15,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Urban Rural 6 fold as the category and the 6 options being the category split, for all financial years
    basefile %>%
      summarise_data(category = "urban rural 6", 
                     category_split = urban_rural,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Urban Rural 2 fold as the category and the urban/rural option being the category split, for all financial years
    basefile %>%
      summarise_data(category = "urban rural 2", 
                     category_split = urban_rural_2,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Methodology Comparison
    # This includes old los calculation for comparison, with comparison as the category and 'old' as the category split for all financial years
    basefile %>%
      mutate(los = los_old) %>%
      summarise_data(category = "comparison",
                     category_split = "old",
                     include_years = "all",
                     format_numbers = FALSE)
      
  )


### 5 - Write data to excel workbooks ----
# This section of the code writes the data produced above into the template excel outputs
# Firstly, read in the figures template saved in the reference files folder

figures <- loadWorkbook(here("reference-files", "figures-template.xlsx"))

# Read in the data produced above into the 'data' tab, start from column 2
# Column 1 is an index variable produced by combining financial year, category and category split

writeData(figures,
          "data",
          excel_data %>% select(-(deaths:hosp)),
          startCol = 2)

# Looks at the 'calculation' tab, define if publication is provisional or standard update, this helps complete the 'Notes' tab

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

# Inserts figure 2 which is the map, defining the width and height of the image and where it should be placed on the page
# The map has to be created and inserted separately

insertImage(figures,
            "Figure 2",
            here("markdown", "figures", "figure-2.png"),
            width = 10, height = 12, 
            units = "cm", dpi = 600,
            startCol = 2,
            startRow = 7)

# Adds a hyperlink to the note produced on row 19, column 3 of the 'Notes', also hides the 'Data' and 'Calculation' tabs

writeData(figures, 
          "Notes", 
          startRow = 19,
          startCol = 3,
          x = link)

sheetVisibility(figures)[13:14] <- "hidden"

# Saves the figures excel document in the output folder, adding publication date to the file name

saveWorkbook(figures,
             here("output", glue("{pub_date}_figures.xlsx")),
             overwrite = TRUE)

# Read in the qom template saved in the referene files folder

qom <- loadWorkbook(here("reference-files", "qom-template.xlsx"))

# Read in the data produced above into the 'data' tab, starting from column 2, column 1 is an index variable
# All data tables and charts should now be populated

writeData(qom, 
          "data",
          excel_data %>% select(-(qom_hosp:hosp)),
          startCol = 2)

#This looks at the 'calculation' tab, defining if the publication is either provisional or an update, this completes the 'Notes' tab

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

# Creates a hyperlink on row 16, column 3 of the 'Notes' tab, also hides the 'Data' and 'Calculation' tabs

writeData(qom,
          "Notes", 
          startRow = 16,
          startCol = 3,
          x = link)

sheetVisibility(qom)[13:14] <- "hidden"

# Save the qom excel file in the output folder, adding publication dates to the file name

saveWorkbook(qom,
             here("output", glue("{pub_date}_qom.xlsx")),
             overwrite = TRUE)
  

### END OF SCRIPT ###