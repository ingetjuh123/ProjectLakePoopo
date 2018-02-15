#!/bin/bash

echo "Install Package Started ..."

## Download Necessary Packages
sudo apt-get update

sudo apt-get install python-pip python-numpy python-scipy libgdal-dev libatlas-base-dev gfortran libfreetype6-dev python-setuptools python-dev

pip install pycurl

sudo pip install python-utils

echo "Install Package Finished ..."
