#!/bin/bash 
# initiate conda
eval "$(conda shell.bash hook)"

# create pyseer environment
conda create -n pyseer

# activate pyseer environment
conda activate pyseer

# install pyseer
conda install pyseer

# test pyseer installation
pyseer --help