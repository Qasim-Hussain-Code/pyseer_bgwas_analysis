#!/bin/bash 
set -e

# initiate conda
eval "$(conda shell.bash hook)"

# activate pyseer environment
conda activate pyseer

# get the data
wget https://doi.org/10.6084/m9.figshare.7588832



