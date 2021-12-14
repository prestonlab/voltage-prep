#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage:   voltage.sh subjno phase session run"
    echo "Example: voltage.sh 1 study 2 3"
    exit 1
fi

SITE=DS # Dell Seton
subjno=$1
subjid=$(printf 'DS%03d' "$subjno")
phase=$2
session=$3
run=$4

filebase=${phase}_${session}_${run}
config=data/$subjid/config_${filebase}.txt
output=data/$subjid/log_${filebase}.xml
if [ ! -e $config ]; then
    echo "Error: config file not found: $config"
    exit 1
fi
if [ -e config.txt ]; then
    echo "Error: there is an existing config.txt file. Please delete or move."
    exit 1
fi
if [ -e $output ]; then
    echo "Error: output file already exists: $output"
    exit 1
fi

# prep config
cp $config config.txt

log=data/$subjid/log.txt
echo "Starting phase $phase, session $session, run $run." >> $log
start=$(date +%s)

# run program and wait to finish
open -W Build.app

finish=$(date +%s)

if [ ! -e output.xml ]; then
    echo "Error: output.xml file not found. Please check output files."
    # remove temp copy of config file
    rm config.txt
    exit 1
fi

# move output to the subject's data directory with standard naming
mv output.xml data/$subjid/log_${filebase}.xml
mv soundoutput.xml data/$subjid/sync_${filebase}.xml
mv frames.xml data/$subjid/frame_${filebase}.xml
rm config.txt

printf "Run finished. Duration: %02d:%02d:%02d (%d s).\n" $(((finish-start)/3600)) $(((finish-start)%3600/60)) $(((finish-start)%60)) $((finish-start)) >> $log
