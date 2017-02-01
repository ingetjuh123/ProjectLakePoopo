#!/bin/bash

## Download Landsat Imagery from Google Storage to data directory
python ./Python/downloadLandsatDirect.py

## Untar Tar.Bz files from Landsat into new directory in data
bash ./Bash/UntarResample.sh

## Calculate Decline Lake Area For Different Water Indexes
Rscript ./R/CalcBiggestWaterArea.R

## Calculate Salinity Index For Lake Area
#Rscript ./R/SalinityIndex.R

## Visualize Decline Lake Area (MNDWI)


