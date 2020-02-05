## R Project Structure

The following provides a description of each folder and file in the publication repository. For more information on what specific files need to be run, please see the [SOP](/sop/sop.md).

### code/

* **00_setup-environment.R** - This script loads all packages required by the scripts in the repo and defines all parameters required to produce the basefile; e.g. dates, external cause of death codes, etc. This script is automatically run at the beginning of every R script that is run.
* **01_create-basefile.R** - This script extracts data from SMRA, calculates length of stay in the last 6 months for each death, and aggregates to the required level for the basefile.
* **02_old-method.R** - This script uses the SMRA extracts created in the previous script and applies the old methodology (to count Care Home episodes as hospital activity). The script then appends an extra column, `los_old`, to the basefile. This is then used to provide a methodology comparison in an appendix of the report.
* **03_create-figures.R** - This script uses the basefile to create a .png file of every figure to be included in the report and summary.
* **04_create-excel-tables.R** - This script uses the basefile to populate the excel templates (see below [reference-files/](#reference-files). 
* **05_create-open-data.R** - This script uses the basefile to produce six .csv files to be uploaded to the [NHS Scotland Open Data platform](https://www.opendata.nhs.scot/dataset/palliative-and-end-of-life-care).
* **06_knit-markdown.R** - This script runs the two markdown files; `markdown/summary.Rmd` and `markdown/report.Rmd`, and saves their output to the `output/` folder.

### functions/
The scripts in this folder define functions that are sourced and used by the scripts in the `code/` and `markdown/` folders.

* **completeness.R** - Given the end date of the publication reporting period, this function sources SMR01 completeness information from the [NHS Scotland Open Data platform](https://www.opendata.nhs.scot/dataset/scottish-morbidity-record-completeness) and formats this as a table for use in the report appendix.
* **day_diff.R** - Given two QoM figures representing the percentage of the last six months, this function calculates the difference in average days between these two figures.
* **extract_date.R** - Given the publication date, this function finds the date the relevant basefile was created. This is used in the metadata table in the report.
* **flextable_style.R** - Given a flextable object, this function applies required formatting for tables in publication report; e.g. purple background in header, bold Scotland row, etc.
* **sql_queries.R** - This script defines three functions, defining a SQL query for each of the following; NRS Deaths, SMR01 and SMR04. Each function takes the extract start date, end date, external and fall cause of death codes. The SMR01 function also takes an argument to define whether a GLS extract is required or not. Each function returns a SQL query as a string. 
* **summarise_data.R** - This function takes the basefile and named variables to breakdown by, returning a tibble with commonly used figures required for outputs; e.g. QoM, number of deaths, average days spent in hospital, etc. The function also takes arguments to control which financial years are returned and whether figures are formatted.

### markdown/
The templates in this folder are adapted from the [National Stats Templates](https://github.com/NHS-NSS-transforming-publications/National-Stats-Template) produced by the TPP team.

* **cover-page-provisional.docx** - The template cover page added to the provisional publication report.
* **cover-page-update.docx** - Same as above but for the update version.
* **report-template.docx** - The template used for styles and formatting of the publication report.
* **report.Rmd** - The R Markdown script used to produce the publication report.
* **summary-template.docx** - The template used for styles and formatting of the publication summary.
* **summary.Rmd** - The R Markdown script used to produce the publication summary.
* **figures/** - The .png files produced by the `code/03_create-figures.R` script are saved here. This folder is not tracked by git.

### reference-files/
The files in this folder are used by the `code/04_create-excel-tables.R` script to produce the final publication excel tables.

* **figures-template.xlsx** - Contains a tab for each figure in the publication report and a tab containing the data used to produce each.
* **qom-template.xlsx** - Contains trend data tables and charts for various breakdowns of the data.

### data/
This folder is not tracked by git, however it can be found in the master copy of this repository on the network containing an archive of all data outputs as follows:

* **basefiles/** - The files in this folder are produced by scripts `01` and `02` in the `code/` folder. They contain all the data required to produce the publication. This folder acts as an archive by date stamping each file with the publication date; e.g. `2019-10-08_base-file.rds`.
* **extracts/** - This folder contains the original data extracts from SMRA including NRS Deaths, SMR01 and SMR04. These are also date stamped with the publication date to enable a historic publication to be reproduced if required.
* **open-data/** - The `code/05_create-open-data.R` script produces the six files that are uploaded to NHS Scotland Open Data platform. These .csv files are saved in this folder.

### output/
As with the `data/` folder, this folder isn't tracked by git, but can be found in the master copy of this repository on the network. For each publication release, this folder will contain two excel files produced by the `code/04_create-excel-tables.R` script, as well as the summary and report word documents, produced by the `code/06_knit-markdown.R` script.

### sop/
Guidance documents detailing how to use this Reproducible Analytical Pipeline (RAP). 
* **Standard Operating Procedure (SOP)** - A step by step guide to produce the publication.
* **R Project Structure** (this document) - A description of each file in the repostiory and how these all fit together.
* **Methodology** - More information on methodologies used where R code isn't self explanatory.

### Other folders/files in the repo

* **.gitignore** - This file lists any files and folders that should not be tracked by git. For more information of what should be included see the [TPP team's GitHub Guidance](https://github.com/NHS-NSS-transforming-publications/GitHub-guidance).
* **.git/** - This is the folder containing the version control history of the repository. It can be safely ignored.
* **.Rproj.user/** - Where project-specific temporary files are saved. This can be safely ignored.
* **README.md** - The short text introduction that is displayed when viewing the repository on GitHub.
* **end-of-life-pub.Rproj** - The R project file for the repository. This can be safely ignored.
