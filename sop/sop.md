## Percentage of End of Life Spent at Home or in a Community Setting

## Folder Structure

All the publication files and folders are stored in the Publication folder of the End of Life network area. This folder should contain:
* A "master" folder
* A folder named after each analyst who has worked on the publication e.g. a folder called "federico"

### The "master" folder

The **master** folder is the **master copy** of the publication repository. This is the "production-ready" version that is used for the publication process each year. Within it there will be a folder called `data/` containing all data extracts and basefiles used to produce previous publications and an `output/` folder containing publication outputs (e.g. excel tables, summary and report) for all previous publications. The master copy should **never be edited** and should only be updated from approved changes pulled from GitHub.

### Individual analyst folders

These folders also contain up-to-date copies of the repository and these are the versions which are edited each time the publication is updated or each time a change to the process has to be made. Analysts should only work in their own folders on their own development branches. Once they are content that their changes are ready for the master branch, they must create a pull request on GitHub and have other analysts from the team review their changes and, if satisfied, merge them back into the master branch. It is then that the **master folder is updated** by pulling from GitHub.

## Running the Publication

### Preparation

Before starting to run the publication, there are a few things that should be checked:
* **SMR Completeness** - In the run up to publication time, keep an eye on [SMR Completeness](https://www.isdscotland.org/products-and-Services/Data-Support-and-Monitoring/SMR-Completeness/) to ensure this is sufficient for publication. If there are any concerns, these should be raised as early as possible with Data Management.
* **Markdown Templates** - Check whether there have been any updates to the publication templates on GeNSS and if so, make sure these changes are included when [updating the code](#updating-the-code).

If you have not run the publication before, please also follow these one time preparation steps:
* Save custom cover page and footer to Microsoft Word.
   * Open `markdown/cover-page-provisional.docx`. Press Ctrl + A to select all contents. Go to Insert –> Cover Page –> Save Selection to Cover Page Gallery. Give it a name (e.g. eol-provisional) and click OK. Repeat for `cover-page-update.docx`.
   * Double click on the footer in one of the cover page templates (doesn't matter which one), and select the whole footer by pressing Ctrl + A. Select Insert –> Footer –> Save Selection to Footer Gallery. Give it a name (e.g. official-stats-footer) and click OK.
* Both RStudio Server and RStudio Desktop are required to run the publication in full. Ideally, RStudio Server would be used to run all scripts, however the package `flextable` is used by the markdown scripts, which requires a version of pandoc only available when using RStudio v1.2. Neither RStudio Server nor RStudio Desktop versions currently used by ISD have been upgraded to v1.2, however RStudio Desktop can be upgraded to v1.2 on request to IT. **This version of RStudio is a requirement to run this publication.**
* You will need to ensure you have installed all packages that are used in the code - a list of required packages can be found in the `code/00_setup-environment.R` script. This must be done in both RStudio Server and RStudio Desktop. Any that have not been installed can be done so by running `install.packages("<PACKAGE NAME>")`. 
* Two exceptions to this are for the `officedown` package, which is not on CRAN, and the `flextable` package, which has a function not yet on the CRAN version that is used in the code. Instead, these must be installed from their GitHub repositories - [officedown](https://github.com/davidgohel/officedown) and [flextable](https://github.com/davidgohel/flextable). These are only required by the markdown scripts and so only need to be installed on your desktop version of R. To do this, download each repo as a ZIP file, and install by running the following code for each: `remotes::install_local("<FILEPATH OF ZIPPED FILE>/<officedown-master.zip", upgrade = "never")`.

### Updating the code

The project is designed to require as little human intervention as possible. To update the publication, the analyst responsible for updating the scripts/running the publication should complete the following steps. **Note that at no point is there a need to run code in this section.**

* Pull the most recent version of the master branch into their own folder; e.g. 'federico'
* Create a fresh branch to make necessary changes.
* Make updates to the `code/00_setup-environment.R` file
    * Update dates
    * Check filepaths for lookups are still correct
    * Define whether publication is provisional or update version
* Commit and push new branch to GitHub.
* Create pull request on GitHub for another analyst to review changes.
* Once changes have been approved, merge the branch into the master and delete personal branch.
* If no more changes are required, pull the updated master branch into the master folder.

### Running the code

* Ensure you have pulled the updated master branch into the **master folder** before continuing.

* In the **master folder**, open each script in the `code/` folder from `01_create-basefile.R` to `06_knit-markdown.R` in turn and do the following:
    * Highlight the entire script and run
    * Check for any errors and investigate as necessary
    * Check the output of the script looks as it should
    
* The first two scripts, `01_create-basefile.R` and `02_old-method.R` need to be run using the RStudio Server as desktop memory is not sufficient to extract data from SMRA. The last script, `06_knit-markdown.R` must be run using RStudio Desktop v1.2 as it requires pandoc v2 to run successfully (see [preparation section](#preparation)). The other scripts can be run using either Server or Desktop, it doesn't matter.

* When running `03_create-figures.R`, check what Health Boards have the maximum and minimum QoM figures. These boards should be labelled on the map (Figure 2), however the positioning of these labels has not been automated (see [Issue #12](/../../issues/12)) and may need to be tweaked if the max/min boards change.

### Manual Steps

Some manual steps are required to finish off the markdown documents. Once these changes have been made, it is fine to save over the file produced by the markdown script, as these can be reproduced if need be. Also note that if you are using Word 2016, you may get an error message when opening the report document (see [Issue #9](/../../issues/9)). If you click through these errors, indicating that yes you want to recover the document, all content should display correctly. It's unclear what is causing this, however the final output is unafffected.

* Summary
   * Highlight the first three lines of the header; from "Percentage" to "31 March *year* to *year*". Change line spacing to 1.15 and select Remove Space Before Paragraph. This will alter the spacing so that the chart and footnote also fits on the first page of the document.
   * Centre the chart.   

* Report
   * Edit date in header: Double click the header and update the embargo date to the publication date.
   * Add cover page: Ensure the cursor is at the very beginning of the document, then select Insert -> Cover Page and select the relevant (provisional/update) template. Update the date in the purple circle and the embargo date to the publication date.
   * Add footer: With the cursor still on the cover page, select Insert -> Footer and select the custom footer.
   * Add table of contents: Click on the end of last text line on the page “This is a National Publication” (page number 1). Select Insert –> Blank Page, so that a new blank page will be inserted. Next, select References –> Table of Contents. Choose Built-in template Automatic Table 1. Use the Format Painter to format the Contents title text to the same as the header for Introduction on the next page.
   * Centre the map (Figure 2).

* The open data files saved in `data/open-data/` should be copied to the appropriate folder in the Open Data team's network area (there is a shortcut to this in the End of Life publication folder). Make any necessary changes to the metadata document also in this folder; e.g. update revisions statement. Then email the Open Data mailbox to let them know the files are there and request that these are uploaded to the Open Data platform on the publication date.

## Notes

* It is **very important** that the files in the **master folder** are not manually edited. For example, please do not make manual changes to excel tables, report or summary - any changes required should be made to the code in analyst folders and a pull request opened on GitHub for review.

* Following on from the above, if a reviewer wishes to made tracked changes to the report and/or summary from Microsoft Word, they should take a copy of the file and feedback via email. Ideally, reviewers should request changes via the pull request process on GitHub.

* All output files are date stamped with the publication date, so there is no need to manually archive any files. When each publication is run, new files labelled with the new publication date will be created and added to the relevant folder.

* This SOP can be printed by highlighting all text, right clicking and selecting Print.
