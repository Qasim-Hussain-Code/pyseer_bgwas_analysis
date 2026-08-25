#!/bin/bash 
set -e

# initiate conda
eval "$(conda shell.bash hook)"

# activate pyseer environment
conda activate pyseer

# get the data
curl -L -A "Mozilla/5.0" https://figshare.com -o pyseer_tutorial.tar.bz2

# extract the archive
tar xvf pyseer_tutorial.tar.bz2
