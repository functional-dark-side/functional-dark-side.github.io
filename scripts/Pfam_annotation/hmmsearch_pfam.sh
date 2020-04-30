#!/bin/bash

#Usage:
# ${PWD}/scripts/Pfam_annotation/hmmsearch_pfam.sh \
  #  data/gene_prediction/TARA_OSD_GOS_malaspina_hmpI-II.fasta.gz \
  #  data/pfam_annotation/marine_hmp_pfam31_results.tsv

INPUT=${PWD}/${1}
OUTPUT=${PWD}/${2}\
  NP=${3}
PFAM=data/DBs/Pfam31
OUTDIR=$(dirname "${OUTPUT}")
MPIRUN=mpirun
HMMER=${PWD}/hmmer-3.1b2/bin/hmmsearch

if [[ -d "${OUTDIR}" ]]; then
  cd "${OUTDIR}"
else
  mkdir -p "${OUTDIR}"
  cd "${OUTDIR}"
fi

NSEQS=$(grep -c '^>' "${INPUT}")
N=$((NSEQS * 16712))

"${MPIRUN}" -np 32 "${HMMER}" --mpi --cut_ga -Z "${N}" --domtblout "${OUTDIR}"/HMMPfam.out -o "${OUTDIR}"/HMMPfam.log "${PFAM}"/Pfam-A.hmm "${INPUT}"

#Collect the results
grep -v '^#' "${OUTDIR}"/HMMPfam.out > "${OUTPUT}"
