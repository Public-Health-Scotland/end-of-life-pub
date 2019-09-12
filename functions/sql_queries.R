#########################################################################
# Name of file - sql_queries.R
# Data release - End of Life Publication
# Original Authors - Alice Byers
# Orginal Date - September 2019
#
# Written/run on - RStudio Server
# Version of R - 3.2.3
#
# Description - Functions for extracting data.
#
# Approximate run time - xx minutes
#########################################################################


### 1 - Deaths query ----

deaths_query <- function(extract_start, extract_end, external_causes){
  
  glue("select link_no, date_of_death, postcode, ",
       
       # Age groups
       "case when age between 0 and 54 then '0-54' ",
       "when age between 55 and 64 then '55-64' ",
       "when age between 65 and 74 then '65-74' ",
       "when age between 75 and 84 then '75-84' ",
       "when age >= 85 then '85+' ",
       "else 'null' ",
       "end age_grp, ",
       
       # Sex
       "case when sex = '1' then 'Male' ",
       "when sex = '2' then 'Female' ",
       "else 'null' ",
       "end sex, ",
       
       # Financial year of death
       "case when extract(month from date_of_death) between 1 and 3 ",
       "then concat(to_char(add_months(date_of_death, -12), 'yyyy'), ",
       "concat('/', to_char(date_of_death, 'yy'))) ",
       "else concat(to_char(date_of_death, 'yyyy'), ",
       "concat('/', to_char(add_months(date_of_death, 12), 'yy'))) ",
       "end fy, ",
       
       # Financial quarter of death
       "case when extract(month from date_of_death) between 4 and 6 then '1' ",
       "when extract(month from date_of_death) between 7 and 9 then '2' ",
       "when extract(month from date_of_death) between 10 and 12 then '3' ",
       "when extract(month from date_of_death) between 1 and 3 then '4' ",
       "end quarter ",
       
       "from analysis.gro_deaths_c ",
       
       # Exclude external causes of death
       "where {{fn left(underlying_cause_of_death, 3)}} not in ",
       "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')}) ",
       
       "and ({{fn left(cause_of_death_code_0, 3)}} is null or ",
       "{{fn left(cause_of_death_code_0, 3)}} not in ",
       "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",

       "and ({{fn left(cause_of_death_code_1, 3)}} is null or ",
       "{{fn left(cause_of_death_code_1, 3)}} not in ",
       "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",

       "and ({{fn left(cause_of_death_code_2, 3)}} is null or ",
       "{{fn left(cause_of_death_code_2, 3)}} not in ",
       "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",

       "and ({{fn left(cause_of_death_code_3, 3)}} is null or ",
       "{{fn left(cause_of_death_code_3, 3)}} not in ",
       "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",

       "and ({{fn left(cause_of_death_code_4, 3)}} is null or ",
       "{{fn left(cause_of_death_code_4, 3)}} not in ",
       "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",

       "and ({{fn left(cause_of_death_code_5, 3)}} is null or ",
       "{{fn left(cause_of_death_code_5, 3)}} not in ",
       "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",

       "and ({{fn left(cause_of_death_code_6, 3)}} is null or ",
       "{{fn left(cause_of_death_code_6, 3)}} not in ",
       "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",

       "and ({{fn left(cause_of_death_code_7, 3)}} is null or ",
       "{{fn left(cause_of_death_code_7, 3)}} not in ",
       "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",

       "and ({{fn left(cause_of_death_code_8, 3)}} is null or ",
       "{{fn left(cause_of_death_code_8, 3)}} not in ",
       "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",

       "and ({{fn left(cause_of_death_code_9, 3)}} is null or ",
       "{{fn left(cause_of_death_code_9, 3)}} not in ",
       "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
       
       # Select deaths in reporting period
       "and (date_of_death between ",
       "to_date({shQuote(extract_start, type = 'sh')}, 'yyyy-mm-dd') ",
       "and to_date({shQuote(extract_end, type = 'sh')}, 'yyyy-mm-dd')) ",
       
       # Exclude deaths with missing postcode
       "and postcode is not null"
       
  )
  
}
  
  
### 2 - SMR01 query ----

