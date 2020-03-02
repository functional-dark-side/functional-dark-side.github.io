#!/bin/bash

# Step performed after the cluster validation, to remove:
# 1. bad clusters (≥ 10% bad-aligned ORFs)
# 2. shadow clusters (≥ 30% shadow ORFs)
# 3. single rejected ORFs (shadow, spurious and bad-aligned)

# From the validation results we already have a table with the good clusters:
# good_cl.tsv (in the directory with the validation results)
MD=/bioinf/projects/megx/UNKNOWNS/2017_11
GOOD="${MD}"/cluster_validation/res_files/good_cl.tsv
OUTDIR="${MD}"/refinement

if [[ ! -d "${OUTDIR}" ]]; then
 mkdir -p "${OUTDIR}"
fi

#Cluster db
CLSTR="${MD}"/clustering/results/marine_hmp_db_03112017_clu_fa
# Table with info about shadow and spurious ORFs
# Column: orf - length - cl_name - cl_size - prop_shadow - is.shadow - is.spurious
SHSP="${MD}"/spurious_and_shadows/marine_hmp_info_shadow_spurious.tsv

# Remove the clusters with ≥ 30% shadows
join -11 -21 -v2 <(awk '$5>=0.3 && !seen[$2]++{print $2}' ${SHSP} | sort -k1,1) \
  <(awk '{print $1}' ${GOOD} | sort -k1,1) > ${OUTDIR}/marine_hmp_good_less30_cl.txt

# retrieve the subdb with the ORFs opf these clusters
~/MMseqs2/bin/mmseqs createsubdb ${OUTDIR}/marine_hmp_good_less30_cl.txt ${CLSTR} ${OUTDIR}/marine_hmp_kept_less30_clu_fa

# retrieve the bad-aligned sequences in these clusters
#awk '$1!="cl_name"' ${OUTDIR}/marine_hmp_good_less30_cl.txt | parallel --progress -j 20 cat "${MD}"/cluster_validation/compositional/results/{}_rejected.txt > ${OUTDIR}/marine_hmp_good_less30_cl_rejected.txt
# Or if we have instaed the file with all the rejected sequences
# (/bioinf/projects/megx/UNKNOWNS/2017_11/cluster_validation/res_files/rejected_seqs_cl.tsv)
join -11 -21 <(sort -k1,1 ${OUTDIR}/marine_hmp_good_less30_cl.txt) \
  <(sort -k1,1 ${MD}/cluster_validation/res_files/rejected_seqs_cl.tsv) > ${OUTDIR}/marine_hmp_good_less30_cl_rejected.txt

# Add the bad-aligned sequences to the spurious and shadows
cat ${OUTDIR}/marine_hmp_good_less30_cl_rejected.txt <(awk '$5<0.3 && $6!="FALSE" || $5<0.3 && $7!="FALSE"{print $1}' ${SHSP}) > ${OUTDIR}/marine_hmp_orfs_to_remove.txt

# add cluster membership
join -11 -21 <(sort ${OUTDIR}/${SMPL}_orfs_to_remove.txt) \
  <(awk '{print $2,$1}' <(zcat ${PWD}/${SMPL}/clustering/${SMPL}_clu_info.tsv.gz) | sort -k1,1) > ${OUTDIR}/marine_hmp_orfs_to_remove_cl.tsv

# remove the single orfs from the clusters with less than 10% bad-aligned ORFs and less than 30% shadows.
/bioinf/software/openmpi/openmpi-1.8.1/bin/mpirun -np 12 /home/cvanni/opt/ffindex_mg_updt/bin/ffindex_apply_mpi \
  ${OUTDIR}/marine_hmp_kept_less30_clu_fa ${OUTDIR}/marine_hmp_kept_less30_clu_fa.index \
  -i ${OUTDIR}/ffindex_files/marine_hmp_refined_cl_fa.ffindex -d ${OUTDIR}/ffindex_files/marine_hmp_refined_cl_fa.ffdata -- ${PWD}/scripts/C_refinement/remove_orfs.sh ${OUTDIR}/marine_hmp_orfs_to_remove_cl.tsv

# From the refined clusters select the annotated and the not annotated for the following classification steps

# Create tables with new seqs and new clusters for some stats and checking the numbers
join -11 -22 <(awk '{print $1}' ${OUTDIR}/ffindex_files/marine_hmp_refined_cl_fa.ffindex | sort -k1,1) \
 <(awk '{print $1,$2}' ${SHSP} | sort -k2,2) > ${OUTDIR}/tmp

