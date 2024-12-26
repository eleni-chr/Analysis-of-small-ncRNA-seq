function remove_low_RNAs_VST
%% Function written by Dr Eleni Christoforidou in MATLAB R2024b.

% This function reads CSV files containing VST-normalised count data for different RNA types 
% (miRNAs, tRFs, piRNAs), identifies lowly-expressed RNAs based on the lower 25% quantile of 
% median expression, and outputs two Excel files per input file: one with lowly-expressed RNAs 
% and another with highly-expressed RNAs (after filtering).
%
% The function performs the following steps:
% 1. Reads RNA count data from a CSV file where the first column contains RNA names 
%    and subsequent columns contain VST-normalised counts across different samples.
% 2. Calculates the 25th percentile (lower quartile) of median expression values across all samples 
%    for each RNA type, using this as the low-expression threshold.
% 3. Identifies RNAs with median expression below this threshold, saves these lowly-expressed RNAs 
%    to an Excel file named 'Lowly-expressed_VST_<RNA_type>.xlsx'.
% 4. Filters out lowly-expressed RNAs from the dataset and saves the remaining highly-expressed RNAs 
%    to another Excel file named 'Highly-expressed_VST_<RNA_type>_counts.xlsx'.
%
% Files processed (hardcoded):
% - 'VST_normalised_miRNA_counts.csv'
% - 'VST_normalised_tRF_counts.csv'
% - 'VST_normalised_piRNA_counts.csv'
%
% Outputs:
% - 'Lowly-expressed_miRNAs.xlsx': Excel file containing miRNAs with median expression below the 25th percentile.
% - 'Highly-expressed_miRNA_counts.xlsx': Excel file containing VST-normalised counts of miRNAs above the threshold.
% - 'Lowly-expressed_tRFs.xlsx': Excel file containing tRFs with median expression below the 25th percentile.
% - 'Highly-expressed_tRF_counts.xlsx': Excel file containing VST-normalised counts of tRFs above the threshold.
% - 'Lowly-expressed_piRNAs.xlsx': Excel file containing piRNAs with median expression below the 25th percentile.
% - 'Highly-expressed_piRNA_counts.xlsx': Excel file containing VST-normalised counts of piRNAs above the threshold.
%
% Usage:
% - Ensure the VST-normalised RNA counts are stored in CSV files with RNA names in the first column 
%   and the rest as numeric data representing the VST-normalised counts across samples.
% - Run the function in MATLAB to generate the output Excel files.

%%
% Hardcoded input files and corresponding output suffixes
fileList = {
    'VST_normalised_miRNA_counts.csv', 'miRNA_counts', 'miRNAs';
    'VST_normalised_tRF_counts.csv', 'tRF_counts', 'tRFs';
    'VST_normalised_piRNA_counts.csv', 'piRNA_counts', 'piRNAs'
};

% Process each file
for i = 1:size(fileList, 1)
    inputFile = fileList{i, 1};
    highSuffix = fileList{i, 2};
    lowSuffix = fileList{i, 3};
    
    % Step 1: Read VST-normalised counts from the CSV file
    data = readtable(inputFile, 'VariableNamingRule', 'preserve');
    
    % Step 2: Extract names (assumed to be in the first column)
    names = data{:, 1};
    
    % Step 3: Extract VST-normalised counts (assumed to be in subsequent columns)
    vst_counts = data{:, 2:end};
    
    % Step 4: Calculate the median expression for each entry across all samples
    medians = median(vst_counts, 2);
    
    % Step 5: Determine the 25th percentile threshold for low expression
    low_expression_threshold = quantile(medians, 0.25);
    
    % Step 6: Identify lowly-expressed entries based on the 25th percentile threshold
    lowly_expressed_mask = medians < low_expression_threshold;
    
    % Step 7: Extract the entries that are lowly expressed
    lowly_expressed_names = names(lowly_expressed_mask);
    lowlyExpressedTable = table(lowly_expressed_names, 'VariableNames', {'Lowly-expressed_entries'});
    
    % Step 8: Save the lowly-expressed entries to an output file
    lowly_outputFile = ['Lowly-expressed_VST_' lowSuffix '.xlsx'];
    writetable(lowlyExpressedTable, lowly_outputFile);
    
    % Step 9: Filter out these lowly-expressed entries from the VST-normalised counts
    vst_counts_filtered = vst_counts(~lowly_expressed_mask, :);
    names_filtered = names(~lowly_expressed_mask);
    
    % Step 10: Create variable names for the output table
    sample_names = data.Properties.VariableNames(2:end);
    
    % Step 11: Save the filtered counts to another output file
    filteredTable = array2table(vst_counts_filtered, 'VariableNames', sample_names);
    filteredTable.Name = names_filtered;
    filteredTable = movevars(filteredTable, 'Name', 'Before', 1);
    high_outputFile = ['Highly-expressed_VST_' highSuffix '.xlsx'];
    writetable(filteredTable, high_outputFile);
end
end
