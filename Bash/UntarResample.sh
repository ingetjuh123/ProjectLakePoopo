#!/bin/bash


## Function UntarResample
#@ parameter res - input resolution in meters for resampling (standard res is 30 by 30m)
function UntarResample {
	echo "UntarResample Started ..."
	# Receive First Argument   	
	res=$1
	
	# Untar File and Resample to specific resolution
	# Remove Files that are not needed
	for file in ./data/LC8*.tar.bz
		do
		NEWDIR=`echo $file | tr -d [a-zA-Z.]`
		sudo mkdir $NEWDIR
		sudo tar xvfj $file -C $NEWDIR
		sudo rm $file
		cd ./$NEWDIR
		for file2 in ./data/LC8*.TIF
			do
			sudo gdalwarp -tr $res $res $file2 ${file2/.TIF}_res${res}.tif -r bilinear
			sudo rm $file2
		done
		for file3 in ./data/LC8*.IMD
			do
			sudo rm $file3
		done

	echo "UntarResample Finished ..."
	done
}
