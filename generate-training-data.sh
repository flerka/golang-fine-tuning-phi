#!/bin/bash

directory="preprocessed_files/"

# сreate a CSV header
echo "name,code,test_code" > dataset.csv

# go over .go files in the directory
for file in "${directory}"*.go; do
    # skip test files
    if [[ $file != *_test.go ]]; then
        name=$(basename "${file%.go}")
        test_file="${directory}${name}_test.go"

        # check if the test file exists
        if [ -f "$test_file" ]; then
            code=$(<"$file")
            test_code=$(<"$test_file")

            # escape double quotes and newlines for CSV
            code=$(echo "$code" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' -e 's/"/""/g')
            test_code=$(echo "$test_code" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' -e 's/"/""/g')

            # append to CSV
            echo "\"$name\",\"$code\",\"$test_code\"" >> dataset.csv
        else
            echo "skipping $file without test file."
        fi
    fi
done