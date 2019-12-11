## Percentage of End of Life Spent at Home or in a Community Setting

## Contents
* [Preparation](#preparation)
* [Running the Publication](#running-the-publication)

## Preparation

* **Update Report and Summary templates** - Go to the [TPP repo](https://github.com/NHS-NSS-transforming-publications/National-Stats-Template) containing these templates and update the versions in the reference-files folder of this repo.
Check whether the report and summary templates have been updated since the last publication.

* Check SMR completeness.

* If you have not run this publication before, there are a few steps to follow to set up Microsoft Word to format report and summary. Follow the instructions in the [TPP repo](https://github.com/NHS-NSS-transforming-publications/National-Stats-Template).

## Running the Publication

### Run R Scripts

The only R script which requires manual updates is `code/00_setup-environment.R`. In section 3 of this script, update dates as required and define whether the release version is provisional or update. There is no need to run this script once updated.

Run each of the scripts in the `code` folder in order from `01_create-basefile.R` to `05_create-open-data.R` in turn. No changes are required to be made to the code in these scripts.

Knit both `markdown/report.Rmd` and `markdown/summary.Rmd`. 

Following these steps will produce all publication documents.

### Manual changes to Summary and Reports

### Open Data

### Notes
* Methodology information
* Folder structure
* Importance of not making manual updates and editing master directly
* Archiving
* How to feedback on report/summary wording
* Built in checks
