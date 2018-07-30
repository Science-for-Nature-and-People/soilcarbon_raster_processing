setwd("/home/csparks/soilcarbon_raster_processing")

library(raster)
library(sf)
library(sp)
library(leaflet)
library(tidyverse)

NDVI <- raster("/home/shares/soilcarbon/NDVI_grassland/Raster_Grasslands/CA_Landsat8_maxNDVI_20161101_20170701.tif")how 
crs(NDVI)


## Issues with Management Zones - have a database/attribute table but no associated geometry.
## If zones are raster format, they will likely need conversion into shapefile for zonal statistics (this makes most sense to me)
## For now, will use counties dataset

## Takes too long (never stops hanging) to use all counties, will use subset

counties <- st_read("/home/shares/soilcarbon/NDVI_grassland/Raster_Grasslands", layer = "CA_Counties_Tiger2016")

counties_test <- counties %>% 
  select(NAME)

counties_proj <- st_transform(counties_test, "+init=epsg:4326")
plot(st_geometry(counties_proj), axes = TRUE)
plot(st_geometry(counties_sub), add = TRUE)

## Creating subset
counties_sub <- counties_proj %>% 
  filter(NAME == "Mariposa" | NAME == "Ventura") %>% 
  select(NAME)

plot(NDVI)
plot(counties_proj["NAME"], add = TRUE)


 max_number <- raster::extract(NDVI, counties_sub, fun = max, df = TRUE, na.rm = TRUE)
 min_number <- raster::extract(NDVI, counties_sub, fun = min, na.rm = TRUE)
 med_number <- raster::extract(NDVI, counties_sub, fun = median, na.rm = TRUE)
# max_number <- raster::extract(NDVI, counties_sub, fun = max, sp = TRUE) #Do we want a spatial frame or a df?
 ## It works but takes a very very long time




# ####
# #import required libraries
# library(maptools)
# library(raster)
# 
# #list files (in this case raster TIFFs)
# grids <- list.files("./path/to/data", pattern = "*.tif$")
# 
# #check the number of files in the raster list (grids)
# length <- length(grids)
# 
# #read-in the polygon shapefile
# poly <- readShapePoly("./path/to/data/shapefile.shp")
# 
# #create a raster stack
# s <- stack(paste0("./path/to/data/", grids))
# 
# #extract raster cell count (sum) within each polygon area (poly)
# for (i in 1:length(grids)){
#   ex <- extract(s, poly, fun=sum, na.rm=TRUE, df=TRUE)
# }
# 
# #write to a data frame
# df <- data.frame(ex)
# 
# #write to a CSV file
# write.csv(df, file = "./path/to/data/CSV.csv")
# ###



#grazing_zones <- raster("/home/shares/soilcarbon/NDVI_grassland/Raster_Grasslands/RMZ/RMZ.tif")

#grazing_zones <- st_read(system.file("/home/shares/soilcarbon/NDVI_grassland/Raster_Grasslands", layer = "RMZ"))
