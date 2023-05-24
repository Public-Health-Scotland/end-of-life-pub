#########################################################################
# Name of file - 01_create-basefile.R / his_ir_part2.R
# Data release - End of Life Publication / HIS IR2023-00329 part1 / HIS IR2023-00364 part2
# Original Authors - Alice Byers / Sam Colville part1 / Sissi Pizzo part2
# Orginal Date - September 2019 / May 2023 part1 and part2
#
# Written/run on - RStudio Server / Posit
# Version of R - 3.2.3 / 4.1.2
#
# Description - Create base file.
#
# Approximate run time - xx minutes
#########################################################################

### 1 - Setup environment and load functions ----

source(here::here("code", "00_setup-environment_ir_part2.R"))
source(here::here("functions", "sql_queries_ir_part2.R"))
#source(here::here("functions", "completeness.R"))            # No need of this for this request
#source(here::here("functions", "completeness_workaround.R")) # No need of this for this request
source(here::here("functions", "summarise_data_IR.R"))

### 2 - Open SMRA Connection ----

smra_connect <- dbConnect(odbc(), 
                          dsn  = "SMRA",
                          uid  = .rs.askForPassword("SMRA Username:"), 
                          pwd  = .rs.askForPassword("SMRA Password:"))


### 3 - Extract data ----
# Read in GRO deaths, SMR01 (including GLS) and SMR04 using dates defined in previous syntax
# Access to these data sets are required via data authoriser in order to be able to run


deaths <- 
  as_tibble(dbGetQuery(smra_connect, 
                       deaths_query_full(extract_start = start_date,
                                    extract_end = end_date,
                                    external_causes = external,
                                    falls = falls))) %>% 
  clean_names()



smr01 <- 
  
  as_tibble(dbGetQuery(smra_connect, 
                       smr01_query(extract_start = start_date,
                                   extract_end = end_date,
                                   external_causes = external,
                                   falls = falls,
                                   gls = FALSE))) %>% 
  
  bind_rows(as_tibble(dbGetQuery(smra_connect, 
                                 smr01_query(extract_start = start_date,
                                             extract_end = end_date,
                                             external_causes = external,
                                             falls = falls,
                                             gls = TRUE)))) %>%
  
  clean_names()


smr04 <- 
  as_tibble(dbGetQuery(smra_connect, 
                       smr04_query(extract_start = start_date,
                                   extract_end = end_date,
                                   external_causes = external,
                                   falls = falls))) %>% 
  clean_names()


### 4 - Save data extracts ----

write_rds(deaths, 
          here("data", "extracts", glue("{pub_date}_deaths.rds")),
          compress = "gz")
write_rds(smr01,
          here("data", "extracts", glue("{pub_date}_smr01.rds")),
          compress = "gz")
write_rds(smr04,
          here("data", "extracts", glue("{pub_date}_smr04.rds")),
          compress = "gz")

# Read in previous extracts to prevent having run queries during script updates/changes
# deaths <- read_rds( 
#           here("data", "extracts", glue("{pub_date}_deaths.rds")))
# smr01 <- read_rds(
#           here("data", "extracts", glue("{pub_date}_smr01.rds")))
# smr04 <- read_rds(
#           here("data", "extracts", glue("{pub_date}_smr04.rds")))
# 


### 5 - Aggregate SMR data to CIS level ----
# Aggregate SMR01 and SMR04 data by CIS which includes community care home episodes, these are flagged and removed

smr01 %<>%
  group_by(link_no) %>%
  arrange(admission_date) %>%
  mutate(index = c(0, cumsum(lead(ch_flag) != ch_flag | 
                               lead(gls_cis_marker) != gls_cis_marker)[-n()])) %>%
  filter(ch_flag == 0) %>%
  group_by(link_no, index) %>%
  summarise(admission_date = min(admission_date),
            discharge_date = max(discharge_date),
            date_of_death = max(date_of_death)) %>%
  ungroup() %>%
  select(-index)

