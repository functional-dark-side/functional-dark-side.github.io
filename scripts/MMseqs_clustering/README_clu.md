### Cascaded clustering

"clustering.sh" (script calling the cascaded clustering program of MMSeqs2):
  - input: "data/gene_prediction/TARA_OSD_GOS_malaspina_hmpI-II.fasta.gz"
  - output: "data/mmseqs_clustering/marine_hmp_db/marine_hmp_db_03112017" & "/data/mmseqs_clustering/marine_hmp_db/marine_hmp_db_03112017_clu"

"clustering_res.sh" & "clustering_info.sh":
  - input: The output DBs from "clustering.sh" and the orfs fasta file
  - output: Files in "/data/mmseqs_clustering/" folder
      - marine_hmp_db_03112017_clu.tsv      (clusters, long format)
      - marine_hmp_db_03112017_clu_wide.tsv (clusters, wide format, first column = representative)
      - marine_hmp_db_03112017_clu_size.tsv (clusters representative - size)
      - marine_hmp_db_03112017_clu_rep.tsv  (clusters representatives)
      - marine_hmp_db_03112017_clu_fa (.index) (cluster sequence DB)
      - marine_hmp_db_03112017_clu_ge10.tsv (clusters with more than 10 members)
      - marine_hmp_db_03112017_singletons.txt (clusters with only one member)
      - marine_hmp_db_03112017_clu_info.tsv (info about cluster ID, size, ORFs length)
