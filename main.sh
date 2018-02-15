#!/bin/bash
## Load functions
source ./Bash/UntarResample.sh

## Set landsat tiles to download from google earth engine
url_l8_2013=$'http://storage.googleapis.com/earthengine-public/landsat/L8/233/073/LC82330732013310LGN00.tar.bz'
url_l8_2015=$'http://storage.googleapis.com/earthengine-public/landsat/L8/233/073/LC82330732015284LGN00.tar.bz'

## Install Packages
bash ./Bash/InstallPackages.sh 

## Create data and output directories
python3 ./Python/createDataOutputDirs.py

## Download Landsat Imagery from Google Storage to data directory
#@ parameter url - input urls which you want to download
python3 ./Python/downloadLandsatDirect.py $url_l8_2013 $url_l8_2015

## Untar Tar.Bz files from Landsat into new directory in data
## Resample Images to New Resoultion
#@ parameter res - input resolution in meters for resampling (standard res is 30 by 30m)
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



