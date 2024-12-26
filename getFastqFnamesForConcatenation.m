function getFastqFnamesForConcatenation(main_folder)
%% Function written by Dr Eleni Christoforidou in MATLAB R2024a.

% This function scans through a specified main folder and its subfolders to
% collect information about FASTQ files. It identifies files corresponding
% to patient codes and organises this information into an Excel file and a
% text file. The text file contains a list of cat commands (for file
% concatenation in Linux/Ubuntu). It assumes the user wants to concatenate
% 3 files that have the same patient ID in the filename (but the filenames
% can contain other non-identical information, too) that are currently 
% stored in separate folders. The Excel file contains further information 
% to manually check if the cat commands were constructed with the correct 
% files. All information is taken from the filenames only.

% Patient codes are in the filename in the format P<number>-<number>

% INPUT:
%   - main_folder: Full path to the main folder containing subfolders with
%     FASTQ files. E.g., main_folder = "C:\Fastq files"

% OUTPUTS:
%   - An Excel file with columns for patient codes, file paths of FASTQ files,
%     concatenated filenames, and `cat` commands.
%   - A text file containing the `cat` commands to concatenate the FASTQ files later in Linux/Ubuntu.

%%
    % Initialise a cell array to store the data
    data = {}; % To store patient codes and file paths
    
    % Get a list of all subfolders in the main folder
    subfolders = dir(main_folder);
    subfolders = subfolders([subfolders.isdir]); % Keep only directories
    subfolders = subfolders(~ismember({subfolders.name}, {'.', '..'})); % Remove . and .. directories
    
    % Loop over each subfolder
    for i = 1:length(subfolders)
        subfolder_path = fullfile(main_folder, subfolders(i).name);
        
        % Get a list of all .fastq.gz files in the subfolder
        fastq_files = dir(fullfile(subfolder_path, '*.fastq.gz'));
        
        % Loop over each file and extract the patient code
        for j = 1:length(fastq_files)
            filename = fastq_files(j).name;
            filepath = fullfile(subfolder_path, filename);
            
            % Extract patient code that matches the pattern 'P<number>-<number>'
            tokens = regexp(filename, '(P\d+-\d+)', 'tokens');
            if ~isempty(tokens)
                patient_code = tokens{1}{1};
                
                % Initialise `idx` to empty
                idx = [];
                
                % Check if `data` is not empty and has at least one column
                if ~isempty(data) && size(data, 2) >= 1
                    % Find the index in the data cell array corresponding to this patient code
                    idx = find(strcmp(data(:,1), patient_code), 1);
                end
                
                % If patient code is not yet in the data cell array, add it
                if isempty(idx)
                    new_entry = {patient_code, '', '', '', '', ''}; % Initialise row with empty columns
                    new_entry{2} = filepath; % Set the file path in the first column
                    data = [data; new_entry];
                    idx = size(data, 1); % Update index for the newly added row
                else
                    % Add the file path to the appropriate column
                    if isempty(data{idx, 2})
                        data{idx, 2} = filepath; % Column B: first file path
                    elseif isempty(data{idx, 3})
                        data{idx, 3} = filepath; % Column C: second file path
                    elseif isempty(data{idx, 4})
                        data{idx, 4} = filepath; % Column D: third file path
                    end
                end
            end
        end
    end
    
    % Add the concatenated filename and cat command to Column E and F
    for k = 1:size(data, 1)
        if ~isempty(data{k, 1}) % Ensure patient code is not empty
            % Construct the full path for the concatenated file
            concatenated_path = fullfile(main_folder, 'Concatenated_fastq_files', strcat(data{k, 1}, '_concatenated_runs.fastq.gz'));
            data{k, 5} = concatenated_path; % Column E: full path to concatenated filename
            
            % Convert Windows-style paths to Unix-style paths
            paths = {data{k, 2}, data{k, 3}, data{k, 4}, concatenated_path};
            paths = cellfun(@(p) strrep(p, '\', '/'), paths, 'UniformOutput', false); % Replace backslashes with slashes
            paths = cellfun(@(p) strrep(p, 'C:', 'c'), paths, 'UniformOutput', false); % Replace C: with c
            paths = cellfun(@(p) strcat('/mnt/', p), paths, 'UniformOutput', false); % Prefix with /mnt/
           
            % Enclose paths in double quotes
            paths = cellfun(@(p) strcat('"', p, '"'), paths, 'UniformOutput', false);

            % Construct the cat command
            cat_command = sprintf('cat %s %s %s > %s', ...
                paths{1}, ...
                paths{2}, ...
                paths{3}, ...
                paths{4});
            data{k, 6} = cat_command; % Column F: cat command
        end
    end
    
 % Convert cell array to table and write to Excel file
    headers = {'Patient Code', 'File 1', 'File 2', 'File 3', 'Concatenated Filename', 'Cat Command'};
    try
        % Ensure the output path is a string
        if ischar("for_cat_commands.xlsx") || isstring("for_cat_commands.xlsx")
            output_table = cell2table(data, 'VariableNames', headers);
            writetable(output_table, "for_cat_commands.xlsx");
            disp(['Data has been written to ', "for_cat_commands.xlsx"]);
        else
            error('Output Excel file path must be a string or character vector.');
        end
    catch ME
        disp('Error occurred while creating or writing the table:');
        disp(ME.message);
    end
    
    % Write cat commands to text file
    try
        % Ensure the output path is a string
        if ischar("cat_commands.txt") || isstring("cat_commands.txt")
            fid = fopen("cat_commands.txt", 'w');
            if fid == -1
                error('Cannot open file for writing: %s', "cat_commands.txt");
            end
            for k = 1:size(data, 1)
                if ~isempty(data{k, 6}) % Ensure cat command is not empty
                    fprintf(fid, '%s\n', data{k, 6});
                end
            end
            fclose(fid);
            disp(['Cat commands have been written to ', "cat_commands.txt"]);
        else
            error('Output text file path must be a string or character vector.');
        end
    catch ME
        disp('Error occurred while creating or writing the text file:');
        disp(ME.message);
    end
end