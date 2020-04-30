#!/bin/bash
FILE=$(perl -ne 'print $_')

python ${PWD}/scripts/Cluster_categories_refinement/hh_reader.py <(echo "$FILE") | awk '$2 >= 90' | awk -F"OS=" '{$0=$1}1'
