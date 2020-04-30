#!/bin/bash
#$ -S /bin/bash
#$ -j y
#$ -pe mpi 20
#$ -cwd
#$ -R y
#$ -N hhblits_cl

export LD_LIBRARY_PATH="${HOME}"/opt/igraph-0.7.1_mg/lib:${LD_LIBRARY_PATH}


function cleanup() {
  rm -rf "${OUTDIR}"
}

#trap cleanup EXIT SIGHUP SIGINT SIGPIPE SIGTERM
CAT=k
OUTDIR=data/cluster_communities/community_inference_wd/data/"${CAT}"
mkdir -p "${OUTDIR}"
DB=data/cluster_categories/ffindex_files/"${CAT}"
MPIRUN=mpirun
FFINDEX_BIN=ffindex_apply_mpi
HHPARSE="${PWD}"/hhparse.sh
RES="${OUTDIR}"/"${CAT}"_hhblits.tsv

"${MPIRUN}" -np "${NSLOTS}" "${FFINDEX_BIN}" "${DB}"_hmm.ff{data,index} -i "${OUTDIR}"/"${CAT}"_all.ffindex -d "${OUTDIR}"/"${CAT}"_all.ffdata  -- "${HHPARSE}" "${DB}"

sed -e 's/\x0//g' "${OUTDIR}"/"${CAT}"_all.ffdata > "${RES}"

#rm "${OUTDIR}" -rf

#cleanup
