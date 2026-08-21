#!/bin/bash 
# initiate conda
eval "$(conda shell.bash hook)"

# create pyseer environment
conda create -n pyseer

# activate pyseer environment
conda initialize bash
conda activate pyseer

# install pyseer
conda install pyseer

# test pyseer installation
pyseer --help

# install fsm-lite
conda install fsm-lite

# install seer
conda install seer

# conda install unitig-counter and unitig-caller
conda install unitig-counter unitig-caller
