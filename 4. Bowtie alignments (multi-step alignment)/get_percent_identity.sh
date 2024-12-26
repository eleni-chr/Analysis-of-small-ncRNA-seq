#!/bin/bash

# Script written by Dr Eleni Christoforidou

# Create the output directory "Percent identity files" if it doesn't exist
mkdir -p "Percent identity files"

# Associative array to map folder names to file suffixes
declare -A folder_suffix_map=(
    ["Bowtie miRNA alignment output"]="_miRNA_percent_identity.txt"
    ["Bowtie tRF alignment output"]="_tRF_percent_identity.txt"
    ["Bowtie piRNA alignment output"]="_piRNA_percent_identity.txt"
    ["Bowtie other ncRNA alignment output"]="_other_ncRNA_percent_identity.txt"
)

# Loop through each folder and process all SAM files in them
for folder in "${!folder_suffix_map[@]}"; do
    suffix="${folder_suffix_map[$folder]}"
    
    # Loop through each SAM file in the current folder
    for samfile in "${folder}"/*.sam; do
        # Extract the sample ID from the filename (assuming it starts with 'P' followed by digits and a dash and one more digit)
        sample_id=$(basename "$samfile" | grep -o 'P[0-9]\+-[0-9]')
        
        # Define the output file based on the sample ID and the folder type
        outputfile="Percent identity files/${sample_id}${suffix}"

        if [[ -f "$samfile" ]]; then
            echo "Processing $samfile -> $outputfile"  # Debugging output

            # Process the SAM file and calculate percent identity
            awk '
            BEGIN { OFS="\t"; }
            {
                if ($1 !~ /^@/) {  # Skip header lines
                    cigar = $6;
                    md_tag = "";
                    
                    # Extract the MD tag (it starts with MD:Z:)
                    for (i = 12; i <= NF; i++) {
                        if ($i ~ /^MD:Z:/) {
                            md_tag = substr($i, 6);  # Extract the MD tag content after "MD:Z:"
                            break;
                        }
                    }

                    if (md_tag == "") {
                        next;  # Skip if no MD tag is found
                    }

                    total_length = 0;
                    mismatches = 0;

                    # Simplified CIGAR parsing logic
                    # Iterate through the CIGAR string
                    while (cigar) {
                        # Extract the length and type of the current operation
                        len = gensub(/([0-9]+)([MIDNSHP=X])/, "\\1", "g", cigar);
                        type = gensub(/([0-9]+)([MIDNSHP=X])/, "\\2", "g", cigar);

                        if (len != "") {
                            if (type ~ /[MX=]/) {  # M, X, or = are considered matches
                                total_length += len;
                            }
                            cigar = substr(cigar, length(len) + 1);  # Move past the processed part
                        } else {
                            break;  # No more CIGAR operations left
                        }
                    }

                    # Count the mismatches from the MD tag (uppercase letters in MD tag are mismatches)
                    mismatches = gsub(/[A-Z]/, "", md_tag);

                    # Calculate the percent identity
                    if (total_length > 0) {
                        percent_identity = ((total_length - mismatches) / total_length) * 100;
                        print $1, percent_identity;  # Output read name and percent identity
                    }
                }
            }' "$samfile" > "$outputfile"

            echo "Processed $samfile -> $outputfile"
        else
            echo "Warning: SAM file not found for $sample_id in $folder"
        fi
    done
done
