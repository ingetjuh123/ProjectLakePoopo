#!/bin/bash
###!/usr/bin/python

## Download Landsat Imagery from Google Storage to data directory
#@ parameter urls - input url which you want to download
#from downloadLandsatDirect import download
#urls = ['http://storage.googleapis.com/earthengine-public/landsat/L8/233/073/LC82330732013310LGN00.tar.bz','http://storage.googleapis.com/earthengine-public/landsat/L8/233/073/LC82330732015284LGN00.tar.bz']
#for url in urls:
#	download(url)

#!/bin/bash

## Untar Tar.Bz files from Landsat into new directory in data
## Resample Images to New Resoultion
#@ parameter res - input resolution you want to Resample too
## Sstandard resolution of landsat is 30 by 30 meter 
#source ./Bash/UntarResample.sh
#UntarResample 150

	
## Calculate Decline Lake Area For Different Water Indexes
bands=$'6,7,Red,NIR,NDWIgeo<x>7,8,NIR,MIR,NDWIgao<x>5,7,Green,NIR,NDWI<x>5,8,Green,MIR,MNDWI'

#sudo chmod +x CalcBiggestWaterArea.R
Rscript CalcBiggestWaterArea.R -a $bands

#Rscript test.R -a $bands
#sudo Rscript --vanilla test.R --slave --no-save --no-restore --no-environ --silent --args $bands
#Rscript test.R

#bands <- list(c(6,7,Red,NIR,NDWIgeo"),c(7,8,"NIR","MIR","NDWIgao"),c(5,7,"Green","NIR","NDWI"),c(5,8,"Green","MIR","MNDWI"))

## Calculate Salinity Index For Lake Area
#Rscript ./R/SalinityIndex.R

## Visualize Decline Lake Area (MNDWI)


