#!/bin/bash

# specify input and output directries
# all files in-place remain unchanged
code_dir="all_test_criteria"
dest_dir="preprocessed_files"

# create destination directory if not exist
mkdir -p "$dest_dir"

# create log directory if not exist
mkdir -p "preprocessed_files/logs"
log_file="preprocessed_files/logs/preprocess.log"

# log start
echo "start processing at $(date)" | tee "$log_file"

# for each file
for go_file in "$code_dir"/*.go; do
    # check for the corresponding test file
    test_file="${go_file%.go}_test.go"

    for file in "$go_file" "$test_file"; do
        if [[ -f "$file" ]]; then
            # copy file to destination directory
            dest_file="$dest_dir/$(basename "$file")"
            cp "$file" "$dest_file"

            # skip to the next file if error and log
            if [ $? -ne 0 ]; then
                echo "failed to copy $file to $dest_file" | tee -a "$log_file"
                continue
            fi

            echo "processing $dest_file" | tee -a "$log_file"
            
            # remove single-line comments if when they are not part of a string
            sed -i '/^[[:space:]]*\/\//d' "$dest_file" || echo "failed to remove single-line comments from $dest_file" | tee -a "$log_file"

            # remove block comments
            sed -i '/^[[:space:]]*\/\*/,/\*\//d' "$dest_file" || echo "failed to remove block comments from $dest_file" | tee -a "$log_file"

            # format the file with gofmt
            gofmt -s -w "$dest_file"
            gofmt_exit_status=$?
            if [ $gofmt_exit_status -ne 0 ]; then
                echo "failed to format $dest_file using gofmt with error status $gofmt_exit_status" | tee -a "$log_file"
                continue
            fi

            echo "finished processing $dest_file" | tee -a "$log_file"
        else
            echo "file does not exist - $file" | tee -a "$log_file"
        fi
    done
done

echo "all files processed" | tee -a "$log_file"
echo "ended processing at $(date)" | tee -a "$log_file"