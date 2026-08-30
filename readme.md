[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

# Bacterial Genome Wide Association Study of Penicillin Resistance in *Streptococcus pneumoniae*

A reproducible bacterial genome wide association study (bGWAS) pipeline designed to identify genetic determinants of penicillin resistance across 604 clinical *Streptococcus pneumoniae* isolates. This workflow evaluates three distinct variant representations (single nucleotide polymorphisms, clusters of orthologous groups, and reference-free k-mers) using both fixed effects models and linear mixed models (LMM) to separate genuine biological signals from population structure confounding.

## Background

Antimicrobial resistance in *Streptococcus pneumoniae* poses a continuous global public health challenge. While target mutations in penicillin binding proteins (PBPs) are well characterized, identifying novel resistance drivers across the accessory genome requires unbiased, genome scale association testing. 

Microbial GWAS presents distinct methodological challenges compared to human GWAS. Bacterial populations exhibit high clonality and strong linkage disequilibrium, which severely inflates false positive rates if population structure is uncorrected. Additionally, the open pangenome introduces structural variants and accessory genes that cannot be captured by SNP calling alone.

This pipeline implements [**pyseer**](https://github.com/mgalardini/pyseer) (Lees et al., 2018) to address these analytical hurdles through multidimensional scaling (MDS) of pairwise genomic distances and phylogeny derived kinship matrices for mixed model association testing.

## Dataset Specification

| Parameter | Specification |
|---|---|
| **Organism** | *Streptococcus pneumoniae* |
| **Isolate Count** | 604 clinical strains |
| **Phenotype** | Penicillin resistance (binary classification: resistant vs susceptible) |
| **Assembly Method** | Velvet de novo contig assembly per strain |
| **Reference Genome** | *Streptococcus pneumoniae* strain ATCC 700669 (Spn23F) |
| **Data Source** | [Figshare repository (pyseer tutorial archive)](https://doi.org/10.6084/m9.figshare.7588832) |

## Association Testing Strategies

The workflow executed in `analysis.sh` encompasses four primary analytical steps:

### 1. Fixed Effects Association on Pangenome COGs

Pairwise Mash distances are computed across all assemblies. A scree plot analysis determines the optimal number of MDS dimensions (top 8 retained) to incorporate as covariates for population structure correction. Gene presence and absence patterns derived from Roary are tested against penicillin resistance using logistic regression under a fixed effects framework.

### 2. Fixed Effects Association on Core Genome SNPs

Single nucleotide polymorphisms identified across core alignment regions are tested using the same fixed effects logistic framework. The model estimates lineage specific Wald test statistics across each MDS axis to quantify how lineage differentiation correlates with the phenotype. Association coordinates are formatted for visualization in Phandango.

### 3. Linear Mixed Model Association on Reference-Free k-Mers

Variable length k-mers (6 to 610 base pairs) are extracted from assembled contigs via `fsm-lite`. This reference agnostic approach captures point mutations, indels, and structural gene variations simultaneously. Association testing is conducted under a Linear Mixed Model (LMM), using a distance matrix calculated from the core genome phylogenetic tree to model genetic relatedness among isolates.

An empirical significance threshold is established based on the number of unique k-mer patterns rather than total k-mer count. Statistically significant k-mers are aligned to the Spn23F reference genome and annotated to locate associated coding sequences.

### 4. Quality Control and Statistical Validation

- **MDS Scree Plot Inspection:** Confirms appropriate dimensionality selection for fixed effect covariates.
- **Quantile-Quantile (Q-Q) Plotting:** Evaluates p-value distributions to verify effective mitigation of population structure inflation.
- **Minor Allele Frequency Filtering:** Imposes a threshold requiring a minimum allele count of 10 (MAC >= 10; MAF range 0.02 to 0.98) to eliminate low frequency variants prone to spurious association.

## Repository Organization

```
.
├── analysis.sh              # Master execution pipeline
├── install.sh               # Conda environment configuration script
├── readme.md                # Project documentation
├── .gitignore               # Version control exclusion rules
├── LICENSE                  # Open source MIT license terms
│
├── resistances.pheno        # Excluded data: binary phenotype matrix
├── gene_presence_absence.Rtab  # Excluded data: pangenome matrix
├── snps.vcf.gz              # Excluded data: variant call format file
├── core_genome_aln.tree     # Excluded data: core genome phylogeny
├── fsm_file_list.txt        # Excluded data: assembly manifest
├── assemblies/              # Excluded data: de novo contig directory
│
├── mash_sketch.msh          # Excluded intermediate: Mash sketch database
├── mash.tsv                 # Excluded intermediate: pairwise distance matrix
├── mash_mds.pkl             # Excluded intermediate: serialised MDS coordinates
├── scree_plot.png           # Excluded intermediate: scree plot graphic
│
├── penicillin_COGs.txt      # Excluded output: COG association results
├── penicillin_SNPs.txt      # Excluded output: SNP association results
├── lineage_effects.txt      # Excluded output: lineage Wald test statistics
│
├── Spn23F.fa / Spn23F.gff   # Excluded reference: reference genome and annotation
└── 6952_7#3.fa / .gff       # Excluded reference: example isolate assembly
```

*Note: All raw data, intermediate matrices, and output text files are excluded from git tracking via `.gitignore`. Running `analysis.sh` automatically fetches the raw data from Figshare and regenerates all downstream files.*

## Software Dependencies

| Tool | Function | Installation |
|---|---|---|
| [pyseer](https://pyseer.readthedocs.io/) | Fixed effects and linear mixed model GWAS | `conda install pyseer` |
| [Mash](https://mash.readthedocs.io/) | MinHash distance estimation | `conda install mash` |
| [fsm-lite](https://github.com/nvalimak/fsm-lite) | Assembly based k-mer counting | `conda install fsm-lite` |
| [bedtools](https://bedtools.readthedocs.io/) | Genomic arithmetic operations | `conda install bedtools` |
| [bedops](https://bedops.readthedocs.io/) | Genomic region extraction | `conda install bedops` |
| [pybedtools](https://daler.github.io/pybedtools/) | Python interface for bedtools | `conda install pybedtools` |
| [bwa](https://github.com/lh3/bwa) | Read and k-mer alignment | `conda install bwa` |

Environment dependencies can be installed collectively using `install.sh`.

## Reproduction Steps

```bash
# Initialize and activate the Conda environment
bash install.sh

# Execute the complete analysis pipeline
bash analysis.sh
```

The pipeline automatically performs data retrieval, distance matrix construction, fixed effects testing, LMM k-mer scanning, and functional annotation.

## Output File Glossary

| File Name | Content Description |
|---|---|
| `penicillin_COGs.txt` | Fixed effects association statistics for 6,087 pangenome COGs |
| `penicillin_SNPs.txt` | Fixed effects association statistics for 89,691 core SNPs |
| `penicillin_kmers.txt` | Linear mixed model association statistics for k-mers |
| `significant_kmers.txt` | Filtered k-mers exceeding pattern based significance thresholds |
| `lineage_effects.txt` | Per axis Wald test values indicating lineage association |
| `Spn23F_kmers.plot` | Position mapped association p-values for Phandango plot rendering |
| `annotated_kmers.txt` | Genomic coordinates and feature annotations for hit k-mers |
| `gene_hits.txt` | Aggregated gene level summary of candidate resistance loci |

## Methodological Summary

- **Structure Control:** Fixed effects models utilize top MDS dimensions from Mash distances. Linear mixed models utilize a phylogenetic covariance matrix calculated from core alignment distances.
- **Variant Resolution:** Core SNPs identify point mutations, COGs assess accessory gene burden, and k-mers provide reference-free resolution across complex structural variants.
- **Multiple Testing Correction:** Significance thresholds are adjusted based on unique k-mer pattern count rather than total k-mer count, accounting for non-independence due to linkage disequilibrium.

## Literature References

- Lees, J. A., Galardini, M., Bentley, S. D., Weiser, J. N., & Corander, J. (2018). pyseer: a comprehensive tool for microbial pangenome-wide association studies. *Bioinformatics*, 34(24), 4310-4312. [doi:10.1093/bioinformatics/bty539](https://doi.org/10.1093/bioinformatics/bty539)
- Lees, J. A., Mai, T. T., Galardini, M., Wheeler, N. E., Horsfield, S. T., Parkhill, J., & Corander, J. (2020). Improved inference and prediction of bacterial genotype-phenotype associations using interpretable pangenome-spanning regressions. *mBio*, 11(4), e01344-20. [doi:10.1128/mBio.01344-20](https://doi.org/10.1128/mBio.01344-20)

## License

This project is open-source software licensed under the terms of the MIT License. See the [LICENSE](LICENSE) file for the full text. Third-party packages and tutorial dataset assets retain their respective upstream software licenses.
