#########################################################################
# Name of file - 06_knit-markdown.R
# Data release - End of Life Publication
# Original Authors - Alice Byers
# Orginal Date - December 2019
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Knit report and summary Rmd files.
#
# Approximate run time - xx minutes
#########################################################################


### 1 - Setup environment ----

source(here::here("code", "00_setup-environment.R"))


### 2 - Knit markdown report and summary
# Creates summary file using template summary document
# Implements required information using the 'summary.Rmd' file

render(
  input = here("markdown", "summary.Rmd"),
  output_file = here("output", glue("{pub_date}_summary.docx"))
)

# Creates report using template report file
# Implements required information using the 'report.Rmd' file

render(
  input = here("markdown", "report.Rmd"),
  output_file = here("output", glue("{pub_date}_report.docx"))
)


### END OF SCRIPT ###