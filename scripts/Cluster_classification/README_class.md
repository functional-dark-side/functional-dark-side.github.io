### Cluster classification

"classification.sh"

1. Unannotated clusters:
  - "cluster_ffindex_files.sh": input="data/cluster_refinement/refined/marine_hmp_refined_noannot_cl_ids.txt"; output="data/cluster_classification/unannotated_cl/marine_hmp_refined_noannot_cl_cons.fasta"
  - "double_search.sh":
    - Search vs Uniref90: input="data/cluster_classification/unannotated_cl/marine_hmp_refined_noannot_cl_cons.fasta" and the Uniref90 DB; output=search hits, which are then parsed with the scripts "hypo_parser.sh" (which requires the awk script "evalue_06_filter.awk" and the file "unknown_grep.tsv").
    - Search vs NCBI nr: input=previous search no-hits; output=search hits, parsed in the same way of the uniref90 hits.
  - general output: set of EUs and KWPs, and the preliminary set of GUs.

1. Annotated clusters:
  - "pfam_domain_architect_ref.r": input="data/cluster_refinement/refined/marine_hmp_refined_annot_cl.tsv"; output="data/cluster_classification/annotated_cl/kept_PF/DUFs" (the first are the Ks and the second are added to the preliminary set of GUs) and "data/cluster_classification/annotated_cl/pfam_domain_architecture.tsv".

- Final output: a first set of cluster categories (Ks,KWPs,GUs,and EUs) that will be further refined through two HMM vs HMM searches.
