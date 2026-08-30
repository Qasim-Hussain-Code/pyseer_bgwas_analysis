# Bacterial GWAS of Penicillin Resistance in *Streptococcus pneumoniae*

A reproducible bacterial genome-wide association study (bGWAS) pipeline for identifying genetic determinants of penicillin resistance across 604 clinical *S. pneumoniae* isolates. This analysis employs complementary variant representations — single-nucleotide polymorphisms (SNPs), clusters of orthologous groups (COGs), and *k*-mers — under both fixed-effects and linear mixed model (LMM) frameworks to disentangle true genotype–phenotype associations from population structure confounding.

## Background

Antimicrobial resistance (AMR) in *S. pneumoniae* remains a major clinical concern worldwide. Conventional resistance prediction relies on known determinants (e.g., penicillin-binding protein mutations), but discovery of novel or accessory-genome-mediated resistance mechanisms requires unbiased, genome-scale association testing. Bacterial GWAS presents unique statistical challenges compared to human GWAS: strong clonal population structure inflates false-positive rates, while the open pangenome introduces combinatorial variant spaces far larger than SNP-only analyses.

This pipeline addresses these challenges using [**pyseer**](https://github.com/mgalardini/pyseer) (Lees *et al.*, 2018), which implements population-structure correction via Mash-distance multidimensional scaling (MDS) covariates and phylogeny-derived kinship matrices for mixed-model association.

## Dataset

| Property | Value |
|---|---|
| **Organism** | *Streptococcus pneumoniae* |
| **Isolates** | 604 clinical strains |
| **Phenotype** | Penicillin resistance (binary: resistant / susceptible) |
| **Assemblies** | Velvet *de novo* contigs per isolate |
| **Reference genome** | *S. pneumoniae* ATCC 700669 (Spn23F) |
| **Data provenance** | [Figshare archive (pyseer tutorial)](https://doi.org/10.6084/m9.figshare.7588832) |

## Analysis Overview

The pipeline is executed end-to-end by [`analysis.sh`](analysis.sh) and proceeds through four complementary GWAS strategies:

### 1. Fixed-Effects Model — COG Presence/Absence

Pairwise Mash distances are computed across all 604 assemblies. A scree plot guides retention of the top 8 MDS components as covariates for population-structure correction. Gene presence/absence across the pangenome (from Roary output) is then tested for association with penicillin resistance under a fixed-effects logistic model.

### 2. Fixed-Effects Model — SNP Variants

Core-genome SNPs (VCF) are tested under the same fixed-effects framework, additionally estimating lineage effects to quantify the contribution of each MDS axis to resistance. A Manhattan-style `.plot` file is generated for visualisation in Phandango.

### 3. Linear Mixed Model — *k*-mer Association

Short *k*-mers (length 6–610 bp) are enumerated from assemblies using `fsm-lite`, providing a reference-free variant representation that captures SNPs, indels, and structural variation in a single test. Association is performed under an LMM using a phylogenetic kinship matrix derived from the core-genome alignment tree, which more rigorously accounts for relatedness than MDS covariates alone.

A significance threshold is calibrated empirically from the number of unique *k*-mer patterns. Significant *k*-mers are mapped back to the Spn23F reference using `phandango_mapper` and annotated with `annotate_hits_pyseer` to identify the underlying genes.

### 4. Quality Control

- **Scree plot** — ensures adequate dimensionality reduction for population-structure correction
- **Q–Q plot** — verifies that *p*-values are well-calibrated (i.e., no residual inflation from uncontrolled structure)
- **Minor allele frequency filtering** — enforces a minimum allele count of 10 (MAC ≥ 10; MAF 0.02–0.98) to exclude rare variants with unstable effect estimates

## Repository Structure

```
.
├── analysis.sh              # End-to-end GWAS pipeline (bash)
├── install.sh               # Conda environment setup
├── readme.md                # This document
├── .gitignore               # Excludes all data and results from version control
│
├── resistances.pheno        # ⊘ gitignored — binary phenotype matrix (604 isolates)
├── gene_presence_absence.Rtab  # ⊘ gitignored — pangenome gene presence/absence
├── snps.vcf.gz              # ⊘ gitignored — core-genome SNP calls
├── core_genome_aln.tree     # ⊘ gitignored — phylogenetic tree (Newick)
├── fsm_file_list.txt        # ⊘ gitignored — assembly manifest for fsm-lite
├── assemblies/              # ⊘ gitignored — 616 Velvet contigs
│
├── mash_sketch.msh          # ⊘ gitignored — Mash sketch database
├── mash.tsv                 # ⊘ gitignored — pairwise Mash distance matrix
├── mash_mds.pkl             # ⊘ gitignored — serialised MDS embedding
├── scree_plot.png           # ⊘ gitignored — MDS scree plot
│
├── penicillin_COGs.txt      # ⊘ gitignored — COG association results
├── penicillin_SNPs.txt      # ⊘ gitignored — SNP association results (89,691 variants)
├── lineage_effects.txt      # ⊘ gitignored — per-MDS-axis lineage Wald statistics
│
├── Spn23F.fa / Spn23F.gff   # ⊘ gitignored — reference genome and annotation
└── 6952_7#3.fa / .gff       # ⊘ gitignored — example isolate genome
```

> **Note:** Files marked ⊘ are excluded from version control via `.gitignore`. They are regenerated automatically by running `analysis.sh`, which downloads the source data from Figshare.

## Prerequisites

| Software | Purpose | Install |
|---|---|---|
| [pyseer](https://pyseer.readthedocs.io/) | Association testing (fixed & mixed models) | `conda install pyseer` |
| [Mash](https://mash.readthedocs.io/) | Genome distance estimation | `conda install mash` |
| [fsm-lite](https://github.com/nvalimak/fsm-lite) | *k*-mer enumeration from assemblies | `conda install fsm-lite` |
| [bedtools](https://bedtools.readthedocs.io/) | Genomic interval operations | `conda install bedtools` |
| [bedops](https://bedops.readthedocs.io/) | BED format conversion | `conda install bedops` |
| [pybedtools](https://daler.github.io/pybedtools/) | Python interface to bedtools | `conda install pybedtools` |
| [bwa](https://github.com/lh3/bwa) | Short-read alignment (*k*-mer mapping) | `conda install bwa` |

All dependencies can be installed via the provided [`install.sh`](install.sh) script using Conda (Bioconda channel recommended).

## Quickstart

```bash
# 1. Create and activate the conda environment
bash install.sh

# 2. Run the full pipeline
bash analysis.sh
```

The pipeline will:
1. Download the tutorial dataset from Figshare (~395 MB compressed)
2. Compute Mash distances and MDS embedding
3. Run fixed-effects association on COGs and SNPs
4. Enumerate *k*-mers and run LMM association
5. Map and annotate significant *k*-mers against the Spn23F reference

## Key Outputs

| File | Description |
|---|---|
| `penicillin_COGs.txt` | COG association results (6,087 genes tested) |
| `penicillin_SNPs.txt` | SNP association results (89,691 variants tested) |
| `penicillin_kmers.txt` | *k*-mer LMM association results |
| `significant_kmers.txt` | *k*-mers exceeding the empirical significance threshold |
| `lineage_effects.txt` | Wald test statistics for each MDS axis (lineage contribution) |
| `Spn23F_kmers.plot` | Manhattan plot coordinates for Phandango visualisation |
| `annotated_kmers.txt` | Gene-level annotation of significant *k*-mers |
| `gene_hits.txt` | Summary of significantly associated genes |

## Methodological Notes

- **Population structure correction.** Two complementary approaches are used: (i) Mash-distance MDS components as fixed-effect covariates, and (ii) a phylogenetic kinship matrix under an LMM. The latter is theoretically preferable for clonal organisms but computationally more expensive.
- **Variant representations.** SNPs capture core-genome point mutations; COGs capture accessory-genome gene content variation; *k*-mers provide a unified, reference-free representation that subsumes both classes and additionally captures structural variants.
- **Significance calibration.** Rather than a Bonferroni correction over all tested *k*-mers (which would be overly conservative due to linkage), the threshold is derived from the number of unique *k*-mer patterns, reflecting the effective number of independent tests.

## Citation

If you use this pipeline or adapt it for your own analyses, please cite the underlying tools:

> Lees, J. A., Galardini, M., Bentley, S. D., Weiser, J. N., & Corander, J. (2018). pyseer: a comprehensive tool for microbial pangenome-wide association studies. *Bioinformatics*, 34(24), 4310–4312. [doi:10.1093/bioinformatics/bty539](https://doi.org/10.1093/bioinformatics/bty539)

> Lees, J. A., *et al.* (2020). Improved inference and prediction of bacterial genotype–phenotype associations using interpretable pangenome-spanning regressions. *mBio*, 11(4), e01344-20. [doi:10.1128/mBio.01344-20](https://doi.org/10.1128/mBio.01344-20)

## License

This repository is provided for academic and research use. Please see individual tool licenses for redistribution terms.
