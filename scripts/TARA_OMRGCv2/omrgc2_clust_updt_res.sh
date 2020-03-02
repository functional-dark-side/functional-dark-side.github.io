#!/bin/bash

set -e
set -x

# Results are in /vol/cloud/omrgc2/mg_g_omrgc_update/ and /vol/cloud/omrgc2/mg_g_omrgc_update/tmp/latest
# "clusterupdate" creates a new sequence database DB_new_updated that has consistent identifiers with the previous version.
# Meaning, the same sequences in both sets will have the same numeric identifier.
# All modules afterwards (for example convertalis) expect this sequence database to be passed.

seqDB="${1}" #/vol/cloud/omrgc2/mg_g_omrgc_update/mg_g_omrgc2_db_20200128_clu
CLSTR="${2}" #/vol/cloud/omrgc2/mg_g_omrgc_update/mg_g_omrgc2_db_20200128_clu
NAME=$(basename "${CLSTR}" _clu)
DIR=$(dirname "${CLSTR}")
MMSEQS=/vol/cloud/test_wkfl/bin/mmseqs

# The clustering results in the internal format can be converted to a flat tsv file
# All members of the clustering are listed line by line. The first column always contains the representative sequence, the second contains the cluster member.
"${MMSEQS}" createtsv "${seqDB}" "${CLSTR}" "${CLSTR}".tsv

# Fasta/sequences database for each cluster
"${MMSEQS}" createseqfiledb "${seqDB}" "${CLSTR}" "${CLSTR}"_fa
# This DB can be accessed with ffindex, to extract separated fasta files for each cluster and perform operations on them (https://github.com/soedinglab/MMseqs2/wiki#how-to-run-external-tools-for-each-database-entry)
# Ex: ffindex_apply_mpi "${CLUSTER}"/unkdb_update_hmp/marine_hmp_db_03112017_clu_fa "${CLUSTER}"/unkdb_update_hmp/marine_hmp_db_03112017_clu_fa.index -- your_program

# To convert this tsv file in wide format (repres member member member ..)
# This file usually defines the cluster number/ID,
# since the tab separated file, from which it comes from, has not the same order as the original clustering,
# we are going to map this file back to the origianl clustering and name the new clusters incrementally from the last original one:
awk -f ${PWD}/scripts/convert_long_wide.awk "${CLSTR}".tsv > "${CLSTR}"_wide.tsv

# Collecting cluster information
# File with cluster name, ORFs, length, size
seqtk comp "${PWD}"/data/"${SAMPLE}".fasta | cut -f1,2 > "${CLSTR}"_length.tsv

# Cluster name rep and number of ORFs (size)
awk -F'\t' '{print NR"\t"$1"\t"NF-1}' "${CLSTR}"_wide.tsv > "${CLSTR}"_cl_name_rep_size.tsv

# Join with the original clustering using the representative sequences
join -12 -22 <(sort -k2,2 "${CLSTR_OLD}"_cl_name_rep_size.tsv) \
  <(sort -k2,2 "${CLSTR}"_cl_name_new_rep_size.tsv) > "${CLSTR}"_rename_original

join -12 -22 -v2 <(sort -k2,2 "${CLSTR_OLD}"_cl_name_rep_size.tsv) \
  <(sort -k2,2 "${CLSTR}"_cl_name_rep_size.tsv) > "${CLSTR}"_rename_new

# Store the information about changes in the original Clusters
sort -k2,2n "${CLSTR}"_rename_original | awk '{print $2"\t"$1"\t"$3"\t"$5}' > "${CLSTR}"_original_cl_name_rep_size_old_new.tsv
# Order and rejoin old and new cluster ids/NAMES (the new ids will start from the last of the original clustering)
OR=$(wc -l "${CLSTR}"_original_cl_name_rep_size_old_new.tsv | cut -d ' ' -f1)

awk -v OR=$OR '{print NR+OR"\t"$1"\t"$3}' "${CLSTR}"_rename_new > "${CLSTR}"_new_clu_rep_size.tsv

cat <(awk '{print $1"\t"$2"\t"$4}' "${CLSTR}"_original_cl_name_rep_size_old_new.tsv ) \
  "${CLSTR}"_new_clu_rep_size.tsv > "${CLSTR}"_cl_name_rep_size.tsv

# Cluster naming - Updated index of cluster mmseqs index-numbers and custom cluster names
# The official cluster names are going to be based on the line number of the wide formatted file
# We are also going to produce a correspondence file to access the clusters in the MMseqs2 indices
# Output: "${CLSTR}"_name_index.txt: <MMseqs2-index-num> <Cluster-name>
${PWD}/cluster_naming.sh "${seqDB}" "${CLSTR}" "${CLSTR}"_cl_name_rep_size.tsv "${MMSEQS}" "${NSLOTS}"

#Join with the long format cluster file
join -11 -22 <(sort -k1,1 "${CLSTR}".tsv ) <(sort -k2,2 "${CLSTR}"_cl_name_rep_size.tsv ) > "${CLSTR}"_tmpl

# Add length info
join -11 -22 <(sort -k1,1 "${CLSTR}"_length.tsv) <(sort -k2,2 "${CLSTR}"_tmpl) > "${CLSTR}"_info.tsv

# Reorder fields (cl_name rep orf length size)
sort -k4,4n "${CLSTR}"_info.tsv | awk '{print $4"\t"$3"\t"$1"\t"$2"\t"$5}' > "${CLSTR}"_tmpl

