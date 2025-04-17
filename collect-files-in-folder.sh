#!/bin/bash

# define source and destination directories
src_dir="cloned_repos"
dest_dir="all_test_criteria"

# create destination directory if not exist
mkdir -p "$dest_dir"

# check inclusion criteria size between 1KB and 50KB
check_size() {
    local file_size=$(stat -c %s "$1")
    [[ $file_size -ge 1000 && $file_size -le 50000 ]]
}

echo "process of making copies started"

# go for each repository directory
for repo in "$src_dir"/*; do
    if [[ -d "$repo" ]]; then
        repo_name=$(basename "$repo")

        # find all go files
        find "$repo" -type f -name '*.go' ! -name '*_test.go' -print0 | while IFS= read -r -d $'\0' go_file; do
            base_name=$(basename "${go_file%.go}")
            test_file="${go_file%/*}/${base_name}_test.go"
            
            # check if the corresponding test file exists
            if [[ -f "$test_file" ]]; then
                # check the size of both files
                if check_size "$go_file" && check_size "$test_file"; then
                    # add prefix with repo name and copy to the directory with results
                    dest_go="${dest_dir}/${repo_name}_$(basename "$go_file")"
                    dest_test="${dest_dir}/${repo_name}_$(basename "$test_file")"
                    cp "$go_file" "$dest_go"
                    cp "$test_file" "$dest_test"
                fi
            fi
        done

        echo "copied files from $repo_name"
    fi
done

echo "all files are copied"