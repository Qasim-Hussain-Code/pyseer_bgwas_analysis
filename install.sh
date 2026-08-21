#!/bin/bash 

# create pyseer environment
conda create -n pyseer

# activate pyseer environment
conda activate pyseer

# install pyseer
conda install pyseer

# test pyseer installation
# run unit tests
pytest -v tests
# test functions and outputs
cd tests/ && bash run_test.sh && cd ../