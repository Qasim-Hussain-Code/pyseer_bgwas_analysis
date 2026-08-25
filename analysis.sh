#!/bin/bash 
set -e

# initiate conda
eval "$(conda shell.bash hook)"

# activate pyseer environment
conda activate pyseer

# get the data
wget --content-disposition "https://ndownloader.figshare.com/files/14091179"

# extract the archive
tar xvf pyseer_tutorial.tar.bz2
