#!/bin/bash

echo Create of file structure
mkdir -p result
rm -rf result/*

echo Collect compiler information
echo "{" > result/summary.json
hetaCompilerVersion=$(heta --version)
echo "  \"hetaCompilerVersion\": \"$hetaCompilerVersion\"," >> result/summary.json
started=$(date)
echo "  \"started\": \"$started\"," >> result/summary.json
dirs=$(find ./cases/semantic/ -type d -regex '.*/[0-9]+' -print0 | xargs -0 -n1 basename ) # find all directories with numbers
#dirs=$(find ./cases/semantic/ -type f -name "*-sbml-l2v5.xml" -exec dirname {} \; | xargs -n1 basename )
totalCasesCount=$(echo "$dirs" | wc -l)
echo "  \"totalCasesCount\": \"$totalCasesCount\"," >> result/summary.json

echo Copy files from cases and build models
echo "  \"cases\": [" >> result/summary.json

counter=0
for dir in $dirs; do
    counter=$((counter+1))
    [ $counter==$totalCasesCount ] && delimiter="" || delimiter=","
    
    mkdir -p result/$dir
    cp bash/index.heta result/$dir/index.heta

    # Extract line starting from "synopsis" until the end of line
    synopsis=$(sed -n '/(\*/,/*)/p' cases/semantic/$dir/$dir-model.m | sed '1d;$d')
    echo "$synopsis" > result/$dir/synopsis.txt

    cp cases/semantic/$dir/$dir-sbml-l2v5.xml result/$dir/model-sbml-l2v5.xml > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "    {\"id\": \"$dir\", \"retCode\": 9}$delimiter" >> result/summary.json
        echo "$dir has no SBML file"
        continue
    fi

    # supress logs
    heta build --skip-updates --dist-dir . --log-mode error result/$dir > /dev/null 2>&1 
    retCode=$(echo $?)
    echo "    {\"id\": \"$dir\", \"retCode\": $retCode}$delimiter" >> result/summary.json
    echo "$dir finished with $retCode"
done

echo "  ]," >> result/summary.json
finished=$(date)
echo "  \"finished\": \"$finished\"" >> result/summary.json
echo "}" >> result/summary.json

# Save list of directories in JSON file
# sudo apt-get install jq
# echo "$dirs" | jq -R . | jq -s . > result/dirs.json
