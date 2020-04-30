#!/bin/bash

# MG=data/gene_prediction/TARA_OSD_GOS_malaspina_hmpI-II.fasta.gz
# GTDB=data/GTDB/gtdb_data/gtdb_orfs.fasta.gz
# DIR=data/GTDB

MG="${1}"
GTDB="${2}"
DIR="${3}"

# RELEASE=$(date +%Y%m%d)
cd "${DIR}"
mkdir -p mg_gtdb_db_update

zcat "${MG}" "${GTDB}" | gzip > mg_gtdb_orfs.fasta.gz

mmseqs createdb mg_gtdb_orfs.fasta.gz mg_gtdb_orfs_db
