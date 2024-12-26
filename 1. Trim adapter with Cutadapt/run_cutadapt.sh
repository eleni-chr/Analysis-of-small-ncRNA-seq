#!/bin/bash

# Script written by Dr Eleni Christoforidou

# Create the output directory if it doesn't exist
output_dir="../Cutadapt output"
mkdir -p "$output_dir"

# Loop through all .fastq.gz files in the current directory
for file in *.fastq.gz; do
    # Extract the base name of the file (without extension)
    base_name=$(basename "$file" .fastq.gz)
    
    # Define the output file name with the required suffix
    output_file="${output_dir}/${base_name}_trimmed.fastq.gz"
    
    # Define the summary statistics file name with the required suffix
    summary_file="${output_dir}/${base_name}_trim_report.txt"
    
    # Run cutadapt command and redirect summary statistics to the report file
    cutadapt -j 6 -a AACTGTAGGCACCATCAAT --error-rate=0.1 --times=1 --overlap=10 --action=trim --discard-untrimmed --minimum-length=14 -o "$output_file" "$file" > "$summary_file" # NOTE THIS COMMAND USES 6 THREADS WITH OPTION -j
    
    echo "Processed $file -> $output_file"
    echo "Summary statistics saved to $summary_file"
done
