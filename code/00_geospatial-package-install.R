#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# RStudio Workbench is strictly for use by Public Health Scotland staff and     
# authorised users only, and is governed by the Acceptable Usage Policy https://github.com/Public-Health-Scotland/R-Resources/blob/master/posit_workbench_acceptable_use_policy.md.
#
# This is a shared resource and is hosted on a pay-as-you-go cloud computing
# platform.  Your usage will incur direct financial cost to Public Health
# Scotland.  As such, please ensure
#
#   1. that this session is appropriately sized with the minimum number of CPUs
#      and memory required for the size and scale of your analysis;
#   2. the code you write in this script is optimal and only writes out the
#      data required, nothing more.
#   3. you close this session when not in use; idle sessions still cost PHS
#      money!
#
# For further guidance, please see https://github.com/Public-Health-Scotland/R-Resources/blob/master/posit_workbench_best_practice_with_r.md.
#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

### Geospatial package install
# The below code must be run every time a session is opened
# Required to create figure 2 on 03_create-figures

# Set environment variables to point to installations of geospatial libraries ----

## Amend 'LD_LIBRARY_PATH' ----

# Get the existing value of 'LD_LIBRARY_PATH'
old_ld_path <- Sys.getenv("LD_LIBRARY_PATH") 

# Append paths to GDAL and PROJ to 'LD_LIBRARY_PATH'
Sys.setenv(LD_LIBRARY_PATH = paste(old_ld_path,
                                   "/usr/gdal34/lib",
                                   "/usr/proj81/lib",
                                   sep = ":"))

rm(old_ld_path)

## Specify additional proj path in which pkg-config should look for .pc files ----

Sys.setenv("PKG_CONFIG_PATH" = "/usr/proj81/lib/pkgconfig")

## Specify the path to GDAL data ----

Sys.setenv("GDAL_DATA" = "/usr/gdal34/share/gdal")

# List of geospatial packages that will be installed
geo_pkgs <- c("leaflet", "rgdal", "raster", "sp", "terra", "sf")

# List of geospatial package dependencies
geo_deps <- unique(
  unlist(tools::package_dependencies(packages = geo_pkgs,
                                     recursive = TRUE)))

# Remove geospatial packages and their dependencies
pkgs_to_remove <- unique(unlist(c(geo_pkgs, geo_deps)))
remove.packages(pkgs_to_remove)

# Remove 'parallelly' if it is already installed
remove.packages("parallelly")

# Install the 'parallelly' package
install.packages("parallelly")

# Identify number of CPUs available
ncpus <- as.numeric(parallelly::availableCores())

# Get list of geospatial package dependencies that can be installed as binaries
geo_deps_bin <- sort(setdiff(geo_deps, geo_pkgs))

# Remove packages that are already installed from the list of geospatial package dependencies
geo_deps_bin <- sort(setdiff(geo_deps_bin, as.data.frame(installed.packages())$Package))

# Install these as binaries
install.packages(pkgs = geo_deps_bin,
                 repos = c("https://ppm.publichealthscotland.org/all-r/__linux__/centos7/latest"),
                 Ncpus = ncpus)

geo_config_args <- c("--with-gdal-config=/usr/gdal34/bin/gdal-config",
                     "--with-proj-include=/usr/proj81/include",
                     "--with-proj-lib=/usr/proj81/lib",
                     "--with-geos-config=/usr/geos310/bin/geos-config")

# Install the {sf} package
install.packages("sf",
                 configure.args = geo_config_args,
                 INSTALL_opts = "--no-test-load",
                 repos = c("https://ppm.publichealthscotland.org/all-r/latest"),
                 Ncpus = ncpus)

# Install the {terra} package
install.packages("https://ppm.publichealthscotland.org/all-r/latest/src/contrib/Archive/terra/terra_1.7-29.tar.gz",
                 repos = NULL,
                 type = "source",
                 configure.args = geo_config_args,
                 INSTALL_opts = "--no-test-load",
                 Ncpus = ncpus)

# Install the {sp} package
install.packages("sp",
                 configure.args = geo_config_args,
                 INSTALL_opts = "--no-test-load",
                 repos = c("https://ppm.publichealthscotland.org/all-r/latest"),
                 Ncpus = ncpus)

# Install the {raster} package
install.packages("https://ppm.publichealthscotland.org/all-r/latest/src/contrib/Archive/raster/raster_2.5-8.tar.gz",
                 repos = NULL,
                 type = "source",
                 configure.args = geo_config_args,
                 INSTALL_opts = "--no-test-load",
                 Ncpus = ncpus)

# Install the {rgdal} package
install.packages("https://ppm.publichealthscotland.org/all-r/latest/src/contrib/Archive/rgdal/rgdal_1.5-25.tar.gz",
                 repos = NULL,
                 type = "source",
                 configure.args = geo_config_args,
                 INSTALL_opts = "--no-test-load",
                 Ncpus = ncpus)

# Install the {leaflet} package
install.packages("leaflet",
                 repos = c("https://ppm.publichealthscotland.org/all-r/__linux__/centos7/latest"),
                 type = "source",
                 dependencies = FALSE,
                 configure.args = geo_config_args,
                 INSTALL_opts = "--no-test-load",
                 Ncpus = ncpus)

dyn.load("/usr/gdal34/lib/libgdal.so")
dyn.load("/usr/geos310/lib64/libgeos_c.so", local = FALSE)


