#!/bin/bash

#Usage:
# ${PWD}/scripts/A_annotation/hmmsearch_pfam.sh \
#  /bioinf/projects/megx/UNKNOWNS/2017_11/DATA/ORFs/ORFs_fasta/TARA_OSD_GOS_malaspina_hmpI-II.fasta.gz \
#  /bioinf/projects/megx/UNKNOWNS/2017_11/Pfam_annotation/results/marine_hmp_pfam31_results.tsv

INPUT=${PWD}/${1}
OUTPUT=${PWD}/${2}\
NP=${3}
PFAM=/bioinf/projects/megx/UNKNOWNS/2017_11/Pfam_annotation/Pfam31
OUTDIR=$(dirname "${OUTPUT}")

if [[ -d "${OUTDIR}" ]]; then
  cd "${OUTDIR}"
else
  mkdir -p "${OUTDIR}"
  cd "${OUTDIR}"
fi

NSEQS=$(grep -c '^>' "${INPUT}")
N=$((NSEQS * 16712))

/bioinf/software/openmpi/openmpi-1.8.1/bin/mpirun -np 32 /bioinf/software/hmmer/hmmer-3.1b2/bin/hmmsearch --mpi --cut_ga -Z "${N}" --domtblout "${OUTDIR}"/HMMPfam.out -o "${OUTDIR}"/HMMPfam.log "${PFAM}"/Pfam-A.hmm "${INPUT}"

#Collect the results
grep -v '^#' "${OUTDIR}"/HMMPfam.out > "${OUTPUT}"
