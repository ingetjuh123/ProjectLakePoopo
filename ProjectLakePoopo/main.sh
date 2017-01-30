#!/bin/bash

python ./Python/downloadLandsatDirect.py
cd ./data




#for file in LC8*.tar.bz
#	do
#	bunzip2 $file
#done

DIR="./data"

for file2 in LC8*.tar
	do
	NEWDIR=`echo $file2 | tr -d [a-zA-Z.]`
	sudo mkdir $DIR/$NEWDIR
	tar -xvzf $file2 -C $DIR/$NEWDIR
done

## Rscript ./R/untar.R

