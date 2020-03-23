---
layout: page
title: Cluster Databases
---

<h3 class="section-heading  text-primary">Environmental origin (MG)</h3>

**Starting data:**

| Data set  | Samples | Sites |
|:---------:|:-------:|:-----:|
|   TARA    |   242   |  141  |
| Malaspina |   116   |  30   |
|    OSD    |   145   |  139  |
|    GOS    |   80    |  70   |
|    HMP    |  1,249  |  18   |

| Total metagenomes | 1,832           |
| ----------------- | --------------- |
| **Total ORFs**    | **322,248,552** |


**MMseqs clustering:**

|          |    Total    | Clusters ≥ 10 ORFs | Clusters 1< ORFs < 10 | Singletons |
| -------- |:-----------:|:------------------:|:---------------------:|:----------:|
| Clusters | 32,465,074  |     3,003,897      |       9,549,853       | 19,911,324 |
| ORFs     | 322,248,552 |    268,467,763     |      33,869,465       | 19,911,324 |


**Cluster validation:**

|          | Kept        | Discarded  |
| -------- | ----------- | ---------- |
| Clusters | 2,940,257   | 29,524,817 |
| ORFs     | 260,142,354 | 62,106,198 |


Discarded cluster classes:

|          | Singletons | Small clusters | Bad clusters |
| -------- | ---------- | -------------- | ------------ |
| Clusters | 19,911,324 | 9,549,853      | 63,640       |
| ORFs     | 19,911,324 | 33,869,465     | 8,325,409    |


**Cluster and cluster community categories:**

|             |      K      |    KWP     |     GU     |    EU     |      Total      |
| ----------- |:-----------:|:----------:|:----------:|:---------:|:---------------:|
| Communities |   24,181    |   64,938   |  146,100   |  48,095   |   **283,314**   |
| Clusters    |  1,050,166  |  632,453   | 1,121,809  |  135,829  |  **2,940,257**  |
| ORFs        | 172,147,128 | 30,601,694 | 54,052,275 | 3,341,257 | **260,142,354** |


<h3 class="section-heading  text-primary">Environmental (MG) + Genomic origin (GTDB)</h3>

**Starting data:**

|           | Genomes |  Proteins  |
|:---------:|:-------:|:----------:|
| Bacterial | 27,372  | 90,621,864 |
| Archaeal  |  1,569  | 3,101,326  |
|   Total   | 28,941  | 93,723,190 |

**MMseqs incremental clustering:**

|          |     MG      |    GTDB    |    Total    |
|:--------:|:-----------:|:----------:|:-----------:|
| Clusters | 32,465,074  | 7,958,475  | 40,423,549  |
|   ORFs   | 322,248,552 | 93,723,190 | 415,971,742 |


**MMseqs new clustering classes:**

|          |    Total    | Clusters ≥ 10 ORFs | Clusters 1< ORFs < 10 | Singletons |
| -------- |:-----------:|:------------------:|:---------------------:|:----------:|
| Clusters | 40,423,549  |     3,599,944      |      11,846,082       | 24,977,524 |
| ORFs     | 415,971,742 |    349,446,528     |      41,547,690       | 24,977,524 |


**Cluster validation:**

|          | Kept        | Discarded  |
| -------- | ----------- | ---------- |
| Clusters | 5,287,759   | 35,135,790 |
| ORFs     | 338,125,790 | 78,953,207 |


Discarded cluster classes:

|          | Singletons | Small clusters | Bad clusters | Others**  |
| -------- | ---------- | -------------- | ------------ | --------- |
| Clusters | 25,469,762 | 9,549,853      | 116,175      | 240,711   |
| ORFs     | 25,469,762 | 35,579,477     | 8,902,149    | 9,001,819 |

**Others: MG clusters previously discarded cause singlentons or small clusters, which, with the integration of GTDB ORFs, became clusters with ≥ 10 ORFs. These clusters are momentaneously discarded and will be further investigated/validated.


**Cluster and cluster community categories:**

|             |      K      |    KWP     |     GU     |    EU     |      Total      |
| ----------- |:-----------:|:----------:|:----------:|:---------:|:---------------:|
| Communities |   76,541    |  112,141   |  485,568   |  105,994  |   **780,244**   |
| Clusters    |  1,667,510  |  768,859   | 2,647,359  |  204,031  |  **5,287,759**  |
| ORFs        | 232,895,994 | 32,930,286 | 68,757,918 | 3,541,592 | **338,125,790** |


<h3 class="section-heading  text-primary">MG + GTDB</h3>

<div class="img_container" style="width:60%; margin:2em auto;">

<img alt="MG_GTDB_venn.png" src="/img/MG_GTDB_venn.png" width="" height="" >

</div>

<div class="img_container" style="width:90%; margin:2em auto;">

<img alt="mg_gtdb_numbers.png" src="/img/mg_gtdb_numbers.png" width="" height="" >

</div>

<h3 class="section-heading  text-primary">Integration with the TARA OM-RGC-v2 (OMRGC2)</h3>

OM-RGC.v2 contains 46,775,154 non-redundant genes.

**MMseqs incremental clustering:**

|          | MG-GTDB     | MG-GTDB-OMRGC2 | OMRGC2    | Total       |
| -------- | ----------- | -------------- | --------- | ----------- |
| Clusters | 32,666,889  | 7,756,660      | 4,284,357 | 44,707,906  |
| ORFs     | 158,585,789 | 297,573,606    | 6,587,501 | 462,746,896 |

**Cluster categories:**

|          |      K      |    KWP     |     GU     |    EU    |      Total      |
| -------- |:-----------:|:----------:|:----------:|:--------:|:---------------:|
| Clusters |  1,797,860  |  829,466   | 2,853,501  | 505,933  |  **5,986,760**  |
| ORFs     | 233,736,295 | 33,167,164 | 69,675,441 | 4,513,27 | **341,091,927** |


<h3 class="section-heading  text-primary">MG + GTDB + OMRGC2</h3>

<div class="img_container" style="width:60%; margin:2em auto;">

<img alt="MG_GTDB_OMRGC2_venn.png" src="/img/MG_GTDB_OMRGC2_venn.png" width="" height="" >

</div>
