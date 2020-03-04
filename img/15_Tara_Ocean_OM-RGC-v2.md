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

**Scripts:** To update the cluster DB with the new sequences from the TARA OM-RGC-v2 we first combine all the sequences together using the script [combine_seq_dbs.sh](scripts/TARA_OMRGCv2/combine_seq_dbs.sh), we then integrate the gene catalog via incremental clustering using the script [omrgc2_clu_update.sh](scripts/TARA_OMRGCv2/omrgc2_clu_update.sh). The results were parsed using the script [omrgc2_clu_updt_res.sh](scripts/TARA_OMRGCv2/omrgc2_clu_updt_res.sh). The new clusters (only-OMRGC2) were processed through the workflow and categorised.
(The compositional validation was run using: [run_comp_valid.sh](scripts/TARA_OMRGCv2/run_comp_valid.sh) and [compositional_validation.sh](scripts/TARA_OMRGCv2/compositional_validation.sh). Ran in the deNBI cloud.)

<h3 class="section-heading  text-primary">Results</h3>

### 1. Incremental clustering

**New cluster DB:**

| Genes       | Clusters   |
| ----------- | ---------- |
| 462,746,896 | 44,707,906 |

| Singletons | Cluster ≥ 2genes |
| ---------- | ---------------- |
| 25,254,004 |   19,453,902     |

|          | MG-GTDB     | MG-GTDB-OMRGC2 | OMRGC2    |
| -------- | ----------- | -------------- | --------- |
| Clusters | 32,666,889  | 7,756,660      | 4,284,357 |
| ORFs     | 158,585,789 | 297,573,606    | 6,587,501 |

Of the 46,775,154 OM-RGC.v2 genes: 40,187,653 (86%) fell into MG-GTDB clusters and 6,587,501 (14%) were grouped into 4,284,357 new clusters.

**OMRGC2 - cluster DB**

|          | Clusters        | Singletons      | Total     |
| -------- | --------------- | --------------- | --------- |
| Clusters | 705,215 (17%)   | 3,579,142 (83%) | 4,284,357 |
| ORFs     | 3,008,359 (46%) | 3,579,142 (54%) | 6,587,501 |


**Mixed MG-G-OMRGC2 clusters**

| G10       | LT10      | Total     |
| --------- | --------- | --------- |
| 2,059,769 | 5,696,891 | 7,756,660 |

|      | K       | KWP     | GU        | EU        |
| ---- | ------- | ------- | --------- | --------- |
| G10  | 815,558 | 317,161 | 717,332   | 187,734   |
| LT10 | 571,807 | 869,002 | 1,179,592 | 3,074,379 |

### 2. Only/New OMRGC2 clusters processing through the workflow:

**1. Pfam annotation**

| Annotated | Not annotated | Total     |
| --------- | ------------- | --------- |
| 578,241   | 2,430,118     | 3,008,359 |

Pfam annotations in the clusters:

|          | Annotated clusters | Not annotated clusters |
| -------- | ------------------ | ---------------------- |
| Clusters | 108,931            | 596,284                |
| ORFs     | 752,293            | 2,256,066              |


**2. Validation**
**2.1 Functional Validation**

| Jaccard raw index == 1 | Jaccard raw index <1 |
| ---------------------- | -------------------- |
| 108,069                | 862                  |

| MoDA | MuDA    |
| ---- | ------- |
| 357  | 108,547 |

Homog_clan      1352
Homog_pf      101226
Homog_pf_term   2317
Mono_clan         26
Mono_pf          331
Multi_pf        1533
Singl_pf        2146

**2.2 Compositional Validation**

The proportion of "rejected" ORFs defining a cluster as "BAD" was found at 0.12 "bad-aligned"/"rejected" ORFs per cluster.

<img alt="omrgc2_val_rej_non_homolog.png" src="assets/omrgc2_val_rej_non_homolog.png" width="500" height="" >

**Result summary:**

|          | Original  | GOOD      | BAD    | Compos-GOOD | Compos-BAD | Funct-GOOD | Funct-BAD |
| -------- | --------- | --------- | ------ | ----------- | ---------- | ---------- | --------- |
| Clusters | 705,215   | 699,001   | 6,214  | 699,851     | 5,364      | 108,069    | 862       |
| ORFs     | 3,008,359 | 2,966,137 | 42,222 | 2,972,704   | 35,655     | 745,647    | 6,646     |


| GOOD clusters | annotated | not annotated |
| ------------- | --------- | ------------- |
| 699,001       | 107,016   | 591,985       |


**3. Classification**

Unknown classification - double database search

Good not annotated vs Uniref90:

