---
layout: page
title: Metagenomic cluster DB - Singletons & small clusters
---

<h2 class="section-heading  text-primary">Singletons</h2>

The sinlgetons are the clusters with only one member/ORF.

<div class="img_container" style="width:70%; margin:2em auto;">

*Singletons Pfan annotations*

| Singletons |   Annotated  |   Not-annotated  |
| :--------: | :----------: | :--------------: |
| 19,911,324 | 934,548 (5%) | 18,976,776 (95%) |

| Annotated DUFs | Annotated PF (known function) |
| :------------: | :---------------------------: |
|   82,135 (9%)  |         852,413 (91%)         |

</div>

<h5 class="section-heading  text-primary">_Genomic unknowns_ singletons: search against UniRef90</h5>

We searched the set of not annotated singletons against UniRef90. We were able to annotate 32% of the not annotated singletons, with 43% of the hits annotated to "hypothetical proteins."

<div class="img_container" style="width:50%; margin:2em auto;">

*Not annotated singletons vs UniRef90 search results*

|  Hits (unique)  |      No-hits     |
| :-------------: | :--------------: |
| 6,024,464 (32%) | 12,952,312 (68%) |

</div>

<div class="img_container" style="width:70%; margin:2em auto;">

*UniRef90 hits functional characterization*

|   Hits to hypothetical proteins   | Hits to not-hypothetical prot. |
| :-------------------------------: | :----------------------------: |
| 2,579,709 (14%) (43% of the hits) |   3,444,755 (57% of the hits)  |

</div>

<h5 class="section-heading  text-primary">Singletons _Environmental unknowns_: search against NCBI nr database</h5>

We searched the representatives that reported no matches to the UniRef90 entries (12,952,312) against the NCBI nr database (version 28-08-2017; 130,469,055 non-redundant proteins).

From the 12,952,312 queries we wereable to annotate only the 1.3%.

<div class="img_container" style="width:50%; margin:2em auto;">

*UniRef90-nohits vs NCBI-nr search results*

|      Hits      |       No-hits      |
| :------------: | :----------------: |
| 162,038 (1.3%) | 12,790,274 (98.7%) |

</div>

<div class="img_container" style="width:70%; margin:2em auto;">

*NCBI-nr hits functional characterization*

|          NR hypothetical         |    NR not-hypothetical   |
| :------------------------------: | :----------------------: |
| 101,632 (0.8%) (63% of the hits) | 60,406 (37% of the hits) |

</div>

<h5 class="section-heading  text-primary">Singletons categories</h5>

<div class="img_container" style="width:70%; margin:2em auto;">

|      K       |       KWP       |       GU        |        EU        |
|:------------:|:---------------:|:---------------:|:----------------:|
| 852,413 (4%) | 3,505,161 (18%) | 2,763,476 (14%) | 12,790,274 (64%) |

</div>

<h2 class="section-heading  text-primary">Small clusters</h2>

The small clusters are the set of clusters with less than 10 ORFs.

<div class="img_container" style="width:50%; margin:2em auto;">

*Nuber of small clusters and their ORFs*

|  Clusters | Members (ORFs) |
| :-------: | :------------: |
| 9,549,853 |   33,869,465   |

</div>

<div class="img_container" style="width:70%; margin:2em auto;">

*Small clusters Pfam annotations*

| Annotated clusters | Annotated to PF | Annotated to DUFs |
| :----------------: | :-------------: | :---------------: |
|      1,028,076     |  946,112 (92%)  |    81,964 (8%)    |

</div>

We retrieved the consensus sequences for the clusters and we proceeded with the classification:

<h5 class="section-heading  text-primary">Small clusters _Genomic unknowns_: search against UniRef90</h5>

We searched the 8,521,777 not annotated small clusters consensus againt the UniRef90 database. We annotated 56% of the queries.

<div class="img_container" style="width:50%; margin:2em auto;">

*Not annotated small clusters vs UniRef90 search results*

|  Hits (unique)  |     No-hits     |
| :-------------: | :-------------: |
| 4,767,685 (56%) | 3,754,092 (44%) |

</div>

The majority (54%) of the UniRef90 hits are annotated to "hypothetical" proteins.

<div class="img_container" style="width:70%; margin:2em auto;">

*UniRef90 hits functional characterization*

|   Hits to hypothetical proteins   | Hits to not-hypothetical prot. |
| :-------------------------------: | :----------------------------: |
| 2,590,710 (30%) (54% of the hits) |  2,176,975  (46% of the hits)  |

</div>


<h5 class="section-heading  text-primary">Small clusters _Environmental unknowns_: search against NCBI nr database</h5>

We searched the consensus that reported no matches to the UniProtKB entries (3,754,092) against the NCBI nr database (version 28-08-2017; 130,469,055 non-redundant proteins).

From these 3,754,092 queries we got only 108,267 hits.

<div class="img_container" style="width:50%; margin:2em auto;">

*UniRef90-nohits vs NCBI-nr search results*

|     Hits     |     No-hits     |
| :----------: | :-------------: |
| 108,267 (3%) | 3,645,825 (97%) |

</div>

We screened these hits for "hypothetical" labels, the results are reported in the table below.

<div class="img_container" style="width:70%; margin:2em auto;">

*NCBI-nr hits functional characterization*

|        NR hypothetical        |    NR not-hypothetical   |
| :---------------------------: | :----------------------: |
| 71,588 (2%) (66% of the hits) | 36,679 (33% of the hits) |

</div>

<h5 class="section-heading  text-primary">Small clusters categories</h5>

<div class="img_container" style="width:90%; margin:2em auto;">

|          |       K       |       KWP       |       GU        |       EU        |   Total    |
|:--------:|:-------------:|:---------------:|:---------------:|:---------------:|:----------:|
| Clusters | 946,112 (10%) | 2,213,654 (23%) | 2,744,262 (29%) | 3,645,825 (38%) | 9,549,853  |
|   ORFs   |   3,890,895   |    8,304,629    |   10,281,417    |   11,392,524    | 33,869,465 |
