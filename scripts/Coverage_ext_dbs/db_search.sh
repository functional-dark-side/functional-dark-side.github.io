#!/bin/#!/usr/bin/env bash

#DIR=/bioinf/projects/megx/UNKNOWNS/2017_11
# The cluster profiles are in /bioinf/projects/megx/UNKNOWNS/2017_11/cl_categories/ffindex_files/cl_hmm_db
DB=${1} # fasta file
NAME=$(basename "${DB}" .fasta)
PROFILES=cl_hmm_db
NSLOTS=${2}
CATEG=/bioinf/projects/megx/UNKNOWNS/2017_11/cl_categories/cl_ids_categ.tsv

# Create databases
# MMseqs2 Version: 8.fac81
mmseqs createdb "${DB}" "${NAME}"_db

#Search the database sequences against the cluster PROFILES
# MMseqs2 Version: 8.fac81
mmseqs search "${NAME}"_db "${PROFILES}" "${NAME}"_hmm_db tmp --threads "${NSLOTS}" -e 1e-20 --cov-mode 2 -c 0.6

mmseqs convertalis "${NAME}"_db "${PROFILES}" "${NAME}"_cl_hmm_db "${NAME}"_cl_hmm_qcov06.tsv --threads "${NSLOTS}" --format-output 'query,target,pident,alnlen,mismatch,gapopen,qstart,qend,tstart,tend,evalue,bits,qcov,tcov'

# Majority-vote step
# Add the cluster category information
join -12 -21 <(sort -k2,2 "${NAME}"_cl_hmm_qcov06.tsv ) <(sort -k1,1 "${CATEG}" ) > "${NAME}"_cl_hmm_qcov06_categ.tsv
sed -i 's/ /\t/g' "${NAME}"_cl_hmm_qcov06_categ.tsv

# Optional testing for category consistency between the different evalue filtering
# Parse the results retriving iteratively the hits within the 60-70-80-90% of the Log(best(e-value))
awk -v P=0.6 -f ./evalue_filter.awk "${NAME}"_cl_hmm_qcov06_categ.tsv | gzip > "${NAME}"_cl_hmm_qcov06_categ_e60.tsv
awk -v P=0.7 -f ./evalue_filter.awk "${NAME}"_cl_hmm_qcov06_categ.tsv | gzip > "${NAME}"_cl_hmm_qcov06_categ_e70.tsv
awk -v P=0.8 -f ./evalue_filter.awk "${NAME}"_cl_hmm_qcov06_categ.tsv | gzip > "${NAME}"_cl_hmm_qcov06_categ_e80.tsv
awk -v P=0.9 -f ./evalue_filter.awk "${NAME}"_cl_hmm_qcov06_categ.tsv | gzip > "${NAME}"_cl_hmm_qcov06_categ_e90.tsv
# Check the consisntency of the consensus category for each e-value filtering
Rscript --vanilla ./majority_vote_categ_test_all.R "${NAME}"_cl_hmm_qcov06_categ_e90.tsv.gz
# Ouput example
# One r-object: "${NAME}"_cl_hmm_qcov06_categ_consistency.rda;
# plus stdout with the case of inconsistency and their proportion over the total hits

#  con_cat     n     p
#  <chr>    <int>  <dbl>
# GU_KWP    2118 0.0555
# GU_K       515 0.0135
# K_KWP      355 0.00930
# GU_K_KWP    22 0.000576

# Parse results choosing an evalue filtering [suggested: 90%Log(best(e-value))]
awk -v P=0.9 -f ./evalue_filter.awk "${NAME}"_cl_hmm_qcov06_categ.tsv | gzip > "${NAME}"_cl_hmm_qcov06_categ_e90.tsv
# Report the consensus category, get the best-hits and output summary tables
Rscript --vanilla ./majority_vote_categ.R "${NAME}"_cl_hmm_qcov06_categ_e90.tsv.gz

# In case you want the proportion of different functional catgories per contig/genome/MAG/BIOMES
# Provide a table with information about the correspondence gene - contig/genome/biome etc..
# Rscript --vanilla ./majority_vote_categ.R "${NAME}"_cl_hmm_qcov06_categ_e90.tsv.gz "${NAME}"_gene_info.tsv
