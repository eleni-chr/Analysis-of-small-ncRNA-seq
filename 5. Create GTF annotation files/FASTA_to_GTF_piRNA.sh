#!/bin/bash

# Script written by Dr Eleni Christoforidou

# Define the input FASTA file
input_fasta="piRNA_gold_standard_set.fa"
output_gtf="piRNA_gold_standard_set.gtf"

# Create or clear the output GTF file
echo -n > "$output_gtf"

# Read the FASTA file and generate the custom GTF file
while read -r line; do
    if [[ $line == \>* ]]; then
        # This is a header line (piRNA name)
        piRNA_name=$(echo "$line" | awk '{print $1}' | sed 's/>//') # Keep only the first part (remove '>')

        read -r sequence # Read the next line which is the sequence
        seq_length=${#sequence} # Get the length of the sequence

        # Write the custom GTF line with the last column formatted correctly
        echo -e "${piRNA_name}\tpiRBASE\ttranscript\t1\t${seq_length}\t.\t+\t.\ttranscript_id \"${piRNA_name}\";" >> "$output_gtf"
    fi
done < "$input_fasta"

echo "Custom GTF file created: $output_gtf"
