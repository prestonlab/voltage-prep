#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage:   push_data.sh subject [rsync options]"
    echo "Example: push_data DS004 --dry-run"
    echo
    echo "Data will be synced with monolith."
    echo
    exit 1
fi

subject=$1
shift

src=$HOME/experiments/voltage/exp/data/$subject/
dest=monolith:data/ecog/$subject/behav/voltage

ssh monolith mkdir -p data/ecog/$subject/behav/voltage

rsync -azvu $src $dest --include="*.txt" --include="*.mat" --include="*.xml" --include="*/" --exclude "*" --prune-empty-dirs "$@"
