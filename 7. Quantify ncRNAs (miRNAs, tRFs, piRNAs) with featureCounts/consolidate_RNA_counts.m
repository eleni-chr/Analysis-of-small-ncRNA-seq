function consolidate_RNA_counts
%% Function written by Dr Eleni Christoforidou in MATLAB R2024b.

% This function consolidates RNA count data from multiple folders, each containing 
% text files for a specific RNA type (miRNA, tRF, piRNA, other ncRNA). Each folder 
% should be located in the current directory and named as follows:
%   - "featureCounts output miRNA" for miRNA counts
%   - "featureCounts output tRF" for tRF counts
%   - "featureCounts output piRNA" for piRNA counts
%   - "featureCounts output other ncRNA" for other ncRNA counts
%
% Each text file within these folders contains RNA counts for a single sample, with
% RNA names in the first column and counts in the last column. The filename should
% include a sample ID in the format "P<number>-<number>", which the function uses to
% label each sample's data in the output file.
%
% The function will:
%   1. Read RNA count data from each .txt file in each specified folder.
%   2. Extract the sample ID from each filename.
%   3. Consolidate the RNA counts into a table with RNA names as rows and sample IDs as columns.
%   4. Replace any missing values (RNA not present in a sample) with zeros.
%   5. Save the consolidated data for each RNA type to a separate Excel file in the current directory.
%
% Output Files:
%   - miRNA_counts_all_samples.xlsx: Consolidated counts for miRNA
%   - tRF_counts_all_samples.xlsx: Consolidated counts for tRF
%   - piRNA_counts_all_samples.xlsx: Consolidated counts for piRNA
%   - other_ncRNA_counts_all_samples.xlsx: Consolidated counts for other ncRNAs
%
% Requirements:
%   - MATLAB must be able to access the RNA folders in the current directory.
%   - Each .txt file should be formatted with RNA names in the first column and counts
%     in the last column.

%%
    % Define folders and output Excel filenames
    rnaTypes = {'miRNA', 'tRF', 'piRNA', 'other ncRNA'};
    folders = {'featureCounts output miRNA', 'featureCounts output tRF', ...
               'featureCounts output piRNA', 'featureCounts output other ncRNA'};
    outputFiles = {'miRNA_counts_all_samples.xlsx', 'tRF_counts_all_samples.xlsx', ...
                   'piRNA_counts_all_samples.xlsx', 'other_ncRNA_counts_all_samples.xlsx'};

    % Regular expression to extract sample ID (e.g., "P123-4") from filename
    sampleID_pattern = 'P\d+-\d+';
    
    % Process each RNA type folder
    for f = 1:length(folders)
        folder = folders{f};
        outputFile = outputFiles{f};
        
        % Get list of .txt files in the current folder
        files = dir(fullfile(folder, '*.txt'));
        
        % Initialise an empty table for the consolidated counts
        consolidatedData = table();
        
        for i = 1:length(files)
            % Read each file within the folder
            filename = fullfile(folder, files(i).name);
            data = readtable(filename, 'FileType', 'text', 'ReadVariableNames', false);
            
            % Extract RNA names and counts
            RNA_names = data{:, 1};    % RNA names (miRNA, tRF, etc.)
            counts = data{:, end};     % Counts in the last column
            
            % Extract sample ID from the filename
            sampleID = regexp(files(i).name, sampleID_pattern, 'match', 'once');
            
            if isempty(sampleID)
                error('Sample ID not found in filename: %s', files(i).name);
            end
            
            % Create a temporary table for the current sample
            tempTable = table(RNA_names, counts, 'VariableNames', {'RNA', sampleID});
            
            % Merge with the consolidated data table
            if i == 1
                consolidatedData = tempTable;
            else
                consolidatedData = outerjoin(consolidatedData, tempTable, ...
                                             'Keys', 'RNA', 'MergeKeys', true);
            end
        end
        
        % Replace missing values with zeros for numeric columns only
        numericVars = consolidatedData.Properties.VariableNames;
        numericVars = numericVars(~strcmp(numericVars, 'RNA')); % Exclude the RNA name column
        consolidatedData = fillmissing(consolidatedData, 'constant', 0, 'DataVariables', numericVars);
        
        % Save the result to an Excel file
        writetable(consolidatedData, outputFile, 'Sheet', 1);
        fprintf('Consolidation complete for %s. Data saved to "%s".\n', folder, outputFile);
    end
end
