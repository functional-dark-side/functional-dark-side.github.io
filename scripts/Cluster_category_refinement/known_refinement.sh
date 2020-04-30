#!/bin/bash

set -x
set -e

DIR=data/cluster_classification/unkn_refinement
SMPL="marine_hmp"
INPUT="${DIR}"/"${SMPL}"_new_kwp_ids.txt
OUTDIR=data/cluster_classification/known_refinement
OUTDIR_CATEG=data/cluster_categories
OUTPUT="${OUTDIR}"/cl_kwp
NSLOTS=${1}
PFAM=data/DBs/pfam
PF_FILES=data/DBs/pfam_files
MPIRUN=mpirun
FFINDEX=ffindex_apply_mpi

STEP="known_refinement"

${PWD}/scripts/E_categories_refinement/categ_ffindex_files.sh "${INPUT}" "${OUTPUT}"_hhbl.ffdata "${STEP}"

mkdir -p ${OUTDIR}/hhr

"${MPIRUN}" -np "${NSLOTS}" "${FFINDEX}" ${OUTDIR}/${SMPL}_kwp_hmm.ff{data,index} -d ${OUTPUT}_hhbl.ffdata -i ${OUTPUT}_hhbl.ffindex \
  -- ${PWD}/scripts/E_categories_refinement/hhparse_kwp.sh "${PFAM}" "${OUTDIR}"/hhr

rm ${OUTDIR}/${SMPL}_kwp_hmm.ff* ${OUTDIR}/${SMPL}_kwp_aln.ff* ${OUTDIR}/${SMPL}_kwp_cons.ff*
rm ${OUTDIR}/${SMPL}_kwp_a3m.ff* ${OUTDIR}/${SMPL}_kwp_cs219.ff* ${OUTDIR}/${SMPL}_kwp_clu*
rm -rf ${OUTDIR}/hhr

# Parsing hhr result files and filtering for hits with probability ≥ 90%
$mysed -e 's/\x0//g' ${OUTPUT}_hhbl.ffdata | sed 's/ /_/g'  > ${OUTPUT}_hhbl.tsv

#Parsing hhblits result files and filtering for hits with probability ≥ 90% and coverage > 0.4, and removing overlapping pfam domains/matches
awk '{print $2,$12,$1,$11,$3,$9,$10,$7,$8}' ${OUTPUT}_kwp_hhbl.tsv | sed 's/ /\t/g' |\
  sort --parallel 16 -S25% -k 3,3 -k 8n -k 9n |\
  perl -e 'while(<>){chomp;@a=split(/\t/,$_);if(($a[-1]-$a[-2])>80){print $_,"\t",($a[-3]-$a[-4])/$a[1],"\n" if $a[4]>=90;}else{print $_,"\t",($a[-3]-$a[-4])/$a[1],"\n" if $a[4]>=90;}}' |\
  awk '$NF>0.4' |\
  awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9}' |\
  perl -e 'while(<>){chomp;@a=split;next if $a[-1]==$a[-2];push(@{$b{$a[2]}},$_);}foreach(sort keys %b){@a=@{$b{$_}};for($i=0;$i<$#a;$i++){@b=split(/\t/,$a[$i]);@c=split(/\t/,$a[$i+1]);$len1=$b[-1]-$b[-2];$len2=$c[-1]-$c[-2];$len3=$b[-1]-$c[-2];if($len3>0 and ($len3/$len1>0.5 or $len3/$len2>0.5)){if($b[4]<$c[4]){splice(@a,$i+1,1);}else{splice(@a,$i,1);}$i=$i-1;}}foreach(@a){print $_."\n";}}' > ${OUTPUT}_filt.tsv

# join with the pfam names and clans
join -11 -21 <(awk '{split($1,a,"."); print a[1],$3,$8,$9}' ${OUTPUT}_filt.tsv | sort -k1,1) \
  <(gzip -dc ${PF_FILES}/Pfam-A.clans.tsv.gz |\
    awk -F '\t' '{print $1"\t"$2"\t"$4}' |\
  awk 'BEGIN { FS = OFS = "\t" } { for(i=1; i<=NF; i++) if($i ~ /^ *$/) $i = "no_clan" }; 1' | sort -k1,1) > ${OUTPUT}_filt_name_acc_clan.tsv

# Multi domain format
awk '{print $2,$3,$4,$5,$1,$6}' ${OUTPUT}_filt_name_acc_clan.tsv |\
  sort -k1,1 -k2,3g |\
  awk 'BEGIN { getline; id=$1; l1=$1;l2=$4;l3=$5;l4=$6;} { if ($1 != id) { print l1,l2,l3,l4; l1=$1;l2=$4;l3=$5;l4=$6;} else { l2=l2"|"$4; l3 =l3"|"$5; l4=l4"|"$6} id=$1; } END { print l1,l2,l3,l4; }' > ${OUTPUT}_filt_name_acc_clan_multi.tsv

rm ${OUTPUT}_filt_name_acc_clan.tsv

if [ -s ${OUTPUT}_filt_name_acc_clan_multi.tsv ]; then
  # Divide the new hits with pfam into DUFs and not DUFs
  R CMD BATCH "--args ${OUTPUT}_filt_name_acc_clan_multi.tsv ${OUTDIR} ${SMPL}" ${PWD}/scripts/E_categories_refinement/pfam_domain_known_ref.r ${OUTDIR}/pfam_domain_known_ref.Rout

  # New Ks clusters
  cat "${DIR}"/"${SMPL}"_new_k_ids.txt \
    <(awk 'NR>1{print $1}' "${OUTDIR}"/"${SMPL}"_new_k_ids_annot.tsv) > "${OUTDIR_CATEG}"/"${SMPL}"_k_ids.txt

  #New GUs clusters
  cat "${DIR}"/"${SMPL}"_new_gu_ids.txt \
    <(awk 'NR>1{print $1}' "${OUTDIR}"/"${SMPL}"_new_gu_ids_annot.tsv) > "${OUTDIR_CATEG}"/"${SMPL}"_gu_ids.txt

  #New KWPs clusters
  join -11 -21 -v1 <(sort -k1,1 "${DIR}"/"${SMPL}"_new_kwp_ids.txt) \
    <(awk '{print $1}' ${OUTPUT}_filt_name_acc_clan_multi.tsv | sort -k1,1) > "${OUTDIR_CATEG}"/"${SMPL}"_kwp_ids.txt

  # EUs remain the same
  cp "${DIR}"/"${SMPL}"_new_eu_ids.txt "${OUTDIR_CATEG}"/"${SMPL}"_eu_ids.txt
else
  # The categories mantain the same clusters
  cp "${DIR}"/"${SMPL}"_new_k_ids.txt "${OUTDIR_CATEG}"/"${SMPL}"_k_ids.txt
  cp "${DIR}"/"${SMPL}"_new_kwp_ids.txt "${OUTDIR_CATEG}"/"${SMPL}"_kwp_ids.txt
  cp "${DIR}"/"${SMPL}"_new_gu_ids.txt "${OUTDIR_CATEG}"/"${SMPL}"_gu_ids.txt
  cp "${DIR}"/"${SMPL}"_new_eu_ids.txt "${OUTDIR_CATEG}"/"${SMPL}"_eu_ids.txt
fi
