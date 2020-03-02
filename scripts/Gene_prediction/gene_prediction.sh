#!/bin/bash

set -x
set -e

# Usage:
# ./gene_prediciton.sh contif.fasta orfs.fasta orfs.txt meta

CONTIGS=${PWD}/"${1}"
ORFS=${PWD}/"${2}"
TXT=${PWD}/"${3}"
SMPL=$(basename "${TXT}" _orfs.txt)
DIR=$(dirname "${TXT}")
PRODIGAL=prodigal
MODE="${4}"

"${PRODIGAL}" -i "${CONTIGS}" -a "${ORFS}" -m -p "${MODE}" -f gff  -o "${DIR}"/"${SMPL}"_info.gff -q

awk -f ${PWD}/scripts/rename_orfs.awk "${ORFS}" > "${DIR}"/"${SMPL}"_tmpl && mv "${DIR}"/"${SMPL}"_tmpl "${ORFS}"

grep '^>' "${ORFS}" | sed 's/^>//' > "${TXT}"

awk '$1!~/^#/{split($9,a,"_");split(a[2],b,";");split(b[2],c,"="); print $1"_"$7"_"$4"_"$5"_""orf-"b[1]"\t""\""c[2]"\""}' "${DIR}"/"${SMPL}"_info.gff | gzip > "${DIR}"/"${SMPL}"_partial_info.tsv.gz
