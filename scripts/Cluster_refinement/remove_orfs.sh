#!/bin/bash

REMOV=${1}
DIR=$(dirname ${REMOV})
SEQS=$(perl -ne 'print $_')

echo "${SEQS}" | awk '/^>/{split($1,a,"- OS"); print a[1]; next}1' > ${DIR}/${FFINDEX_ENTRY_NAME}_fa

awk -v N=$FFINDEX_ENTRY_NAME '$2==N{print $1}' ${REMOV}  > ${DIR}/${FFINDEX_ENTRY_NAME}_rem.txt

if [[ -s ${DIR}/${FFINDEX_ENTRY_NAME}_rem.txt ]]; then
   seqkit fx2tab ${DIR}/${FFINDEX_ENTRY_NAME}_fa  | LC_ALL=C grep -v -f ${DIR}/${FFINDEX_ENTRY_NAME}_rem.txt | seqkit tab2fx
   rm ${DIR}/${FFINDEX_ENTRY_NAME}_rem.txt
   rm ${DIR}/${FFINDEX_ENTRY_NAME}_fa
else
   awk '{print $0}' ${DIR}/${FFINDEX_ENTRY_NAME}_fa
   rm ${DIR}/${FFINDEX_ENTRY_NAME}_rem.txt
   rm ${DIR}/${FFINDEX_ENTRY_NAME}_fa
fi
