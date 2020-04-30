#!/bin/bash
#SBATCH --nodes=9
#SBATCH --ntasks-per-node=1
#SBATCH --natsks=9
#SBATCH --partition=nomaster
#SBATCH --job-name=cl_update

set -x
set -e

#MMseqs2 Version: 13e0fe466bc0cb8a13bf493f23695b35ebc5632b-MPI
MMSEQS=~/opt/MMseqs2/bin/mmseqs
DIR=/vol/cloud/omrgc2
OUTDIR="${DIR}"/results
DATE=20200131
SDIR=/vol/scratch/omrgc2

export OMPI_MCA_btl=^openib
export OMP_NUM_THREADS=28
export OMP_PROC_BIND=FALSE

"${MMSEQS}" clusterupdate \
  "${DIR}"/mg_gtdb_db_20190502 \
  "${DIR}"/mg_g_omrgc2_orfs_db \
  "${DIR}"/mg_gtdb_db_20190502_clu \
  "${OUTDIR}"/mg_g_omrgc2_update/mg_g_omrgc2_db_"${DATE}" \
  "${OUTDIR}"/mg_g_omrgc2_update/mg_g_omrgc2_db_"${DATE}"_clu \
  "${OUTDIR}"/mg_g_omrgc2_update/tmp \
  --mpi-runner "srun --mpi=pmi2" \
  --local-tmp "${SDIR}"/tmp \
  --min-seq-id 0.3 -s 5 --cov-mode 0 -c 0.8
