setwd("/home/csparks/soilcarbon_raster_processing")

library(raster)
library(sf)
library(sp)
library(leaflet)
library(tidyverse)

## Using NDVI and California County datasets as placeholders for subsequent data

## Load data and create subsets to improve processing times

NDVI <- raster("/home/shares/soilcarbon/NDVI_grassland/Raster_Grasslands/CA_Landsat8_maxNDVI_20161101_20170701.tif")

counties <- st_read("/home/shares/soilcarbon/NDVI_grassland/Raster_Grasslands", layer = "CA_Counties_Tiger2016")

counties_select <- counties %>% # Don't need the other columns
  select(NAME)

counties_proj <- st_transform(counties_select, "+init=epsg:4326") # Ensure data is in same projection

## Creating subsets - using Mariposa and Ventura counties only

counties_sub <- counties_proj %>% 
  filter(NAME == "Mariposa" | NAME == "Ventura") %>% 
  select(NAME)

NDVI_sub <- mask(NDVI, counties_sub)

## Start analyses

## Functions to get the max, min, and median values of the NDVI subset for the county subset

max_number <- raster::extract(NDVI_sub, counties_sub, fun = max, na.rm = TRUE)
min_number <- raster::extract(NDVI_sub, counties_sub, fun = min, na.rm = TRUE)
med_number <- raster::extract(NDVI_sub, counties_sub, fun = median, na.rm = TRUE)

## Accesses the resulting matrices and appends the relevant column to the counties shapefile for display if needed

NDVI_sub_stats <- counties_sub %>% 
  mutate(max_number = max_number[,1]) %>% 
  mutate(min_number = min_number[,1]) %>% 
  mutate(med_number = med_number[,1])

## Converts shapefile into csv file format

NDVI_sub_stats_df <- NDVI_sub_stats %>% # Create dataframe out of file to remove geometry
  st_set_geometry(NULL)

path_for_csv <- getwd()
write.csv(NDVI_sub_stats_df, file = file.path(path_for_csv, "NDVI_subset_statistics.csv"), row.names = FALSE)
