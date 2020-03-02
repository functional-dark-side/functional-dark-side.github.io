#!/bin/bash

set -x
set -e


join -11 -23 <( awk '{print $1,$3,$8,$9}' only_omrgc2_clu_pfam_parsed.tsv | sort -k1,1) \
  <(zcat /bioinf/projects/megx/UNKNOWNS/2017_11/DBs/pfam_files/Pfam-A.clans.tsv.gz | \
    awk 'BEGIN{FS=OFS="\t"}{print $1,$2,$4}' | \
  awk 'BEGIN{FS=OFS="\t"}{for(i=1; i<=NF; i++) if($i ~ /^ *$/) $i = "no_clan"};1' | sort -k3,3 ) \
  > only_omrgc2_clu_pfam_multi_annot_name_acc_clan.tsv

awk '{print $2"\t"$1"\t"$5"\t"$6"\t"$3"\t"$4}' only_omrgc2_clu_pfam_multi_annot_name_acc_clan.tsv > \
  tmp && mv tmp only_omrgc2_clu_pfam_multi_annot_name_acc_clan.tsv

sort -k1,1 -k5,6g only_omrgc2_clu_pfam_multi_annot_name_acc_clan.tsv | \
  awk '{print $1"\t"$2"\t"$3"\t"$4}' | \
  sort -k1,1 | \
  awk -f ~/opt/scripts/concat_multi_annot.awk > \
  tmpl && mv tmpl only_omrgc2_clu_pfam_multi_annot_name_acc_clan.tsv

Rscript ~/opt/scripts/clu_annot.r only_omrgc2_clu_pfam_multi_annot_name_acc_clan.tsv \
  omrgc2_clusters_nosingl.tsv \
  /bioinf/projects/megx/UNKNOWNS/chiara/OM-RGC-v2/OM-RGC_v2_partial_info.tsv \
  omrgc2_clusters_annotated.tsv \
  omrgc2_clusters_not_annotated.tsv
