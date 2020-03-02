---
layout: page
title: Sequence clustering with MMseqs2
---

To get a biologically meaningful partitioning and reduce data redundancy, we performed a cascaded clustering of our ORFs set, using a final similarity threshold of 30%.

<h3 class="section-heading  text-primary">Methods</h3>

We chose a sequence similarity-based method, because a higher speed characterizes it compared to other approaches, like the graph-based clustering methods, and therefore considered more suitable to be applied to the massive metagenomic datasets.
The cascaded clustering was performed using the MMseqs2 (Many-against-Many sequence searching 2) open-source software [[1]](#1), which allows a fast and deep clustering of large datasets, based on sequence similarity and greedy set cover approach to identify the clusters. We selected a coverage threshold of 80%, a sequence identity threshold of 30% and a sensitivity of 5.

The obtained cluster database was filtered based on cluster size. We first removed the singletons (clusters form by only one gene). Then, applying the broken-stick model, we determined a cluster-size threshold below which a cluster is discarded.


- **Scripts and description**: The input for the script [clustering.sh](scripts/MMseqs_clustering/clustering.sh) is the multi-fasta file containing the predicted ORFs (amino acids). The sequences are clustered down to 30% sequence similarity and the results are parsed by the scripts [clustering_res.sh](scripts/MMseqs_clustering/clustering_res.sh) and [cluster_info.sh](scripts/MMseqs_clustering/cluster_info.sh). From the parsing we obtain a sequence database of the clusters, tables containing information about the cluster representative, the size and the cluster members and we identified the set of clusters with more than 10 ORFs, those with less and the set of singletons. For more information check the [README_clu.md](scripts/MMseqs_clustering/README_clu.md) file.


<h3 class="section-heading  text-primary">Results</h3>

The dataset of predicted ORFs proved to be rather redundant. The clustering step identified 32,465,074 clusters, represented by a non-redundant sequence, from the original 322,248,552 ORFs and yielded a 90% reduction rate. From the ~32 million clusters at/with 30% level of homology.
We filtered out ~19M singletons and ~9.5M clusters with a number of genes found below the broken-stick threshold of 10genes per cluster.
For our downstream analyses we only will use the remaining **3,003,897** clusters (with ≥ 10 genes).

<br>

<div class="img_container" style="width:50%; margin:2em auto;">

*Cascaded clustering results*

|                     |  Clusters   |
|:-------------------:|:-----------:|
|     **Initial**     | 322,248,552 |
| **Redundancy step** | 137,568,876 |
| **Cluster step 0**  | 67,369,644  |
| **Cluster step 1**  | 42,891,295  |
| **Cluster step 2**  | 35,267,181  |
| **Cluster step 3**  | 32,465,074  |

</div>

Total number of clusters for each level in the cascaded clustering (we keep the intermediate results of the clustering) and report the size of each cluster and it’s related statistics (average, min, max).

<div class="img_container" style="width:100%; margin:2em auto;">

*Parsed clustering results*

|          |    Total    | Clusters ≥ 10 ORFs | Clusters 1< ORFs < 10 | Singletons |
| -------- |:-----------:|:------------------:|:---------------------:|:----------:|
| Clusters | 32,465,074  |     3,003,897      |       9,549,853       | 19,911,324 |
| ORFs     | 322,248,552 |    268,467,763     |      33,869,465       | 19,911,324 |

</div>

The clustering general results after the filtering based on the number of members, i.e. genes, for each cluster.

<br>
<br>

<img alt="MG_mmseqs_clustering_res.png" src="/img/MG_mmseqs_clustering_res.png" width="80%" height="" >

*Clustering results: (a) Percentage of clusters in the different sets and (b) percentage of ORFs in the different cluster sets.*

<br>

#### Cluster sizes

<img alt="MG_cluster_size_threshold.png" src="/img/MG_cluster_size_threshold.png" height="" width="60%">

*Cluster size distribution. The red line indicates the "breaking point" of the distribution, which corresponds to clusters of ~10 ORFs.*

* * *

<h4 class="section-heading  text-primary">References</h4>

<a name="1"></a>[1]	M. Steinegger and J. Söding, “MMseqs2 enables sensitive protein sequence searching for the analysis of massive data sets.,” Nature biotechnology, vol. 35, no. 11, pp. 1026–1028, Nov. 2017.
