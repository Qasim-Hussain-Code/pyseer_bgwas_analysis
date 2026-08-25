#!/bin/bash 
set -e

# initiate conda
eval "$(conda shell.bash hook)"

# activate pyseer environment
conda activate pyseer

# get the data
wget https://figshare.com -O pyseer_tutorial.tar.bz2
# extract the archive
tar xvf pyseer_tutorial.tar.bz2
