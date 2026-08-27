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

# take a look at the top hits
sort -g -k4,4 penicillin_COGs.txt | head

# perform analysis using the SNPs
pyseer --phenotypes resistances.pheno --vcf snps.vcf.gz --load-m mash_mds.pkl --lineage --print-samples > penicillin_SNPs.txt

# convert co-ordinates and p-values to a .plot using awk
cat <(echo "#CHR SNP BP minLOG10(P) log10(p) r^2") \\
<(paste <(sed '1d' penicillin_SNPs.txt | cut -d "_" -f 2) \\
<(sed '1d' penicillin_SNPs.txt | cut -f 4) | \\
awk '{p = -log($2)/log(10); print "26",".",$1,p,p,"0"}' ) | \\
tr ' ' '\t' > penicillin_snps.plot

# MAF cutoff corresponding to a MAC of at least 10
pyseer --phenotypes resistances.pheno --vcf snps.vcf.gz --load-m output/mash_mds.pkl --min-af 0.02 --max-af 0.98 > penicillin_SNPs.txt

# count the k-mers from the assemblies
mkdir -p assemblies
cd assemblies
tar xvf ../assemblies.tar.bz2
fsm-lite -l ../fsm_file_list.txt -s 6 -S 610 -v -t fsm_kmers | gzip -c - > ../fsm_kmers.txt.gz
cd ..

# use the distances from the core genome phylogeny
python scripts/phylogeny_distance.py --lmm core_genome_aln.tree > phylogeny_K.tsv

# increase the number of CPUs used to 8
pyseer --lmm --phenotypes resistances.pheno --kmers fsm_kmers.txt.gz --similarity phylogeny_K.tsv --output-patterns kmer_patterns.txt --cpu 8 > penicillin_kmers.txt

# determine a significance threshold using the number of unique k-mer patterns
python scripts/count_patterns.py kmer_patterns.txt

# create a Q-Q plot to check that p-values are not inflate
python scripts/qq_plot.py penicillin_kmers.txt

# filter those k-mers which exceeded the significance threshold in the mixed model analysis using awk 
cat <(head -1 penicillin_kmers.txt) <(awk '$4<1.90E-08 {print $0}' penicillin_kmers.txt) > significant_kmers.txt

# map to a single reference using bwa mem
phandango_mapper significant_kmers.txt Spn23F.fa Spn23F_kmers.plot

# annotate the k-mers which haven’t already been mapped to a previous annotation (requires bedtools, bedops and the pybedtools package)
annotate_hits_pyseer significant_kmers.txt references.txt annotated_kmers.txt

# summarise these annotations to create a plot of significant genes
python scripts/summarise_annotations.py annotated_kmers.txt > gene_hits.txt