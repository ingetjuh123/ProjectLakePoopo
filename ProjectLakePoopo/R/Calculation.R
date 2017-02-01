## Team Script0rs - Inge & David
## Project Lake Poopo - Calculation.r

## Load Library
library(raster)
library(rgdal)
library(bitops)

par(mfrow=c(2,2), oma=c(0,0,2,0))

bands <- list(c(6,7,"Red","NIR","NDWIgeo"),c(7,8,"NIR","MIR","NDWIgao"),c(5,7,"Green","NIR","NDWI"),c(5,8,"Green","MIR","MNDWI"))

## Create layers for Mask

landsatStack2013 <- stack("./data/8233073201331000//LC82330732013310LGN00_BQA.TIF")
landsatStack2015 <- stack("./data/8233073201528400//LC82330732015284LGN00_BQA.TIF")

## Set extent
xminset <- max(landsatStack2013@extent[1],landsatStack2015@extent[1])
xmaxset <- min(landsatStack2013@extent[2],landsatStack2015@extent[2])
yminset <- min(landsatStack2013@extent[3],landsatStack2015@extent[3])
ymaxset <- max(landsatStack2013@extent[4],landsatStack2015@extent[4])

landsatStack2013 <-crop(landsatStack2013, extent(xminset, xmaxset,yminset,ymaxset))
landsatStack2015 <-crop(landsatStack2015, extent(xminset, xmaxset,yminset,ymaxset))

## Calculate Mask of Snow, Salt and Cloud in both years
Mask2013 <- setValues(raster(landsatStack2013), NA)
Mask2013[landsatStack2013==20480]<-1
Mask2013[landsatStack2013==23552]<-1

Mask2015 <- setValues(raster(landsatStack2013), NA)
Mask2015[landsatStack2015==28672]<-1
Mask2015[landsatStack2015==23552]<-1

SnowCloudsSalt <- setValues(raster(landsatStack2013), NA)
SnowCloudsSalt[Mask2013!=1]<-1
writeRaster(SnowCloudsSalt, filename="./output/SnowCloudSalt2", format="GTiff",overwrite=T)
SnowCloudsSalt[Mask2015!=1]<-1

writeRaster(SnowCloudsSalt, filename="./output/SnowCloudSalt", format="GTiff",overwrite=T)

## Remove Variables
rm(landsatStack2013,landsatStack2015,Mask2013,Mask2015)

for (band in bands){
  ## Create Stacks for Bands
  landsatPath2013 <- list.files("./data/8233073201331000/", pattern = glob2rx('LC8*.TIF'), full.names = TRUE)[c(band[1],band[2])]
  landsatStack2013 <- stack(landsatPath2013)

  landsatPath2015 <- list.files("./data/8233073201528400/", pattern = glob2rx('LC8*.TIF'), full.names = TRUE)[c(band[1],band[2])]
  landsatStack2015 <- stack(landsatPath2015)


  landsatStack2013 <-crop(landsatStack2013, extent(xminset,xmaxset,yminset,ymaxset))
  landsatStack2015 <-crop(landsatStack2015, extent(xminset,xmaxset,yminset,ymaxset))
  
  ## Remove "Cloud"-mask from Landsatstacks
  landsatStack2013[SnowCloudsSalt==1]<-NA
  landsatStack2015[SnowCloudsSalt==1]<-NA

  # ## Change Data Type
  # landsatStack2015 <- calc(landsatStack2015, fun=function(x) x /10000)
  
  ## Add Names
  names(landsatStack2013)<- c(paste0("band", as.character(band[1])),paste0("band", as.character(band[2])))
  names(landsatStack2015)<- c(paste0("band", as.character(band[1])),paste0("band", as.character(band[2])))
  
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

  ## Write Raster Sieved Lake
  # writeRaster(Lake2013Sieved, filename="./output/Lake2013RedMIR", format="GTiff",overwrite=T)
  # writeRaster(Lake2015Sieved, filename="./output/Lake2015RedMIR", format="GTiff",overwrite=T)


  ## Calculate Surface Area (30m by 30m resolution per pixel) and into Square Kilometer
  Lake2013Surface <- LakeValue2013 * 900 / 1000000
  Lake2015Surface <- LakeValue2015 * 900 / 1000000

  ## Calculate Decline Surface Area (Percentage that is 
  DeclineLakePerc <- format(round((100-((Lake2015Surface/Lake2013Surface)*100)),1), nsmall=1)
  DeclineLakeArea <- format(round((Lake2013Surface - Lake2015Surface),1), nsmall=1)

  ## Visualize
  textwaterindex <- paste("Water Index", as.character(band[5]),": (", as.character(band[3]), "-", as.character(band[4]), ") / (", as.character(band[3]), "+", as.character(band[4]), ")")
  textlakearea <- paste("Lake Area Decline:", as.character(DeclineLakeArea), "KM2 -", as.character(DeclineLakePerc),"%")
  plot(Lake2013Sieved, legend = F, main = textwaterindex, col="red")
  plot(Lake2015Sieved, legend = F, col = "black", add=T)
  legend("bottom", textlakearea, border=NULL)
  legend("topright", c("2013","2015"), fill = c("red","black")) 
}

title("Difference Lake Poopo 2013-2015 Bolivia", outer=T)
