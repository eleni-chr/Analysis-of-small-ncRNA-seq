#!/bin/bash

# Script written by Dr Eleni Christoforidou

# Define the output directory
output_dir="../Bowtie piRNA alignment output"

# Create the output directory if it does not exist
mkdir -p "$output_dir"

# Loop through each .fastq.gz file in the current directory
for file in *unmapped.fastq.gz; do
    # Extract the base name of the file (without extension)
    base_name=$(basename "$file" .fastq.gz)

    # Remove the _tRF_unmapped suffix if it exists
    base_name=${base_name/_tRF_unmapped/}

    # Define output paths with the output directory
    output_piRNA_unmapped="${output_dir}/${base_name}_piRNA_unmapped.fastq.gz"
    output_piRNA_alignments="${output_dir}/${base_name}_piRNA_alignments.sam"
    output_piRNA_log="${output_dir}/${base_name}_piRNA_bowtie.log"

    # Bowtie alignment
    bowtie -p 6 -q -n 2 -l 12 -e 100 --best -x "../Bowtie index of piRNA reference/piRNA_gold_standard_set" "$file" --un "$output_piRNA_unmapped" -S "$output_piRNA_alignments" 2>"$output_piRNA_log" # NOTE THIS COMMAND USES 6 THREADS WITH OPTION -p

    echo "Processing of $file completed."
done

echo "All eligible files have been processed."
