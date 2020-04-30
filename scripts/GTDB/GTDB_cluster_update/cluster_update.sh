#!/bin/bash
#$ -S /bin/bash
#$ -j y
#$ -pe mpi 280
#$ -cwd
#$ -R y
#$ -N cl_updt

set -x
set -e

MMSEQS=~/opt/MMseqs2/bin/mmseqs
DIR=data/GTDB
CDIR=data/mmseqs_clustering/marine_hmp_db

export OMPI_MCA_btl=^openib
export OMP_NUM_THREADS=28

#MMseqs2 version mmseqs2-8.fac81-hf3e9acd_1

RUNNER="mpirun --mca btl_tcp_if_include ens3 -n 10 --map-by ppr:1:node --bind-to none " \
  "${MMSEQS}" clusterupdate "${CDIR}"/marine_hmp_db_03112017 \
  "${DIR}"/mg_gtdb_orfs_db \
  "${CDIR}"/marine_hmp_db_03112017_clu \
  "${DIR}"/mg_gtdb_update/mg_gtdb_db_052019 \
  "${DIR}"/mg_gtdb_update/mg_gtdb_052019_clu \
  "${DIR}"/mg_gtdb_update/tmp \
  —local-tmp /scratch/gtdb/ \
  --min-seq-id 0.3 \
  -s 5 \
  --cov-mode 0 \
  -c 0.8