smr04 %<>%
  group_by(link_no) %>%
  arrange(admission_date) %>%
  mutate(index = c(0, cumsum(lead(ch_flag) != ch_flag | 
                               lead(cis_marker) != cis_marker)[-n()])) %>%
  filter(ch_flag == 0) %>%
  group_by(link_no, index) %>%
  summarise(admission_date = min(admission_date),
            discharge_date = max(discharge_date),
            date_of_death = max(date_of_death)) %>%
  ungroup() %>%
  select(-index)


### 6 - Join SMR01/50 and SMR04 data ----
# Combine SMR01 and SMR04 files, aggregate and remove records where stays overlap

smr <-
  
  bind_rows(smr01 %>% mutate(recid = "01"), 
            smr04 %>% mutate(recid = "04")) %>%
  
  # Aggregate where SMR01 and SMR04 stays overlap
  group_by(link_no) %>%
  arrange(admission_date) %>%
  mutate(index = c(0, cumsum(as.numeric(lead(admission_date)) >
                               cummax(as.numeric(discharge_date)))[-n()])) %>%
  group_by(link_no, index) %>%
  summarise(admission_date = min(admission_date),
            discharge_date = max(discharge_date),
            date_of_death  = max(date_of_death)) %>%
  ungroup() %>%
  select(-index)


### 7 - Calculate measure ----

smr %<>%
  
  # Calculate date twelve months before death
  mutate(twelve_months = date_of_death - days(365)) %>%
  
  # For stays spanning this date, fix admission date to twelve months before death
  mutate(admission_date = if_else(admission_date < twelve_months & 
                                    discharge_date >= twelve_months,
                                  twelve_months,
                                  admission_date)) %>%
  
  # Select only stays within last twelve months of life
  filter(admission_date >= twelve_months) %>%
  
  # Remove records where admission date is after date of death
  filter(admission_date <= date_of_death) %>%
  
  # Where discharge date is after date of death, fix to date of death
  mutate(discharge_date = if_else(discharge_date > date_of_death,
                                  date_of_death,
                                  discharge_date)) %>%
  
  # Calculate length of stay
  mutate(los = time_length(interval(admission_date, discharge_date),
               "days")) %>%

  # Aggregate to patient level
  group_by(link_no) %>%
  summarise(los = sum(los)) %>%
  ungroup() %>%
  
  # Recode 183 LOS to 182.5 (exact six months)
  mutate(los = if_else(los == 183, 182.5, los))


### 8 - Match on lookup files to deaths ----

# Match on postcode, SIMD and locality information to the deaths data set

deaths %<>%
  
  left_join(postcode(), by = c("postcode" = "pc7")) %>%
  left_join(simd(), by = c("postcode" = "pc7")) %>%
  left_join(locality(), by = "datazone2011")

private  <- c("G412V", "G502V", "L330V", "S124V")

other  <- c("G585C", "N693C", "V205C", "Y177C", "S142V")

comm_hosp <- function(){
  
  haven::read_sav(glue("/conf/irf/03-Integration-Indicators/02-MSG/",
                       "01-Data/05-EoL - Community Hospital Lookup/",
                       "HospTypesComm.sav")) %>%
    
    clean_names()
  
}

deaths %<>%
  
  mutate(location_death = case_when(
    #Specific Codes
    institution == "G588C" ~ "Hospital",
    
    # Hospital
    institution %in% comm_hosp() ~ "Hospital",
    substr(institution, 5, 5) %in% c("H") ~ "Hospital",
    institution %in% private ~ "Hospital",
    
    # Home & Other
    institution == "D201N" ~ "Home",
    institution == "d201n" ~ "Home",
    institution  %in% other ~ "Other",
    TRUE ~ "Other"
    
  ))

### 9 - Create flags for specific Causes of Death groupings ----

