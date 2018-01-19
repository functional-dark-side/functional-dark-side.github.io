---
layout: page
title: Clustering and annotation
---

Our pipeline starts predicting the ORFs with Prodigal from the metagenomic assemblies. Then annotates all ORFs in our data set and performs a _de novo_ protein clustering.  

<div class="img_container img-responsive">
![](/img/pipeline_annotation.png){:height="80%" width="80%"}
</div>

<h2 class="section-heading  text-primary">Annotation</h2>

The predicted ORFs in the metagenomic samples are functionally annotated using the Pfam database of protein domain families (version 30.0) [26], with the hmmsearch program from the HMMER package (version: 3.1b2) [27]. We will only accept those non-overlapping hits with an e-value &lt; 1e-5 and a coverage > 0.4.

<h2 class="section-heading  text-primary">Clustering</h2>

To get a biologically meaningful partitioning and reduce data redundancy, we will perform a [cascaded clustering](https://github.com/soedinglab/MMseqs2/wiki#cascaded-clustering) of our ORFs set. The cascaded clustering will be performed using the MMSeqs2 (Many-against-Many sequence searching 2) software [28], which allows a fast and deep clustering of large datasets, based on sequence similarity and greedy set cover approach to identify the clusters.

<div class="img_container img-responsive">
![](https://github.com/soedinglab/MMseqs2/wiki/images/cluster-cascaded-clustering-workflow.png){:height="50%" width="50%"}
</div>

For more information related to the clustering process check MMseqs2 [wiki](https://github.com/soedinglab/MMseqs2/wiki#cascaded-clustering).

From the clustering results, we will remove those clusters with less than 10 members and the further analyses will be performed only on the subset with ≥ 10 members.
