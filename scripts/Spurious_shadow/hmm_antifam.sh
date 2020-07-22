#!/bin/bash

#usage:
#1st: /bioinf/software/hmmer/hmmer-3.1b2/bin/hmmpress DB/AntiFam.hmm
#2nd: cat DB/antifam_keys | parallel --progress -j 32 ./hmm_antifam.sh {} \;

set -x
set -e

hmm="${1}"
DB="${2}"
FA="${3}"
OUTDIR="${4}"

if [[ -d "${OUTDIR}" ]]; then
  cd "${OUTDIR}"
else
  mkdir -p "${OUTDIR}"
  cd "${OUTDIR}"
fi


/bioinf/software/hmmer/hmmer-3.1b2/bin/hmmfetch -o ${DB}/antifam_hmm.${hmm} ${DB}/AntiFam.hmm ${hmm}

/bioinf/software/hmmer/hmmer-3.1b2/bin/hmmsearch --cut_ga -Z 322248552 --domtblout ${OUTDIR}/antifam.${hmm}.out -o ${OUTDIR}/antifam.${hmm}.log ${DB}/antifam_hmm.${hmm}
