#!/bin/bash

# Retrieve compositional validation results
DIR="${1}"
CLSTR=/bioinf/projects/megx/UNKNOWNS/2017_11/annot_and_clust # clusters
CDIR="${DIR}"/compositional # directory with compositional validation results for each cluster
SMPL=$(basename "${CDIR}")
VRES="${DIR}"/res_files # output directory for both validations results
FRES="${DIR}"/functional/shingl_jacc_val_annot.tsv # table with functional validation results

cat "${CDIR}"/results/*_SSN_filt_stats.tsv > "${CDIR}"/marine_hmp_db_03112017_compos_validation.tsv

#Retrieve old cluster representatives information
# Clusters with no annotations
join -12 -22 <(awk '{print $1,$2}' "${CDIR}"/marine_hmp_db_03112017_compos_validation.tsv | sort -k2,2 --parallel 10 -S20%) \
  <(awk '{print $1,$2,"noannot",$3}' "${CLSTR}"/marine_hmp_db_03112017_clu_ge10_not_annot.tsv | sort -k2,2 --parallel 10 -S20%) > "${VRES}"/"${SMPL}"_annot_noannot
# Cluster with representative annotated
join -12 -22 <(awk '{print $1,$2}' "${CDIR}"/marine_hmp_db_03112017_compos_validation.tsv | sort -k2,2 --parallel 10 -S20%) \
  <(awk '{print $1,$2,"annot",$3}' "${CLSTR}"/marine_hmp_db_03112017_clu_ge10_annot.tsv | sort -k2,2 --parallel 10 -S20%) >> "${VRES}"/"${SMPL}"_annot_noannot

awk '{print $2"\t"$1"\t"$3"\t"$5"\t"$4}' "${VRES}"/marine_hmp_db_03112017_annot_noannot > "${VRES}"/tmp && mv "${VRES}"/tmp "${VRES}"/marine_hmp_db_03112017_annot_noannot

# Combine with functional validation results
# Results in SQlite as table of database and plots(as R objects)
~/R-3.4.2/bin/Rscript --vanilla "${PWD}"/scripts/B_validation/validation_res.r "${VRES}" "${FRES}" "${CDIR}"/marine_hmp_db_03112017_compos_validation.tsv "${VRES}"/marine_hmp_db_03112017_annot_noannot

rm "${VRES}"/tmp