join -12 -21 -v1 <(sort -k2,2 ${OUTDIR}/tmp) \
  <(sort -k1,1 ${OUTDIR}/marine_hmp_orfs_to_remove.txt) > ${OUTDIR}/refined/marine_hmp_refined_cl.tsv

rm ${OUTDIR}/tmp

# annotated (check those left with no-annotated sequences) --> join with file with all annotated clusters..for annotations

join -11 -21 <(sort -k1,1 ${OUTDIR}/refined/marine_hmp_refined_cl.tsv) \
  <(awk '{print $2,$1}' ${MD}/annot_and_clust/marine_hmp_clu_ge10_annot.tsv \
  |  sort -k1,1) > ${OUTDIR}/refined/marine_hmp_refined_annot_cl.tsv

join -11 -21 <( awk '{print $3,$2}' ${OUTDIR}/refined/marine_hmp_refined_annot_cl.tsv | sort -k1,1) \
 <(awk '{print $1,$2,$3}' ${MD}/annot_and_clust/marine_hmp_clu_ge10_annot.tsv \
  | sort -k1,1) > ${OUTDIR}/refined/marine_hmp_refined_all_annot_cl.tsv

#find clusters with no annotated members
sort -k1,1 ${OUTDIR}/refined/marine_hmp_refined_all_annot_cl.tsv \
  | awk '!seen[$2,$4]++{print $2,$4}' \
  | awk 'BEGIN{ getline; id=$1;l1=$1;l2=$2;} { if ($1 != id) { print l1,l2; l1=$1;l2=$2;} else { l2=l2"|"$2;} id=$1;} END { print l1,l2;}' \
  | grep -v '|' | awk '$2=="NA"{print $1}' > ${OUTDIR}/marine_hmp_new_unkn_cl.txt

if [[ ! -s ${OUTDIR}/marine_hmp_new_unkn_cl.txt ]]; then
        #move the clusters left with no annotated member to the not annotated
        join -12 -21 -v1 <(awk '!seen[$1,$2,$3]++' ${OUTDIR}/refined/marine_hmp_refined_all_annot_cl.tsv | sort -k2,2) \
          <(sort ${OUTDIR}/marine_hmp_new_unkn_cl.txt) > ${OUTDIR}/refined/marine_hmp_refined_annot_cl.tsv

        join -12 -21 <(awk '!seen[$1,$2,$3]++' ${OUTDIR}/refined/marine_hmp_refined_annot_cl.tsv | sort -k2,2) \
          <(sort ${OUTDIR}/marine_hmp_new_unkn_cl.txt) > ${OUTDIR}/refined/marine_hmp_refined_noannot_cl.tsv

        # not annotated
        join -12 -21 <(sort -k2,2 ${OUTDIR}/refined/marine_hmp_refined_cl.tsv) \
        <(awk '$4=="noannot"{print $1,$2}' ${GOOD} | sort -k1,1) >> ${OUTDIR}/refined/marine_hmp_refined_noannot_cl.tsv

else
        # not annotated
        join -12 -21 <(sort -k2,2 ${OUTDIR}/refined/marine_hmp_refined_cl.tsv) \
        <(awk '$4=="noannot"{print $1,$2}' ${GOOD} | sort -k1,1) > ${OUTDIR}/refined/marine_hmp_refined_noannot_cl.tsv
fi

# Uisng the cluster ids retrieve the two sub database for annotated clusters and not
ln -s ${OUTDIR}/ffindex_files/marine_hmp_refined_cl_fa.ffindex ${OUTDIR}/ffindex_files/marine_hmp_refined_cl_fa.index
ln -s ${OUTDIR}/ffindex_files/marine_hmp_refined_cl_fa.ffdata ${OUTDIR}/ffindex_files/marine_hmp_refined_cl_fa

~/MMseqs2/bin/mmseqs createsubdb <(awk '!seen[$1]++{print $1}' ${OUTDIR}/refined/marine_hmp_refined_annot_cl.tsv) ${OUTDIR}/ffindex_files/marine_hmp_refined_cl_fa ${OUTDIR}/ffindex_files/marine_hmp_refined_cl_annot_fa

~/MMseqs2/bin/mmseqs createsubdb <(awk '!seen[$1]++{print $1}' ${OUTDIR}/refined/marine_hmp_refined_noannot_cl.tsv) ${OUTDIR}/ffindex_files/marine_hmp_refined_cl_fa ${OUTDIR}/ffindex_files/marine_hmp_refined_cl_noannot_fa
