## Team Script0rs - Inge & David
## Project Lake Poopo - Calculation.r

## Load Library
library(raster)
library(rgdal)
library(bitops)

## Create Stacks for Bands
landsatPath2013 <- list.files("./data/8233073201331000/", pattern = glob2rx('LC8*.TIF'), full.names = TRUE)[c(5,8)]
landsatStack2013 <- stack(landsatPath2013)

landsatPath2015 <- list.files("./data/8233073201528400/", pattern = glob2rx('LC8*.TIF'), full.names = TRUE)[c(5,8)]
landsatStack2015 <- stack(landsatPath2015)

xminset <- max(landsatStack2013@extent[1],landsatStack2015@extent[1])
xmaxset <- min(landsatStack2013@extent[2],landsatStack2015@extent[2])
yminset <- min(landsatStack2013@extent[3],landsatStack2015@extent[3])
ymaxset <- max(landsatStack2013@extent[4],landsatStack2015@extent[4])
landsatStack2013 <-crop(landsatStack2013, extent(xminset,xmaxset,yminset,ymaxset))
landsatStack2015 <-crop(landsatStack2015, extent(xminset,xmaxset,yminset,ymaxset))

## Add Names
names(landsatStack2013)<- c("band3","band6")
names(landsatStack2015)<- c("band3","band6")

## Calculate NDWI
ndwi2013 <- overlay(landsatStack2013[[1]], landsatStack2013[[2]], fun=function(x,y){(x-y)/(x+y)},na.rm=T)
ndwi2015 <- overlay(landsatStack2015[[1]], landsatStack2015[[2]], fun=function(x,y){(x-y)/(x+y)},na.rm=T)

## Write Raster NDWI Lakes
#writeRaster(ndwi2013, filename="./output/NDWI2013", format="GTiff",overwrite=T)
#writeRaster(ndwi2015, filename="./output/NDWI2015", format="GTiff",overwrite=T)

## Create empty raster Lake
Lake2013 <- setValues(raster(ndwi2013), NA)
Lake2013[ndwi2013>0]<-1
Lake2015 <- setValues(raster(ndwi2015), NA)
Lake2015[ndwi2015>0]<-1

## Write Raster Classified Lake
#writeRaster(Lake2013, filename="./output/Lake2013", format="GTiff",overwrite=T)
#writeRaster(Lake2015, filename="./output/Lake2015", format="GTiff",overwrite=T)

## Group Raster Cells
Lake2013Clump <- clump(Lake2013, directions=8)
Lake2015Clump <- clump(Lake2015, directions=8)

## Calculate Frequency
Lake2013clumpFreq <- freq(Lake2013Clump)
Lake2015clumpFreq <- freq(Lake2015Clump)

## Create Data Frame from Clump Data
Lake2013clumpFreq <- as.data.frame(Lake2013clumpFreq)
Lake2015clumpFreq <- as.data.frame(Lake2015clumpFreq) 

## Calculate Second Biggest Value Area
n2013 <- length(Lake2013clumpFreq$count)
LakeValue2013 <- sort(Lake2013clumpFreq$count, partial=n2013-1)[n2013-1]

n2015 <- length(Lake2015clumpFreq$count)
LakeValue2015 <- sort(Lake2015clumpFreq$count, partial=n2015-1)[n2015-1]

## Calculate Excluded ID's
Lake2013excludeID <- Lake2013clumpFreq$value[which(Lake2013clumpFreq$count<LakeValue2013)]
Lake2015excludeID <- Lake2015clumpFreq$value[which(Lake2015clumpFreq$count<LakeValue2015)]

## Create New Lake Mask
Lake2013Sieved <- Lake2013
Lake2015Sieved <- Lake2015

## Assign NA to all variables with excluded ID
Lake2013Sieved[Lake2013Clump %in% Lake2013excludeID] <- NA
Lake2015Sieved[Lake2015Clump %in% Lake2015excludeID] <- NA

rm(list=setdiff(ls(),c("Lake2013Sieved", "Lake2015Sieved")))

## Create Stacks for Bands
landsatPath2013 <- list.files("./data/8233073201331000/", pattern = glob2rx('LC8*.TIF'), full.names = TRUE)
landsatStack2013 <- stack(landsatPath2013[c(4,6)])

landsatPath2015 <- list.files("./data/8233073201528400/", pattern = glob2rx('LC8*.TIF'), full.names = TRUE)
landsatStack2015 <- stack(landsatPath2015[c(4,6)])

landsatStack2013 <-crop(landsatStack2013, extent(Lake2013Sieved))
landsatStack2015 <-crop(landsatStack2015, extent(Lake2013Sieved))

landsatStack2013 <- mask(landsatStack2013, Lake2013Sieved)
landsatStack2015 <- mask(landsatStack2015, Lake2015Sieved)

writeRaster(landsatStack2015[[1]], filename="./output/Stack2015Lake", format="GTiff",overwrite=T)

## Set extent
xminset <- min(landsatStack2013@extent[1],landsatStack2015@extent[1])
xmaxset <- max(landsatStack2013@extent[2],landsatStack2015@extent[2])
yminset <- max(landsatStack2013@extent[3],landsatStack2015@extent[3])
ymaxset <- min(landsatStack2013@extent[4],landsatStack2015@extent[4])

landsatStack2013 <-crop(landsatStack2013, extent(xminset, xmaxset,yminset,ymaxset))
(landsatStack2015 <-crop(landsatStack2015, extent(xminset, xmaxset,yminset,ymaxset)))

## Add Names
names(landsatStack2013)<- c("Blue", "Red")
names(landsatStack2015)<- c("Blue", "Red")

## Calculate Salinity Index
SI2013 <- overlay(landsatStack2013[[1]], landsatStack2013[[2]], fun=function(x,y){sqrt(x*y)},na.rm=T)
SI2015 <- overlay(landsatStack2015[[1]], landsatStack2015[[2]], fun=function(x,y){sqrt(x*y)},na.rm=T)

## Write Raster Salinity Index
writeRaster(SI2013, filename="./output/SI2013Lake", format="GTiff",overwrite=T)
writeRaster(SI2015, filename="./output/SI2015Lake", format="GTiff",overwrite=T)

## Visualization
crs<-"+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
ViSI2013 <-projectRaster(SI2013, crs=crs, method="ngb")

  

