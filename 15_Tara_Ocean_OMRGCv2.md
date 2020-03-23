---
layout: page
title: Integration of the TARA Oceans OM-RGC-v2
---

<h2 class="section-heading  text-primary">Analysis of the TARA Ocean OM-RGC-v2 and integration with the MG-GTDB cluster database</h2>

OM-RGC-v2 reference paper: "Gene Expression Changes and Community Turnover Differentially Shape the Global Ocean Metatranscriptome"
<https://www.sciencedirect.com/science/article/pii/S009286741931164X>

We integrated the second version of the TARA Ocean Microbial Reference Gene Catalog (OM-RGC) [[1]](#1) in our combined cluster dataset (MG+GTDB).

The OM-RGC.v2 contains 46,775,154 non-redundant genes [[1]](#1), 39% classified as unknowns.
It can be downloaded from the <https://www.ocean-microbiome.org/> portal.

<h3 class="section-heading  text-primary">Methods</h3>

1.  Incremental clustering to integrate the catalog genes in our dataset
2.  Process the genes not found in our cluster dataset through our pipeline steps
3.  Check correspondence between their "unknowns" and ours
4.  Use their transcriptomics information for exploratory analyses of the whole dataset

**Scripts and description:** To update the cluster DB with the new sequences from the TARA OM-RGC-v2 we first combine all the sequences together using the script [combine_seq_dbs.sh](scripts/TARA_OMRGCv2/combine_seq_dbs.sh), we then integrate the gene catalog via incremental clustering using the script [omrgc2_clu_update.sh](scripts/TARA_OMRGCv2/omrgc2_clu_update.sh). The results were parsed using the script [omrgc2_clu_updt_res.sh](scripts/TARA_OMRGCv2/omrgc2_clu_updt_res.sh). The new clusters (only-OMRGC2) were processed through the workflow and categorised.
(The compositional validation was run using: [run_comp_valid.sh](scripts/TARA_OMRGCv2/run_comp_valid.sh) and [compositional_validation.sh](scripts/TARA_OMRGCv2/compositional_validation.sh). Ran in the deNBI cloud.)

<h3 class="section-heading  text-primary">Results</h3>

<h4 class="section-heading  text-primary">1. Incremental clustering</h4>

Of the 46,775,154 OM-RGC.v2 genes: the large majority,  40,187,653 (86%), was found into the MG-GTDB clusters and the remaioning 6,587,501 (14%) were clustered into 4,284,357 new clusters.

<div class="img_container" style="width:60%; margin:2em auto;">

*New integrated cluster DB (MG+GTDB+OMRGC2):*

| Genes       | Clusters   |
| ----------- | ---------- |
| 462,746,896 | 44,707,906 |

| Singletons | Cluster ≥ 2genes |
| ---------- | ---------------- |
| 25,254,004 | 19,453,902       |

</div>

<div class="img_container" style="width:80%; margin:2em auto;">

|          | MG-GTDB     | MG-GTDB-OMRGC2 | OMRGC2    |
| -------- | ----------- | -------------- | --------- |
| Clusters | 32,666,889  | 7,756,660      | 4,284,357 |
| ORFs     | 158,585,789 | 297,573,606    | 6,587,501 |

</div>

**Only-OMRGC2 - cluster DB**

The ~4M of only-OMRGC2 clusters are constituted for the 83% by singletons and we retrieved only 705,215 clusters with more than one gene. Numbers are reported in the table below:

<div class="img_container" style="width:60%; margin:2em auto;">

*Only-OMRGC2 clustering results*

|          | Clusters        | Singletons      | Total     |
| -------- | --------------- | --------------- | --------- |
| Clusters | 705,215 (17%)   | 3,579,142 (83%) | 4,284,357 |
| ORFs     | 3,008,359 (46%) | 3,579,142 (54%) | 6,587,501 |

</div>


<h4 class="section-heading  text-primary">2. Only-OMRGC2 cluster DB processing through the workflow</h4>

-   *Pfam annotation*

Overall we were able to annotate to a Pfam protein domain family only 19% of the ORFs in the only-OMRGC2 clusters.

<div class="img_container" style="width:60%; margin:2em auto;">

*Only-OMRGC2 Pfam annotation results*

| Annotated | Not annotated | Total     |
| --------- | ------------- | --------- |
| 578,241   | 2,430,118     | 3,008,359 |

</div>

The distribution of the Pfam annotation in the cluster resulted in 15% annotated clusters and 85% not annotated clusters. The cluster and ORFs numbers are reported in the following table:

<div class="img_container" style="width:60%; margin:2em auto;">

*Pfam annotations in the clusters*

|          | Annotated clusters | Not annotated clusters |
| -------- | ------------------ | ---------------------- |
| Clusters | 108,931            | 596,284                |
| ORFs     | 752,293            | 2,256,066              |

</div>

-   *Cluster validation*

The cluster validation results showed a general good cluster quality, both in terms of functional and compositional intra-cluster homogeneity. Only 1% of the clusters were classified as "bad".

The proportion of "rejected" ORFs defining a cluster as "BAD" was found at 0.12 "bad-aligned"/"rejected" ORFs per cluster.

<div class="img_container" style="width:70%; margin:2em auto;">

<img alt="omrgc2_val_rej_non_homolog.png" src="/img/omrgc2_val_rej_non_homolog.png" width="" height="" >

*Proportion of bad-aligned/non-homologous ORFs detected within each cluster MSA. Distribution of observed values compared with those of the Broken-stick model. The threshold was determined at 12% non-homologous ORFs per cluster.*

</div>

<div class="img_container" style="width:90%; margin:2em auto;">

*Cluster validation result summary:*

|          | Original  |   GOOD    |  BAD   | Compos-GOOD | Compos-BAD | Funct-GOOD | Funct-BAD |
| -------- |:---------:|:---------:|:------:|:-----------:|:----------:|:----------:|:---------:|
| Clusters |  705,215  |  699,001  | 6,214  |   699,851   |   5,364    |  108,069   |    862    |
| ORFs     | 3,008,359 | 2,966,137 | 42,222 |  2,972,704  |   35,655   |  745,647   |   6,646   |

</div>

<div class="img_container" style="width:60%; margin:2em auto;">

*Good clusters set*

| GOOD clusters | annotated | not annotated |
|:-------------:|:---------:|:-------------:|
|    699,001    |  107,016  |    591,985    |

</div>

-   *Cluster classification*

<h5 class="section-heading  text-primary">Unknown classification - double database search</h5>

<h6 class="section-heading  text-primary">Good not annotated cluster consensus vs Uniref90</h6>

Of the 591,985 good not-annotated clusters 48% were found in the UniRef90 database. Of these hits, 68% are labeled as "hypothetical" proteins.

<div class="img_container" style="width:70%; margin:2em auto;">

*Cluster consensus vs UniRef90 results and hits functional classification*

|  Hits   | Hypothetical | Characterised | Nohits  |
|:-------:|:------------:|:-------------:|:-------:|
| 283,212 |   191,620    |    91,592     | 308,773 |

</div>

<h6 class="section-heading  text-primary">Uniref90-nohits vs NCBI nr</h6>

The 308,773 Uniref90-nohit consensus were searched against the NCBI-nr database, and only the 0.3% reported a match. Of the 931 hits 60% are annotated to proteins labeled as "hypothetical".

<div class="img_container" style="width:70%; margin:2em auto;">

*UniRef90-nohits vs NCBI-nr results and hits functional classification*

| Hits | Hypothetical | Characterised | Nohits  |
|:----:|:------------:|:-------------:|:-------:|
| 931  |     561      |      370      | 307,842 |

</div>

<h5 class="section-heading  text-primary">Known classification - cluster consensus domain architectures</h5>

The annotated clusters were divided into 98,569 (92%) clusters annotated to Pfam domains of known function (PFs) and 8,447 clusters annotated to Pfam domains of unknown function (DUFs).

<div class="img_container" style="width:50%; margin:2em auto;">

*Cluster domain architecture classification*

|  PFs   | DUFs  |
|:------:|:-----:|
| 98,569 | 8,447 |

</div>

<div class="img_container" style="width:90%; margin:2em auto;">

*Cluster classification categories*

|          |    K    |   KWP   |   GU    |   EU    |
| -------- |:-------:|:-------:|:-------:|:-------:|
| Clusters | 98,569  | 91,962  | 200,628 | 307,842 |
| ORFs     | 692,725 | 387,752 | 895,082 | 990,578 |

</div>

-   *Cluster category refinement*

Only 2% of the EU clusters were found to have distant homologies to Uniclust proteins, and the majority of these were found to be homologs of characterised proteins.

<div class="img_container" style="width:90%; margin:2em auto;">

*Unknown refinement steps*

|                 |   K    |  KWP   |   GU    |   EU    |
| --------------- |:------:|:------:|:-------:|:-------:|
| Clusters-pre    | 98,569 | 91,962 | 200,628 | 307,842 |
| Refinement-step |   -    | +4,030 | +1,910  | -5,940  |
| Clusters-post   | 98,569 | 95,992 | 202,538 | 301,902 |

</div>

The refinement of the KWPs resulted in 37% of KWP clusters having distant homologies to Pfam entries, and 90% of the hits are annotated to Pfam domain of known function.

<div class="img_container" style="width:90%; margin:2em auto;">

*Known refinement steps*

|                 |    K    |   KWP   |   GU    |   EU    |
| --------------- |:-------:|:-------:|:-------:|:-------:|
| Clusters-pre    | 98,569  | 95,992  | 202,538 | 301,902 |
| Refinement-step | +31,781 | -35,385 | +3,604  |    -    |
| Clusters-post   | 130,350 | 60,607  | 206,142 | 301,902 |

</div>

Finally, the only-OMRGC2 clusters are mainly classified as GUs and EUs.
The numbers of clusters and ORFs for each category are reported in the table below.

<div class="img_container" style="width:90%; margin:2em auto;">

**Final cluster categories:**

|          | K       | KWP     | GU      | EU      |
| -------- | ------- | ------- | ------- | ------- |
| Clusters | 130,350 | 60,607  | 206,142 | 301,902 |
| ORFs     | 840,301 | 236,878 | 917,523 | 971,435 |

</div>


<h4 class="section-heading  text-primary">OMRGC-v2 singletons</h4>

<div class="img_container" style="width:90%; margin:2em auto;">

| Singletons | Pfam annotated | Pfam not annotated |
|:----------:|:--------------:|:------------------:|
| 3,579,142  |    184,582     |     3,394,560      |

</div>

<div class="img_container" style="width:90%; margin:2em auto;">

**Singletons categories:**

| Category | Singletons |
| -------- | ---------- |
| K        | 167,432    |
| KWP      | 359,453    |
| GU       | 632,175    |
| EU       | 2,420,082  |

</div>

<h3 class="section-heading  text-primary">3. Correspondance between OMRGC-v2 unknowns and MG+GTDB unknowns</h3>

<div class="img_container" style="width:90%; margin:2em auto;">

*OM-RGC-v2 gene classification*

| OMRGCv2 knowns | OMRGCv2 unknowns |
|:--------------:|:----------------:|
|   28,505,011   |    18,270,143    |

</div>

**The OMRGCv2 unknowns in our clusterDB:**

<div class="img_container" style="width:80%; margin:2em auto;">

<img alt="om-rgc_v2_unkn.png" src="/img/om-rgc_v2_unkn.png" width="" height="" >

</div>

<div class="img_container" style="width:50%; margin:2em auto;">

*In the new omrgc2 clusters:*

| Category | ORFs    |
| -------- | ------- |
| K        | 76,557  |
| KWP      | 83,156  |
| GU       | 556,591 |
| EU       | 910,951 |

<sup>Identified as knowns: 159,713</sup>

*In omrgc2 singletons:*

| Category | Singletons |
| -------- | ---------- |
| K        | 12,135     |
| KWP      | 133,890    |
| GU       | 378,198    |
| EU       | 2,335,251  |

<sup>Identified as knowns: 146,025</sup>

*In the mixed clusters:*

| Category | ORFs      |
| -------- | --------- |
| K        | 1,075,529 |
| KWP      | 1,188,174 |
| GU       | 6,419,268 |
| EU       | 5,028,738 |

<sup>Identified as knowns: 2,263,703</sup>

</div>

Total now identified as knowns (K or KWP): 2,569,441 (14%)

Total GUs: 7,354,057 (40%)

Total EUs: 8,274,940 (46%)

Found in the discarded clusters: 71,705

<h3 class="section-heading  text-primary">4. Co-expression pairs</h3>

Co-expression pairs table: <https://www.cell.com/cms/10.1016/j.cell.2019.10.014/attachment/c450baf9-7f5b-44ae-9b39-7a738e3bda2b/mmc1.xlsx>

Results table: "OM-RGC_v2_all_genes_class_categ_pairs.tsv.gz"

<br>
<br>

* * *

<h4 class="section-heading  text-primary">References</h4>

<a name="1"></a>[1] Salazar, Guillem, Lucas Paoli, Adriana Alberti, Jaime Huerta-Cepas, Hans-Joachim Ruscheweyh, Miguelangel Cuenca, Christopher M. Field, et al. 2019. “Gene Expression Changes and Community Turnover Differentially Shape the Global Ocean Metatranscriptome.” Cell 179 (5): 1068–83.e21.
