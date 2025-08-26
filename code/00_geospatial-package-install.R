
### Geospatial package install
# The below code must be run every time a session is opened
# Required to create figure 2 on 03_create-figures

# Set environment variables to point to installations of geospatial libraries ----

### Session info ### - DIAGNOSIS
sessionInfo()
.libPaths()

# Do we have compilers & build tools?
Sys.which(c("gcc","g++","make","pkg-config","gfortran","tar"))
# R’s view of compilers
system("R CMD config CC; R CMD config CXX; R CMD config CXX17", intern = TRUE)

# Do we have geo configs?
Sys.which(c("gdal-config","geos-config"))
system("pkg-config --modversion proj", intern = TRUE)

# Can we write to user lib?
userlib <- .libPaths()[1]; userlib; file.access(userlib, 2)  # 0 means writable




### INSTALLS GEOSPATIAL PACKAGES CORRECTLY WITH NO ERRORS ###

## 1) Use the correct jammy repos (and a safe public fallback)
options(repos = c(
  PHS   = "https://ppm-prod.publichealthscotland.org/cran/__linux__/jammy/latest",
  Posit = "https://packagemanager.posit.co/cran/__linux__/jammy/latest"
))

## 2) Make sure R uses your user library first
userlib <- "~/R/x86_64-pc-linux-gnu-library/4.4"
if (!dir.exists(userlib)) dir.create(userlib, recursive = TRUE)
.libPaths(c(userlib, .libPaths()))

## 3) (Optional but helpful) Tell sf/terra where PROJ & GDAL live
##    These are the standard Ubuntu jammy locations that match your diag.
Sys.setenv(
  PROJ_LIB  = "/usr/share/proj",
  GDAL_DATA = "/usr/share/gdal"
)

## 4) Install low-level deps FIRST, then geo packages
##    Skip rgdal (retired on R 4.4); keep sp/raster only if you truly need them.
base_deps <- c("Rcpp","DBI","wk","classInt","units","s2")
install.packages(base_deps, Ncpus = max(1L, parallel::detectCores(logical = FALSE)))

## If any of those report "is not available" or fail: run again once — now that toolchain is warm.

## 5) Install the geospatial stack (modern path)
install.packages(c("sf","terra","leaflet"), Ncpus = max(1L, parallel::detectCores(logical = FALSE)))

## If you STILL get configure issues, force sf/terra to use detected configs explicitly:
cfg <- c(
  "--with-gdal-config=/usr/bin/gdal-config",
  "--with-geos-config=/usr/bin/geos-config"
)
if (!requireNamespace("sf", quietly = TRUE))
  install.packages("sf", Ncpus = max(1L, parallel::detectCores(logical = FALSE)), configure.args = cfg)
if (!requireNamespace("terra", quietly = TRUE))
  install.packages("terra", Ncpus = max(1L, parallel::detectCores(logical = FALSE)), configure.args = cfg)

## 6) (Only if needed for legacy code) install sp/raster last
##    Prefer refactoring away from them (see note below).
install.packages(c("sp","raster"), Ncpus = max(1L, parallel::detectCores(logical = FALSE)))

## 7) Verify everything loads and is linked to system libs
library(sf);      print(sf::sf_extSoftVersion())
library(terra);   print(terra::gdal(help = TRUE))
library(leaflet); print(packageVersion("leaflet"))

# Retired / problematic packages

# rgdal → fully retired, cannot be loaded in R 4.4

# rgeos → also retired, functionality is in sf and terra now

# maptools → retired (relied on sp + rgdal), not installable on R 4.4
