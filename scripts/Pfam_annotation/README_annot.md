### Functional annotations

"hmmsearch_pfam.sh":
  - input: "data/gene_prediction/TARA_OSD_GOS_malaspina_hmpI-II.fasta.gz"
  - output: "data/pfam_annotation/marine_hmp_pfam31_results.tsv"

"hmmsearch_res_parser.sh":
  - input: "data/pfam_annotation/marine_hmp_pfam31_results.tsv", e-value=1e-05, coverage=0.4
  - output: "data/pfam_annotation/marine_hmp_pfam31_1e-5_c04.tsv"
