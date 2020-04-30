### Functional validation scripts usage

Validation of clusters annotated to Pfam domains, in terms of intra-cluster functional homogeneity.

#### R required packages:

```{r}
tidyverse
data.table
proxy
stringr
textreuse
parallel
```

#### Addintional data required (found in this folder)

"files/pfam_shared_all" : a list of pfam terminal or middle domains of the same proteins

#### Usage

```bash
Rscript eval_shingl_jacc.r "data/annot_and_clust/marine_hmp_db_03112017_clu_ge10_annot.tsv" "data/cluster_validation/functional/shingl_jacc_val_annot.tsv"
```

- output: tab-formatted table with 7 fields:
  - <old_repres>  clusters old (MMseqs2) representative
  - <jacc_median_raw> jaccard average similarity value not scaled by the number of annotated members/ORFs in the cluster
  - <jacc_median_sc> jaccard average similarity value scaled by the number of annotated members/ORFs in the cluster
  - <annot_type> Type of annotation (completely homogeneous, Not homogeneous only mono-domain, not homogeneous multi-domain and singl-domain in the same cluster)
  - <prop_type> Proportion of that type of annotation in the cluster
  - <prop_partial> Proportion of partial/complete ORFs in the cluster
  - <annot_categ> Based on the annotation type, 3 different categories HA, MoDA or MuDA