smr01_query <- function(extract_start, 
                        extract_end,
                        external_causes,
                        gls){
  
  data <- if_else(gls == TRUE, "smr01_1e_pi", "smr01_pi")
  
  extract_start_smr <- extract_start - months(6)
  
  glue(
    "select s.link_no, s.gls_cis_marker, ",
    "s.admission_date, s.discharge_date, d.date_of_death ",
    
    "from analysis.{data} s, analysis.gro_deaths_c d ",
    
    # Only extract SMR records with matching death record
    "where s.link_no = d.link_no ",
    
    # Inpatients only
    "and s.inpatient_daycase_identifier = 'I' ",
    
    # Select records in reporting period (and six months before)
    "and s.discharge_date between ",
    "to_date({shQuote(extract_start_smr, type = 'sh')}, 'yyyy-mm-dd') ",
    "and to_date({shQuote(extract_end, type = 'sh')}, 'yyyy-mm-dd') ",
    
    # Exclude external causes of death
    "and {{fn left(d.underlying_cause_of_death, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')}) ",

    "and ({{fn left(d.cause_of_death_code_0, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_0, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_1, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_1, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_2, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_2, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_3, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_3, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_4, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_4, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_5, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_5, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_6, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_6, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_7, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_7, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_8, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_8, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_9, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_9, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    # Select deaths in reporting period
    "and (d.date_of_death between ",
    "to_date({shQuote(extract_start, type = 'sh')}, 'yyyy-mm-dd') ",
    "and to_date({shQuote(extract_end, type = 'sh')}, 'yyyy-mm-dd')) ",
    
    # Sort
    "order by s.link_no, s.admission_date, s.discharge_date, ",
    "s.admission, s.discharge, s.uri"
    
  )
  
}


### 3 - SMR04 query ----

smr04_query <- function(extract_start, 
                        extract_end,
                        external_causes){
  
  extract_start_smr <- extract_start - months(6)
  
  glue(
    "select s.link_no, s.cis_marker, ",
    "s.admission_date, s.discharge_date, d.date_of_death ",
    
    "from analysis.smr04_pi s, analysis.gro_deaths_c d ",
    
    # Only extract SMR records with matching death record
    "where s.link_no = d.link_no ",
    
    # Inpatients only
    "and s.management_of_patient in ('1', '3', '5', '7', 'A') ",
    
    # Select records in reporting period (and six months before and 
    # missing discharge date)
    "and (s.discharge_date between ",
    "to_date({shQuote(extract_start_smr, type = 'sh')}, 'yyyy-mm-dd') ",
    "and to_date({shQuote(extract_end, type = 'sh')}, 'yyyy-mm-dd') ",
    "or discharge_date is null) ",
    
    # Exclude external causes of death
    "and {{fn left(d.underlying_cause_of_death, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')}) ",

    "and ({{fn left(d.cause_of_death_code_0, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_0, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_1, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_1, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_2, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_2, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_3, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_3, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_4, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_4, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_5, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_5, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_6, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_6, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_7, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_7, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_8, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_8, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    "and ({{fn left(d.cause_of_death_code_9, 3)}} is null or ",
    "{{fn left(d.cause_of_death_code_9, 3)}} not in ",
    "({paste0(shQuote(external_causes, type = 'sh'), collapse = ',')})) ",
    
    # Select deaths in reporting period
    "and (d.date_of_death between ",
    "to_date({shQuote(extract_start, type = 'sh')}, 'yyyy-mm-dd') ",
    "and to_date({shQuote(extract_end, type = 'sh')}, 'yyyy-mm-dd')) ",
    
    # Sort
    "order by s.link_no, s.admission_date, s.discharge_date, ",
    "s.admission, s.discharge, s.uri"
    
  )
  
}
  

### END OF SCRIPT ###