| Hits    | Hypothetical | Characterised | Nohits  |
| ------- | ------------ | ------------- | ------- |
| 283,212 | 191,620      | 91,592        | 308,773 |


Uniref90 nohits vs NCBI nr:

| Hits | Hypothetical | Characterised | Nohits  |
| ---- | ------------ | ------------- | ------- |
| 931  | 561          | 370           | 307,842 |


Known classification - cluster consensus domain architectures

| Domains of known function | Domains of unknown function |
| ------------------------- | --------------------------- |
| 98,569                    | 8,447                       |


Cluster categories (pre-refinement):

|          | K       | KWP     | GU      | EU      |
| -------- | ------- | ------- | ------- | ------- |
| Clusters | 98,569  | 91,962  | 200,628 | 307,842 |
| ORFs     | 692,725 | 387,752 | 895,082 | 990,578 |


**4. Category refinement**

Unknown refinement

|                 | K      | KWP    | GU      | EU      |
| --------------- | ------ | ------ | ------- | ------- |
| Clusters-pre    | 98,569 | 91,962 | 200,628 | 307,842 |
| Refinement-step | -      | +4,030 | +1,910  | -5,940  |
| Clusters-post   | 98,569 | 95,992 | 202,538 | 301,902 |


Known refinement

|                 | K       | KWP     | GU      | EU      |
| --------------- | ------- | ------- | ------- | ------- |
| Clusters-pre    | 98,569  | 95,992  | 202,538 | 301,902 |
| Refinement-step | +31,781 | -35,385 | +3,604  | -       |
| Clusters-post   | 130,350 | 60,607  | 206,142 | 301,902 |

**Final/Refined cluster categories:**

|          | K       | KWP     | GU      | EU      |
| -------- | ------- | ------- | ------- | ------- |
| Clusters | 130,350 | 60,607  | 206,142 | 301,902 |
| ORFs     | 840,301 | 236,878 | 917,523 | 971,435 |


**5. Cluster communities**

### OMRGC-v2 SINGLETONS

| Singletons | Pfam annotated | Pfam not annotated |
| ---------- | -------------- | ------------------ |
| 3,579,142  | 184,582        | 3,394,560          |

**Singletons categories:**

| Category | Singletons |
| -------- | ---------- |
| K        | 167,432    |
| KWP      | 359,453    |
| GU       | 632,175    |
| EU       | 2,420,082  |


### 3. Correspondance between OMRGC-v2 unknowns and MG+GTDB unknowns

| OMRGCv2 knowns | OMRGCv2 unknowns |
| -------------- | ---------------- |
| 28,505,011     | 18,270,143       |

**The OMRGCv2 unknowns in our clusterDB:**

<img alt="om-rgc_v2_unkn.png" src="assets/om-rgc_v2_unkn.png" width="" height="" >

In the new omrgc2 clusters:

| Category | ORFs    |
| -------- | ------- |
| K        | 76,557  |
| KWP      | 83,156  |
| GU       | 556,591 |
| EU       | 910,951 |

Identified as knowns: 159,713

In omrgc2 singletons:

| Category | Singletons |
| -------- | ---------- |
| K        | 12,135     |
| KWP      | 133,890    |
| GU       | 378,198    |
| EU       | 2,335,251  |

Identified as knowns: 146,025

In the mixed clusters:

| Category | ORFs      |
| -------- | --------- |
| K        | 1,075,529 |
| KWP      | 1,188,174 |
| GU       | 6,419,268 |
| EU       | 5,028,738 |

Identified as knowns: 2,263,703

Total now identified as knowns (K or KWP): 2,569,441 (14%)

Total GUs: 7,354,057 (40%)

Total EUs: 8,274,940 (46%)

Found in the discarded clusters: 71,705

### 4. Co-expression pairs

Co-expression pairs table: <https://www.cell.com/cms/10.1016/j.cell.2019.10.014/attachment/c450baf9-7f5b-44ae-9b39-7a738e3bda2b/mmc1.xlsx>

Results table: "OM-RGC_v2_all_genes_class_categ_pairs.tsv.gz"

<br>
<br>

* * *

<h4 class="section-heading  text-primary">References</h4>

<a name="1"></a>[1] Salazar, Guillem, Lucas Paoli, Adriana Alberti, Jaime Huerta-Cepas, Hans-Joachim Ruscheweyh, Miguelangel Cuenca, Christopher M. Field, et al. 2019. “Gene Expression Changes and Community Turnover Differentially Shape the Global Ocean Metatranscriptome.” Cell 179 (5): 1068–83.e21.

<a name="2"></a>[2]
