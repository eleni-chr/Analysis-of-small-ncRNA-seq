#!/bin/bash

# Script written by Dr Eleni Christoforidou

# Create the output directory if it doesn't exist
output_dir="../featureCounts output miRNA"
mkdir -p "$output_dir"

# Path to the GTF file
gtf_file="../Bowtie index of miRNA reference/mature_hsa_miRNAs.gtf"

# Loop through each .sam file in the current directory
for sam_file in *_alignments.sam; do
    if [[ -f "$sam_file" ]]; then
        # Get the base name of the file (without the "_alignments" suffix and extension)
        base_name=$(basename "$sam_file" _alignments.sam)

        # Set output file names with "_miRNA_counts" suffix
        output_txt="$output_dir/${base_name}_miRNA_counts.txt"
        output_summary="$output_dir/${base_name}_miRNA_counts.summary"

        # Run featureCounts command (NB: -d and -D values have been selected as the minimum and maximum length read lengths as seen by FastQC results)
        featureCounts -T 6 -d 14 -D 63 --primary -t transcript -g transcript_id -a "$gtf_file" -o "$output_txt" "$sam_file" # NOTE THIS COMMAND USES 6 THREADS WITH OPTION -T

        # Rename the summary file to match the output filename
        mv "${output_txt}.summary" "$output_summary"

        # Output progress message
        echo "Processed: $sam_file -> ${base_name}_miRNA_counts.txt and ${base_name}_miRNA_counts.summary"
    fi
done

echo "All files processed."