deaths_flags <- deaths %>%
  mutate(
    cancer = purrr::pmap_dbl(select(., contains("cause_of_")),
                                      ~any(grepl("^C[0-8]|^C9[0-7]", c(...)),
                                           na.rm = TRUE) * 1),
    
    circ_sys_dis = purrr::pmap_dbl(select(., contains("cause_of_")),
                                   ~any(grepl("^I[0-9]", c(...)),
                                        na.rm = TRUE) * 1),
    
    ischaemic = purrr::pmap_dbl(select(., contains("cause_of_")),
                                   ~any(grepl("^I2[0-5]", c(...)),
                                        na.rm = TRUE) * 1),
    
    stroke = purrr::pmap_dbl(select(., contains("cause_of_")),
                                   ~any(grepl("^I6[0-9]", c(...)),
                                        na.rm = TRUE) * 1),
    
    respiratory = purrr::pmap_dbl(select(., contains("cause_of_")),
                                   ~any(grepl("^J[0-9]", c(...)),
                                        na.rm = TRUE) * 1),
    
    copd = purrr::pmap_dbl(select(., contains("cause_of_")),
                                   ~any(grepl("^J4[0-4]", c(...)),
                                        na.rm = TRUE) * 1),
    
    dementia = purrr::pmap_dbl(select(., contains("cause_of_")),
                                   ~any(grepl("^F0[1-3]|^G30", c(...)),
                                        na.rm = TRUE) * 1),
    
    #Accidental/Falls label when creating output files
    accidental = purrr::pmap_dbl(select(., contains("cause_of_")),
                                   ~any(grepl("^W01|^W0[3-8]|^W10|^W1[7-9]", c(...)),
                                        na.rm = TRUE) * 1),
    
    alcohol = purrr::pmap_dbl(select(., contains("cause_of_")),
                              ~any(grepl("^E244|^F10|^G312|^G621|^G721|^I426|^K292|^K70|^K852|^K860|^Q860|^R780|^X45|^X65|^Y15", c(...)),
                                   na.rm = TRUE) * 1),
    
    drug = purrr::pmap_dbl(select(., contains("cause_of_")),
                           ~any(grepl("F1[1-6]|^F19|^X4[0-4]|^X6[0-4]|^X85|^Y1[0-4]", c(...)),
                                na.rm = TRUE) * 1),
    
    covid = purrr::pmap_dbl(select(., contains("cause_of_")),
                                   ~any(grepl("^U071|^U072|^U099|^U109", c(...)),
                                        na.rm = TRUE) * 1),
      )


### 10 - Create final basefile ----
# Match on deaths data set to SMR by link number, keep required variables and save

final_ir <-
  
  left_join(deaths_flags, smr, by = "link_no") %>%
  
  group_by(fy, quarter, hb, hbcode, ca, cacode, hscp, hscpcode,
           ca2018, hscp2018, locality, simd, simd_15, sex, age_grp, 
           urban_rural, urban_rural_2, location_death, cancer, circ_sys_dis, 
           ischaemic, stroke, respiratory, copd, dementia,
           accidental, alcohol, drug, covid) %>%
  
  summarise(los = sum(los, na.rm = TRUE),
            deaths = n()) %>%
  
  ungroup()


write_rds(final_ir, 
          here("data", "basefiles", glue("{pub_date}_base-file_IR_part2.rds")),
          compress = "gz")


### 11 - Create excel summaries for hospital and other location of death ----

basefile_IR <- final_ir %>%
  mutate_at(vars(cancer:covid), as.character) 

rm(final_ir)

basefile_IR_hosp <- basefile_IR %>% 
  filter(location_death == 'Hospital')

basefile_IR_other <- basefile_IR %>% 
  filter(location_death == 'Other')


# For the hospital setting add on extra ICD-10 groupings flags

