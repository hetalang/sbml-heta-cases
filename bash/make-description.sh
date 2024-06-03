#!/bin/bash

# $1 is version of SBML
base_dir="result/$1"

echo Create of file structure
mkdir -p $base_dir
rm -rf $base_dir/*

echo Collect compiler information
echo "{" > $base_dir/summary.json
hetaCompilerVersion=$(heta --version)
echo "  \"hetaCompilerVersion\": \"$hetaCompilerVersion\"," >> $base_dir/summary.json
started=$(date)
echo "  \"started\": \"$started\"," >> $base_dir/summary.json
dirs=$(find ./cases/semantic/ -type d -regex '.*/[0-9]+' -print0 | xargs -0 -n1 basename | sort ) # find all directories with numbers and sort by name
totalCasesCount=$(echo "$dirs" | wc -l)
echo "  \"totalCasesCount\": \"$totalCasesCount\"," >> $base_dir/summary.json

echo Copy files from cases and build models
echo "  \"cases\": [" >> $base_dir/summary.json

counter=0
for dir in $dirs; do
    counter=$((counter+1))
    if [ $counter == $totalCasesCount ]; then
        delimiter=""
    else
        delimiter=","
    fi
    
    mkdir -p $base_dir/$dir
    cp bash/$1-index.heta $base_dir/$dir/index.heta

    # Extract line starting from "synopsis" until the end of line
    synopsis=$(sed -n '/(\*/,/*)/p' cases/semantic/$dir/$dir-model.m | sed '1d;$d')
    echo "$synopsis" > $base_dir/$dir/synopsis.txt

    cp cases/semantic/$dir/$dir-sbml-$1.xml $base_dir/$dir/model-sbml-$1.xml > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "    {\"id\": \"$dir\", \"retCode\": 9}$delimiter" >> $base_dir/summary.json
        echo "$dir has no SBML file"
        continue
    fi

    # supress logs
    heta build --skip-updates --dist-dir . --log-mode error $base_dir/$dir > /dev/null 2>&1 
    retCode=$(echo $?)
    echo "    {\"id\": \"$dir\", \"retCode\": $retCode}$delimiter" >> $base_dir/summary.json
    echo "$dir finished with $retCode"
done

echo "  ]," >> $base_dir/summary.json
finished=$(date)
echo "  \"finished\": \"$finished\"" >> $base_dir/summary.json
echo "}" >> $base_dir/summary.json

# Save list of directories in JSON file
# sudo apt-get install jq
# echo "$dirs" | jq -R . | jq -s . > $base_dir/summary.json
