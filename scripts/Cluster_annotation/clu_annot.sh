#!/bin/bash

#Usage clusters_PFAMation.sh <cluster output> <annotation parsed output>

CL_RES=${PWD}/"${1}"
CLSTR=$(basename "${CL_RES}")
PF_RES=${PWD}/"${2}"
PFAM=$(basename "${PF_RES}")
filesPF=/bioinf/projects/megx/UNKNOWNS/2017_11/Pfam_annotation/pfam_files
D=$(dirname "${1}")
DD=$(dirname "${DIR}")
OUTDIR="${DD}"/annot_and_clust

if [[ ! -d "${OUTDIR}" ]]; then
  mkdir -p "${OUTDIR}"
fi

printf "###############################\n"
printf "#### Multi-domainPfam annotations and clan info on the ORFs\n"
printf "###############################\n"

# Retrieve clan info for the parsed results from the hmmersearch against the Pfam v31 database
join -11 -23 <( awk '{print $1"\t"$3"\t"$8"\t"$9}' "${PF_RES}" | sort -k1,1 --parallel=10 -S25%) \
	<( zcat "${filesPF}"/Pfam-A.clans.tsv.gz \
        | awk -F '\t' '{print $1"\t"$2"\t"$4}' \
	| awk 'BEGIN { FS = OFS = "\t" } { for(i=1; i<=NF; i++) if($i ~ /^ *$/) $i = "no_clan" }; 1' \
	| sort -k3,3 --parallel=10 -S25% ) > "${OUTDIR}"/"${PFAM}"_name_acc_clan

# Sort columns
awk '{print $2,$1,$5,$6,$3,$4}' "${OUTDIR}"/"${PFAM}"_name_acc_clan \
	| sed 's/ /\t/g' > tmp && mv tmp "${OUTDIR}"/"${PFAM}"_name_acc_clan

# Multiple annotation on the same line, separated by “|” (the annotations were ordered first by alignment position)
sort -k1,1 -k5,6g "${OUTDIR}"/"${PFAM}"_name_acc_clan \
	| awk '{print $1"\t"$2"\t"$3"\t"$4}' \
	| sort -k1,1 --parallel=10 -S25% \
	| awk 'BEGIN { getline; id=$1; l1=$1;l2=$2;l3=$3;l4=$4;} { if ($1 != id) { print l1,l2,l3,l4; l1=$1;l2=$2;l3=$3;l4=$4;} else { l2=l2"|"$2; l3 =l3"|"$3; l4=l4"|"$4} id=$1; } END { print l1,l2,l3,l4; }' > "${OUTDIR}"/"${PFAM}"_name_acc_clan_multi.tsv

rm "${OUTDIR}"/"${PFAM}"_name_acc_clan

printf "###############################\n"
printf "#### Cluster representatives Pfam annotations\n"
printf "###############################\n"

# Annotated representatives
join -11 -21 <(sort -k1,1 --parallel=10 -S25% "${CL_RES}"_rep.tsv ) \
	<( sort -k1,1 --parallel=10 -S25% "${OUTDIR}"/"${PFAM}"_name_acc_clan_multi.tsv ) \
	| gzip > "${OUTDIR}"/"${CLSTR}"_rep_annot.tsv.gz

# Not-annotated representatives
join -11 -21 -v1 <( sort -k1,1 --parallel=10 -S25% "${CL_RES}"_rep.tsv ) \
	<( zcat "${OUTDIR}"/"${CLSTR}"_rep_annot.tsv.gz | sort -k1,1 --parallel=10 -S25% ) \
	| gzip > "${OUTDIR}"/"${CLSTR}"_rep_no_annot.tsv.gz

# Cluster >= 10 members annotated representatives
join -11 -21 <( zcat "${OUTDIR}"/"${CLSTR}"_rep_annot.tsv.gz \
	| sort -k1,1 --parallel=10 -S25% ) \
	<(awk '!seen[$1]++{print $1}' "${CL_RES}"_ge10.tsv \
	| sort -k1,1 --parallel=10 -S25%) > "${OUTDIR}"/"${CLSTR}"_rep_annot_ge10.tsv

printf "###############################\n"
printf "#### Cluster members annotations \n"
printf "###############################\n"

# Annotated members
join -12 -21 <(sort -k2,2 --parallel=10 -S25% "${CL_RES}"_ge10.tsv ) \
	<(sort -k1,1 --parallel=10 -S25% "${OUTDIR}"/"${PFAM}"_name_acc_clan_multi.tsv ) > "${OUTDIR}"/"${CLSTR}"_ge10_annot_memb.tsv

# Keeping all members
join -12 -21 -a1 <(sort -k2,2 --parallel=10 -S25% "${CL_RES}"_ge10.tsv ) \
	<(sort -k1,1 --parallel=10 -S25% "${OUTDIR}"/"${PFAM}"_name_acc_clan_multi.tsv  ) > "${OUTDIR}"/"${CLSTR}"_ge10_cl_annot.tsv

# Add "NAs" for the not annotated orfs
max=$(awk '{print NF}' "${OUTDIR}"/"${CLSTR}"_ge10_cl_annot.tsv | sort -nu | tail -n1)
awk -v max=$max '{for (i=NF+1; i<=max; i++) $i="NA"; print}' "${OUTDIR}"/"${CLSTR}"_ge10_cl_annot.tsv > tmp && mv tmp "${OUTDIR}"/"${CLSTR}"_ge10_cl_annot.tsv

