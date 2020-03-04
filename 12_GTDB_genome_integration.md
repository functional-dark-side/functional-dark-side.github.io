---
layout: page
title: Cluster update - Genome Taxonomy Database genomes
---

<h2 class="section-heading  text-primary">Clusters analysis of the Genome Taxonomy Database and integration with the metagenomic database</h2>

**The Genome Taxonomy Database (GTDB):**

<div class="img_container" style="width:50%; margin:2em auto;">

| Genomes | Archaea | Bacteria |
|:-------:|:-------:|:--------:|
| 127,318 |  2,075  | 125,243  |

*Release 03-RS86 (19th August 2018)*

</div>

"A phylogeny inferred from the concatenation of 120 ubiquitous single-copy proteins, and we used this phylogeny to propose a bacterial taxonomy that covers 94,759 bacterial genomes, including 13,636 (14.4%) from uncultured organisms (metagenome- assembled or single-cell genomes). Taxonomic groups in this classification describe monophyletic lineages of similar phylogenetic depth after normalization for lineage-specific rates of evolution. This taxonomy, which we have named the GTDB taxonomy, is publicly available at the Genome Taxonomy Database website (http://gtdb.ecogenomic.org/)." (Parks et al. 2018) [[1]](#1)

Bacterial and archaeal ORFs from the Genome Taxonomy Database (GTDB) Release 03-RS86 (19th August 2018) [[1]](#1) were integrated in our clusters. For the integration we used the same data used and processed by Mendler at al. (Annotree) [[2]](#2). The dataset consist of ~94M bacterial and archaeal ORFs stemming from 28,941 genomes (27,372 bacterial and 1,569 archaeal). We used  the *clusterupdate* program of the MMSeqs2 software [[3]](#3), with the same parameters applied for the original clustering (minimum sequence identity set to 30% and bi-directional coverage to 80%). The new sequences were queried against the old cluster representatives. Those that passed the specified thresholds were merged with the previous clustering. The remaining unmapped sequences were then clustered separately, following the same steps of the original clustering.
The new clusters composed solely of GTDB ORFs were validated and classified following the main workflow steps.

<h3 class="section-heading  text-primary">Methods</h3>

**1)** Incremental clustering update with the GTDB sequences: \
 We downloaded the protein sequences from bacterial and archaeal genomes stored in the Annotree website at <https://data.ace.uq.edu.au/public/misc_downloads/annotree/r86/>.

NB: We renamed the predicted genes to follow the nomenclature used for the metagenomic dataset.

We collected 90,621,864 proteins from 27,372 bacterial genomes, and 3,101,326 from 1,569 archaeal genomes:

<div class="img_container" style="width:50%; margin:2em auto;">

*GTDB dataset*

|           | Genomes |  Proteins  |
|:---------:|:-------:|:----------:|
| Bacterial | 27,372  | 90,621,864 |
| Archaeal  |  1,569  | 3,101,326  |
|   Total   | 28,941  | 93,723,190 |

</div>

We then integrated the collected genomes in the metagenomic gene clusters, using the incremental clustering algorithm of MMseqs2.

**Scripts and description:** The renaming script [renaming_orfs.sh](scripts/GTDB/renaming_orfs.sh) downloads and renames the GTDB predicted genes. The genomic genes are then merged with the metagenomic ones with the script [combined_seq_db.sh](scripts/GTDB/combined_seq_db.sh). The incremental clustering script [clustering_update.sh](scripts/GTDB/GTDB_cluster_update/clustering_update.sh) takes in input the old cluster database in MMseqs2 format, and the new combined sequence database. The output is a new integrated cluster database. To further parse the results the script [clustering_updt_res.sh](scripts/GTDB/GTDB_cluster_update/clustering_updt_res.sh) is used. From the parsing we obtain a sequence database of the clusters, tables containing information about the cluster representative, the size and the cluster members, and whether a cluster is from the original clustering, an updated one or a new cluster, i.e made of only new sequeunces.

**2)** The only-GTDB clusters are parsed through the next steps of the workflow:

**Scripts and description:** The scripts are the same used on the original clustering results.

<h3 class="section-heading  text-primary">Results</h3>

<h4 class="section-heading  text-primary">Cluster update results</h4>

Metagenomes + Genomes cluster database ("mg_gtdb_db_20190502", MG+GTDB): 72% of GTDB ORFs (67,446,376) were found in our clusters (in 2,163,381 metagenomic clusters).

<img alt="GTDB_clu_update.png" src="/img/GTDB_clu_update.png" width="60%" height="" >

<br>

<div class="img_container" style="width:80%; margin:2em auto;">

