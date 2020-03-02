#!/bin/bash
#$ -S /bin/bash
#$ -j y
#$ -pe mpi 20
#$ -cwd
#$ -R y
#$ -N hhblits_cl

### SET-UP environment

OPENMPI_HOME=/bioinf/software/openmpi/openmpi-1.8
export PATH=${OPENMPI_HOME}/bin:${PATH}
export LD_LIBRARY_PATH=${OPENMPI_HOME}/lib:${LD_LIBRARY_PATH:-}

GCC_HOME=/bioinf/software/gcc/gcc-4.9
export PATH=${GCC_HOME}/bin:$PATH
export LD_LIBRARY_PATH=${GCC_HOME}/lib64:${LD_LIBRARY_PATH}

HHLIB=/home/cvanni/opt/hhsuite_mg_mpi
export PATH=${HHLIB}/bin:${HHLIB}/scripts:${PATH}

export LD_LIBRARY_PATH="${HOME}"/opt/igraph-0.7.1_mg/lib:${LD_LIBRARY_PATH}


function cleanup() {
  rm -rf "${OUTDIR}"
}

#trap cleanup EXIT SIGHUP SIGINT SIGPIPE SIGTERM
CAT=k
OUTDIR=/bioinf/projects/megx/UNKNOWNS/chiara/unkn_hhblits/"${CAT}"
mkdir -p "${OUTDIR}"
DB=/bioinf/projects/megx/UNKNOWNS/2017_11/cl_categories/ffindex_files/"${CAT}"
MPIRUN=/bioinf/software/openmpi/openmpi-1.8.1/bin/mpirun
FFINDEX_BIN=/home/cvanni/opt/ffindex_mg_updt/bin/ffindex_apply_mpi
HHPARSE="${PWD}"/hhparse.sh
RES="${OUTDIR}"/"${CAT}"_hhblits.tsv

"${MPIRUN}" -np "${NSLOTS}" "${FFINDEX_BIN}" "${DB}"_hmm.ff{data,index} -i "${OUTDIR}"/"${CAT}"_all.ffindex -d "${OUTDIR}"/"${CAT}"_all.ffdata  -- "${HHPARSE}" "${DB}"

sed -e 's/\x0//g' "${OUTDIR}"/"${CAT}"_all.ffdata > "${RES}"

#rm "${OUTDIR}" -rf

#cleanup
