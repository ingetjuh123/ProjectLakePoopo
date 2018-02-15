#!/bin/bash


## Function UntarResample
#@ parameter res - input resolution in meters for resampling (standard res is 30 by 30m)
function UntarResample {
	echo UntarResample Started ...
	# Receive First Argument   	
	res=$1	
	# Untar File and Resample to specific resolution
	# Remove Files that are not needed
	for filename in ./data/LC8*.tar.bz
		do
		NEWDIR=${filename%.tar.bz}
		echo Creating new directory $NEWDIR
		sudo mkdir $NEWDIR
		echo Extracting TIFs to $NEWDIR	
		sudo tar xvfj $filename -C $NEWDIR
		sudo rm $filename
		echo Resampling TIF to $res m resolution
		for filename2 in $NEWDIR/LC8*.TIF #loop over all TIFs in new directory
			do
			sudo gdalwarp -tr $res $res $filename2 ${filename2/.TIF}_res${res}.tif -r bilinear
			sudo rm $filename2
		done
		for filename3 in $NEWDIR/LC8*.IMD
			do
			sudo rm $filename3
		done

	echo UntarResample Finished ...
	done
}
