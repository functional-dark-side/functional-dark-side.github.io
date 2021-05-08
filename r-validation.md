---
layout: page
title: Clustering and annotation results
---

Our _de novo_ ORF cluster validation relies in two different approaches, from one side we test the compositional homogeneity of each cluster based in the sequence space, and from the other side, we evaluate the functional homogeneity of each cluster based on the Pfam annotations.

<div class="img_container img-responsive">
![](/img/pipeline_validation.png){:height="80%" width="80%"}
</div>

> **Note:** All the results presented here are for those clusters >= 10 members

In overall, MMseqs2 does an amazing job creating very homogenous clusters.

<h2 class="section-heading  text-primary">Compositional homogeneity</h2>

As a brief reminder of our approach:

<div class="img_container img-responsive">
![](/img/pipeline_validation_ch.png){:height="50%" width="50%"}
</div>

> **Note:** The most important factor of this evaluation is the number of sequences rejected in each cluster by LEON-BIS/OD-SEQ

The compositional homogeneity evaluation of the clusters confirms a good cluster quality at the sequence level. Of the ∼2.6 million clusters, 125,390 contain a rejected sequence (i.e. bad aligned sequence). About ∼9.6K clusters have more than 10% rejected sequences and were thus classified as “bad”.

<div class="img_container img-responsive">
![](/img/results_validation.jpg){:height="50%" width="50%"}
</div>

Those 125,390 rejected clusters represented 183,393 ORFs

|  Clusters |     ORFs    | Rejected clusters | Rejected sequences |
| :-------: | :---------: | :---------------: | :----------------: |
| 2,624,229 | 106,201,515 |      125,390      |       183,393      |

> **Note:** For 13 clusters, all belonging to the not annotated set of clusters, we were not able to run mmseqs2 to retrieve the alignments,

From those 183,393 sequences the majority (~67%) were from TARA metagenomes:

|  Total  |   TARA  | MALASPINA |  OSD  |   GOS  |
| :-----: | :-----: | :-------: | :---: | :----: |
| 183,393 | 122,938 |   29,541  | 9,318 | 21,596 |

<br />

We decided to use the 10% threshold for the number of rejected sequences after exploring the “scree plot” showing the relationship between number of clusters and rejected sequences:

<p align="center">
<img width=“80%” height=“80%” src="https://github.com/ChiaraVanni/unknown_protein_clusters/blob/master/img/cl_msa_eval/eval_msa_3.png">
</p>

We also investigated if there is any relationship between the number of rejected sequences and the size of the clusters:

<p align="center">
<img width=“80%” height=“80%” src="https://github.com/ChiaraVanni/unknown_protein_clusters/blob/master/img/cl_msa_eval/rej_size_n.png”>
</p>

As we can see in the plot the number of rejected clusters is higher on clusters with smaller sizes.

We also can look at the nature of the elements in the clusters:

<p align="center">
<img width=“80%” height=“80%” src="https://github.com/ChiaraVanni/unknown_protein_clusters/blob/master/img/cl_msa_eval/eval_msa_2.png">
</p>

## Functional validation

As a brief reminder of our approach:

<p align="center">
<img width="55%" height="55%" src="https://github.com/ChiaraVanni/unknown_protein_clusters/blob/master/img/pipeline_all.003_val_B2.png">
</p>

We are going to check the functional evaluation, but first, we will use the new representatives refined during the MSA based approach described previously. Is very interesting to see that with new representatives we have been able to increase the number of annotated cluster representatives:

| Old Rep_annot | New Rep_annot | Difference | Good/Kept new Rep_annot |
| :-----------: | :-----------: | :--------: | :---------------------: |
|    929,946    |    952,507    |   22,561   |         948,070         |

We will present the results based on the different categories based on the annotation’s groups

> **Note:** Since we are going to keep only the clusters with high sequence-level homogeneity (good multiple sequence alignment results), we decided to filter the annotated clusters based on the raw Jaccard median similarity, and not on the one scaled by the percentage/proportion of annotated members. We are showing the scaled results just for documentation purposes

### Clusters with annotated representatives:

The following plots shows the Jaccard similarity distribution for the comparisons scaled by the number of annotated members in the cluster (right) and the ones not taking in account the number of annotated members (left)

<img src="https://github.com/ChiaraVanni/unknown_protein_clusters/blob/master/img/cl_func_eval/shingl_jacc_rep_sc.jpg" width="300"><img src="https://github.com/ChiaraVanni/unknown_protein_clusters/blob/master/img/cl_func_eval/shingl_jacc_rep.jpg" width="300">

