function filter_low_piRNAs
%% Function written by Dr Eleni Christoforidou in MATLAB R2024b.

% This MATLAB function performs additional filtering on piRNA count data 
% to remove lowly expressed piRNAs. It takes the filtered piRNA count file 
% (`piRNA_counts_filtered.xlsx`) as input and applies a threshold-based 
% filtering criterion. The function outputs two new files:
% 
% 1. `piRNA_counts_filtered_strict.xlsx`: Contains piRNAs that meet the 
%    filtering criteria (i.e., robustly expressed in a sufficient fraction 
%    of samples).
% 2. `Lowly_expressed_piRNAs.xlsx`: Lists piRNAs filtered out for having 
%    low or sporadic expression.
% 
% Why this additional filtering step is required:
% - After initial filtering, some piRNAs may still have very low or sporadic 
%   counts (e.g., expressed in only one or two samples). These lowly expressed 
%   piRNAs can cause issues during downstream analyses, such as DESeq2 
%   variance-stabilizing transformation (VST), which may produce nonsensical 
%   normalized counts (e.g., negative values). 
% - By applying this additional filtering step, we ensure that only piRNAs 
%   with robust and consistent expression across samples are retained, 
%   improving the reliability and interpretability of downstream analyses.
% 
% Filtering criteria:
% - A piRNA must have a count greater than a user-defined threshold (`min_count`)
%   in at least a certain fraction of samples (`min_samples_fraction`).
% - The default values are:
%   - `min_count = 10`: A piRNA must have counts >10 in a sample to be considered expressed.
%   - `min_samples_fraction = 0.1`: A piRNA must meet the `min_count` criterion 
%     in at least 10% of samples to be retained.
% 
% How to use:
% 1. Ensure the `piRNA_counts_filtered.xlsx` file is in the current MATLAB 
%    working directory.
% 2. Save this function as `filter_lowly_expressed_piRNAs.m` in the MATLAB path.
% 3. Run the function in MATLAB:
%       >> filter_lowly_expressed_piRNAs
% 4. After execution, the following output files will be created:
%    - `piRNA_counts_filtered_strict.xlsx`: Filtered piRNA counts.
%    - `Lowly_expressed_piRNAs.xlsx`: List of filtered-out piRNAs.
% 
% Parameters:
% - To customize the filtering thresholds, modify the `min_count` and 
%   `min_samples_fraction` variables in the function code.
% 
% Output summary:
% - The function prints the number of piRNAs retained and filtered out 
%   to the MATLAB command window for quick verification.

%%
    % Input and output file names
    inputFile = 'piRNA_counts_filtered.xlsx';
    outputFilteredFile = 'piRNA_counts_filtered_strict.xlsx';
    outputLowlyExpressedFile = 'Lowly_expressed_piRNAs.xlsx';

    % Parameters for filtering
    min_count = 10; % Minimum count threshold
    min_samples_fraction = 0.1; % Minimum fraction of samples required to exceed the threshold

    % Step 1: Read the counts from the input Excel file
    data = readtable(inputFile, 'VariableNamingRule', 'preserve');

    % Ensure the first column (RNA names) is treated as strings
    data.(1) = string(data.(1)); % Convert the first column to strings if necessary

    % Extract RNA names and counts
    rna_names = data{:, 1};        % First column: RNA names
    counts = data{:, 2:end};       % Remaining columns: counts
    num_samples = size(counts, 2); % Number of samples

    % Step 2: Filter piRNAs based on the minimum count threshold
    min_samples = ceil(min_samples_fraction * num_samples); % Minimum number of samples required
    high_counts_mask = sum(counts > min_count, 2) >= min_samples; % Logical mask for sufficient expression

    % Step 3: Create filtered and lowly-expressed tables
    % Filtered piRNAs (highly expressed)
    counts_filtered = counts(high_counts_mask, :); % Filter counts
    rna_names_filtered = rna_names(high_counts_mask); % Filter RNA names
    filteredTable = array2table(counts_filtered, 'VariableNames', data.Properties.VariableNames(2:end));
    filteredTable.piRNA_names = rna_names_filtered; % Add RNA names as a new column
    filteredTable = movevars(filteredTable, 'piRNA_names', 'Before', 1); % Move RNA names to the first column

    % Lowly expressed piRNAs (filtered out)
    lowly_expressed_rna_names = rna_names(~high_counts_mask); % RNA names of filtered-out piRNAs
    lowlyExpressedTable = table(lowly_expressed_rna_names, ...
        'VariableNames', {'Lowly_expressed_piRNAs'});

    % Step 4: Save the results to new Excel files
    writetable(filteredTable, outputFilteredFile, 'WriteRowNames', false);
    writetable(lowlyExpressedTable, outputLowlyExpressedFile, 'WriteRowNames', false);

    % Display summary of results
    fprintf('Filtering complete. Results:\n');
    fprintf(' - %d piRNAs retained in "%s".\n', height(filteredTable), outputFilteredFile);
    fprintf(' - %d lowly expressed piRNAs saved in "%s".\n', height(lowlyExpressedTable), outputLowlyExpressedFile);
end
