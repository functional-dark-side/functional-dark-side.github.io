#!/bin/bash

set -x
set -e

# Detection of spurious ORFs
FA="${1}" #ORFs fasta file in /bioinf/projects/megx/UNKNOWNS/2017_11/DATA/ORFs/ORFs_fasta/TARA_OSD_GOS_malaspina_hmp_orf.fa.gz
ADB=/bioinf/projects/megx/UNKNOWNS/chiara/pipeline/DB/Antifam.hmm
OUTPUT=/bioinf/projects/megx/UNKNOWNS/2017_11/spurious_and_shadows/marine_hmp_info_shadow_spurious.tsv
OUTDIR=$(dirname "${OUTPUT}")

# Collect AntiFam keys/names
grep '^NAME' "${ADB}"/AntiFam.hmm | awk '{print $2}' > "${ADB}"/antifam_keys

# Prepare the DB
/bioinf/software/hmmer/hmmer-3.1b2/bin/hmmpress "${ADB}"/AntiFam.hmm

# Run hmmsearch
cat "${ADB}"/antifam_keys | parallel --progress -j 32 ${PWD}/scripts/hmm_antifam.sh {} ${ADB} ${FA} ${OUTDIR}\;

# Parse the results
cat ${OUTDIR}/antifam_res/*.out \
	| grep -v '^#' \
	| awk '$13<=1e-05 && !seen[$1]++{print $1}' > ${OUTDIR}/spurious_orfs_e05.txt

rm "${ADB}"/antifam_hmm.Spurious_ORF_* "${ADB}"/AntiFam.hmm.*

# Detection of shadow ORFs
# for our data set we divided the orfs by project, so this needs to be run for all projects
# ex:/bioinf/projects/megx/UNKNOWNS/2017_11/DATA/ORFs/orfs_x_projects/osd_orfs.txt.gz
grep '^>' ${FA} > ${OUTDIR}/orfs.txt
~/R-3.4.2/bin/Rscript --vanilla ${PWD}/scripts/A_spur_shadow/shadow_orfs.r ${OUTDIR}/orfs.txt ${OUTDIR}

# Parsing of results
#Table containing cl_name orf_name cl_size orf_length
INFO=/bioinf/projects/megx/UNKNOWNS/2017_11/clustering/results/marine_hmp_db_03112017_clu_info.tsv.gz

#in case we have multiple result tables, one for each projects
# concatenate them together:
# cat ${OUTDIR}/*_shadow_orfs.tsv > ${OUTDIR}/shadow_orfs.tsv
RES=${OUTDIR}/shadow_orfs.tsv
# Add cluster name size and ORF length
join -12 -22 <(sort -k2,2 --parallel 10 -S20% ${RES}) \
	<(zcat ${INFO} | sort -k2,2 --parallel 20 -S25%) > ${OUTDIR}/shadow1.tsv

awk '{print $6,$7,$8,$9,$1,$11,$12,$13,$3,$4,$5,$2,$10}' ${OUTDIR}/shadow1.tsv > ${OUTDIR}/tmp && mv ${OUTDIR}/tmp ${OUTDIR}/shadow1.tsv

join -11 -22 <(sort -k1,1 --parallel 10 -S20% ${OUTDIR}/shadow1.tsv) \
	<(zcat ${INFO} | sort -k2,2 --parallel 20 -S25%) > ${OUTDIR}/shadow2.tsv

awk 'BEGIN{FS=" ";OFS="\t"}{print $1,$14,$15,$16,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13}' ${OUTDIR}/shadow2.tsv > ${OUTDIR}/shadow_parsed.tsv

rm ${OUTDIR}/shadow1.tsv ${OUTDIR}/shadow2.tsv

# always an ORFs is in the shadow of another, we first keep the longest of the pair,
# then if the length is the same we kepp the one in the bigger cluster
awk 'BEGIN{FS=OFS="\t"}{if($4>$11) print $8,"TRUE"; else if($11>$4) print $1,"TRUE"; else if($4==$11 && $3<$10) print1; else if($4==$11 && $3>$10) print $1"\t""TRUE";}' ${OUTDIR}/shadow_parsed.tsv > ${OUTDIR}/only_shadows.tsv
# If the length is the same and the cluster size also we tag/flag both ORFs as shadows
awk 'BEGIN{FS=OFS="\t"}{if($4==$11 && $3==$10) print $1,"BOTH";}' ${OUTDIR}/shadow_parsed.tsv >> ${OUTDIR}/only_shadows.tsv
awk 'BEGIN{FS=OFS="\t"}{if($4==$11 && $3==$10) print $8,"BOTH";}' ${OUTDIR}/shadow_parsed.tsv >> ${OUTDIR}/only_shadows.tsv

join -12 -21 -a1 <(zcat ${INFO} | sort -k2,2 --parallel 20 -S25%) \
  <(sort -k1,1 ${OUTDIR}/only_shadows.tsv ) > ${OUTDIR}/orfs_info_shadow.tsv

awk '{if($5=="TRUE" || $5=="BOTH") print $1,$2,$3,$4,$5; else print $1,$2,$3,$4,"FALSE";}' ${OUTDIR}/orfs_info_shadow.tsv > ${OUTDIR}/tmp && mv ${OUTDIR}/tmp ${OUTDIR}/orfs_info_shadow.tsv
rm ${OUTDIR}/shadow_parsed.tsv ${OUTDIR}/only_shadows.tsv

# Add spurious information
join -11 -21 -a1 <(sort -k1,1 ${OUTDIR}/orfs_info_shadow.tsv) \
	<(awk '{print $1"\t""TRUE"}' ${OUTDIR}/spurious_orfs_e05.txt | sort -k1,1) > ${OUTDIR}/tmp

awk '{if($6=="TRUE") print $1,$2,$3,$4,$5,$6; else print $1,$2,$3,$4,$5,"FALSE";}' ${OUTDIR}/tmp \
	| awk '{print $1,$2,$4,$5,$3,$6}' > ${OUTPUT}

# calculate proportion of shadows per cluster
grep 'TRUE\|BOTH' ${OUTDIR}/orfs_info_shadow.tsv \
	| awk '{a[$2"\t"$3]+=1}END{for(i in a) print i,a[i]}' \
	| awk '{print $1,$2,$3/$2}' > ${OUTDIR}/prop_shadow_cluster.tsv

# join with the whole table on cluster ID
join -13 -21 -a1 <(sort -k3,3 --parallel 20 -S25% ${OUTPUT}) \
	<(sort -k1,1 ${OUTDIR}/prop_shadow_cluster.tsv) > ${OUTDIR}/tmp

# Add 0 for the clusters with no shadows
# order column: orf - length - cl_name - cl_size - prop_shadow - is.shadow - is.spurious
awk 'BEGIN { FS =" "; OFS = "\t" } { for(i=1; i<=7; i++) if($i ~ /^ *$/) $i = 0 }; 1' ${OUTDIR}/tmp \
	| awk '{print $2"\t"$3"\t"$1"\t"$5"\t"$7"\t"$4"\t"$6}' > ${OUTPUT}

rm ${OUTDIR}/orfs.txt ${OUTDIR}/tmp ${OUTDIR}/orfs_info_shadow.tsv ${OUTDIR}/prop_shadow_cluster.tsv
