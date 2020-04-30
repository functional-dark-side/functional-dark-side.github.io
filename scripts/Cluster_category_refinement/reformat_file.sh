#!/bin/bash

SEQS=$(perl -ne 'print $_')
TMP=$(mktemp -q)
LIB=~/opt/hh-suite

${LIB}/scripts/reformat.pl -v 0 -M 50 fas a3m <(echo "${SEQS}") ${TMP}

cat ${TMP}

rm ${TMP}
