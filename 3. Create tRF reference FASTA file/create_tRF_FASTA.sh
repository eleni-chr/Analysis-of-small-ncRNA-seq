#!/bin/bash

# Script written by Dr Eleni Christoforidou

# Input CSV files
input_file1="tRF-1_IDs.csv"
input_file2="tRF-3_IDs.csv"
input_file3="tRF-5_IDs.csv"
output_file="tRFs.fa"

# Check if the input files exist
if [[ ! -f "$input_file1" ]] || [[ ! -f "$input_file2" ]] || [[ ! -f "$input_file3" ]]; then
    echo "One or more input files do not exist."
    exit 1
fi

# Use awk to extract unique tRF IDs and sequences from all three files
awk -F , '{print ">"$1"\n"$2}' "$input_file1" "$input_file2" "$input_file3" > "$output_file"

echo "FASTA file created: $output_file"
