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

proj <- projectExtent(rangelands, crs = newproj)  # Set a new reprojection (blank raster)
range_proj <- projectRaster(rangelands, proj, method= "ngb", alignOnly = FALSE) # Apply new projection to rangelands data
NDVI_proj <- projectRaster(NDVI, range_proj, method = "ngb", alignOnly = FALSE) # Project, align, and crop the NDVI layer to the projection

writeRaster(range_proj, filename = "range_proj", format = "GTiff", overwrite = TRUE, datatype = "FLT4S")
writeRaster(NDVI_proj, filename = "NDVI_proj", format = "GTiff", overwrite = TRUE, datatype = "FLT4S")

## Analyses

## Creating the raster of median values

mean_NDVI <- zonal(NDVI_proj, range_proj, 'mean', na.rm = TRUE) # This creates a matrix of mean values for each RMZ (median only works for smaller rasters)
mean_NDVI_df <- as.data.frame(mean_NDVI) # Converts into dataframe, col 1 shows RMZ value (1-6), col 2 shows corresponding mean value
mean_raster <- subs(range_proj, mean_NDVI_df, by=1, which=2, subsWithNA = TRUE) # Uses dataframe to reclassify raster (replace values in column 1 with matching values in column 2)

## Finding the ratio raster (NDVI/mean; only shows cells that fall within an RMZ)

ratio_raster <- NDVI_proj/mean_raster # Values less than one mean that the NDVI value at that cell is less than the average for that RMZ type

## Write final raster to file

writeRaster(ratio_raster, filename = "RMZ_NDVI_Mean_Ratio", format = "GTiff", overwrite = TRUE, datatype = "FLT4S")



# ## CROPPED VERSION -- for testing
# 
# ## Using NDVI dataset as placeholder for subsequent data
# 
# ## Load data
# 
# NDVI <- raster("/home/shares/soilcarbon/NDVI_grassland/Raster_Grasslands/CA_Landsat8_maxNDVI_20161101_20170701.tif")
# rangelands <- raster("/home/shares/soilcarbon/soilc-california/rangeland-production/data/RMZ/RMZ.tif")
# range_crop <- raster("/home/shares/soilcarbon/NDVI_grassland/Raster_Grasslands/RMZ/RMZ_crop.tif") # A cropped version to use to test script
# 
# ## Data wrangling
# 
# ## Set crs of cropped dataset to the same as its original
# 
# crs(range_crop) <- crs(rangelands)
# 
# # Define the projection to use (ESPG 3310: NAD 83 California Albers)
# newproj <- "+proj=aea +lat_1=34 +lat_2=40.5 +lat_0=0 +lon_0=-120 +x_0=0 +y_0=-4000000 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
# 
# proj <- projectExtent(range_crop, crs = newproj)  # Reproject the RMZ file
# range_crop_proj <- projectRaster(range_crop, proj, method= "ngb", alignOnly = FALSE)
# NDVI_crop_proj <- projectRaster(NDVI, range_crop_proj, method = "ngb", alignOnly = FALSE) #Project, align, and crop the NDVI layer to RMZ layer
# 
# ## Analyses
# 
# ## Creating the raster of median values
# 
# med_NDVI <- zonal(NDVI_crop_proj, range_crop_proj, 'mean', na.rm = TRUE) # This creates a matrix of median values for each RMZ
# med_NDVI_df <- as.data.frame(med_NDVI) # Converts into dataframe
# med_raster <- subs(range_crop_proj, med_NDVI_df, by=1, which=2, subsWithNA = TRUE) # Uses dataframe to reclassify raster
# 
# ## Finding the ratio raster (NDVI/median; only shows cells that fall within an RMZ)
# 
# ratio_raster <- NDVI_crop_proj/med_raster # Values less than one mean that the NDVI value at that cell is less than the median for that RMZ type
# 
# ## Write final raster to file
# 
# writeRaster(ratio_raster, filename = "RMZ_NDVI_Median_Ratio_CROP.tif", format = "GTiff", overwrite = TRUE, datatype = "FLT4S")
