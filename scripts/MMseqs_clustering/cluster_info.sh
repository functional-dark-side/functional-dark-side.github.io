#!/bin/bash

set -x
set -e

SEQS=$(perl -ne 'print $_')

N=${FFINDEX_ENTRY_NAME}

NSEQS=$(grep -c '^>' <(echo "${SEQS}"))

~/opt/seqtk/seqtk comp <(echo "${SEQS}") | awk -v clu=${N} -v size=${NSEQS} '{print clu"\t"$1"\t"size"\t"$2}'
