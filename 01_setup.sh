#!/bin/bash
## setup_01

## this script prepares the working directory and downloads the raw data we will use in this project

# make sure we are at the top of the git directory
REPOLOC="$(git rev-parse --show-toplevel)"
cd $REPOLOC

# if it doesn't exist, create the data director
mkdir -p data

# download and prepare the data

# mta turnstile data

# loop through and download
d=$(date +"%y%m%d" -d "last saturday")
for i in {7..28..7}
do
    curl -o ./data/mta_$d.csv http://web.mta.info/developers/data/nyct/turnstile/turnstile_$d.txt
    d=$(date +%y%m%d -d "$d - $i days")
done

# combine mta files into one file
count=0 # counter so we only get the column headers once
# loop through files
for wk in $(ls data | grep mta_)
do
    # if we haven't yet, add the headers
    if [ $count -eq 0 ]; then
        head -1 ./data/$wk > ./data/mta.csv
    fi
    # add everything but headers
    tail -n +2 ./data/$wk >> ./data/mta.csv
    count=$(($count + 1)) # increase the count
    # and remove the small csv
    rm ./data/$wk
done
