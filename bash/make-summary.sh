#!/bin/bash

base_dir="result/latest"

echo Create of file structure
mkdir -p $base_dir/cases
rm -rf $base_dir/cases/*

echo Collect compiler information
echo "{" > $base_dir/summary.json
hetaCompilerVersion=$(npx heta --version)
echo "  \"hetaCompilerVersion\": \"$hetaCompilerVersion\"," >> $base_dir/summary.json
started=$(date)
echo "  \"started\": \"$started\"," >> $base_dir/summary.json
dirs=$(find ./cases/semantic/ -type d -regex '.*/[0-9]+' -print0 | xargs -0 -n1 basename | sort | head -n 10000) # | head -n 100, find all directories with numbers and sort by name
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
    
    mkdir -p $base_dir/cases/$dir/l2v5
    mkdir -p $base_dir/cases/$dir/l3v2
    cp bash/l2v5-index.heta $base_dir/cases/$dir/l2v5/index.heta
    cp bash/l3v2-index.heta $base_dir/cases/$dir/l3v2/index.heta

    # Extract line starting from "synopsis" until the end of line
    synopsis=$(sed -n '/(\*/,/*)/p' cases/semantic/$dir/$dir-model.m | sed '1d;$d')
    echo "$synopsis" > $base_dir/cases/$dir/synopsis.txt

    cp cases/semantic/$dir/$dir-sbml-l2v5.xml $base_dir/cases/$dir/model-sbml-l2v5.xml > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "$dir has no SBML L2V5 file"
        l2v5RetCode=9
    else
        npx heta build --export HetaCode,JSON --skip-updates --dist-dir . --log-mode error $base_dir/cases/$dir/l2v5 > /dev/null 2>&1 
        l2v5RetCode=$(echo $?)
    fi
    cp cases/semantic/$dir/$dir-sbml-l3v2.xml $base_dir/cases/$dir/model-sbml-l3v2.xml > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "$dir has no SBML L3V2 file"
        l3v2RetCode=9
    else
        npx heta build --export HetaCode,JSON --skip-updates --dist-dir . --log-mode error $base_dir/cases/$dir/l3v2 > /dev/null 2>&1
        l3v2RetCode=$(echo $?)
    fi

    echo "    {\"id\": \"$dir\", \"l2v5RetCode\": $l2v5RetCode, \"l3v2RetCode\": $l3v2RetCode}$delimiter" >> $base_dir/summary.json
    echo "$dir finished with $l2v5RetCode, $l3v2RetCode"
done

echo "  ]," >> $base_dir/summary.json
finished=$(date)
echo "  \"finished\": \"$finished\"" >> $base_dir/summary.json
echo "}" >> $base_dir/summary.json

# Save list of directories in JSON file
# sudo apt-get install jq
# echo "$dirs" | jq -R . | jq -s . > $base_dir/summary.json
