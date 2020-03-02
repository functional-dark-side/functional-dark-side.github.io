#!/bin/bash

# MG=/bioinf/projects/megx/UNKNOWNS/2017_11/DATA/ORFs/ORFs_fasta/TARA_OSD_GOS_malaspina_hmpI-II.fasta.gz
# GTDB=/bioinf/projects/megx/UNKNOWNS/2017_11/GTDB/gtdb_ata/gtdb_orfs.fasta.gz
# DIR=/bioinf/projects/megx/UNKNOWNS/2017_11/GTDB

MG="${1}"
GTDB="${2}"
DIR="${3}"

# RELEASE=$(date +%Y%m%d)
cd "${DIR}"
mkdir -p mg_gtdb_db_update

zcat "${MG}" "${GTDB}" | gzip > mg_gtdb_orfs.fasta.gz

mmseqs createdb mg_gtdb_orfs.fasta.gz mg_gtdb_orfs_db
