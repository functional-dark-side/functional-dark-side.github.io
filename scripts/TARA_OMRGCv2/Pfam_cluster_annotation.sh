#!/bin/bash

set -x
set -e


join -11 -23 <( awk '{print $1,$3,$8,$9}' data/OM-RGC-v2/pfam_annotation/only_omrgc2_clu_pfam_parsed.tsv | sort -k1,1) \
  <(zcat data/DBs/pfam_files/Pfam-A.clans.tsv.gz | \
    awk 'BEGIN{FS=OFS="\t"}{print $1,$2,$4}' | \
  awk 'BEGIN{FS=OFS="\t"}{for(i=1; i<=NF; i++) if($i ~ /^ *$/) $i = "no_clan"};1' | sort -k3,3 ) \
  > data/OM-RGC-v2/annot_and_clust/only_omrgc2_clu_pfam_multi_annot_name_acc_clan.tsv

awk '{print $2"\t"$1"\t"$5"\t"$6"\t"$3"\t"$4}' data/OM-RGC-v2/annot_and_clust/only_omrgc2_clu_pfam_multi_annot_name_acc_clan.tsv > \
  tmp && mv tmp data/OM-RGC-v2/annot_and_clust/only_omrgc2_clu_pfam_multi_annot_name_acc_clan.tsv

sort -k1,1 -k5,6g data/OM-RGC-v2/annot_and_clust/only_omrgc2_clu_pfam_multi_annot_name_acc_clan.tsv | \
  awk '{print $1"\t"$2"\t"$3"\t"$4}' | \
  sort -k1,1 | \
  awk -f scripts/TARA_OMRGCv2/concat_multi_annot.awk > \
  tmpl && mv tmpl data/OM-RGC-v2/annot_and_clust/only_omrgc2_clu_pfam_multi_annot_name_acc_clan.tsv

Rscript scripts/TARA_OMRGCv2/clu_annot.r data/OM-RGC-v2/annot_and_clust/only_omrgc2_clu_pfam_multi_annot_name_acc_clan.tsv \
  data/OM-RGC-v2/annot_and_clust/omrgc2_clusters_nosingl.tsv \
  data/OM-RGC-v2/gene_prediction/OM-RGC_v2_partial_info.tsv \
  data/OM-RGC-v2/annot_and_clust/omrgc2_clusters_annotated.tsv \
  data/OM-RGC-v2/annot_and_clust/omrgc2_clusters_not_annotated.tsv
