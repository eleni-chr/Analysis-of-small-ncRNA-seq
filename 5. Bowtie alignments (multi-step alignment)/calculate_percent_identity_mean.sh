#!/bin/bash

# Script written by Dr Eleni Christoforidou

# RNA types to process
RNA_TYPES=("miRNA" "tRF" "piRNA" "other_ncRNA")

# Function to calculate mean
calculate_mean() {
    local file="$1"
    
    # Extract values from the second column and calculate the mean
    awk 'NR>1 {sum+=$2; count+=1} END {if (count > 0) print sum / count; else print "N/A"}' "$file"
}

# Loop through each RNA type
for RNA_TYPE in "${RNA_TYPES[@]}"; do
    output_file="${RNA_TYPE}_percent_identity_menas.csv"
    > "$output_file"  # Create/empty the output file

    # Add header row to the output file
    echo "SampleID,MeanPercentIdentity" > "$output_file"

    # Process each file that matches the pattern
    for file in *"${RNA_TYPE}"*_percent_identity.txt; do
        # Extract sample ID from filename (assuming format P<number>-<digit>)
        sample_id=$(echo "$file" | grep -o 'P[0-9]\+-[0-9]')

        # Calculate mean
        mean=$(calculate_mean "$file")

        # Write results to output file
        echo "$sample_id,$mean" >> "$output_file"
    done
done

echo "CSV files with mean percent identity have been created for each RNA type."
