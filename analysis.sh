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

# SNP and COG association with fixed effects model
mkdir assemblies
cd assemblies
tar xf ../assemblies.tar.bz2
cd ..
mash sketch -s 10000 -o mash_sketch assemblies/*.fa

# calculate distances between all pairs of samples
mash dist mash_sketch.msh mash_sketch.msh| square_mash > mash.tsv

# look at a scree plot to choose the number of dimensions to retain
scree_plot_pyseer mash.tsv

# run the analysis on the COGs
pyseer --phenotypes resistances.pheno --pres gene_presence_absence.Rtab --distances mash.tsv --save-m mash_mds --max-dimensions 8 > penicillin_COGs.txt