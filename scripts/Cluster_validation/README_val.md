### Validation Results

**Usage:**

```bash
validation_res.sh /bioinf/projects/megx/UNKNOWNS/2017_11/cluster_validation
```

"validation_res.sh" calls "validation_res.r", which produces summary tables and plots.

  - input: Compositional validation results folder "/bioinf/projects/megx/UNKNOWNS/2017_11/cluster_validation/compositional/results", functional validation result table "/bioinf/projects/megx/UNKNOWNS/2017_11/cluster_validation/functional/shingl_jacc_val_annot.tsv", set of annotated and not annotated clusters "/bioinf/projects/megx/UNKNOWNS/2017_11/annot_and_clust/marine_hmp_db_03112017_clu_ge10_annot/not_annot.tsv".
  - output:
    - SQLite database "/bioinf/projects/megx/UNKNOWNS/2017_11/cluster_validation/res_files/cluster_val_res.sqlite3" containing the following tables: "funct_val", "comp_val", "cluster_val_res".
    - Two summary tables "/bioinf/projects/megx/UNKNOWNS/2017_11/cluster_validation/res_files/validation_stats.tsv" and "/bioinf/projects/megx/UNKNOWNS/2017_11/cluster_validation/res_files/cluster_validation_res.tsv"
    - A table with the good clusters "/bioinf/projects/megx/UNKNOWNS/2017_11/cluster_validation/res_files/good_cl.tsv"
    - Two R objects containing summary plots: "/bioinf/projects/megx/UNKNOWNS/2017_11/cluster_validation/res_files/funct_val_plots.rda" and "/bioinf/projects/megx/UNKNOWNS/2017_11/cluster_validation/res_files/comp_val_plots.rda".
