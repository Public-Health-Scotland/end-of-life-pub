## Percentage of End of Life Spent at Home or in a Community Setting

## Folder Structure

All the publication files and folders are stored in the Publication folder of the End of Life network area. This folder should contain:
* A "master" folder
* A folder named after each analyst who has worked on the publication e.g. a folder called "Alice"

### The "master" folder

The **master** folder is the **master copy** of the publication repository. This is the "production-ready" version that is used for the publication process each year. Within it there will be a folder called `data/` containing all data extracts and basefiles used to produce previous publications and an `output/` folder containing publication outputs (e.g. excel tables, summary and report) for all previous publications. The master copy should **never be edited** and should only be updated from approved changes pulled from GitHub.

### Individual analyst folders

These folders also contain up-to-date copies of the repository and these are the versions which are edited each time the publication is updated or each time a change to the process has to be made. Analysts should only work in their own folders on their own development branches. Once they are content that their changes are ready for the master branch, they must create a pull request on GitHub and have other analysts from the team review their changes and, if satisfied, merge them back into the master branch. It is then that the **master folder is updated** by pulling from GitHub.

## Running the Publication

Before starting to run the publication, there are a few things that should be checked:
* **SMR Completeness** - In the run up to publication time, keep an eye on [SMR Completeness](https://www.isdscotland.org/products-and-Services/Data-Support-and-Monitoring/SMR-Completeness/) to ensure this is sufficient for publication. If there are any concerns, these should be raised as early as possible with Data Management.
* **Markdown Templates** - Check if there have been any changes made to the [master versions](https://github.com/NHS-NSS-transforming-publications/National-Stats-Template) of these. If so, update these in the `markdown/` folder. If you have not run the publication before, there are a [few steps](https://github.com/NHS-NSS-transforming-publications/National-Stats-Template) you must follow to ensure correct formatting in Microsoft Word.

### Updating the code

The project is designed to require as little human intervention as possible. To update the publication, the analyst responsible for updating the scripts/running the publication should complete the following steps. **Note that at no point is there a need to run code in this section.**

* Pull the most recent version of the master branch into their own folder.
* Create a fresh branch to make necessary changes.
* Make updates in the `code/00_setup-environment.R` file
    * Update dates
    * Check filepaths for lookups are still correct
    * Define whether publication is provisional or update version
* Commit and push new branch to GitHub.
* Create pull request on GitHub for another analyst to review changes.
* Once changes have been approved, merge the branch into the master and delete personal branch.
* If no more changes are required, pull the updated master branch into the master folder.

### Running the code

* In the **master folder**, open each script in the `code/` folder from `01_create-basefile.R` to `06_knit-markdown.R` in turn and do the following:
    * Highlight the entire script and run
    * Check for any errors and investigate as necessary
    * Check the output of the script looks as it should
    
* When running `03_create-figures.R`, check what Health Boards have the maximum and minimum QoM figures. These boards should be labelled on the map (Figure 2), however the positioning of these labels has not been automated and may need to be tweaked if the max/min boards change.

### Manual Steps

* A couple of manual steps are required to finish off the markdown documents (adding cover page, table of contents and formatting tables correctly). They are outlined in the readme in the [National Statistics Publication Templates repository](https://github.com/NHS-NSS-transforming-publications/National-Stats-Template).

* The open data files saved in `data/open-data/` should be copied to the appropriate folder in the Open Data team's network area. Make any necessary changes to the metadata document also in this folder; e.g. update revisions statement. Then email the Open Data mailbox to let them know the files are there and request that these are uploaded to the Open Data platform on the publication date.

### Notes

* It is **very important** that the master branch is not edited. For example, please do not make manual changes to excel tables, report or summary - any changes required should be made to the code in analyst folders and a pull request opened on GitHub for review.

* Following on from the above, if a reviewer wishes to made tracked changes to the report and/or summary from Microsoft Word, they should take a copy of the file and feedback via email. Ideally, reviewers should request changes via the pull request process on GitHub.

* All output files are date stamped with the publication date, so there is no need to manually archive any files. When each publication is run, new files labelled with the new publication date will be created and added to the relevant folder.