# Clusters with annotated representatives
#join -11 -22 <( sort -k1,1 --parallel=10 -S25% "${OUTDIR}"/"${CLSTR}"_rep_annot_ge10.tsv ) <(sort -k2,2 --parallel=10 -S25% "${OUTDIR}"/"${CLSTR}"_ge10_cl_annot.tsv ) > "${OUTDIR}"/"${CLSTR}"_ge10_annot_rep.tsv

# Any annotated member
join -11 -22 <( awk '!seen[$2]++{print $2}' "${OUTDIR}"/"${CLSTR}"_ge10_annot_memb.tsv \
	| sort -k1,1 --parallel=10 -S25%) \
	<( sort -k2,2 --parallel=10 -S25% "${OUTDIR}"/"${CLSTR}"_ge10_cl_annot.tsv ) > "${OUTDIR}"/"${CLSTR}"_ge10_annot.tsv

# Clusters with some annotated member (but not-annotated representatives)
#join -11 -21 -v 1 <(sort -k1,1 --parallel=10 -S25% "${OUTDIR}"/"${CLSTR}"_ge10_any_annot.tsv ) <(sort -k1,1 --parallel=10 -S25% "${OUTDIR}"/"${CLSTR}"_rep_annot_ge10.tsv ) > "${OUTDIR}"/"${CLSTR}"_ge10_not_annot_rep.tsv

# Not-annotated clusters
join -v2 <(awk '!seen[$1]++{print $1}' "${OUTDIR}"/"${CLSTR}"_ge10_annot.tsv \
	| sort -k1,1 --parallel=10 -S25%) \
	<(zcat "${OUTDIR}"/"${CLSTR}"_rep_no_annot.tsv.gz \
	| sort -k1,1 --parallel=10 -S25% ) > "${OUTDIR}"/"${CLSTR}"_ge10_rep_not_annot.tsv

join -11 -22 <(sort -k1,1 --parallel=10 -S25% "${OUTDIR}"/"${CLSTR}"_ge10_rep_not_annot.tsv ) \
	<(sort -k2,2 --parallel=10 -S25% "${OUTDIR}"/"${CLSTR}"_ge10_cl_annot.tsv ) > "${OUTDIR}"/"${CLSTR}"_ge10_not_annot.tsv

rm -f "${OUTDIR}"/"${CLSTR}"_ge10_rep_not_annot.tsv
rm -f "${OUTDIR}"/"${CLSTR}"_ge10_annot_memb.tsv

gzip "${OUTDIR}"/"${CLSTR}"_ge10_cl_annot.tsv

printf "###############################\n"
printf "#### Add info about ORFs completness (some ORFs are fragments/partial) \n"
printf "###############################\n"

# From the gene prediction with Prodigal with obtain an indicator of if a gene runs off the edge of a sequence or into a gap.
# A "0" indicates the gene has a true boundary (a start or a stop),
#whereas a "1" indicates the gene is "unfinished" at that edge (i.e. a partial gene).
#For example, "01" means a gene is partial at the right boundary, "11" indicates both edges are incomplete,
# and "00" indicates a complete gene with a start and stop codon.

# These info (both for the marine data set and the HMP one) are stored in
#/bioinf/projects/megx/UNKNOWNS/2017_11/DATA/ORFs/marine_hmp_orf_partial_info.tsv.gz

# Clusters with annotated representatives
join -12 -21 <(sort -k2,2 --parallel=20 -S25% "${OUTDIR}"/"${CLSTR}"_ge10_annot.tsv) \
	<(zcat /bioinf/projects/megx/UNKNOWNS/2017_11/DATA/ORFs/marine_hmp_orf_partial_info.tsv.gz \
	| sort --parallel=20 -S25% -k1,1) > tmp1

awk '!seen[$1]++{print $2,$1,$3,$4,$5,$6}' tmp1 | sed 's/ /\t/g' > "${OUTDIR}"/"${CLSTR}"_ge10_annot.tsv

# Clusters with some annotated member (but not-annotated representatives)
#join -12 -21 <( sort --parallel=20 -S25% -k2,2 "${OUTDIR}"/"${CLSTR}"_ge10_not_annot_rep.tsv) <(zcat /bioinf/projects/megx/UNKNOWNS/2017_11/DATA/ORFs/marine_hmp_orf_partial_info.tsv.gz | sort --parallel=20 -S25% -k1,1)> tmp1

#awk '!seen[$1]++{print $2,$1,$3,$4,$5,$6}' tmp1 | sed 's/ /\t/g' > "${OUTDIR}"/"${CLSTR}"_ge10_not_annot_rep.tsv

# Not-annotated clusters
join -12 -21 <( sort --parallel=20 -S25% -k2,2 "${OUTDIR}"/"${CLSTR}"_ge10_not_annot.tsv) \
	<(zcat /bioinf/projects/megx/UNKNOWNS/2017_11/DATA/ORFs/marine_hmp_orf_partial_info.tsv.gz \
	| sort --parallel=20 -S25% -k1,1)> tmp2

awk '!seen[$1]++{print $2,$1,$3,$4,$5,$6}' tmp2 | sed 's/ /\t/g' > "${OUTDIR}"/"${CLSTR}"_ge10_not_annot.tsv

rm tmp1 tmp2
