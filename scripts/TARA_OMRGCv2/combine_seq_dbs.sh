#!/bin/bash

# MG_GTDB=/bioinf/projects/megx/UNKNOWNS/2017_11/MG_GTDB_DB/mg_gtdb_orfs.fasta.gz
# OMRGC2=/bioinf/projects/megx/UNKNOWNS/2017_11/chiara/OM-RGC-v2/OM-RGC_v2.aa.OG.fasta.gz
# DIR=/bioinf/projects/megx/UNKNOWNS/2017_11/GTDB

MG_GTDB="${1}"
OMRGC2="${2}"
DIR="${3}"

# RELEASE=$(date +%Y%m%d)
cd "${DIR}"
mkdir -p mg_g_omrgc_db_update

zcat "${MG_GTDB}" "${OMRGC2}" | gzip > mg_g_omrgc2_orfs.fasta.gz

mmseqs createdb mg_g_omrgc2_orfs.fasta.gz mg_g_omrgc2_orfs_db
