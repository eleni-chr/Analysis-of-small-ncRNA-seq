#!/bin/bash

# Specify the full path to the cat_commands.txt file
commands_file="/mnt/PATH-TO/cat_commands.txt" # EDIT THIS LINE TO THE DESIRED PATH

# Check if the file containing the commands exists
if [ ! -f "$commands_file" ]; then
    echo "$commands_file file not found!"
    exit 1
fi

# Read each line in the file and execute the command
while IFS= read -r cmd; do
    if [ -n "$cmd" ]; then  # Check if the line is not empty
        echo "Executing: $cmd"
        eval "$cmd"
        echo "Done executing: $cmd"
    fi
done < "$commands_file"
