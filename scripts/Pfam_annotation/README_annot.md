### Functional annotations

"hmmsearch_pfam.sh":
  - input: "/bioinf/projects/megx/UNKNOWNS/2017_11/DATA/ORFs/ORFs_fasta/TARA_OSD_GOS_malaspina_hmpI-II.fasta.gz"
  - output: "/bioinf/projects/megx/UNKNOWNS/2017_11/Pfam_annotation/results/marine_hmp_pfam31_results.tsv"

"hmmsearch_res_parser.sh":
  - input: "/bioinf/projects/megx/UNKNOWNS/2017_11/Pfam_annotation/results/marine_hmp_pfam31_results.tsv", e-value=1e-05, coverage=0.4
  - output: "/bioinf/projects/megx/UNKNOWNS/2017_11/Pfam_annotation/results/marine_hmp_pfam31_1e-5_c04.tsv"
