#!/bin/bash

# Create ffindex file for each good not-annotated cluster
set -e

SMPL="${1}"
DIRCL="${PWD}"/"${SMPL}"/clustering
#Create cluster DB/subDB
#Ex: not-annotated "good" cluster ids
CIDS="${2}"
DIRVAL=$(dirname "${CIDS}")
mkdir -p "${DIRVAL}"/ffindex_files

~/MMseqs2/bin/mmseqs createsubdb "${CIDS}" "${DIRCL}"/"${SMPL}"_clu_fa "${DIRVAL}"/ffindex_files/"${SMPL}"_kept_noannot_cl_fa

# Create alignments and retrieve the consensus sequences
FF="${DIRVAL}"/ffindex_files

ffindex_apply "${FF}"/"${SMPL}"_kept_noannot_cl_fa "${FF}"/"${SMPL}"_kept_noannot_cl_fa.index \
  -i "${FF}"/"${SMPL}"_kept_noannot_cl_aln.ffindex -d "${FF}"/"${SMPL}"_kept_noannot_cl_aln.ffdata \
  -- famsa STDIN STDOUT 2> /dev/null

ffindex_apply "${FF}"/"${SMPL}"_kept_noannot_cl_aln.ff{data,index} \
  -i "${FF}"/"${SMPL}"_kept_noannot_cl_cons.ffindex -d "${FF}"/"${SMPL}"_kept_noannot_cl_cons.ffdata \
  -- "${PWD}"/scripts/consensus.sh

# Extract the consensus sequences as fasta
CONS=${3}
$mysed -e 's/\x0//' "${FF}"/"${SMPL}"_kept_noannot_cl_cons.ffdata > ${CONS}
