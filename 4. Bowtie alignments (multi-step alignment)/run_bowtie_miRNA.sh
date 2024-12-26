#!/bin/bash

# Script written by Dr Eleni Christoforidou

# Define the output directory
output_dir="../Bowtie miRNA alignment output"

# Create the output directory if it does not exist
mkdir -p "$output_dir"

# Loop through each .fastq.gz file in the current directory
for file in *.fastq.gz; do
    # Extract the base name of the file (without extension)
    base_name=$(basename "$file" .fastq.gz)

    # Define output paths with the output directory
    output_miRNA_unmapped="${output_dir}/${base_name}_miRNA_unmapped.fastq.gz"
    output_miRNA_alignments="${output_dir}/${base_name}_miRNA_alignments.sam"
    output_miRNA_log="${output_dir}/${base_name}_miRNA_bowtie.log"

    # Bowtie alignment
    bowtie -p 6 -q -n 1 -l 6 -e 100 --best -x "../Bowtie index of miRNA reference/mature_hsa_miRNAs_DNA" "$file" --un "$output_miRNA_unmapped" -S "$output_miRNA_alignments" 2>"$output_miRNA_log" # NOTE THIS COMMAND USES 6 THREADS WITH OPTION -p

    echo "Processing of $file completed."
done

echo "All eligible files have been processed."
