#!/bin/bash

# Script written by Dr Eleni Christoforidou

# Define the output directory
output_dir="../Bowtie other ncRNA alignment output"

# Create the output directory if it does not exist
mkdir -p "$output_dir"

# Loop through each .fastq.gz file in the current directory
for file in *unmapped.fastq.gz; do
    # Extract the base name of the file (without extension)
    base_name=$(basename "$file" .fastq.gz)

    # Remove the _piRNA_unmapped suffix if it exists
    base_name=${base_name/_piRNA_unmapped/}

    # Define output paths with the output directory
    output_other_ncRNA_unmapped="${output_dir}/${base_name}_other_ncRNA_unmapped.fastq.gz"
    output_other_ncRNA_alignments="${output_dir}/${base_name}_other_ncRNA_alignments.sam"
    output_other_ncRNA_log="${output_dir}/${base_name}_other_ncRNA_bowtie.log"

    # Bowtie alignment
    bowtie -p 6 -q -n 1 -l 12 -e 100 --best -x "../Bowtie index of other ncRNA reference/hsa_other_ncRNAs" "$file" --un "$output_other_ncRNA_unmapped" -S "$output_other_ncRNA_alignments" 2>"$output_other_ncRNA_log" # NOTE THIS COMMAND USES 6 THREADS WITH OPTION -p

    echo "Processing of $file completed."
done

echo "All eligible files have been processed."
