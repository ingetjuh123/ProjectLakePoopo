## Team Script0rs - Inge & David
## Project Lake Poopo - main

## Load Library
library(raster)
library(rgdal)
library(bitops)

# # Untar 2013
untar("./data/LC82330732013310LGN00.tar.bz", exdir='./data/y2013d310/')

# # Untar 2016
untar("./data/LC82330732016319LGN00.tar.bz", exdir='./data/y2016d319/')

# Create bricks
landsatPath2013 <- list.files("./data/y2013d310/", pattern = glob2rx('LC8*.TIF'), full.names = TRUE)[5:6]
landsatStack2013 <- stack(landsatPath2013)

landsatPath2016 <- list.files("./data/y2016d319/", pattern = glob2rx('LC8*.TIF'), full.names = TRUE)[5:6]
landsatStack2016 <- stack(landsatPath2016)

## Add Names
names(landsatStack2013)<- c("band3","band4")
names(landsatStack2016)<- c("band3","band4")

## Write Raster 
writeRaster(landsatStack2013, filename="./output/Landsat2013", format= "GTiff")

## Visualization
# plot(landsatStack[[3]])
# plot(landsatStack$band2)
# plotRGB(landsatStack,r=3,g=2,b=1)
