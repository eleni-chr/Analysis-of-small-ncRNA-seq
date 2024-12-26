function extract_bowtie_alignment_stats
%% Function written by Dr Eleni Christoforidou in MATLAB R2024b.
%
% This function processes Bowtie alignment log files for miRNAs, tRFs,
% piRNAs, and other ncRNAs. It extracts alignment statistics from the log 
% files located in four specified folders:
% - 'Bowtie miRNA alignment output'
% - 'Bowtie tRF alignment output'
% - 'Bowtie piRNA alignment output'
% - 'Bowtie other ncRNA alignment output'
% 
% For each sample, identified by the sample ID in the filename (format: "P" followed by one or more digits, 
% a dash, and one digit), the function extracts the following information:
% 1. Total reads processed
% 2. Reads aligned to miRNAs
% 3. Reads aligned to tRFs
% 4. Reads aligned to piRNAs
% 5. Reads aligned to "other ncRNAs"
% 6. Unmapped reads (from the "other ncRNAs" alignment log)
%
% The function then calculates the following percentages for each sample:
% - %Aligned to miRNAs (Aligned to miRNAs / Total reads processed * 100)
% - %Aligned to tRFs (Aligned to tRFs / Total reads processed * 100)
% - %Aligned to piRNAs (Aligned to piRNAs / Total reads processed * 100)
% - %Aligned to other ncRNAs (Aligned to other ncRNAs / Total reads processed * 100)
% - %Unmapped (Unmapped reads / Total reads processed * 100)
% - %All mapped (100 - %Unmapped)
%
% Finally, the function saves the extracted information and calculated percentages into an Excel file 
% called 'Bowtie_alignment_stats.xlsx' in the current directory, with appropriate column headers.
%
% Usage:
% 1. Ensure that there are three folders in the current directory:
%    - 'Bowtie miRNA alignment output': Contains the miRNA alignment log files.
%    - 'Bowtie tRF alignment output': Contains the tRF alignment log files.
%    - 'Bowtie piRNA alignment output': Contains the piRNA alignment log files.
%    - 'Bowtie other ncRNA alignment output': Contains the other ncRNA alignment log files.
% 2. Each log file should contain lines formatted like:
%    "# reads processed: 3757947"
%    "# reads with at least one alignment: 396774 (10.56%)"
%    "# reads that failed to align: 3361173 (89.44%)"
% 3. Call the function by typing `extract_bowtie_alignment_stats` in the MATLAB command window.
% 4. The output file 'Bowtie_alignment_stats.xlsx' will be created in the current directory.
%
% Notes:
% - The sample ID is extracted from the log filenames based on the format: "P" followed by one or more digits,
%   a dash, and one digit (e.g., P1-1, P23-2).
% - Ensure that all files are named according to this convention and are correctly placed in the respective folders.
% - This function assumes all samples have matching log files across the three folders.
%
% Example:
% If the filename is 'P1-1_miRNA_bowtie.log', the sample ID will be 'P1-1'.

