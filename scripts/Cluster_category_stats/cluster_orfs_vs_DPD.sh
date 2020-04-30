#!/bin/bash

set -e
set -x

# Usage: ./cluster_orfs_vs_DPD.sh refined_clu_db DPD.fa cluster_darkness/

CL_DB="${1}" #data/cluster_refinement/ffindex_files/marine_hmp_refined_cl_fa
CL_CATEG="${2}" #data/cluster_categories/cl_ids_categ_orfs.tsv
DPD_FA="${3}" #data/cluster_category_stats/darkness/dpd_uniprot_sprot.fasta.gz
OUTDIR="${4}" #data/cluster_category_stats/darkness/

# Extract all sequences from the refined database set:
sed -e 's/\x0//g' "${CL_DB}" | gzip > "${OUTDIR}"/refined_cl_orfs.fasta.gz

# Create MMseqs2 databases
mmseqs createdb "${OUTDIR}"/refined_cl_orfs.fasta.gz "${OUTDIR}"/refined_cl_orfs_db
mmseqs createdb "${DPD_FA}" "${OUTDIR}"/dpd_db
# Search
mmseqs search "${OUTDIR}"/refined_cl_orfs_db "${OUTDIR}"/dpd_db \
  "${OUTDIR}"/refined_cl_orfs_dpd_db "${OUTDIR}"/tmp \
  --threads 32 --max-seqs 300 \
  -e 1e-20 --cov-mode 0 -c 0.6

mmseqs convertalis "${OUTDIR}"/refined_cl_orfs_db "${OUTDIR}"/dpd_db "${OUTDIR}"/refined_cl_orfs_dpd_db \
  "${OUTDIR}"/refined_cl_orfs_dpd.tsv \
  --threads 32 \
  --format-output 'query,target,pident,alnlen,mismatch,gapopen,qstart,qend,tstart,tend,evalue,bits,qcov,tcov'

# Extract best-hits
export LANG=C; export LC_ALL=C; sort -k1,1 -k11,11g -k13,13gr -k14,14gr "${OUTDIR}"/refined_cl_orfs_dpd.tsv | \
  sort -u -k1,1 --merge > "${OUTDIR}"/refined_cl_orfs_dpd_bh.tsv

# Join with cluster categories
join -11 -23 <(awk'{print $1,$2}' "${OUTDIR}"/refined_cl_orfs_dpd_bh.tsv | sort -k1,1) \
  <(sort -k3,3 "${CL_CATEG}") > "${OUTDIR}"/refined_cl_orfs_dpd_bh_categ.tsv

sed -i 's/ /\t/g' "${OUTDIR}"/refined_cl_orfs_dpd_bh_categ.tsv
# Load in "cluster_category_stats.r" to join with DPD info and retrieve statistics for each clusters
# To retrieve the DPD informations/annotations
# Download the excel Dataset S1 from the paper
# wget https://www.pnas.org/content/pnas/suppl/2015/11/17/1508380112.DCSupplemental/pnas.1508380112.sd01.xlsx
# open with Excel, save the stats for the different kingdoms (the different sheets) as a tab-separated file (tsv): dpd_ids_all_info.tsv
