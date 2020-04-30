### Validation Results

**Usage:**

```bash
validation_res.sh data/cluster_validation
```

"validation_res.sh" calls "validation_res.r", which produces summary tables and plots.

  - input: Compositional validation results folder "data/cluster_validation/compositional/", functional validation result table "data/cluster_validation/functional/shingl_jacc_val_annot.tsv", set of annotated and not annotated clusters "data/annot_and_clust/marine_hmp_db_03112017_clu_ge10_annot/not_annot.tsv".
  - output:
    - SQLite database "data/cluster_validation/cluster_val_res.sqlite3" containing the following tables: "funct_val", "comp_val", "cluster_val_res".
    - Two summary tables "data/cluster_validation/validation_stats.tsv" and "data/cluster_validation/cluster_validation_res.tsv"
    - A table with the good clusters "data/cluster_validation/good_cl.tsv"
    - Two R objects containing summary plots: "data/cluster_validation/funct_val_plots.rda" and "data/cluster_validation/comp_val_plots.rda".
