## R Project Structure

The following provides a description of each folder and file in the publication repository. For more information on what specific files need to be run, please see the [SOP](sop/sop.md).

### code/

* **00_setup-environment.R** - This script loads all packages required by the scripts in the repo, 
* **01_create-basefile.R** - 
* **02_old-method.R** -
* **03_create-figures.R** -
* **04_create-excel-tables.R** -
* **05_create-open-data.R** -

### functions/
The scripts in this folder define functions that are sourced and used by the scripts in the `code/` and `markdown/` folders.

* **completeness.R** -
* **day_diff.R** -
* **extract_date.R** -
* **sql_queries.R** -
* **summarise_data.R** -

### markdown/

* **cover-page.docx** -
* **report-template.docx** -
* **report.Rmd** -
* **summary-template.docx** -
* **summary.Rmd** -
* **figures/** - This folder is not tracked by git as it contains unreleased data.

### reference-files/
The files in this folder are used by the `code/04_create-excel-tables.R` script to produce the final publication excel tables.

* **figures-template.xlsm** - 
* **qom-template.xlsm** -

### data/
This folder is not tracked by git, however it can be found in the master copy of this repository on the network containing an archive of all data outputs as follows:

* **basefiles/** - The files in this folder are produced by scripts `01` and `02` in the `code/` folder. They contain all the data required to produce the publication. This folder acts as an archive by date stamping each file with the publication date; e.g. `2019-10-08_base-file.rds`.
* **excel-output/** - This folder contains the two excel files that are released as part of the publication. These are created and saved here by the `code/04_create-excel-tables.R` script.
* **extracts/** - This folder contains the original data extracts from SMRA including NRS Deaths, SMR01 and SMR04. These are also date stamped with the publication date to enable a historic publication to be reproduced if required.
* **open-data/** - The `code/05_create-open-data.R` script produces the six files that are uploaded to NHS Scotland Open Data platform. These .csv files are saved in this folder.

### Other folders/files in the repo

* **.gitignore** - This file lists any files that should not be tracked by git. For more information of what should be included see the [TPP team's GitHub Guidance](https://github.com/NHS-NSS-transforming-publications/GitHub-guidance).
* **.git/** - This is the folder containing the version control history of the repository. It can be safely ignored.
* **.Rproj.user/** - Where project-specific temporary files are saved. This can be safely ignored.
* **README.md** - The short text introduction that is displayed when viewing the repository on GitHub.
* **end-of-life-pub.Rproj** - The R project file for the repository. This can be safely ignored.