| Rep annot clusters | Jacc. median raw == 1 | Jacc. median scaled > 0.75 |
| :----------------: | :-------------------: | :------------------------: |
|  952,507           |    948,302 (99.5%)    |       777,703 (81.6%)      |

Based on the type of annotations in each cluster:

| Rep_annot |    HA   |  MoDA |   MuDA  |
| :-------: | :-----: | :---: | :-----: |
|  952,507  | 839,120 | 3,866 | 109,521 |

> **HA:** Homogeneous annotations  
> **MoDA:** Mono-domain different annotations  
> **MuDA:** Multi-domain different annotations

### Cluster with at least one annotated member (representative excluded):

The following plots shows the Jaccard similarity distribution for the comparisons scaled by the number of annotated members in the cluster (right) and the ones not taking in account the number of annotated members (left)

<img src="https://github.com/ChiaraVanni/unknown_protein_clusters/blob/master/img/cl_func_eval/shingl_jacc_norep_sc.jpg" width="300"><img src="https://github.com/ChiaraVanni/unknown_protein_clusters/blob/master/img/cl_func_eval/shingl_jacc_norep.jpg" width="300">

| Other_annot clusters | Jacc. median raw == 1 | Jacc. median scaled > 0.75 |
| :------------------: | :-------------------: | :------------------------: |
|   252,617            |    250,373 (99.1%)    |       15,474 (6.12%)       |

Based on the type of annotations in each cluster:

| No rep annot |    HA   |  MoDA |  MuDA |
| :----------: | :-----: | :---: | :---: |
|    252,617   | 243,925 | 3,706 | 4,986 |

> **HA:** Homogeneous annotations  
> **MoDA:** Mono-domain different annotations  
> **MuDA:** Multi-domain different annotations

### All annotated clusters:

The following plots shows the Jaccard similarity distribution for the comparisons scaled by the number of annotated members in the cluster (right) and the ones not taking in account the number of annotated members (left)

<img src="https://github.com/ChiaraVanni/unknown_protein_clusters/blob/master/img/cl_func_eval/shingl_jacc_all_sc.jpg" width="300"><img src="https://github.com/ChiaraVanni/unknown_protein_clusters/blob/master/img/cl_func_eval/shingl_jacc_all_raw.jpg" width="300">

Based on the type of annotations in each cluster:

| Annot. clusters |     HA    |  MoDA |   MuDA  |
| :-------------: | :-------: | :---: | :-----: |
|    1,205,124    | 1,083,045 | 7,572 | 114,507 |

> **HA:** Homogeneous annotations  
> **MoDA:** Mono-domain different annotations  
> **MuDA:** Multi-domain different annotations

## Integrating both cluster evaluations strategies

We combined both strategies to have a selection with the highest quality clusters. From 2,624,229 protein clusters:

**Clusters with &lt;= 10% rejected sequences (2,614,684)**

|   Clusters  | Rep-annot | Norep-annot |  No-annot |
| :---------: | :-------: | :---------: | :-------: |
| 2,614,684   |  948,070  |   251,858   | 1,414,756 |
|      -      |   **HA**  |   **MoDA**  |  **MuDA** |
|      -      | 1,079,301 |    7,501    |  113,126  |

**Clusters with > 10% rejected sequences (9,545)**

| Clusters | Rep-annot | Norep-annot | No-annot |
| :------: | :-------: | :---------: | :------: |
|  9,545   |   4,437   |     759     |   4,349  |
|      -   |   **HA**  |   **MoDA**  | **MuDA** |
|     -    |   3,744   |      71     |   1,381  |

A more detailed view of the relationship between the proportion of rejected ORFs identified by LEON-BIS and the average ORF similarity in each cluster (In red rejected clusters).

<img src="https://github.com/ChiaraVanni/unknown_protein_clusters/blob/master/img/cl_msa_eval/evalAB.jpg" width=“110%” height=“110%” >

In total we kept **2,614,684** protein clusters with less than 10% rejected sequences. From those, we removed those clusters that had median Jaccard similarity &lt; 1. In total, we had **2,608,331** high quality clusters.

|  Good clusters  | Bad clusters |
| :-------------: | :----------: |
| 2,608,331 (99%) |  15,898 (1%) |

* * *

Summary of the clusters that have been removed for the downstream analyses:

|  Pfam-DUF  | Pfam-not-DUF | Not-annotated |
| :--------: | :----------: | :-----------: |
| 549 (2,6%) |  11,00 (70%) | 4,349 (26.4%) |

Summary of the clusters that are included for the downstream analyses:

|    Pfam-DUF    |    Pfam-not-DUF   |   Not-annotated   |
| :------------: | :---------------: | :---------------: |
| 65,456 (2.5%)  | 1,128,119 (43,2%) | 1,414,756 (54.3%) |
