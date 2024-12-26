#!/bin/bash

# Script written by Dr Eleni Christoforidou

# Define the output directory
output_dir="../Bowtie tRF alignment output"

# Create the output directory if it does not exist
mkdir -p "$output_dir"

# Loop through each .fastq.gz file in the current directory
for file in *unmapped.fastq.gz; do
    # Extract the base name of the file (without extension)
    base_name=$(basename "$file" .fastq.gz)

    # Remove the _miRNA_unmapped suffix if it exists
    base_name=${base_name/_miRNA_unmapped/}

    # Define output paths with the output directory
   output_tRF_unmapped="${output_dir}/${base_name}_tRF_unmapped.fastq.gz"
    output_tRF_alignments="${output_dir}/${base_name}_tRF_alignments.sam"
    output_tRF_log="${output_dir}/${base_name}_tRF_bowtie.log"

    # Bowtie alignment
    bowtie -p 6 -q -n 2 -l 10 -e 100 --best -x "../Bowtie index of tRF reference/tRFs" "$file" --un "$output_tRF_unmapped" -S "$output_tRF_alignments" 2>"$output_tRF_log" # NOTE THIS COMMAND USES 6 THREADS WITH OPTION -p

    echo "Processing of $file completed."
done

echo "All eligible files have been processed."
