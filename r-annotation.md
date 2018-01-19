---
layout: page
title: Clustering and annotation results
---

This is a summary of the different results of the clustering and functional annotation results, check the individual section for a detailed explanation.

<div class="img_container img-responsive">
![](/img/results_annotation.png){:height="80%" width="80%"}
</div>

<h2 class="section-heading  text-primary">Cascaded clustering</h2>

As the first step in the evaluation of the clustering results we report:

1.  Total number of clusters for each level in the cascaded clustering (we keep the intermediate results of the clustering) and report the size of each cluster and it’s related statistics (average, min, max).
2.  The representative sequences of the last clustering steps
3.  Filtering of the clusters with less than 10 members and labeling of the singletons

The results of the clustering process are:

<div class="img_container" style="width:50%; margin:5em auto;">

|                     |   Clusters  |
| :-----------------: | :---------: |
|     **Initial**     | 322,248,552 |
| **Redundancy step** | 137,568,876 |
|  **Cluster step 0** |  67,369,644 |
|  **Cluster step 1** |  42,891,295 |
|  **Cluster step 2** |  35,267,181 |
|  **Cluster step 3** |  32,465,074 |

</div>

And the results after the filtering based on the number of members for each cluster:

<div class="img_container" style="width:50%; margin:5em auto;">

|                                 | Number of clusters |
| ------------------------------- | :----------------: |
| Singletons                      |     19,911,324     |
| Clusters 1 &lt; members &lt; 10 |      9,549,853     |
| Clusters > 10 members           |      3,003,897     |
| **Total**                       |   **35,232,299**   |

</div>

For our downstream analyses we only will use **3,003,897** clusters

<h2 class="section-heading  text-primary">Functional annotation</h2>

The predicted ORFs in the metagenomic samples were functionally annotated using the [Pfam](http://pfam.xfam.org/) database of protein domain families (version 31.0), with the _hmmsearch_ program from the [HMMER](http://hmmer.org/) package (version: 3.1b2). We only accepted those hits with an e-value &lt; 1e-5 and a coverage > 0.4.

<div class="img_container" style="width:50%; margin:5em auto;">

|                               |      Counts     |
| ----------------------------- | :-------------: |
| Number of ORFs                |   322,248,552   |
| hmmsearch vs pfam31 output    |   191,326,768   |
| Parsed hmmsearch output       |        NA       |
| **Unique ORFs ids annotated** | **140,352,580** |

</div>
We combined the results of the annotation against the Pfam database and the clustering process, to retrieve the position of the annotated sequences in the clusters. Based on this information we defined three sets of clusters:

1.  Clusters where the representative sequence is annotated
2.  Clusters where at least one member is annotated (representative excluded)
3.  Clusters where no member is annotated

For the first category, _Clusters where the representative sequence is annotated_:

<div class="img_container" style="width:50%; margin:5em auto;">

| Clusters with annotated representatives        |   644,996   |
| :--------------------------------------------- | :---------: |
| Members in clusters where repres. is annotated | 135,474,074 |
| Annotated members (repres. included)           | 124,714,342 |
| Not annotated members                          |  10,759,732 |

</div>
And for the second one, _Clusters where at least one member is annotated (representative excluded)_:

<div class="img_container" style="width:50%; margin:5em auto;">

| Clusters with at least one member annotated   |   370,928  |
| :-------------------------------------------- | :--------: |
| Representative annotated (clusters)           |   929,946  |
| Representatives not annotated (clusters)      |   644,996  |
|                                               |            |
| Total members                                 | 45,959,467 |
| Members with an annotation (repres. included) | 11,493,727 |

</div>

And for the third category, _Clusters where no member is annotated_:

<div class="img_container" style="width:50%; margin:5em auto;">

| Clusters with no annotated members |  1,987,973 |
| :--------------------------------- | :--------: |
| Total members not annotated        | 87,034,222 |

</div>
