#!/usr/bin/Rscript
## Team Script0rs - Inge & David
## Project Lake Poopo - Calculation.r

## Install Libraries if needed
list.of.packages <- c("raster", "rgdal", "bitops","optparse","igraph")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages,repos="http://cran.rstudio.com/")

## Load Libraries
library(raster)
library(rgdal)
library(bitops)
library(optparse)
library(igraph)

print("CalcBiggestWaterArea Started ...")

## Create Option List To Store Arguments
option_list = list(
  make_option(c("-a", "--avar"), action="store", default=NA, type='character',
              help="variable that stores text")
)
opt = parse_args(OptionParser(option_list=option_list))

## Read Lines From Arguments By String Splitting
b = as.list(strsplit(opt$a,"<x>"))
bands = list()
for (line in b){
  bands = c(bands,as.list(strsplit(line,",")))
}

### Short Version
## Input Is List of Band(s)
## <band nr1> <band nr2> <band name1> <band name2> <Index Name>
#bands <- list(c(5,8,"Green","MIR","MNDWI"))

## Long Version
## <band nr1> <band nr2> <band name1> <band name2> <Index Name>
#bands <- list(c(6,7,"Red","NIR","NDWIgeo"),c(7,8,"NIR","MIR","NDWIgao"),c(5,7,"Green","NIR","NDWI"),c(5,8,"Green","MIR","MNDWI"))

## Check number of bands and set number of rows and columns appropriately
nrbands = length(bands)
nrow = ceiling(sqrt(nrbands))
ncol = round(sqrt(nrbands))

## Starting to write image to output
png("./output/LakeWaterIndex.png", width = 8, height = 8, units = 'in', res = 300)
par(mfrow=c(nrow,ncol), oma=c(0,0,2,0))

## Starting For-Loop to Create Multiple Images For Multiple Water Indexes
for (band in bands){
  ## Create Stacks
  landsatPath2013 <- list.files("./data/8233073201331000/", pattern = glob2rx('LC8*.tif'), full.names = TRUE)[c(as.numeric(band[1]),as.numeric(band[2]))]
  landsatStack2013 <- stack(landsatPath2013)

  landsatPath2015 <- list.files("./data/8233073201528400/", pattern = glob2rx('LC8*.tif'), full.names = TRUE)[c(as.numeric(band[1]),as.numeric(band[2]))]
  landsatStack2015 <- stack(landsatPath2015)

  ## Set extent For Stacks
  xminset <- max(landsatStack2013@extent[1],landsatStack2015@extent[1])
  xmaxset <- min(landsatStack2013@extent[2],landsatStack2015@extent[2])
  yminset <- min(landsatStack2013@extent[3],landsatStack2015@extent[3])
  ymaxset <- max(landsatStack2013@extent[4],landsatStack2015@extent[4])
  landsatStack2013 <-crop(landsatStack2013, extent(xminset, xmaxset,yminset,ymaxset))
  landsatStack2015 <-crop(landsatStack2015, extent(xminset, xmaxset,yminset,ymaxset))

  ## Add Names
  names(landsatStack2013)<- c(paste0("band", band[3]),paste0("band", band[4]))
  names(landsatStack2015)<- c(paste0("band", band[3]),paste0("band", band[4]))

  ## Calculate NDWI
  ndwi2013 <- overlay(landsatStack2013[[1]], landsatStack2013[[2]], fun=function(x,y){(x-y)/(x+y)},na.rm=T)
  ndwi2015 <- overlay(landsatStack2015[[1]], landsatStack2015[[2]], fun=function(x,y){(x-y)/(x+y)},na.rm=T)

  ## Optional(Write Raster NDWI Lakes)
  #writeRaster(ndwi2013, filename="./output/aaNDWI2013", format="GTiff",overwrite=T)
  #writeRaster(ndwi2015, filename="./output/aaNDWI2015", format="GTiff",overwrite=T)

  ## Create empty raster Lake
  Lake2013 <- setValues(raster(ndwi2013), NA)
  Lake2013[ndwi2013>0]<-1
  Lake2015 <- setValues(raster(ndwi2015), NA)
  Lake2015[ndwi2015>0]<-1

  ## Optional(Write Raster Classified Lake)
  #writeRaster(Lake2013, filename="./output/aaLake2013", format="GTiff",overwrite=T)
  #writeRaster(Lake2015, filename="./output/aaLake2015", format="GTiff",overwrite=T)

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

  ## Optional(Write Raster Sieved Lake)
  #writeRaster(Lake2013Sieved, filename="./output/aaLake2013RedMIR", format="GTiff",overwrite=T)
  #writeRaster(Lake2015Sieved, filename="./output/aaLake2015RedMIR", format="GTiff",overwrite=T)

  ## Calculate Surface Area (30m by 30m resolution per pixel) and into Square Kilometer
  Lake2013Surface <- LakeValue2013 * 900 / 1000000
  Lake2015Surface <- LakeValue2015 * 900 / 1000000

  ## Calculate Decline Surface Area (Percentage that is 
  DeclineLakePerc <- format(round((100-((Lake2015Surface/Lake2013Surface)*100)),1), nsmall=1)
  DeclineLakeArea <- format(round((Lake2013Surface - Lake2015Surface),1), nsmall=1)

  ### Visualize Each Indivual Image Per Water Index
  ## Print Names of Water Index and Bands on Top
  ## Print Amount of Lake Decline in Square Kilometer and Percentage
  ## Print the area of Lake2013 and Lake2015
  textwaterindex <- paste0(band[5],": (", band[3], "-", band[4], ") / (", band[3], "+", band[4],")")
  textlakearea <- paste0("Lake Decline: ", as.character(DeclineLakeArea), "KM2 - ", as.character(DeclineLakePerc),"%")
  plot(Lake2013Sieved, legend = F, main = textwaterindex, col="red", box=F, bty="n", yaxt="n", xaxt="n")
  plot(Lake2015Sieved, legend = F, col = "black", add=T, box=F, bty="n")
  legend("top", textlakearea, bty="n")
  legend("bottom", c("2013","2015"), fill = c("red","black"), bty="n", ncol=2)
}

## Print Title on Top of All Images
title("Difference Lake Poopo in Bolivia 2013-2015 - Landsat 8 OLI", outer=T)
dev.off()

print("CalcBiggestWaterArea Finished ...")
