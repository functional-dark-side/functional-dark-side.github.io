#!/bin/bash

set -e
set -x

DIR=${1} #/bioinf/projects/megx/UNKNOWNS/2017_11/cl_categories
REF=${2} #/bioinf/projects/megx/UNKNOWNS/2017_11/refinement/refined/marine_hmp_refined_cl.tsv

# Create a file with cl_name and category
cat <(awk -vOFS='\t' '{print $1,"K"}' "${DIR}"/cl_k_ids.txt) \
  <(awk -vOFS='\t' '{print $1,"KWP"}' "${DIR}"/cl_kwp_ids.txt) \
  <(awk -vOFS='\t' '{print $1,"GU"}' "${DIR}"/cl_gu_ids.txt) \
  <(awk -vOFS='\t' '{print $1,"EU"}' "${DIR}"/cl_eu_ids.txt) > "${DIR}"/cluster_ids_categ.tsv

# Add ORFs
join -11 -21 <(sort -k1,1 "${DIR}"/cluster_ids_categ.tsv) \
  <(awk '{print $1,$3}' <(zcat "${REF}") | sort -k1,1) \
  > "${DIR}"/cluster_ids_categ_orfs.tsv

# Gather cluster annotations obtained from the classification and the two refinement steps
CLASS=${3} #/bioinf/projects/megx/UNKNOWNS/2017_11/classification
UREF=${4} #/bioinf/projects/megx/UNKNOWNS/2017_11/classification/unkn_refinement
KREF=${5} #/bioinf/projects/megx/UNKNOWNS/2017_11/classification/knwon_refinement

# GU annotations
join -11 -21 <(sort -k1,1 "${DIR}"/cl_gu_ids.txt) \
  <(awk '{print $1,"Uniclust",$3,$4}' "${UREF}"_parsed.tsv | sort -k1,1) \
  > "${DIR}"/GU_annotations.tsv
awk 'NR>1{print $1,"Pfam","0.0",$2}' "${KREF}"_new_gu_ids_annot.tsv >> "${DIR}"/GU_annotations.tsv
cat "${CLASS}"/gu_annotations.tsv >> "${DIR}"/GU_annotations.tsv
sed -i 's/ /\t/g' "${DIR}"/GU_annotations.tsv

# KWP annotations
join -11 -21 <(sort -k1,1 {output.kwp}) \
  <(awk '{print $1,"Uniclust",$3,$4}' "${UREF}"_parsed.tsv | sort -k1,1) \
  > "${DIR}"/KWP_annotations.tsv
join -11 -21 <(sort -k1,1 {output.kwp}) \
  <(sort -k1,1 "${CLASS}"/kwp_annotations.tsv) >> "${DIR}"/KWP_annotations.tsv
sed -i 's/ /\t/g' "${DIR}"/KWP_annotations.tsv

# K annotations
cat "${CLASS}"/k_annotations.tsv \
  <(awk -vOFS='\t' 'NR>1{print $1,"Pfam","0.0",$2}' "${KREF}"_new_k_ids_annot.tsv) \
  > "${DIR}"/K_annotations.tsv
