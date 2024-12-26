function remove_non_expressed_RNAs
%% Function written by Dr Eleni Christoforidou in MATLAB R2024b.
%
% This function performs the following steps for each RNA type (miRNA, tRF, piRNA, and other ncRNA):
% 1. Reads RNA count data from specified input Excel files where the first column contains RNA names 
%    and subsequent columns represent counts across different samples.
% 2. Removes RNAs that have zero counts in ALL samples and saves the names of these non-expressed RNAs
%    to an output Excel file named "Non-expressed_<RNA_type>.xlsx". If this file is empty, it means that all 
%    RNAs had a count >0 in at least one sample.
% 3. Saves the filtered RNA counts (after removal of some RNAs in step 2) to an Excel file named "<RNA_type>_counts_filtered.xlsx".
%
% Input:
% - None (uses hardcoded input file names).
%
% Output:
% - Two Excel files per input file:
%   1. A file listing RNAs that had zero counts in all samples.
%   2. A file containing the counts for RNAs that passed the filtering criteria.

    % Define input files and corresponding output file names
    rnaFiles = {
        'miRNA_counts_all_samples.xlsx', 'miRNA';
        'tRF_counts_all_samples.xlsx', 'tRF';
        'piRNA_counts_all_samples.xlsx', 'piRNA';
        'other_ncRNA_counts_all_samples.xlsx', 'other_ncRNA'
    };

    % Loop over each RNA file
    for i = 1:size(rnaFiles, 1)
        inputFile = rnaFiles{i, 1};
        rnaType = rnaFiles{i, 2};
        
        outputNotExpressedFile = sprintf('Non-expressed_%s.xlsx', rnaType);
        outputFilteredFile = sprintf('%s_counts_filtered.xlsx', rnaType);

        % Step 1: Read the counts from the specified Excel file
        data = readtable(inputFile);

        % Ensure the first column (RNA names) is treated as strings
        data.(1) = string(data.(1));  % Convert the first column to strings if necessary

        % Extract RNA names and counts
        rna_names = data{:, 1};         % First column: RNA names
        counts = data{:, 2:end};        % Remaining columns: counts

        % Step 2: Remove RNAs with zero counts across all samples
        zero_counts_mask = any(counts > 0, 2);  % Logical mask for non-zero counts
        counts_nonzero = counts(zero_counts_mask, :);  % Filter counts
        rna_names_nonzero = rna_names(zero_counts_mask);  % Filter RNA names

        % Identify and save the filtered out RNAs (those with zero counts in all samples)
        rnas_filtered_out = rna_names(~zero_counts_mask);  % RNAs that were filtered out
        filteredRNAsTable = table(rnas_filtered_out, 'VariableNames', {sprintf('Non-expressed_%s', rnaType)});
        writetable(filteredRNAsTable, outputNotExpressedFile);  % Save filtered RNAs to file

        % Step 3: Filter out non-expressed RNAs from the counts
        data_filtered = array2table(counts_nonzero, 'VariableNames', data.Properties.VariableNames(2:end));
        data_filtered.(sprintf('%s_names', rnaType)) = rna_names_nonzero;  % Add RNA names as a new column
        data_filtered = movevars(data_filtered, sprintf('%s_names', rnaType), 'Before', 1);  % Move RNA names to the first column

        % Replace underscores with dashes in the variable names for output
        data_filtered.Properties.VariableNames = strrep(data_filtered.Properties.VariableNames, '_', '-');

        % Save the filtered counts to another Excel file
        writetable(data_filtered, outputFilteredFile, 'WriteRowNames', false);
    end
end