*MG + GTDB cluster DB*

|          | Metagenomes | GTDB genomes |    Total    |
|:--------:|:-----------:|:------------:|:-----------:|
| Clusters | 32,465,074  |  7,958,475   | 40,423,549  |
|   ORFs   | 322,248,552 |  93,723,190  | 415,971,742 |

</div>

<div class="img_container" style="width:90%; margin:2em auto;">

The remaining (unmapped) 26M (28%) GTDB ORFs were clustered in 7,958,475 clusters. Around 5.6M resulted as singletons.

*Only-GTDB clusters:*

|          | GTDB not-singletons | GTDB singletons |   Total    |
|:--------:|:-------------------:|:---------------:|:----------:|
| Clusters |      2,400,037      |    5,558,438    | 7,958,475  |
|   ORFs   |     20,718,376      |    5,558,438    | 26,276,814 |

</div>

The new/only-GTDB non-singletons clusters have an average size, i.e. number of ORFs, of 8.6 (median=3), with a maximum of 18,114 ORFs and a minimum of 2.

<h4 class="section-heading  text-primary">2) Characterization of GTDB Clusters</h4>

<h4 class="section-heading  text-primary">Clusters (> 1 ORFs)</h4>

<div class="img_container" style="width:50%; margin:2em auto;">

*Only-GTDB cluster dataset*

|  Clusters  |    ORFs      |
|:----------:|:------------:|
| 2,400,037  |  20,718,376  |

</div>

-   *Pfam annotation*

We were able to annotate to Pfam protein domain families only 41% of the GTDB ORFs not found in the metagenomic clusters.

<div class="img_container" style="width:60%; margin:2em auto;">

*Number of cluster ORFs Pfam annotated and not*

|       |    Annotated    |   Not annotated  |
|:-----:|:---------------:|:----------------:|
| ORFs  | 8,404,082 (41%) | 12,314,294 (59%) |

</div>

The distribution of the Pfam annotations in the clusters resulted into a set ~500K annotated clusters and a set of 1.8M not-annotated clusters. Nubers are shown in the following table:

<div class="img_container" style="width:70%; margin:2em auto;">

*Pfam annotations at the cluster level*

|          |    Annotated     |  Not annotated   |
|:--------:|:----------------:|:----------------:|
| Clusters |  556,834 (23%)   | 1,843,203 (77%)  |
|   ORFs   | 10,091,203 (49%) | 10,627,173 (51%) |

</div>

-   *Identification of spurious and shadow ORFs*

We screened the AntiFam database to identify potential spurious ORFs. We found only 0.02% of clusters ORFs being potentially spurious.

<div class="img_container" style="width:50%; margin:2em auto;">

*Spurious ORFs:*

| ORFs in clusters | ORFs in singletons |
|:----------------:|:------------------:|
|  3,252 (0.02%)   |   1,312 (0.02%)    |

</div>

We identified 1% of clusters ORFs as shadows.

<div class="img_container" style="width:50%; margin:2em auto;">

*Shadow ORFs:*

| ORFs in clusters | ORFs in singletons |
|:----------------:|:------------------:|
|  223,535  (1%)   |    125,262 (2%)    |

</div>

-   *Cluster validation*

The cluster validation showed a high cluster quality in terms of both cluster functional and compositional homogeneity.
Results for the two validastion steps are reported in the following tables:

<div class="img_container" style="width:70%; margin:2em auto;">

*Functional validation:*

|          |      Good       |     Bad      |
|:--------:|:---------------:|:------------:|
| Clusters |  542,410 (97%)  | 14,424 (3%)  |
|   ORFs   | 9,865,550 (98%) | 225,653 (2%) |


*Compositional validation:*

|          |       Good       |     Bad      |
|:--------:|:----------------:|:------------:|
| Clusters | 2,361,585 (98%)  | 38,452 (2%)  |
|   ORFs   | 20,364,454 (98%) | 353,922 (2%) |

</div>

<img alt="gtdb_cl_comp_val_rej_non_homolog.png" src="/img/gtdb_cl_comp_val_rej_non_homolog.png" width="70%" height="" >

*Proportion of bad-aligned/non-homologous ORFs detected within each cluster MSA. Distribution of observed values compared with those of the Broken-stick model. The threshold was determined at 11% non-homologous ORFs per cluster.*

Overall 98% of the clusters and 97% of their ORFs were classified as "good", and only 2% were discarded.

<div class="img_container" style="width:70%; margin:2em auto;">

*Combined validation results:*

