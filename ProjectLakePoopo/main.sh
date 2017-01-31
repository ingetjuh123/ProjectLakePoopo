#!/bin/bash

#python ./Python/downloadLandsatDirect.py

cd ./data

#for file in LC8*.tar.bz
	#do
	#bunzip2 $file
#done

for file2 in LC8*.tar
	do
	NEWDIR=`echo $file2 | tr -d [a-zA-Z.]`
	sudo mkdir $NEWDIR
	sudo tar -xvf $file2 -C $NEWDIR
done

## Rscript ./R/untar.R

