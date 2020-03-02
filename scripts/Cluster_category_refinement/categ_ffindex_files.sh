#!/bin/bash

DIR=$(dirname ${1})
SMPL="marine_hmp"
OUTDIR=$(dirname ${2})
MMSEQS=~/MMseqs2/bin/mmseqs
FFINDEX=ffindex_apply
LIB=${PWD}/workflow

STEP=${3}

if [[ ${STEP} = "known_refinement" ]]; then
  CATEG=$(echo -e "kwp")
elif [[ ${STEP} = "unkn_refinement" ]]; then
  CATEG=$(echo -e "eu")
else
  CATEG=$(echo -e "eu\ngu\nkwp\nk")
fi

#Create subDB for each cluster categ to retrieve the MSAs, the consensus and the profiles; using the cluster ids/names
#Ex: Genomic unknowns = gu

for categ in $CATEG; do

  "${MMSEQS}" createsubdb "${DIR}"/"${SMPL}"_"${categ}"_ids.txt \
    "${SMPL}"/clustering/"${SMPL}"_clu_fa "${OUTDIR}"/"${SMPL}"_"${categ}"_clu

  # Retrieve set of ORFs for each category
  sed -e 's/\x0//g' "${OUTDIR}"/"${SMPL}"_"${categ}"_clu | gzip > "${OUTDIR}"/"${SMPL}"_"${categ}"_cl_orfs.fasta.gz
  grep '^>' "${OUTDIR}"/"${SMPL}"_"${categ}"_cl_orfs.fasta | sed 's/^>//' | gzip > "${OUTDIR}"/"${SMPL}"_"${categ}"_cl_orfs.txt.gz

  # Retrieve alignments, consensus sequences and HMMs
  "${FFINDEX}" "${OUTDIR}"/"${SMPL}"_"${categ}"_clu "${OUTDIR}"/"${SMPL}"_"${categ}"_clu.index \
    -i "${OUTDIR}"/"${SMPL}"_"${categ}"_aln.ffindex -d "${OUTDIR}"/"${SMPL}"_"${categ}"_aln.ffdata \
    -- famsa STDIN STDOUT 2> /dev/null

  "${FFINDEX}" "${OUTDIR}"/"${SMPL}"_"${categ}"_aln.ff{data,index} \
    -i "${OUTDIR}"/"${SMPL}"_"${categ}"_a3m.ffindex -d "${OUTDIR}"/"${SMPL}"_"${categ}"_a3m.ffdata \
    -- ${PWD}/scripts/E_categories_refinement/reformat_file.sh

  "${FFINDEX}" "${OUTDIR}"/"${SMPL}"_"${categ}"_aln.ff{data,index} \
    -i "${OUTDIR}"/"${SMPL}"_"${categ}"_cons.ffindex -d "${OUTDIR}"/"${SMPL}"_"${categ}"_cons.ffdata \
    -- ${PWD}/scripts/E_categories_refinement/consensus.sh

  cstranslate -A "${LIB}"/data/cs219.lib -D "${LIB}"/data/context_data.lib \
    -x 0.3 -c 4 -f -i "${OUTDIR}"/"${SMPL}"_"${categ}"_aln -o "${OUTDIR}"/"${SMPL}"_"${categ}"_cs219 -I fas -b

  "${FFINDEX}" "${OUTDIR}"/"${SMPL}"_"${categ}"_aln.ff{data,index} \
    -i "${OUTDIR}"/"${SMPL}"_"${categ}"_hmm.ffindex -d "${OUTDIR}"/"${SMPL}"_"${categ}"_hmm.ffdata \
    -- ${PWD}/scripts/E_categories_refinement/hhmake.sh
done

echo "Done all categes of clusters"