|            |       Good       |      Bad      |
|:----------:|:----------------:|:-------------:|
| Clusters   |  2,347,502 (98%) |  52,535 (2%)  |
| ORFs       | 20,141,636 (97%) |  576,740 (3%) |

*Good clusters:*

|   Good     |    Annotated     |   Not annotated  |
|:----------:|:----------------:|:----------------:|
| Clusters   |     530,503      |    1,816,999     |
| ORFs       |    9,749,442     |   10,392,194     |

</div>

-   *Classification*

<h6 class="section-heading  text-primary">Cluster consensus vs Uniref90:</h6>

We searched the not annoataed clusters consensus against the UniRef90 database. The majority (86%) reported at least one match.

<div class="img_container" style="width:50%; margin:2em auto;">

*Not annotated cluster consensus vs UniRef90*

|     Hits        |     No-hits     |
| :-------------: | :-------------: |
| 1,570,094 (86%) |   246,905 (14%) |

</div>

The majority (81%) of the hits were found labeled as "hypothetical" proteins.

<div class="img_container" style="width:70%; margin:2em auto;">

*Hits functional characterisation in UniRef90*

|   Hits to hypothetical proteins   | Hits to not-hypothetical prot. |
| :-------------------------------: | :----------------------------: |
| 1,266,090 (70%) (81% of the hits) |   304,004  (19% of the hits)   |

</div>

<h6 class="section-heading  text-primary">Cluster consensus vs NCBI-nr:</h6>

We searched then the 246,905 consensus sequences without a hit in UniRef90 against the NCBI-nr database. Only 12% of the queries was found in the NCBI-nr database.

<div class="img_container" style="width:50%; margin:2em auto;">

*Consensus UniRef90-nohits vs NCBI-nr*

|     Hits        |     No-hits     |
| :-------------: | :-------------: |
|  28,704 (12%)   |   218,201 (88%) |

</div>

The large majority of the hits (96%) was found annotated to "hypotetical" proteins.

<div class="img_container" style="width:70%; margin:2em auto;">

*Hits functional characterisation in NCBI-nr*

|   Hits to hypothetical proteins   | Hits to not-hypothetical prot. |
| :-------------------------------: | :----------------------------: |
|   27,424 (11%) (96% of the hits)  |    1,280  (4% of the hits)     |

</div>

<h6 class="section-heading  text-primary">Classification of the annotated Clusters</h6>

We processed the annotated clusters to retrieve the cluster consensus Pfam domain architecture (DA). The retrieved numbers divided into annotated to domains of unknown function (DUFs) and domains of known function (PFs) are reported in the next table.

<div class="img_container" style="width:60%; margin:2em auto;">

| Annotated DUFs | Annotated PFs (known function) |
| :------------: | :---------------------------: |
|   65,688 (12%) |         464,815 (88%)         |

</div>

The only-GTDB cluster categories before the known and unknown refinement resulted dominated by the GUs (58%).

<div class="img_container" style="width:80%; margin:2em auto;">

*Only-GTDB cluster categories*

|       K       |      KWP      |       GU        |      PGU      |
|:-------------:|:-------------:|:---------------:|:------------:|
| 464,815 (20%) | 305,284 (13%) | 1,359,202 (58%) | 218,201 (9%) |

</div>

-   *Categories refinement*

We found that 69% of the PGUs show remote homology to a Uniclust entry/protein. Of the matching clusters, 144,295 resulted in distant homologs of hypothetical proteins and were moved to the GU category, whereas 5,704 clusters matched characterized proteins and were transferred to the KWP set. Hence, after this refinement step, the number of PGUs reduced to 68,202 clusters.
The search of the KWP cluster HMMs against the Pfam database resulted in 56% of KWP clusters being remote homologous of Pfam enries. Of this set, the majority, 152,529 clusters, were annotated to PFs, and 22,053 clusters to DUFs.


<div class="img_container" style="width:90%; margin:2em auto;">

*Cluster category refinement steps:*

|                                 |       K       |     KWP      |       GU        |     PGU      |
|:-------------------------------:|:-------------:|:------------:|:---------------:|:-----------:|
|  Clusters (pre-EUs_refinement)  |    464,815    |   305,284    |    1,359,202    |   218,201   |
|         EUs refinement          |       -       |    +5,704    |    +144,295     |  -149,999   |
| Clusters (post-EUs_refinement)  |    464,815    |   310,988    |    1,503,497    |   68,202    |
|         KWPs refinement         |   +152,529    |   -174,582   |     +22,053     |      -      |
| Clusters (post-KWPs_refinement) | 617,344 (26%) | 136,406 (6%) | 1,525,550 (65%) | 68,202 (3%) |

</div>

