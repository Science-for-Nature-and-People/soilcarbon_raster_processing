setwd("/home/csparks/soilcarbon_raster_processing")
path_for_csv <- getwd()

library(raster)
library(sf)
library(sp)
library(tidyverse)
library(rgeos)

## Using NDVI as placeholder for subsequent data

## Load data

NDVI <- raster("/home/shares/soilcarbon/NDVI_grassland/Raster_Grasslands/CA_Landsat8_maxNDVI_20161101_20170701.tif")
rangelands <- raster("/home/shares/soilcarbon/soilc-california/rangeland-production/data/RMZ/RMZ.tif")

## Data wrangling

## Define the projection to use (ESPG 3310: NAD 83 California Albers)
## Takes a long time to process

newproj <- "+proj=aea +lat_1=34 +lat_2=40.5 +lat_0=0 +lon_0=-120 +x_0=0 +y_0=-4000000 +ellps=GRS80 +datum=NAD83 +units=m +no_defs" 

proj <- projectExtent(rangelands, crs = newproj)  # Reproject the RMZ file
range_proj <- projectRaster(rangelands, proj, method= "ngb", alignOnly = FALSE)
NDVI_proj <- projectRaster(NDVI, range_proj, method = "ngb", alignOnly = FALSE) #Project, align, and crop the NDVI layer to RMZ layer

## Analyses

## Creating the raster of median values

med_NDVI <- zonal(NDVI_proj, range_proj, 'median', na.rm = TRUE) # This creates a matrix of median values for each RMZ
med_NDVI_df <- as.data.frame(med_NDVI) # Converts into dataframe
med_raster <- subs(range_proj, med_NDVI_df, by=1, which=2, subsWithNA = TRUE) # Uses dataframe to reclassify raster

## Finding the ratio raster (NDVI/median; only shows cells that fall within an RMZ)

ratio_raster <- NDVI_proj/med_raster # Values less than one mean that the NDVI value at that cell is less than the median for that RMZ type

## Write final raster to file

writeRaster(ratio_raster, filename = "RMZ_NDVI_Median_Ratio", format = "GTiff")

## CROPPED VERSION

## Using NDVI dataset as placeholder for subsequent data

## Load data

NDVI <- raster("/home/shares/soilcarbon/NDVI_grassland/Raster_Grasslands/CA_Landsat8_maxNDVI_20161101_20170701.tif")
rangelands <- raster("/home/shares/soilcarbon/soilc-california/rangeland-production/data/RMZ/RMZ.tif")
range_crop <- raster("/home/shares/soilcarbon/NDVI_grassland/Raster_Grasslands/RMZ/RMZ_crop.tif") # A cropped version to use to test script

## Data wrangling

## Set crs of cropped dataset to the same as its original

crs(range_crop) <- crs(rangelands)

# Define the projection to use (ESPG 3310: NAD 83 California Albers)
newproj <- "+proj=aea +lat_1=34 +lat_2=40.5 +lat_0=0 +lon_0=-120 +x_0=0 +y_0=-4000000 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"

proj <- projectExtent(range_crop, crs = newproj)  # Reproject the RMZ file
range_crop_proj <- projectRaster(range_crop, proj, method= "ngb", alignOnly = FALSE)
NDVI_proj <- projectRaster(NDVI, range_crop_proj, method = "ngb", alignOnly = FALSE) #Project, align, and crop the NDVI layer to RMZ layer

## Analyses

## Creating the raster of median values

med_NDVI <- zonal(NDVI_proj, range_crop_proj, 'median', na.rm = TRUE) # This creates a matrix of median values for each RMZ
med_NDVI_df <- as.data.frame(med_NDVI) # Converts into dataframe
med_raster <- subs(range_crop_proj, med_NDVI_df, by=1, which=2, subsWithNA = TRUE) # Uses dataframe to reclassify raster

## Finding the ratio raster (NDVI/median; only shows cells that fall within an RMZ)

ratio_raster <- NDVI_proj/med_raster # Values less than one mean that the NDVI value at that cell is less than the median for that RMZ type

## Write final raster to file

writeRaster(ratio_raster, filename = "RMZ_NDVI_Median_Ratio_CROP3.tif", format = "GTiff", overwrite = TRUE, datatype = "FLT4S")
