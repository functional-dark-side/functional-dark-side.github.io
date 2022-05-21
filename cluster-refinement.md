---
layout: page
title: Cluster refinement
---

<h3 class="section-heading  text-primary">Methods</h3>

After the validation, we proceeded with the retrieval of a subset of high-quality clusters. At first, we removed the clusters containing ≥10% bad-aligned ORFs and a Jaccard similarity index < 1 and the clusters with ≥ 30% shadow ORFs. From the remaining set of clusters, we removed the single shadow, spurious and/or bad-aligned ORFs.
Steps:

I) Filter out “bad” clusters (≥ 10% bad-aligned ORFs & Jaccard similarity index \<1)
II) Filter out “shadow” clusters (≥ 30% shadow ORFs)
III) Remove the single rejected/bad ORFs (shadow, spurious and bad-aligned)

<h3 class="section-heading  text-primary">Results</h3>

From the set of 3,003,897 clusters, we removed 57,052 clusters classified as “bad” after the validation. From the remaining 2,946,845 clusters we removed 6,252 clusters with more than 30% shadow ORFs. At the end from each of the left 2,940,593 clusters, we removed a total of 2.7 million single shadow, spurious and bad-aligned ORFs, and we obtained a set of 2,940,592 refined clusters with a total of 260,142,446 ORFs. In this last step we lost 336 clusters: 244 resulted composed of only spurious and bad aligned ORFs, one in the annotated set of clusters and 243 in the not annotated set, and 92 clusters were discarded/moved to the singletons set because left with only one sequence. Moreover, 1,190 annotated clusters became non annotated after the refinement/removal of the single ”unwanted”/”rejected” ORFs, which represented the only annotated ORFs in those clusters. Steps in numbers are shown in the tables below:

<div class="img_container" style="width:80%; margin:2em auto;">

_Steps of the cluster refinement both in terms of number of clusters and number of ORFs (kept and removed)._

<img alt="refinement_steps_clu.png" src="/img/refinement_steps_clu.png" width="80%" height="" >

<img alt="refinement_steps_ORFs.png" src="/img/refinement_steps_ORFs.png" width="80%" height="" >

</div>

<br>

Summarising: we removed 63,640 clusters and a total of 8,325,409 ORFs; they constitute the 2% and the 3% of the initial cluster and ORF sets respectively. The majority of the clusters (98%) resulted, therefore, having good quality concerning homogeneity and real/actual ORFs content. The 2.9 million refined clusters are made of ~993K annotated clusters, containing ~174M ORFs, and 1.9M unannotated clusters with about 86M ORFs.

* * *


<br />
<br />

{% capture code %}
**Cluster refinement:** 
<br />
[refinement.sh](scripts/Cluster_refinement/refinement.sh). It takes the output from the cluster validation and the shadows and spurious ORFs, and returns a refined set of clusters (tables plus ffindex databases). More info in the [README](https://raw.githubusercontent.com/functional-dark-side/functional-dark-side.github.io/master/scripts/Cluster_refinement/README_ref.md)

{% endcapture %}
{% include collapsible.html toggle-name="toggle-code" button-text="Code and description" toggle-text=code %}
