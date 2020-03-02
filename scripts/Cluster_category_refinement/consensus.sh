#!/bin/bash

#export HHLIB=$HOME/opt/hh-suite
#export PATH=$PATH:$HHLIB/bin:$HHLIB/scripts

hhconsensus -maxres 65535 -i stdin -s stdout -v 0 \
  | awk -v name="${FFINDEX_ENTRY_NAME}" 'NR==1{print ">"name; next}{print $0}'