%%
    % Define folder paths
    miRNA_folder = 'Bowtie miRNA alignment output';
    tRF_folder = 'Bowtie tRF alignment output';
    piRNA_folder = 'Bowtie piRNA alignment output';
    other_ncRNA_folder = 'Bowtie other ncRNA alignment output';

    % Get a list of log files in each folder
    miRNA_files = dir(fullfile(miRNA_folder, '*.log'));
    tRF_files = dir(fullfile(tRF_folder, '*.log'));
    piRNA_files = dir(fullfile(piRNA_folder, '*.log'));
    other_ncRNA_files = dir(fullfile(other_ncRNA_folder, '*.log'));

    % Initialise data storage
    data = {};
    headers = {'Sample ID', 'Total reads processed', 'Aligned to miRNAs', 'Aligned to tRFs', 'Aligned to piRNAs', 'Aligned to other ncRNAs', 'Unmapped reads', ...
               '%Aligned to miRNAs', '%Aligned to tRFs', '%Aligned to piRNAs', '%Aligned to other ncRNAs', '%Unmapped', '%All mapped'};
    
    % Process miRNA alignment logs
    for i = 1:length(miRNA_files)
        % Get the sample ID from filename
        [~, filename, ~] = fileparts(miRNA_files(i).name);
        sampleID = extract_sample_id(filename);
        
        % Extract information from miRNA log file
        miRNA_log = fullfile(miRNA_folder, miRNA_files(i).name);
        [readsProcessed, alignedMiRNA] = extract_log_info(miRNA_log);
        
        % Store data in a row format
        data{i, 1} = sampleID;
        data{i, 2} = readsProcessed;
        data{i, 3} = alignedMiRNA;
    end
    
    % Process tRF alignment logs
    for i = 1:length(tRF_files)
        % Get the sample ID from filename
        [~, filename, ~] = fileparts(tRF_files(i).name);
        sampleID = extract_sample_id(filename);
        
        % Extract information from tRF log file
        tRF_log = fullfile(tRF_folder, tRF_files(i).name);
        [~, alignedtRF] = extract_log_info(tRF_log);
        
        % Find the row that corresponds to this sample and add tRF alignment data
        rowIndex = find(strcmp(data(:, 1), sampleID));
        if ~isempty(rowIndex)
            % Assign the value to the appropriate column
            data{rowIndex, 4} = alignedtRF;
        end
    end
    
    % Process piRNA alignment logs
    for i = 1:length(piRNA_files)
        % Get the sample ID from filename
        [~, filename, ~] = fileparts(piRNA_files(i).name);
        sampleID = extract_sample_id(filename);
        
        % Extract information from piRNA log file
        piRNA_log = fullfile(piRNA_folder, piRNA_files(i).name);
        [~, alignedpiRNA] = extract_log_info(piRNA_log);
        
        % Find the row that corresponds to this sample and add piRNA alignment and unmapped reads data
        rowIndex = find(strcmp(data(:, 1), sampleID));
        if ~isempty(rowIndex)
            % Assign the values to the appropriate columns
            data{rowIndex, 5} = alignedpiRNA;
        end
    end

        % Process other ncRNA alignment logs
    for i = 1:length(other_ncRNA_files)
        % Get the sample ID from filename
        [~, filename, ~] = fileparts(other_ncRNA_files(i).name);
        sampleID = extract_sample_id(filename);
        
        % Extract information from piRNA log file
        other_ncRNA_log = fullfile(other_ncRNA_folder, other_ncRNA_files(i).name);
        [~, aligned_other_ncRNA, unmappedReads] = extract_log_info(other_ncRNA_log);
        
        % Find the row that corresponds to this sample and add other ncRNA alignment and unmapped reads data
        rowIndex = find(strcmp(data(:, 1), sampleID));
        if ~isempty(rowIndex)
            % Assign the values to the appropriate columns
            data{rowIndex, 6} = aligned_other_ncRNA;
            data{rowIndex, 7} = unmappedReads;
        end
    end
    
    % Calculate percentages for each sample
    for i = 1:size(data, 1)
        totalReads = data{i, 2};
        if isnan(totalReads) || totalReads == 0
            % Avoid division by zero or invalid totalReads
            data{i, 8} = NaN;
            data{i, 9} = NaN;
            data{i, 10} = NaN;
            data{i, 11} = NaN;
            data{i, 12} = NaN;
            data{i, 13} = NaN;
        else
            % Calculate percentages
            data{i, 8} = (data{i, 3} / totalReads) * 100; % %Aligned to miRNAs
            data{i, 9} = (data{i, 4} / totalReads) * 100; % %Aligned to tRFs
            data{i, 10} = (data{i, 5} / totalReads) * 100; % %Aligned to piRNAs
            data{i, 11} = (data{i, 6} / totalReads) * 100; % %Aligned to other ncRNAs
            data{i, 12} = (data{i, 7} / totalReads) * 100; % %Unmapped
            data{i, 13} = 100 - data{i, 12}; % %All mapped
        end
    end
    
    % Write the data to an Excel file
    outputFile = 'Bowtie_alignment_stats.xlsx';
    outputData = [headers; data];
    writecell(outputData, outputFile);
    fprintf('Data written to %s\n', outputFile);
end

% Helper function to extract sample ID from the filename
function sampleID = extract_sample_id(filename)
    % Use a regular expression to extract the sample ID
    % Format: "P" followed by one or more digits, a dash, and one digit
    expr = 'P\d+-\d';
    sampleID = regexp(filename, expr, 'match', 'once');
    
    if isempty(sampleID)
        error('Sample ID not found in filename: %s', filename);
    end
end

% Helper function to extract numerical values from log file
function [readsProcessed, alignedReads, unmappedReads] = extract_log_info(logFile)
    % Initialise values as NaN (in case values are not found)
    readsProcessed = NaN;
    alignedReads = NaN;
    unmappedReads = NaN;
    
    % Open and read the file
    fid = fopen(logFile, 'r');
    if fid == -1
        error('Could not open file: %s', logFile);
    end
    
    % Read through the file line by line
    while ~feof(fid)
        line = fgetl(fid);
        
        % Extract "reads processed"
        if contains(line, 'reads processed')
            readsProcessed = sscanf(line, '# reads processed: %d');
        end
        
        % Extract "reads with at least one alignment"
        if contains(line, 'reads with at least one alignment')
            alignedReads = sscanf(line, '# reads with at least one alignment: %d');
        end
        
        % Extract "reads that failed to align"
        if contains(line, 'reads that failed to align')
            unmappedReads = sscanf(line, '# reads that failed to align: %d');
        end
    end
    
    fclose(fid);
end
