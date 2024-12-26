# Analysis-of-small-ncRNA-seq
This repository contains code and instruction files for processing, analysing, and quantifying small RNAs from non-coding RNA-seq data. It includes steps for trimming, alignment, and quantification of miRNAs, tRFs, piRNAs, and other ncRNAs.

_README written by Dr Eleni Christoforidou._

## Overview
This repository contains the complete workflow for analysing RNA-seq data focusing on small RNAs, including miRNAs, tRFs, and piRNAs. The analysis pipeline processes raw FASTQ files, trims adapters, performs quality control, aligns reads to reference sequences, and quantifies RNA abundance. The associated RNA-seq data files (.fastq.gz) are publicly available at XXXX. The associated publication of the results of this analysis is open-access at XXXXX.

## Features
- **Concatenating:** Scripts for concatenating sequencing files from multiple RNA-seq runs.
- **Trimming:** Adapter trimming using Cutadapt.
- **Quality Control:** FastQC scripts to assess the quality of sequencing reads.
- **Alignment:** Scripts for multi-step alignment using Bowtie.
- **Quantification:** FeatureCounts scripts for quantifying aligned reads.
- **Normalisation:** Scripts to normalise RNA counts using DESeq2's variance-stabilizing transformation.
- **Sample ID Extraction:** Several scripts automatically extract sample IDs from filenames in the format `P<number>-<digit>`.

## Workflow
All detailed instructions for reproducing this analysis are in the `Workflow.docx` file.

## Key Point
Scripts to extract **sample IDs** are tailored to the filename structure `P<number>-<digit>`. Modify the regular expression in any code files that use it if your filenames differ.

## Dependencies
The following tool versions have been used with this code:
- **Cutadapt:** Version 4.9 (for adapter trimming).
- **FastQC:** Version 0.12.1 (for quality control).
- **Bowtie:** Version 1.3.1 (for alignment).
- **featureCounts:** Version 2.0.7 (for quantification).
- **DESeq2:** Version 1.44.0 (for normalisation).
- **MATLAB:** Release R2024a and Release R2024b.
- **R:** Version 4.4.1
- **RStudio:** 2024.09.0 Build 375.

Refer to `Instructions/detailed_analysis_instructions.md` for installation commands and additional dependencies.

## Citation
If you use this repository, please cite:
- This repository: *RNAseq-Small-RNAs-Analysis* (GitHub link to be added)
- Relevant publications for referenced tools (e.g., Cutadapt, FastQC, Bowtie).

## License
This repository is distributed under the Apache v2.0 License. See `LICENSE` for details.
