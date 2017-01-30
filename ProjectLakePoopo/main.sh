#!/bin/bash

cd ../ProjectLakePoopo

python ./Python/downloadLandsatDirect.py

Rscript ./R/untar.R

