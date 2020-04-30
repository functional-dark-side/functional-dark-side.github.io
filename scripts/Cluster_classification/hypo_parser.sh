#!/bin/bash
set -x

# Usage
# bash hypo_parse.sh clstr_uniref90.m8 uniref90_prot_ids.tsv unknown_grep.tsv 0.7 > clstr_biodb_e60_hypo_70.tsv

FILE=${1}
NAME=$(basename "${FILE}" '.m8')
DBPROT=${2}
PATTERNS=${3}
FILT=${4} # select filtering threshold for hypothetical hits
OUT=${5}

# Filter e-value inside the 60% of the best evalue
F06=$(awk -f "${PWD}"/scripts/Cluster_classification/evalue_06_filter.awk <(sort -k1,1 -k11,11g "${FILE}" | awk '!seen[$1,$2]++'))
#Retrive database protein information
F06P="${F06}"_prot
join -12 -21 <(sort -k2,2 --parallel=10 -S25% <(echo "${F06}")) <(sort -k1,1 --parallel=10 -S25% "${DBPROT}") >  "${F06P}"

FOUT="${F06P}"_hypo_char
LC_ALL=C rg -j 4 -i -f "${PATTERNS}" "${F06P}" | awk '{print $0"\thypo"}' > "${FOUT}"
LC_ALL=C rg -j 4 -v -i -f "${PATTERNS}" "${F06P}" | awk '{print $0"\tchar"}' >> "${FOUT}"
sed -i 's/ /\t/g' "${FOUT}"
awk -v P=${FILT} 'BEGIN{FS="\t"}{a[$2][$16]++}END{for (i in a) {N=a[i]["hypo"]/(a[i]["hypo"]+a[i]["char"]); if (N >= P){print i}}}' "${FOUT}" > "${OUT}"

awk '{print $2"\t"$1"\t"$11"\t"$15}' "${FOUT}" > "${F06}" && mv "${F06}" "${FOUT}"

rm "${F06P}"
