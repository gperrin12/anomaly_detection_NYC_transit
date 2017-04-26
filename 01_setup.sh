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

# check bash version (bash v3 handles dates different than bash v4)
if [ ${BASH_VERSION::1} -eq 3 ]; then
    d=$(date -j -f %y%m%d 161231 +%y%m%d)
    for i in $(seq 7 7 28)
    do
        curl -o ./data/mta_$d.csv http://web.mta.info/developers/data/nyct/turnstile/turnstile_$d.txt
        d=$(date -j -f %y%m%d -v -$i'd' 161231 +%y%m%d)
        #echo $d
    done
fi

if [ ${BASH_VERSION::1} -eq 4 ]; then
    d=$(date +%y%m%d -d 160102)
    for i in {0..105..7}
    do
        d1=$(date +%y%m%d -d "$d + $i days")
        curl -o ./data/mta_$d1.csv http://web.mta.info/developers/data/nyct/turnstile/turnstile_$d1.txt
    done
fi

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

# next query TLC data for 2016 january to march
# loop through and download                                                                               
for num in $(seq -w 01 03)
do
    echo $num
    curl -o ./data/tlc_yellow_2016_$num.csv https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2016\
-$num.csv
done


# Also grab the 2016 Citi Bike Data
for m in $(seq -w 1 12)
do
    curl -o 'data/citibike_2016'$m'.zip' https://s3.amazonaws.com/tripdata/2016$m-citibike-tripdata.zip
    unzip -o data/citibike_2016$m.zip -d data/
    mv 'data/2016'$m'-citibike-tripdata.csv' data/citibike_2016$m.csv
    rm 'data/citibike_2016'$m'.zip'
done

# combine
count=0 # counter so we only get the column headers once
# loop through files
for mo in $(ls data | grep citibike_)
do
    # if we haven't yet, add the headers
    if [ $count -eq 0 ]; then
        head -1 ./data/$mo > ./data/citibike_2016.csv
    fi
    # add everything but headers
    tail -n +2 ./data/$mo >> ./data/citibike_2016.csv
    count=$(($count + 1)) # increase the count
    # and remove the small csv
    rm ./data/$mo
done
