## Team Script0rs - Inge & David
## Project Lake Poopo - main

## Load Library
library(raster)
library(rgdal)
library(bitops)

# # Untar 2013
untar("./data/LC82330732013310LGN00.tar.bz", exdir='./data/y2013d310/')
# 
# # Untar 2015
untar("./data/LC82330732015284LGN00.tar.bz", exdir='./data/y2015d284/')

# Create bricks
#landsatPath2013 <- list.files("./data/y2013d310/", pattern = glob2rx('LC8*.TIF'), full.names = TRUE)[c(6,7)]
#landsatStack2013 <- stack(landsatPath2013)

#landsatPath2015 <- list.files("./data/y2015d284/", pattern = glob2rx('LC8*.TIF'), full.names = TRUE)[c(6,7)]
#landsatStack2015 <- stack(landsatPath2015)

## Set extent
#(xminset <- max(landsatStack2013@extent[1],landsatStack2015@extent[1]))
#(xmaxset <- min(landsatStack2013@extent[2],landsatStack2015@extent[2]))
#(yminset <- min(landsatStack2013@extent[3],landsatStack2015@extent[3]))
#(ymaxset <- max(landsatStack2013@extent[4],landsatStack2015@extent[4]))
#landsatStack2013 <-crop(landsatStack2013, extent(xminset, xmaxset,yminset,ymaxset))
#landsatStack2015 <-crop(landsatStack2015, extent(xminset, xmaxset,yminset,ymaxset))

# ## Change Data Type
# landsatStack2015 <- calc(landsatStack2015, fun=function(x) x /10000)

## Add Names
#names(landsatStack2013)<- c("band4","band5")
#names(landsatStack2015)<- c("band4","band5")

## Calculate NDWI
#ndwi2013 <- overlay(landsatStack2013[[1]], landsatStack2013[[2]], fun=function(x,y){(x-y)/(x+y)},na.rm=T)
#ndwi2015 <- overlay(landsatStack2015[[1]], landsatStack2015[[2]], fun=function(x,y){(x-y)/(x+y)},na.rm=T)

## Write Raster NDWI Lakes
#writeRaster(ndwi2013, filename="./output/NDWI2013", format="GTiff",overwrite=T)
#writeRaster(ndwi2015, filename="./output/NDWI2015", format="GTiff",overwrite=T)

## Create empty raster Lake
#Lake2013 <- setValues(raster(ndwi2013), NA)
#Lake2013[ndwi2013>0]<-1
#Lake2015 <- setValues(raster(ndwi2015), NA)
#Lake2015[ndwi2015>0]<-1

## Write Raster Classified Lake
#writeRaster(Lake2013, filename="./output/Lake2013", format="GTiff",overwrite=T)
#writeRaster(Lake2015, filename="./output/Lake2015", format="GTiff",overwrite=T)

## Group Raster Cells
#Lake2013Clump <- clump(Lake2013, directions=8, filename=".output/Lake2013Clump")
#Lake2015Clump <- clump(Lake2015, directions=8, filename=".output/Lake2015Clump")


## ## Write Raster Classified Lake
## writeRaster(Lake2013Clump, filename="./output/Lake2013", format="GTiff",overwrite=T)
## writeRaster(Lake2015Clump, filename="./output/Lake2015", format="GTiff",overwrite=T)