After the refinement the only-GTDB clusters appeared dominated by the GU set, which accounts for 65% of the clusters.

<div class="img_container" style="width:80%; margin:2em auto;">

*Only-GTDB clusters final categories*

|          |     K     |   KWP   |    GU     |   PGU    |     Total      |
|:--------:|:---------:|:-------:|:---------:|:-------:|:--------------:|
| Clusters |  617,344  | 136,406 | 1,525,550 | 68,202  | **2,347,502**  |
|   ORFs   | 9,997,529 | 663,107 | 9,305,621 | 175,379 | **20,141,636** |

</div>

-   *GTDB cluster community inference*

The best inflation value for the cluster aggregation was determined at 2.5, and we obtained a total of ~500K communities.
(Both slightly higher number than those found for the metagenomic dataset/clusters)

<img alt="k_partition_stats_eval_plot_gtdb.png" src="/img/k_partition_stats_eval_plot_gtdb.png" width="50%" height="" >

*Radar plots used to determine the best MCL inflation value for the partitioning of the Ks into cluster components. The plots were built using a combination of five variables: 1=proportion of clusters with 1 component and 2=proportion of clusters with more than 1 member, 3=clan entropy (proportion of clusters with entropy = 0), 4=intra hhblits score-per-column (normalised by the maximum value), and 5=number of clusters (related to the non-redundant set of DAs).*


<div class="img_container" style="width:80%; margin:2em auto;">

*Only-GTDB cluster community categories*

|             |      K      |     KWP     |      GU     |      EU     |      Total     |
|:-----------:|:-----------:|:-----------:|:-----------:|:-----------:|:--------------:|
| Communities |   52,360    |    47,203   |  339,468    |    57,899   |   **496,930**  |
| Clusters    |   617,344   |   136,406   | 1,525,550   |    68,202   | **2,347,502**  |
| ORFs        | 9,997,529   |   663,107   | 9,305,621   |   175,379   | **20,141,636** |

</div>

<br>

* * *

As for the metagenomic cluster database, we retrieved the genomic "High Quality" (mostly complete) set of clusters:

<div class="img_container" style="width:80%; margin:2em auto;">

*GTDB HQ clusters*

| Category | HQ cluster |  HQ ORFs   | pHQ_orfs | pHQ_cl |
|:--------:|:----------:|:----------:|:--------:|:------:|
|    K     |   12,202   | 25,105,156 |  0.0096  | 0.0198 |
|   KWP    |   4,019    | 1,349,165  |  0.0214  | 0.0295 |
|    GU    |   12,699   | 8,403,393  |  0.0062  | 0.0083 |
|    EU    |    438     |  471,820   |  0.0074  | 0.0064 |

</div>

* * *

<h4 class="section-heading  text-primary">MG + GTDB new cluster database and categories</h4>

<div class="img_container" style="width:90%; margin:2em auto;">

**Only MG**

|          |      K      |    KWP     |     GU     |    EU     |      Total      |
| -------- |:-----------:|:----------:|:----------:|:---------:|:---------------:|
| Clusters |  1,050,166  |  632,453   | 1,121,809  |  135,829  |  **2,940,257**  |
| ORFs     | 172,147,128 | 30,601,694 | 54,052,275 | 3,341,257 | **260,142,354** |

<br>

**All GTDB (Including ORFs falling in the MG clusters)**

|          |      K      |     KWP     |      GU     |      EU     |      Total      |
|----------|:-----------:|:-----------:|:-----------:|:-----------:|:---------------:|
| Clusters |  1,115,167  |   263,702   |  1,814,233  |   76,999    | **3,270,101**   |
| ORFs     | 58,494,638  |  2,152,671  | 14,457,060  |   192,950   | **75,297,319**  |

<br>

**MG + GTDB**

|          |      K      |     KWP     |      GU     |      EU     |      Total      |
|----------|:-----------:|:-----------:|:-----------:|:-----------:|:---------------:|
| Clusters | 1,667,510   |   768,859   | 2,647,359   |   204,031   |  **5,287,759**  |
| ORFs     | 232,895,994 | 32,930,286  | 68,757,918  |  3,541,592  | **338,125,790** |

</div>

<br>
<br>

* * *

<h5 class="section-heading  text-primary">Only-GTDB Singletons</h5>

-   *Pfam annotation*

<div class="img_container" style="width:60%; margin:2em auto;">

*Number of Pfam annotated and not-annotated singletons*

|               |   Singletons    |
|:-------------:|:---------------:|
|   Annotated   |  535,012 (10%)  |
| Not-annotated | 5,023,426 (90%) |

