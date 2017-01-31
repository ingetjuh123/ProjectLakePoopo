#!/bin/bash

python ./Python/downloadLandsatDirect.py
bash ./Bash/untar.sh
Rscript ./R/Calculation.R
#Rscript ./R/Visualization.R

