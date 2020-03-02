#!/bin/bash

set -e
set -x

DIR=/bioinf/projects/megx/UNKNOWNS/refinement/refined
SMPL="marine_hmp"
U="${DIR}"/"${SMPL}"_refined_noannot_cl.tsv
K="${DIR}"/"${SMPL}"_refined_annot_cl.tsv
OUTDIR=/bioinf/projects/megx/UNKNOWNS/classification
OUTDIRU="${OUTDIR}"/unannotated_cl
OUTDIRK="${OUTDIR}"/annotated_cl
NSLOTS="${1}"

#Extract not-annotated clusters from the good refined sbset
awk '!seen[$1]++{print $1}' "${U}" > "${OUTDIRU}"/"${SMPL}"_refined_noannot_cl_ids.txt

#Extract consensus sequnces
"${PWD}"/scripts/D_classification/cluster_ffindex_files.sh  "${SMPL}" "${OUTDIRU}"/"${SMPL}"_refined_noannot_cl_ids.txt "${OUTDIRU}"/"${SMPL}"_refined_noannot_cons.fasta

#Search against UniRef90
OUTUR="${OUTDIRU}"/"${SMPL}"_uniref90

mkdir -p "${OUTUR}"

UR="${PWD}"/DBs/uniref90_db
UR_PROT="${PWD}"/DBs/uniref90_prot_ids.tsv.gz

"${PWD}"/scripts/D_classification/double_search.sh "${OUTUR}" "${OUTDIRU}"/"${SMPL}"_refined_noannot_cons.fasta "${UR}" "${NSLOTS}" "${OUTUR}"/"${SMPL}"_cons_uniref90.m8

rm "${OUTUR}"/tmp -rf

"${PWD}"/scripts/D_classification/hypo_parser.sh "${OUTUR}"/"${SMPL}"_cons_uniref90.m8 "${UR_PROT}" "${PWD}"/scripts/unknown_grep.tsv 1.0 "${OUTUR}"/"${SMPL}"_cons_uniref_e60_hypo_1.txt

#Parse results and search nohits against NCBI nr
awk '!seen[$1]++{print $1}' "${OUTUR}"/"${SMPL}"_cons_uniref90.m8 > "${OUTUR}"/"${SMPL}"_cons_uniref90_hits.txt

filterbyname.sh in="${OUTDIRU}"/"${SMPL}"_refined_noannot_cons.fasta out="${OUTUR}"/"${SMPL}"_cons_uniref90_nohits.fasta \
  names="${OUTUR}"/"${SMPL}"_cons_uniref90_hits.txt include=f ignorejunk

#Search against NR
OUTNR="${OUTDIRU}"/"${SMPL}"_NR

mkdir -p "${OUTNR}"

NR="${PWD}"/DBs/nr_db
NR_PROT="${PWD}"/DBs/nr.proteins.tsv.gz

"${PWD}"/scripts/D_classification/double_search.sh "${OUTNR}" "${OUTUR}"/"${SMPL}"_cons_uniref90_nohits.fasta "${NR}" "${NSLOTS}" "${OUTNR}"/"${SMPL}"_cons_nr.m8

rm "${OUTNR}"/tmp -rf

"${PWD}"/scripts/D_classification/hypo_parser.sh "${OUTNR}"/"${SMPL}"_cons_nr.m8 "${NR_PROT}" "${PWD}"/scripts/unknown_grep.tsv 1.0 "${OUTNR}"/"${SMPL}"_cons_nr_e60_hypo_1.txt

#Parse results and define the first categories
awk '!seen[$1]++{print $1}' "${OUTNR}"/"${SMPL}"_cons_nr.m8 > "${OUTNR}"/"${SMPL}"_cons_nr_hits.txt

filterbyname.sh in="${OUTUR}"/"${SMPL}"_cons_uniref90_nohits.fasta out="${OUTNR}"/"${SMPL}"_cons_nr_nohits.fasta \
  names="${OUTNR}"/"${SMPL}"_cons_nr_hits.txt include=f ignorejunk

#Environmental unknowns (EUs)
grep '^>' "${OUTNR}"/"${SMPL}"_cons_nr_nohits.fasta | sed 's/^>//' > "${OUTDIR}"/"${SMPL}"_eu_ids.txt

