#!/bin/bash

set -x
set -e

DIR=data/cluster_classification
SMPL="marine_hmp"
INPUT="${DIR}"/"${SMPL}"_eu_ids.txt
OUTDIR="${DIR}"/unkn_refinement
OUTPUT="${OUTDIR}"/"${SMPL}"_eu
PATTERNS=${PWD}/scripts/Cluster_categories_refinement/unknown_grep.tsv
FILT=1.0
NSLOTS=${1}
UNICL=data/DBs/uniclust30_2017_10/uniclust30_2017_10
HHBLITS_MPI=hhblits_mpi
MPIRUN=mpirun
FFINDEX=ffindex_apply_mpi

STEP="unkn_refinement"

${PWD}/scripts/Cluster_categories_refinement/categ_ffindex_files.sh "${INPUT}" "${OUTPUT}"_hhbl.ffdata "${STEP}"

"${MPIRUN}" -np "${NSLOTS}" "${HHBLITS_MPI}" -i "${OUTDIR}"/"${SMPL}"_eu_hmm -o stdout -d "${OUTPUT}"_hhbl \
  -cpu "${NSLOTS}" -n 2 -v 0 -d "${UNICL}"

rm "${OUTDIR}"/"${SMPL}"_eu_hmm.ff* "${OUTDIR}"/"${SMPL}"_eu_aln.ff* "${OUTDIR}"/"${SMPL}"_eu_cons.ff*
rm "${OUTDIR}"/"${SMPL}"_eu_a3m.ff* "${OUTDIR}"/"${SMPL}"_eu_cs219.ff* "${OUTDIR}"/"${SMPL}"_eu_clu*

# Parsing hhr result files and filtering for hits with probability ≥ 90%
"${FFINDEX}" "${OUTPUT}"_hhbl.ff{data,index} -d "${OUTPUT}"_parsed.ffdata -i "${OUTPUT}"_parsed.ffindex \
  -- ${PWD}/scripts/Cluster_categories_refinement/hh_parser.sh

sed -e 's/\x0//g' "${OUTPUT}"_parsed.ffdata | sed 's/ /_/g' > "${OUTPUT}"_parsed.tsv

LC_ALL=C rg -j 4 -i -f "${PATTERNS}" "${OUTPUT}"_parsed.tsv | awk '{print $0"\thypo"}' > "${OUTPUT}"_hypo_char
LC_ALL=C rg -j 4 -v -i -f "${PATTERNS}" "${OUTPUT}"_parsed.tsv | awk '{print $0"\tchar"}' >> "${OUTPUT}"_hypo_char

sed -i 's/ /\t/g' "${OUTPUT}"_hypo_char

awk -v P="${FILT}" 'BEGIN{FS="\t"}{a[$1][$5]++}END{for (i in a) {N=a[i]["hypo"]/(a[i]["hypo"]+a[i]["char"]); if (N >= P){print i}}}' "${OUTPUT}"_hypo_char > "${OUTDIR}"/"${SMPL}"_new_gu_ids.txt

rm "${OUTPUT}"_hypo_char

join -11 -21 -v1 <(awk '!seen[$1]++{print $1}' "${OUTPUT}"_parsed.tsv | sort -k1,1) \
  <(sort -k1,1 "${OUTDIR}"/"${SMPL}"_new_gu_ids.txt) > "${OUTDIR}"/"${SMPL}"_new_kwp_ids.txt

join -11 -21 -v1 <(sort -k1,1 "${SMPL}"/cluster_classification/"${SMPL}"_eu_ids.txt) \
  <(awk '!seen[$1]++{print $1}' "${OUTPUT}"_parsed.tsv | sort -k1,1) > "${OUTDIR}"/"${SMPL}"_new_eu_ids.txt

cat "${DIR}"/"${SMPL}"_kwp_ids.txt >> "${OUTDIR}"/"${SMPL}"_new_kwp_ids.txt

cat "${DIR}"/"${SMPL}"_gu_ids.txt >> "${OUTDIR}"/"${SMPL}"_new_gu_ids.txt

cp "${DIR}"/"${SMPL}"_k_ids.txt "${OUTDIR}"/"${SMPL}"_new_k_ids.txt
