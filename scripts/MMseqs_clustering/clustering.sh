#!/bin/bash

INPUT="${1}" #/bioinf/projects/megx/UNKNOWNS/2017_11/DATA/ORFs/ORFs_fasta/TARA_OSD_GOS_malaspina_hmpI-II.fasta.gz
NAME=$(basename "${INPUT}" .fasta)
RELEASE=$(date +%Y%m%d)
OUTPUT="${2}" #/bioinf/projects/megx/UNKNOWNS/2017_11/clustering/unkdb_update_hmp/marine_hmp_db
NSLOTS="${3}"
MMSEQS=~/MMseqs2/bin/mmseqs
# create the seqDB for mmeseqs (for the cascade clustering)
"${MMSEQS}" createdb "${INPUT}" clustering/"${NAME}"_db

mkdir -p clustering/tmp1

# run the cascade clustering
"${MMSEQS}" cluster "${NAME}"_db "${OUTPUT}"_"${RELEASE}"_clu tmp1 --threads "${NSLOTS}" -c 0.8 --cov-mode 0 --min-seq-id 0.3 -s 5

#${PWD}/scripts/clustering_res.sh "${INPUT}" "${OUTPUT}"_"${RELEASE}"_clu
