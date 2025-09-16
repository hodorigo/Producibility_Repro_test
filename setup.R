# Set up R project directory structure
# Author: Pierre Rogy


# Directories and files ---------------------------------------------------
# Make directories
## The if statement is to make sure to not overwrite the directroy 
## if it exists (i.e. if it does not exist, create it)
## Raw data
if(!dir.exists("00_rawdata")) {dir.create("00_rawdata")}
## Scripts
if(!dir.exists("01_scripts")) {dir.create("01_scripts")}
## Output data
if(!dir.exists("02_outdata")) {dir.create("02_outdata")}
## Figures
if(!dir.exists("03_figs")) {dir.create("03_figs")}
## Manuscript
if(!dir.exists("04_manuscript")) {dir.create("04_manuscript")}
## Rendered manuscript
if(!dir.exists("04_manuscript/rendered")) {dir.create("04_manuscript/rendered")}

# Make files
## Same idea with the if statement, if it does not exist, create it
## General readme
if(!file.exists("README.rmd")) {file.create("README.rmd")}
## Raw data readme
if(!file.exists("00_rawdata/README.rmd")) {file.create("00_rawdata/README.rmd")}
## Out data readme
if(!file.exists("02_outdata/README.rmd")) {file.create("02_outdata/README.rmd")}
## Out data data dictionary
if(!file.exists("02_outdata/data_dictionary.rmd")) {file.create("02_outdata/data_dictionary.rmd")}

# By default, knitr knits the document to where the .rmd is
# Use this command to save it where you want to
rmarkdown::render(input = '04_manuscript/my_manuscript.Rmd', 
                  output_dir = '04_manuscript/rendered')


# Renv and packages -------------------------------------------------------
# Renv
## Initialise lockfile
renv::init()
## Check lockfile
renv::snapshot()

# Add packages as a .bib file to directory of choice
grateful::cite_packages(out.dir = "04_manuscript/")


# Trackdown ---------------------------------------------------------------
# Initial upload
trackdown::upload_file(file = "04_manuscript/my_manuscript.Rmd")

# Update
trackdown::update_file(file = "04_manuscript/my_manuscript.Rmd")

# Download
trackdown::download_file(file = "04_manuscript/my_manuscript.Rmd")



