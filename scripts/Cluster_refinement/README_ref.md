### Cluster refinement

"refinement.sh" (calling "remove_orfs.sh")

- input:
  - Cluster db "/bioinf/projects/megx/UNKNOWNS/2017_11/clustering/results/marine_hmp_db_03112017_clu_fa"
  - Cluster info table "/bioinf/projects/megx/UNKNOWNS/2017_11/clustering/results/marine_hmp_db_03112017_clu_info.tsv.gz
  - Cluster with spurious and/or shadows ORFs "/bioinf/projects/megx/UNKNOWNS/2017_11/spurious_and_shadows/marine_hmp_info_shadow_spurious.tsv"
  - Set of good cluster from the validation "/bioinf/projects/megx/UNKNOWNS/2017_11/cluster_validation/res_files/good_cl.tsv"
- output:
  - FFINDEX database of refined clusters in "/bioinf/projects/megx/UNKNOWNS/2017_11/refinement/ffindex_files/"
  - Tab separated file containing the refined cluster ids and their ORFs in "/bioinf/projects/megx/UNKNOWNS/2017_11/refinement/refined/"