| Annotated DUFs | Annotated PF (known function) |
| :------------: | :---------------------------: |
|   61,552 (11%) |         473,460 (89%)         |

</div>

-   *Classification*

<h6 class="section-heading  text-primary">*Genomic unknowns*: search against UniRef90</h6>

Sixty-five percent of the 5,023,426 not annotated singletons, were found in the UniRef90 DB, as shown in the table below:

<div class="img_container" style="width:60%; margin:2em auto;">

*Not-annotated singletons vs UniRef90*

|  Hits (unique)  |     No-hits     |
|:---------------:|:---------------:|
| 3,249,823 (65%) | 1,773,603 (35%) |

</div>

The **3,249,823** hits, are divided into 73% hypothetical and 27% characterised UniRef90 protein entries:

<div class="img_container" style="width:80%; margin:2em auto;">

*Hits functional characterisation in UniRef90*

|   Hits to hypothetical proteins   | Hits to not-hypothetical prot. |
|:---------------------------------:|:------------------------------:|
| 2,361,654 (47%) (73% of the hits) |   888,169 (27% of the hits)    |

</div>

<h6 class="section-heading  text-primary">*Environmental unknowns*: search against NCBI nr database</h6>

We searched the consensus seqeunces that reported no matches to the UniRef90 entries (1,773,603) against the NCBI nr database (version 28-08-2017; 130,469,055 non-redundant proteins). We were able to annotate/retrieve only 1.3% of them.

<div class="img_container" style="width:80%; margin:2em auto;">

*UniRef90-nohits singletons vs NCBI-nr*

|      Hits      |      No-hits      |
|:--------------:|:-----------------:|
| 113,122 (1.3%) | 1,660,481 (98.7%) |

</div>

We then screened the hits for "hypothetical", and we found 93% of them being classified as "hypothetical".

<div class="img_container" style="width:80%; margin:2em auto;">

*Hits functional characterisation in NCBI-nr*

|         NR hypothetical          |  NR not-hypothetical   |
|:--------------------------------:|:----------------------:|
| 105,164 (0.6%) (93% of the hits) | 7,958 (7% of the hits) |


</div>

-   *Singletons categories*

The GTDB singletons appeared to be mostly GUs and PGUs.

<div class="img_container" style="width:95%; margin:2em auto;">

|      K       |      KWP      |       GU        |       PGU        |
|:------------:|:-------------:|:---------------:|:---------------:|
| 473,460 (9%) | 896,127 (16%) | 2,528,370 (45%) | 1,660,481 (30%) |

</div>

<br>

* * *

<h4 class="section-heading  text-primary">Enrichment of formaer metagenomic small clusters (less than 10 ORFs) and singletons</h4>

A fraction of the GTDB ORFs were found similar to metagenomic singletons or small clusters.

The majority (55,155,683) (82%) of the 67,446,376 GTDB ORFs found in the metagenomic dataset belonged to the refined set of clusters, 3,700,844 ORFs were found in singletons, 7,010,987 ORFs in small clusters (clusters with less than 10 members) and 1,578,862 ORFs in clusters discarded during the validation/refinement step.

After the integration of genomic ORFs, 52,758 singletons and 187,953 small clusters became clusters with more than 10 members.

Singletons now >=10: 52,758 (0.3%) (total singletons now with one or more GTDB orfs 492,238 (2.5%))

Small clusters now >=10: 187,953 (2%) (total small clusters with one or more GTDB orfs 731,492 (8%))

<div class="img_container" style="width:50%; margin:2em auto;">

*New MG+GTDB clusters with more than 10 ORFs*

| Clusters | ORFs      |
| -------- | --------- |
| 240,711  | 9,001,819 |

</div>

Currently under validation ...

<br>
<br>

* * *

<h4 class="section-heading  text-primary">References</h4>

<a name="1"></a>[1] D. H. Parks, M. Chuvochina, D. W. Waite, C. Rinke, A.Skarshewski, P-A Chaumeil & P. Hugenholtz, "A standardized bacterial taxonomy based on genome phylogeny substantially revises the tree of life." Nat Biotechnology, Aug. 2018.

<a name="2"></a>[2] K. Mendler, H. Chen, D. H. Parks, B. Lobb, L. A. Hug and A. C. Doxey, "AnnoTree: visualization and exploration of a functionally annotated microbial tree of life" Nucleic Acids Research, Mar. 2019.

<a name="3"></a>[3] M. Steinegger and J. Söding, “MMseqs2 enables sensitive protein sequence searching for the analysis of massive data sets.,” Nature biotechnology, vol. 35, no. 11, pp. 1026–1028, Nov. 2017.
