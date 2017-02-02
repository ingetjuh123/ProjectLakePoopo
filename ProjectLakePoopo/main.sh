#!/bin/bash

## Install Packages
./Bash/InstallPackages.sh

## Download Landsat Imagery from Google Storage to data directory
#@ parameter urls - input urls which you want to download (see python file)
python ./Python/downloadLandsatDirect.py

## Untar Tar.Bz files from Landsat into new directory in data
## Resample Images to New Resoultion
#@ parameter res - input resolution in meters for resampling (standard res is 30 by 30m)
source ./Bash/UntarResample.sh
UntarResample 150

## Calculate Decline Lake Area For Different Water Indexes
## String will be converted to list in list (first list is seperated by <x> and second list by ,
#@ parameter bands - holds information on which bands to use per water index
#@ it contains 5 elements per list: Bandnr, Bandnr2, Name Bandnr1, Name Bandnr2, Name WaterIndex
bands=$'6,7,Red,NIR,NDWIgeo<x>7,8,NIR,MIR,NDWIgao<x>5,7,Green,NIR,NDWI<x>5,8,Green,MIR,MNDWI'
chmod +x ./R/CalcBiggestWaterArea.R
Rscript ./R/CalcBiggestWaterArea.R -a $bands

## Calculate Salinity Index For Lake Area
Rscript ./R/SalinityIndex.R



