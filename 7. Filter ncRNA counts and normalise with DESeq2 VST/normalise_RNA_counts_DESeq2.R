## Normalise RNA counts using DESeq2

# R script written by Dr Eleni Christoforidou in R 4.4.1.

# This script normalises raw count data for different RNA types (miRNA, tRF, piRNA) using the DESeq2 package
# and saves the normalised counts as CSV files. It assumes that the input files are Excel files with the first column
# representing RNA names and the remaining columns containing counts for each sample.

# Steps:
# 1. Install and load the required packages (DESeq2, readr, and readxl).
# 2. Load raw RNA counts from Excel files.
# 3. Prepare the count matrices by setting RNA names as row names.
# 4. Create DESeqDataSet objects for each RNA type.
# 5. Perform variance-stabilizing transformation (VST) normalisation using DESeq2.
# 6. Save the VST-normalised counts to CSV files.

# Install required packages
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("DESeq2")

install.packages("readr")
install.packages("readxl")

# Load required libraries
library("DESeq2")
library("readr")
library("readxl")

# Function to normalise RNA counts
normalize_counts <- function(input_file, output_file) {
  # Step 1: Load the raw counts data
  raw_counts <- read_excel(input_file)
  
  # Step 2: Prepare the data
  # The first column contains RNA names, so set it as the row names
  RNA_names <- raw_counts[[1]]  # Get the first column for RNA names
  raw_counts <- as.data.frame(raw_counts[, -1])  # Remove the RNA names from the counts data
  
  # Set the row names of the counts dataframe to be the RNA names
  rownames(raw_counts) <- RNA_names
  
  # Step 3: Create a DESeqDataSet object
  # DESeq2 expects a count matrix (genes in rows, samples in columns)
  # Create a sample information table (colData). Here it is empty.
  sample_info <- data.frame(row.names = colnames(raw_counts))
  
  # Create the DESeq2 object
  dds <- DESeqDataSetFromMatrix(countData = raw_counts, colData = sample_info, design = ~ 1)
  
  # Step 4: Perform normalisation with DESeq2
  vsd <- varianceStabilizingTransformation(dds, blind = TRUE) # Variance stabilizing transformation (VST)
  vst_counts <- assay(vsd)
  
  # Step 5: Save the normalised counts
  write.csv(vst_counts, output_file, row.names = TRUE)
}

# List of input and output files
files <- list(
  list(input = "miRNA_counts_filtered.xlsx", output = "VST_normalised_miRNA_counts.csv"),
  list(input = "tRF_counts_filtered.xlsx", output = "VST_normalised_tRF_counts.csv"),
  list(input = "piRNA_counts_filtered_strict.xlsx", output = "VST_normalised_piRNA_counts.csv")
)

# Process each file
for (file in files) {
  normalize_counts(file$input, file$output)
}
