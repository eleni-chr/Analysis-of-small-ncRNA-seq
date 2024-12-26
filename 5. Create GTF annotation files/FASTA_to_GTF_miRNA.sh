#!/bin/bash

# Script written by Dr Eleni Christoforidou

# Define the input FASTA file
input_fasta="mature_hsa_miRNAs_DNA.fa"
output_gtf="mature_hsa_miRNAs.gtf"

# Create or clear the output GTF file
echo -n > "$output_gtf"

# Read the FASTA file and generate the custom GTF file
while read -r line; do
    if [[ $line == \>* ]]; then
        # This is a header line (miRNA name)
        miRNA_name=$(echo "$line" | awk '{print $1}' | sed 's/>//') # Keep only the first part (remove '>')

        read -r sequence # Read the next line which is the sequence
        seq_length=${#sequence} # Get the length of the sequence

        # Write the custom GTF line with the last column formatted correctly
        echo -e "${miRNA_name}\tmiRBASE\ttranscript\t1\t${seq_length}\t.\t+\t.\ttranscript_id \"${miRNA_name}\";" >> "$output_gtf"
    fi
done < "$input_fasta"

echo "Custom GTF file created: $output_gtf"