# Knowns without Pfam (KWPs)
#Not-hypo hits from UniRef90
join -11 -21 -v1 <(sort "${OUTUR}"/"${SMPL}"_cons_uniref90_hits.txt) \
  <(sort "${OUTUR}"/"${SMPL}"_cons_uniref_e60_hypo_1.txt) > "${OUTUR}"/"${SMPL}"_cons_uniref_not_hypo.txt
#Not-hypo hits from NCBI nr
join -11 -21 -v1 <(sort "${OUTNR}"/"${SMPL}"_cons_nr_hits.txt) \
  <(sort -k1,1 <(awk '{print $1}' "${OUTNR}"/"${SMPL}"_cons_nr_e60_hypo_1.txt)) > "${OUTNR}"/"${SMPL}"_cons_nr_not_hypo.txt

cat "${OUTUR}"/"${SMPL}"_cons_uniref_not_hypo.txt "${OUTNR}"/"${SMPL}"_cons_nr_not_hypo.txt > "${OUTDIR}"/"${SMPL}"_kwp_ids.txt

#Knowns and Genomic unknowns

# Retreive the info about the annotations
join -13 -22 <(sort -k3,3 "${K}") <(sort -k2,2 "${PWD}"/"${SMPL}"/annot_and_clust/"${SMPL}"_clu_ge_avg_size_annot.tsv) > "${OUTDIRK}"/tmp

# Parse columns
awk '{print $2"\t"$3"\t"$4"\t"$1"\t"$6"\t"$8"\t"$9}' "${OUTDIRK}"/tmp | gzip > "${OUTDIRK}"/"${SMPL}"_refined_annot_cl_pfam.tsv.gz

rm "${OUTDIRK}"/tmp

#Load in R and retrieve general table with architectures plus DUFs and PFs
KANNOT="${OUTDIRK}"/"${SMPL}"_cluster_pfam_domain_architect.tsv
R CMD BATCH "--args ${KANNOT} ${OUTDIRK}" "${PWD}"/scripts/D_classification/pfam_domain_architect_ref.r "${OUTDIRK}"/pfam_domain_architecture.Rout

# Add the DUFs annotated clusters to the GU
cat <(awk 'NR>1{print $1}' "${OUTDIRK}"/kept_DUFs.tsv) \
  "${OUTUR}"/"${SMPL}"_cons_uniref_e60_hypo_1.txt \
  "${OUTNR}"/"${SMPL}"_cons_nr_e60_hypo_1.txt > "${OUTDIR}"/"${SMPL}"_gu_ids.txt

# Retrieve the knowns
awk 'NR>1{print $1}' "${OUTDIR}"/kept_PF.tsv > "${OUTDIR}"/"${SMPL}"_k_ids.txt


### Save files with annotations
# Add annotation info:
cat "${OUTUR}"/"${SMPL}"_cons_uniref90_hypo_char \
  "${OUTUR}"/"${SMPL}"_cons_nr_hypo_char > "${OUTUR}"/"${SMPL}"_uniref90_nr_annotations.tsv
## KWP annotations
join -11 -21 <(sort -k1,1 "${OUTDIR}"/"${SMPL}"_kwp_ids.txt ) \
  <(sort -k1,1 "${OUTUR}"/"${SMPL}"_uniref90_nr_annotations.tsv) > "${OUTDIR}"/"${SMPL}"_kwp_annotations.tsv

## GU annotations
join -11 -21 <(sort -k1,1 "${OUTDIR}"/"${SMPL}"_gu_ids.txt ) \
  <(sort -k1,1 ${{DIR}}/noannot_uniref_nr_annotations.tsv) > ${{DIR}}/gu_annotations.tsv
awk 'NR>1 && $9=="DUF"{print $1,"PFAM","0.0",$6}' "${KANNOT}" >> "${OUTDIR}"/"${SMPL}"_gu_annotations.tsv

# Retrieve the Knowns cluster set
awk 'NR>1 && $9=="PF"{print $1,"PFAM","0.0",$6}' "${KANNOT}" >> "${OUTDIR}"/"${SMPL}"_k_annotations.tsv