mv "${CLSTR}"_tmpl "${CLSTR}"_info.tsv

gzip "${CLSTR}"_info.tsv

# Define different cluster classes based on the cluster affiliation with the original or the new datasets:
# Original: Metagenomic (MG) + Genomic (G)
# Integrated: Metagenomic + Genomic + OMRGC2 (MG_G_OMRGC2)
# New: OMRGC.V2 (OMRGC2)

# From the new cluDB.tsv extract mixed cluster rep:
awk '$2~/OM-RGC.v2/ && $1!~/OM-RGC.v2/' "${CLSTR}".tsv | \
  awk '!seen[$1]++{print $1}' > "${CLSTR}"_mix_rep.txt

# Using the representatives extract mixed cluster ids:
join -11 -22 <(sort "${CLSTR}"_mix_rep.txt ) \
  <(sort -k2,2 "${CLSTR}"_cl_name_rep_size.tsv ) > "${CLSTR}"_mix_cl

# And the only old clusters (not-updated)
join -11 -22 -v1 <(sort -k1,1 "${CLSTR}"_original_cl_name_rep_size_old_new.tsv) \
  <(sort -k2,2 "${CLSTR}"_mix_cl ) > "${CLSTR}"_old_cl

# From the summary_tables of MG+GTDB: mg_g_cluster_data_class.tsv.gz --> add class to clusters
SUMDIR=/bioinf/projects/megx/UNKNOWNS/2017_11/summary_tables
join -11 -22 <(zcat "${SUMDIR}"/mg_g_cluster_data_class.tsv.gz | sort -k1,1) \
  <(sort -k2,2 "${CLSTR}"_mix_cl) > "${CLSTR}"_mix_cl1

join -11 -21 <(zcat "${SUMDIR}"/mg_g_cluster_data_class.tsv.gz | sort -k1,1) \
  <(sort -k1,1 "${CLSTR}"_old_cl ) > "${CLSTR}"_old_cl1
# Old MG_G
awk '{print $1"\t"$2"\t"$5}' "${CLSTR}"_old_cl1 > "${CLSTR}"_cluster_class_size.tsv
# Integrated MG_G_OMRGC2
awk '{print $1"\t"$2"_""OMRGC2""\t"$4}' "${CLSTR}"_mix_cl1 >> "${CLSTR}"_cluster_class_size.tsv
# New OMRGC2
awk '{print $1"\t""OMRGC2""\t"$3}' "${CLSTR}"_new_clu_rep_size.tsv >> "${CLSTR}"_cluster_class_size.tsv

# For the mixed/integrated clusters —> we can assign the categories of the old clusters:
awk '$2~/_OMRGC2/' "${CLSTR}"_cluster_class_size.tsv > "${CLSTR}"_mix_clusters.tsv

join -11 -21 <(sort -k1,1 "${CLSTR}"_mix_clusters.tsv ) \
  <(sort -k1,1 --parallel 20  <(zcat ${SUMDIR}/mg_gtdb_cluster_size_class_categories.tsv.gz )) \
  > "${CLSTR}"_mix_cluster_categ.tsv

awk '{if($3==1) print $0,"SINGL"; else if($3!=1 && $3<10) print $0,"LT10"; else if($3>=10) print $0,"G10"}' "${CLSTR}"_mix_cluster_categ.tsv | \
  awk '{print $1,$2,$4,$5,$3,$7,$8,$11,$10}' \
  > tmpl1 && mv tmpl1 "${CLSTR}"_mix_cluster_categ.tsv

sed -i 's/ /\t/g' "${CLSTR}"_mix_cluster_categ.tsv

# Fields: <cl_name> <class> <mg-size> <mg-g-size> <mg-g-omrgc2-size> <mg-size_categ> <mg-g-size_categ> <mg-g-omrgc2-size_categ> <funct-categ>

# Process only new clusters
# Subset the clusters based on their size
# Mean size
N=$(awk '{sum+=$3}END{printf "%.0f\n", sum/NR}' "${CLSTR}"_cl_name_rep_size.tsv)

if [ "$N" -eq "1" ]; then
  let "N = N + 1";
else
  let "N=N";
fi

# Broken stick model R...


echo "For the following analyses we are going to use only the clusters with >= ${N} ORFs"
# Clusters with more than N members
join -11 -21 <(awk -v N="${N}" '$3>=N{print $2}' "${CLSTR}"_new_clu_rep_size.tsv | sort -k1,1) <(sort -k1,1 "${CLSTR}".tsv ) > "${CLSTR}"_ge_avg_size.tsv
# OR
#zcat "${CLSTR}"_info.tsv.gz | awk -v N="${N}" '$5>N{print $1"\t"$2"\t"$3}' > "${CLSTR}"_ge_avg_size.tsv

# Singletons
awk '$3=="1"{print $1"\t"$2}' "${CLSTR}"_new_clu_rep_size.tsv > "${DIR}"/"${NAME}"_singletons.tsv

# Clusters with more than 1 member
join -11 -21 <(awk '$2>1{print $1}' "${CLSTR}"_new_clu_rep_size.tsv | sort -k1,1 --parallel=10 -S25%) <(sort -k1,1 --parallel=10 -S25% "${CLSTR}".tsv ) > "${CLSTR}"_nosingl.tsv
# OR
#zcat "${CLSTR}"_info.tsv.gz | awk '$5>1{print $1"\t"$2"\t"$3}' > "${CLSTR}"_nosingl.tsv
