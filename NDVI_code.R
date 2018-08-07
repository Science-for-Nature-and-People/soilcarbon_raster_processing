setwd("/home/csparks/soilcarbon_raster_processing")

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

# Define the projection to use (ESPG 3310: NAD 83 California Albers)
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



#### OLD CODE

#counties <- st_read("/home/shares/soilcarbon/NDVI_grassland/Raster_Grasslands", layer = "CA_Counties_Tiger2016")

#range_poly <- rasterToPolygons(rangelands, n = 16, na.rm =TRUE, digits = 12, dissolve = TRUE)

#counties_select <- counties %>% # Drop all columns except name
#  select(NAME)

#counties_proj <- st_transform(counties_select, "+init=epsg:4326") # Ensure data is in same projection

## Creating subsets - using Mariposa and Ventura counties only, crop NDVI to this extent

#counties_sub <- counties_proj %>% 
#  filter(NAME == "Mariposa" | NAME == "Ventura") %>% 
#  select(NAME)

#NDVI_sub <- mask(NDVI, counties_sub)

## Start analyses

## Functions to get the max, min, and median values of the NDVI subset for the county subset. Creates matrix.

# max_number <- raster::extract(NDVI_sub, counties_sub, fun = max, na.rm = TRUE)
# min_number <- raster::extract(NDVI_sub, counties_sub, fun = min, na.rm = TRUE)
# med_number <- raster::extract(NDVI_sub, counties_sub, fun = median, na.rm = TRUE)

## Accesses the resulting matrices and appends the relevant column to the counties shapefile for display if needed

# NDVI_sub_stats <- counties_sub %>% 
#   mutate(max_number = max_number[,1]) %>% 
#   mutate(min_number = min_number[,1]) %>% 
#   mutate(med_number = med_number[,1])
# 
# ## Converts shapefile into csv file format
# 
# NDVI_sub_stats_df <- NDVI_sub_stats %>% # Create dataframe out of file to remove geometry
#   st_set_geometry(NULL)
# 
# ## Alternate way to drop geometry (but need to know what columns to select)
# # NDVI_sub_stats_df2 <- NDVI_sub_stats[, c(1:4), drop = TRUE]
# 
# path_for_csv <- getwd()
# write.csv(NDVI_sub_stats_df, file = file.path(path_for_csv, "NDVI_subset_statistics.csv"), row.names = FALSE)
