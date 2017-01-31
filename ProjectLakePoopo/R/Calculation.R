## Team Script0rs - Inge & David
## Project Lake Poopo - Calculation.r

## Load Library
library(raster)
library(rgdal)
library(bitops)

## Create bricks
landsatPath2013 <- list.files("./data/y2013d310/", pattern = glob2rx('LC8*.TIF'), full.names = TRUE)[c(6,7)]
landsatStack2013 <- stack(landsatPath2013)

landsatPath2015 <- list.files("./data/y2015d284/", pattern = glob2rx('LC8*.TIF'), full.names = TRUE)[c(6,7)]
landsatStack2015 <- stack(landsatPath2015)

## Set extent
(xminset <- max(landsatStack2013@extent[1],landsatStack2015@extent[1]))
(xmaxset <- min(landsatStack2013@extent[2],landsatStack2015@extent[2]))
(yminset <- min(landsatStack2013@extent[3],landsatStack2015@extent[3]))
(ymaxset <- max(landsatStack2013@extent[4],landsatStack2015@extent[4]))
landsatStack2013 <-crop(landsatStack2013, extent(xminset, xmaxset,yminset,ymaxset))
landsatStack2015 <-crop(landsatStack2015, extent(xminset, xmaxset,yminset,ymaxset))

# ## Change Data Type
# landsatStack2015 <- calc(landsatStack2015, fun=function(x) x /10000)

## Add Names
names(landsatStack2013)<- c("band4","band5")
names(landsatStack2015)<- c("band4","band5")

## Calculate NDWI
ndwi2013 <- overlay(landsatStack2013[[1]], landsatStack2013[[2]], fun=function(x,y){(x-y)/(x+y)},na.rm=T)
ndwi2015 <- overlay(landsatStack2015[[1]], landsatStack2015[[2]], fun=function(x,y){(x-y)/(x+y)},na.rm=T)

## Write Raster NDWI Lakes
writeRaster(ndwi2013, filename="./output/NDWI2013", format="GTiff",overwrite=T)
writeRaster(ndwi2015, filename="./output/NDWI2015", format="GTiff",overwrite=T)

## Create empty raster Lake
Lake2013 <- setValues(raster(ndwi2013), NA)
Lake2013[ndwi2013>0]<-1
Lake2015 <- setValues(raster(ndwi2015), NA)
Lake2015[ndwi2015>0]<-1

## Write Raster Classified Lake
writeRaster(Lake2013, filename="./output/Lake2013", format="GTiff",overwrite=T)
writeRaster(Lake2015, filename="./output/Lake2015", format="GTiff",overwrite=T)

## Group Raster Cells
Lake2013Clump <- clump(Lake2013, directions=8, filename="./output/Lake2013Clump")
Lake2015Clump <- clump(Lake2015, directions=8, filename="./output/Lake2015Clump")

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

## Write Raster Sieved Lake
writeRaster(Lake2013Sieved, filename="./output/Lake2013Sieved", format="GTiff",overwrite=T)
writeRaster(Lake2015Sieved, filename="./output/Lake2015Sieved", format="GTiff",overwrite=T)

## Calculate Surface Area (30m by 30m resolution per pixel) and into Square Kilometer
(Lake2013Surface <- LakeValue2013 * 900 / 1000000)
(Lake2015Surface <- LakeValue2015 * 900 / 1000000)

## Calculate Decline Surface Area (Percentage that is 
(DeclineLakePerc <-  100-(Lake2015Surface/Lake2013Surface)*100)
(DeclineLakeSquareMeter <- Lake2013Surface - Lake2015Surface)