excel_data_IR_hosp <-
  
  bind_rows(
    
    # Scotland level outputs for all financial years
    basefile_IR_hosp %>%
      summarise_data(category = "Scotland",
                     category_split = "Scotland",
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Health Board output for all financial years, health board name the category split
    basefile_IR_hosp %>%
      summarise_data(category = "hb", 
                     category_split = hb,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Council Area output for all financial years, council area name the category split
    basefile_IR_hosp %>%
      summarise_data(category = "ca", 
                     category_split = ca,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Age/Sex output with a combination of the age group and sex as the category split, for all financial years
    basefile_IR_hosp %>%
      filter(!is.na(sex)) %>% 
      summarise_data(category = "age/sex", 
                     category_split = paste(age_grp, sex),
                     include_years = "all",
                     format_numbers = FALSE),
    
    # All Ages/Sex output with age groups combined to 'All ages' and sex defined as the category split for all financial years
    basefile_IR_hosp %>%
      filter(!is.na(sex)) %>%
      summarise_data(category = "age/sex", 
                     category_split = paste("All Ages", sex),
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Age/All Sex output with the patient sex combined to 'Both' to have age group and both as category split, for all financial years
    basefile_IR_hosp %>%
      summarise_data(category = "age/sex", 
                     category_split = paste(age_grp, "Both"),
                     include_years = "all",
                     format_numbers = FALSE),
    
    # All Ages/All Sex output with age groups combined to 'All ages' and gendr combined to 'Both' with All ages/Both as the category split
    basefile_IR_hosp %>%
      summarise_data(category = "age/sex",
                     category_split = paste("All Ages", "Both"),
                     include_years = "all",
                     format_numbers = FALSE),
    
    # SIMD quintile as the category, with SIMD 1-5 as the category split for all financial years
    basefile_IR_hosp %>%
      summarise_data(category = "simd quintile", 
                     category_split = simd,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # SIMD Top 15% as the category with the top 15% most deprived and other 85% as the category split for all financial years
    basefile_IR_hosp %>%
      summarise_data(category = "simd 15", 
                     category_split = simd_15,
                     include_years = "all",
                     format_numbers = FALSE),

    # Each of the specified ICD-10 groupings split, for all financial years 
    basefile_IR_hosp %>%
      summarise_data(category = "Cancer", 
                     category_split = cancer,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_hosp %>%
      summarise_data(category = "Circulatory system diseases", 
                     category_split = circ_sys_dis,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_hosp %>%
      summarise_data(category = "Ischaemic (coronary) heart disease", 
                     category_split = ischaemic,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_hosp %>%
      summarise_data(category = "Cerebrovascular disease (stroke)",  
                     category_split = stroke,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_hosp %>%
      summarise_data(category = "Respiratory Diseases", 
                     category_split = respiratory,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_hosp %>%
      summarise_data(category = "Chronic Obstructive Pulmonary Disease", 
                     category_split = copd,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_hosp %>%
      summarise_data(category = "Dementia and Alzheimer's disease", 
                     category_split = dementia,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_hosp %>%
      summarise_data(category = "Accidental deaths that occur within the home", 
                     category_split = accidental,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_hosp %>%
      summarise_data(category = "Alcohol-specific", 
                     category_split = alcohol,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_hosp %>%
      summarise_data(category = "Drug", 
                     category_split = drug,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_hosp %>%
      summarise_data(category = "COVID-19", 
                     category_split = covid,
                     include_years = "all",
                     format_numbers = FALSE)
    
    
    

  ) %>%
  
  mutate(qom = round(qom, digits = 1))


write_rds(excel_data_IR_hosp, 
          here("output", glue("{pub_date}_raw_excel_data_ir_part2_hosp.rds")),
          compress = "gz")

# For the Other setting add on extra ICD-10 groupings flags

excel_data_IR_other <-
  
  bind_rows(
    
    # Scotland level outputs for all financial years
    basefile_IR_other %>%
      summarise_data(category = "Scotland",
                     category_split = "Scotland",
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Health Board output for all financial years, health board name the category split
    basefile_IR_other %>%
      summarise_data(category = "hb", 
                     category_split = hb,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Council Area output for all financial years, council area name the category split
    basefile_IR_other %>%
      summarise_data(category = "ca", 
                     category_split = ca,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Age/Sex output with a combination of the age group and sex as the category split, for all financial years
    basefile_IR_other %>%
      filter(!is.na(sex)) %>% 
      summarise_data(category = "age/sex", 
                     category_split = paste(age_grp, sex),
                     include_years = "all",
                     format_numbers = FALSE),
    
    # All Ages/Sex output with age groups combined to 'All ages' and sex defined as the category split for all financial years
    basefile_IR_other %>%
      filter(!is.na(sex)) %>%
      summarise_data(category = "age/sex", 
                     category_split = paste("All Ages", sex),
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Age/All Sex output with the patient sex combined to 'Both' to have age group and both as category split, for all financial years
    basefile_IR_other %>%
      summarise_data(category = "age/sex", 
                     category_split = paste(age_grp, "Both"),
                     include_years = "all",
                     format_numbers = FALSE),
    
    # All Ages/All Sex output with age groups combined to 'All ages' and gendr combined to 'Both' with All ages/Both as the category split
    basefile_IR_other %>%
      summarise_data(category = "age/sex",
                     category_split = paste("All Ages", "Both"),
                     include_years = "all",
                     format_numbers = FALSE),
    
    # SIMD quintile as the category, with SIMD 1-5 as the category split for all financial years
    basefile_IR_other %>%
      summarise_data(category = "simd quintile", 
                     category_split = simd,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # SIMD Top 15% as the category with the top 15% most deprived and other 85% as the category split for all financial years
    basefile_IR_other %>%
      summarise_data(category = "simd 15", 
                     category_split = simd_15,
                     include_years = "all",
                     format_numbers = FALSE),
    
    # Each of the specified ICD-10 groupings split, for all financial years 
    basefile_IR_other %>%
      summarise_data(category = "Cancer", 
                     category_split = cancer,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_other %>%
      summarise_data(category = "Circulatory system diseases", 
                     category_split = circ_sys_dis,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_other %>%
      summarise_data(category = "Ischaemic (coronary) heart disease", 
                     category_split = ischaemic,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_other %>%
      summarise_data(category = "Cerebrovascular disease (stroke)",  
                     category_split = stroke,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_other %>%
      summarise_data(category = "Respiratory Diseases", 
                     category_split = respiratory,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_other %>%
      summarise_data(category = "Chronic Obstructive Pulmonary Disease", 
                     category_split = copd,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_other %>%
      summarise_data(category = "Dementia and Alzheimer's disease", 
                     category_split = dementia,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_other %>%
      summarise_data(category = "Accidental deaths that occur within the home", 
                     category_split = accidental,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_other %>%
      summarise_data(category = "Alcohol-specific", 
                     category_split = alcohol,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_other %>%
      summarise_data(category = "Drug", 
                     category_split = drug,
                     include_years = "all",
                     format_numbers = FALSE),
    
    basefile_IR_other %>%
      summarise_data(category = "COVID-19", 
                     category_split = covid,
                     include_years = "all",
                     format_numbers = FALSE)
    
    
    
    
  ) %>%
  
  mutate(qom = round(qom, digits = 1))


write_rds(excel_data_IR_other, 
          here("output", glue("{pub_date}_raw_excel_data_ir_part2_other.rds")),
          compress = "gz")


#### Create excel output for Hospital

hb_split_hosp <- excel_data_IR_hosp %>%
  filter(category %in% c("Scotland", "hb")) %>%
  pivot_wider(values_from = qom_hosp,
              names_from = fy,
              id_cols = category_split) %>%
  rename(Healthboard = category_split)

ca_split_hosp <- excel_data_IR_hosp %>%
  filter(category %in% c("Scotland", "ca")) %>%
  pivot_wider(values_from = qom_hosp,
              names_from = fy,
              id_cols = category_split) %>%
  rename(`Council Area` = category_split)

age_sex_split_hosp <- excel_data_IR_hosp %>%
  filter(category %in% c("age/sex")) %>%
  pivot_wider(values_from = qom_hosp,
              names_from = fy,
              id_cols = category_split) %>%
  rename(Age_Sex = category_split)

simd_split_hosp <- excel_data_IR_hosp %>%
  filter(category %in% c("simd quintile")) %>%
  pivot_wider(values_from = qom_hosp,
              names_from = fy,
              id_cols = category_split) %>%
  rename(SIMD = category_split)

icd10_split_hosp <- excel_data_IR_hosp %>% 
  filter(category %in% c("Cancer", "Circulatory system diseases",
                         "Ischaemic (coronary) heart disease",
                         "Cerebrovascular disease (stroke)", "Respiratory Diseases",
                         "Chronic Obstructive Pulmonary Disease", 
                         "Dementia and Alzheimer's disease", 
                         "Accidental deaths that occur within the home", "Alcohol-specific", "Drug",
                         "COVID-19"
                         )) %>%
  filter(category_split == 1) %>%
  pivot_wider(values_from = qom_hosp,
              names_from = fy,
              id_cols = category) %>%
  rename(`ICD-10 Grouping` = category)

# Create empty workbook and worksheets - Hospital

output_ir_hosp <- createWorkbook()

addWorksheet(output_ir_hosp, "Healthboard")
addWorksheet(output_ir_hosp, "Council Area")
addWorksheet(output_ir_hosp, "Age & Gender")
addWorksheet(output_ir_hosp, "SIMD")
addWorksheet(output_ir_hosp, "ICD-10 Groupings")

# Add each split data in to tabs in the workbook - Hospital

writeData(output_ir_hosp, "Healthboard", x = hb_split_hosp)
writeData(output_ir_hosp, "Council Area", x = ca_split_hosp)
writeData(output_ir_hosp, "Age & Gender", x = age_sex_split_hosp)
writeData(output_ir_hosp, "SIMD", x = simd_split_hosp)
writeData(output_ir_hosp, "ICD-10 Groupings", x = icd10_split_hosp)

 
#Save out excel workbook - Hospital

saveWorkbook(output_ir_hosp,
             here("output", glue("{pub_date}_his_ir_qom_hosp.xlsx")),
             overwrite = TRUE)



#### Create excel output for Other - NOTE THAT UNLESS I CHANGE THE FUNCTION'summarise_data_IR', THE VAR qom_hosp CONTAINS VALUES FOR 'qom Other'

hb_split_other <- excel_data_IR_other %>%
  filter(category %in% c("Scotland", "hb")) %>%
  pivot_wider(values_from = qom_hosp,
              names_from = fy,
              id_cols = category_split) %>%
  rename(Healthboard = category_split)

ca_split_other <- excel_data_IR_other %>%
  filter(category %in% c("Scotland", "ca")) %>%
  pivot_wider(values_from = qom_hosp,
              names_from = fy,
              id_cols = category_split) %>%
  rename(`Council Area` = category_split)

age_sex_split_other <- excel_data_IR_other %>%
  filter(category %in% c("age/sex")) %>%
  pivot_wider(values_from = qom_hosp,
              names_from = fy,
              id_cols = category_split) %>%
  rename(Age_Sex = category_split)

simd_split_other <- excel_data_IR_other %>%
  filter(category %in% c("simd quintile")) %>%
  pivot_wider(values_from = qom_hosp,
              names_from = fy,
              id_cols = category_split) %>%
  rename(SIMD = category_split)

icd10_split_other <- excel_data_IR_other %>% 
  filter(category %in% c("Cancer", "Circulatory system diseases",
                         "Ischaemic (coronary) heart disease",
                         "Cerebrovascular disease (stroke)", "Respiratory Diseases",
                         "Chronic Obstructive Pulmonary Disease", 
                         "Dementia and Alzheimer's disease", 
                         "Accidental deaths that occur within the home", "Alcohol-specific", "Drug",
                         "COVID-19"
  )) %>%
  filter(category_split == 1) %>%
  pivot_wider(values_from = qom_hosp,
              names_from = fy,
              id_cols = category) %>%
  rename(`ICD-10 Grouping` = category)

# Create empty workbook and worksheets - Other

output_ir_other <- createWorkbook()

addWorksheet(output_ir_other, "Healthboard")
addWorksheet(output_ir_other, "Council Area")
addWorksheet(output_ir_other, "Age & Gender")
addWorksheet(output_ir_other, "SIMD")
addWorksheet(output_ir_other, "ICD-10 Groupings")

# Add each split data in to tabs in the workbook - Other

writeData(output_ir_other, "Healthboard", x = hb_split_other)
writeData(output_ir_other, "Council Area", x = ca_split_other)
writeData(output_ir_other, "Age & Gender", x = age_sex_split_other)
writeData(output_ir_other, "SIMD", x = simd_split_other)
writeData(output_ir_other, "ICD-10 Groupings", x = icd10_split_other)


# Save out excel workbook - Other

saveWorkbook(output_ir_other,
             here("output", glue("{pub_date}_his_ir_qom_other.xlsx")),
             overwrite = TRUE)


# ### END OF SCRIPT ###
