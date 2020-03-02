#!/bin/bash

#Usage: ./clustering_res.sh orfs.fasta clustering_output_db

seqDB="${1}"
CLSTR="${2}"
NAME=$(basename "${CLSTR}" _clu)
DIR=$(dirname "${CLSTR}")
MMSEQS=~/MMseqs2/bin/mmseqs

# The clustering results in the internal format can be converted to a flat tsv file
# All members of the clustering are listed line by line. The first column always contains the representative sequence, the second contains the cluster member.
"${MMSEQS}" createtsv "${seqDB}" "${seqDB}" "${CLSTR}" "${CLSTR}".tsv

#!/bin/#!/usr/bin/env bash
#Parse the clustering update results
#Usage: ./clustering_res.sh orfs.fasta clustering_output_db

seqDB="${1}"
CLSTR="${2}"
NAME=$(basename "${CLSTR}" _clu)
DIR=$(dirname "${CLSTR}")
MMSEQS=~/MMseqs2/bin/mmseqs

# The clustering results in the internal format can be converted to a flat tsv file
# All members of the clustering are listed line by line. The first column always contains the representative sequence, the second contains the cluster member.
"${MMSEQS}" createtsv "${seqDB}" "${seqDB}" "${CLSTR}" "${CLSTR}".tsv

# Fasta/sequences database for each cluster
"${MMSEQS}" createseqfiledb "${seqDB}" "${CLSTR}" "${CLSTR}"_fa
# This DB can be accessed with ffindex, to extract separated fasta files for each cluster and perform operations on them (https://github.com/soedinglab/MMseqs2/wiki#how-to-run-external-tools-for-each-database-entry)
# Ex: ffindex_apply_mpi "${CLUSTER}"/unkdb_update_hmp/marine_hmp_db_03112017_clu_fa "${CLUSTER}"/unkdb_update_hmp/marine_hmp_db_03112017_clu_fa.index -- your_program

# To convert this tsv file in wide format (repres member member member ..)
# This file defines the cluster number/ID,
awk -f ${PWD}/convert_long_wide.awk "${CLSTR}".tsv > "${CLSTR}"_wide.tsv

# Collecting cluster information
# File with cluster name, ORFs, length, size
seqtk comp "${PWD}"/data/"${SAMPLE}".fasta | cut -f1,2 > "${CLSTR}"_length.tsv

# Cluster name and number of ORFs (size)
awk -F'\t' '{print NR"\t"$1"\t"NF-1}' "${CLSTR}"_wide.tsv > "${CLSTR}"_cl_name_new_rep_size.tsv

# Cluster naming
# The official cluster names are going to be based on the line number of the wide formatted file
# We are also going to produce a correspondence file to access the clusters in the MMseqs2 indices
# Output: "${CLSTR}"_name_index.txt: <MMseqs2-index-num> <Cluster-name>
${PWD}/cluster_naming.sh "${seqDB}" "${CLSTR}" "${MMSEQS}" "${NSLOTS}"

#Join with the long format cluster file
join -11 -22 <(sort -k1,1 "${CLSTR}".tsv ) <(sort -k2,2 "${CLSTR}"_cl_name_rep_size.tsv ) > "${CLSTR}"_tmpl

# Add length info
join -11 -22 <(sort -k1,1 "${CLSTR}"_length.tsv) <(sort -k2,2 "${CLSTR}"_tmpl) > "${CLSTR}"_info.tsv

# Reorder fields (cl_name rep orf length size)
sort -k4,4n "${CLSTR}"_info.tsv | awk '{print $4"\t"$3"\t"$1"\t"$2"\t"$5}' > "${CLSTR}"_tmpl

mv "${CLSTR}"_tmpl "${CLSTR}"_info.tsv

gzip "${CLSTR}"_info.tsv

# Subset the clusters based on their size
N=$(awk '{sum+=$3}END{printf "%.0f\n", sum/NR}' "${CLSTR}"_cl_name_rep_size.tsv)

if [ "$N" -eq "1" ]; then
        let "N = N + 1";
else
        let "N=N";
fi

echo "For the following analyses we are going to use only the clusters with >= ${N} ORFs"
# Clusters with more than N members
join -11 -21 <(awk -v N="${N}" '$3>=N{print $2}' "${CLSTR}"_cl_name_rep_size.tsv | sort -k1,1) <(sort -k1,1 "${CLSTR}".tsv ) > "${CLSTR}"_ge_avg_size.tsv
# OR
#zcat "${CLSTR}"_info.tsv.gz | awk -v N="${N}" '$5>N{print $1"\t"$2"\t"$3}' > "${CLSTR}"_ge_avg_size.tsv

# Singletons
awk '$3=="1"{print $1"\t"$2}' "${CLSTR}"_cl_name_rep_size.tsv > "${DIR}"/"${NAME}"_singletons.tsv

# Clusters with more than 1 member
join -11 -21 <(awk '$2>1{print $1}' "${CLSTR}"_size.tsv | sort -k1,1 --parallel=10 -S25%) <(sort -k1,1 --parallel=10 -S25% "${CLSTR}".tsv ) > "${CLSTR}"_nosingl.tsv
# OR
#zcat "${CLSTR}"_info.tsv.gz | awk '$5>1{print $1"\t"$2"\t"$3}' > "${CLSTR}"_nosingl.tsv
