#!/bin/bash 
set -e

# initiate conda
eval "$(conda shell.bash hook)"

# activate pyseer environment
conda activate pyseer

# fetch geonmes from ena
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR065/ERR065292/ERR065292_2.fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR065/ERR065290/ERR065290_1.fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR065/ERR065293/ERR065293_1.fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR065/ERR065288/ERR065288_1.fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR065/ERR065288/ERR065288_2.fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR065/ERR065292/ERR065292_1.fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR065/ERR065290/ERR065290_2.fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR065/ERR065293/ERR065293_2.fastq.gz



