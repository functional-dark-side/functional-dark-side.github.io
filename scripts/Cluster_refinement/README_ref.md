### Cluster refinement

"refinement.sh" (calling "remove_orfs.sh")

- input:
  - Cluster db "data/mmseqs_clustering/marine_hmp_db_03112017_clu_fa"
  - Cluster info table "data/mmseqs_clustering/marine_hmp_db_03112017_clu_info.tsv.gz
  - Cluster with spurious and/or shadows ORFs "data/spurious_and_shadows/marine_hmp_info_shadow_spurious.tsv.gz"
  - Set of good cluster from the validation "data/cluster_validation/good_cl.tsv"
- output:
  - FFINDEX database of refined clusters in "data/cluster_refinement/ffindex_files/"
  - Tab separated file containing the refined cluster ids and their ORFs in "data/cluster_refinement/"
