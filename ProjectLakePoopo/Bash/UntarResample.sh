#!/bin/bash

# Set Directory Data
cd ./data

# Untar File and Resample to specific resolution
# Remove Files that are not needed
for file in LC8*.tar.bz
	do
	NEWDIR=`echo $file | tr -d [a-zA-Z.]`
	sudo mkdir $NEWDIR
	sudo tar xvfj $file -C $NEWDIR
	cd ./$NEWDIR
	for file2 in LC8*.TIF
		do
		sudo gdalwarp -tr 150 150 $file2 ${file2/.TIF}_res150.tif -r bilinear
		sudo rm $file2
	done
	for file3 in LC8*.IMD
		do
		sudo rm $file3
	done
	cd ../
done

