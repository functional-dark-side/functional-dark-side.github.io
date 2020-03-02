---
layout: page
title: Cluster validation
---

An evaluation of the clustering is necessary to compare the functional homogeneity of the sequences within the same cluster [[1]](#1).
The ORF clusters represent the basis of all the further analyses; hence we need to ensure a good clustering quality in terms of high intra-cluster homogeneity.

<h3 class="section-heading  text-primary">Methods</h3>

We proceeded with the validation of both annotated and not annotated clusters following two different strategies: i) we evaluated clusters homogeneity at the sequence level, based on an estimation of the homologous and non-homologous relations between sequences in a protein multiple alignment; and ii) we measured the functional homogeneity within the clusters, based on the members functional annotations.
A detailed description of both methods follows:

**A) Compositional homogeneity**
To identify improper/incongruous sequences inside each cluster, we performed a multiple sequence alignment (MSA) within each cluster, using the FAMSA fast multiple alignments program [[2]](#2) (version 1.1). To evaluate the MSAs of clusters with a size ranging between 10 and 1K ORFs, we then used LEON-BIS [[3]](#3), a method that allows the accurate detection of conserved regions in multiple sequence alignments, via Bayesian statistics, identifying the non-homologous sequences with respect to the cluster representative. LEON-BIS proved to be too computationally expensive in processing clusters with more than 1K ORFs, thus we proceeded with OD-SEQ [[4]](#4), a tool that identifies outliers ORFs based on their average distance from the other sequences. In the end, We applied the broken-stick model [[5]](#5) to the detected incongruous ORFs distribution in the clusters to determine the cut-off number above which we classified a cluster as “bad”. In parallel we applied PARASAIL [[6]](#6) (version 2.1.5), a C library for global, semi-global and local alignments, to retrieve the ‘all vs all’ similarities (pairwise similarities) within each cluster and build the correspondent sequence similarity network (SSN), i.e. an homology graph where the nodes are the ORFs and the edges the similarities). We thus trimmed the SSN using an algorithm that removes edges while maintaining the structural integrity, and we used a measure of centrality (specifically the eigenvector centrality) to refine the cluster representative selection and identify a proper representative sequence for each cluster (more details in the next paragraph/supplementary).

<img alt="pipeline_validation_ch.png" src="/img/pipeline_validation_ch.png" width="400" height="" >

*Cluster compositional homogeneity validation scheme.*

- **Scripts and description:** The input for the compositional validation main script, [compos_val.sh](scripts/Cluster_validation/compositional/compos_val.sh), is the cluster sequence DB. The output is a tab-formatted file containing the new representatives and the results from the MSA evaluation expressed/measured in terms of number and proportion of bad-aligned sequences per cluster. For more detailed info check the [README_comp.md](scripts/Cluster_validation/compositional/README_comp.md) file.

**B) Functional homogeneity**
Since our predicted ORFs can have multiple (multi-domain) annotations, in different orders, we investigated the functional composition of the annotated clusters applying a combination of text mining and Jaccard similarity. As text mining technique we used Shingling, a method commonly used in the field of language processing to represent documents as sets. A k-shingle is a consecutive set of k words. Once transformed the protein domain annotations of each cluster’s member into shingle sets, we calculated the Jaccard similarity between sets of shingles as the ratio between distinct shared shingles and distinct unshared shingles between two members. The median Jaccard similarity score was calculated for each cluster and scaled by the percentage of annotated members. Since different Pfam domains can be grouped into the same clan (_"A collection of related Pfam entries. The relationship may be defined by similarity of sequence, structure or profile-HMM."_), we decided to consider completely homogeneous those clusters annotated to the same clan.
In addition Pfam contains both C-terminal, N-terminal and few times the M-(middle) domains of some proteins, hence (since we are dealing with fragmented ORFs) we decided to consider completely homogeneous those clusters annotated to different domains of the same protein.

<img alt="Funct_val_scheme.png" src="/img/Funct_val_scheme.png" width="400" height="" >

*Cluster functional homogeneity validation: general scheme.*

<img alt="pipeline_validation_fh_cases.png" src="/img/pipeline_validation_fh_cases.png" width="350" height="" >

*Cluster functional homogeneity validation: illustration of different possible cases inside the clusters.*

More in detail, the evaluation of the functional homogeneity is based on the following decisions:

<img alt="pipeline_validation_fh.jpeg" src="/img/pipeline_validation_fh.jpeg" width="450" height="" >

1.  If all the cluster members are annotated to the same Pfam domain (_"Homog_pf"_) Shingling is not applied and the Jaccard similarity index is calculated, and scaled for the percentage of annotated members.

2.  If all the cluster members are annotated to different Pfam domains belonging to the same clan (_"Homo_clan"_) Shingling is not applied and the Jaccard similarity index is calculated, and scaled for the percentage of annotated members.

3.  If the annotations (domains - clans) are not completely homogeneous, we look for different terminal (or middle) domains of the same protein.
    -   If all the cluster members are terminal/middle domains of the same protein (_"Homog_pf_term"_) Shingling is not applied and the Jaccard similarity index is calculated, and scaled for the percentage of annotated members.

In the case, that any of the conditions is true, we will check if the cluster contains only mono-domain annotations, or also multi-domain?

1.  _”Mono"_: Shingling is not applied and the Jaccard similarity index is calculated, both for Pfam domains (_"Mono_pf"_) and clans (_"Mono_clan"_) annotations, and scaled for the percentage of annotated members. The higher index (between domains and clans) is reported.

2.  If a cluster contains also multi-domain annotations, does it contains also ORFs with mono-domain annotations?

    -   If **yes**: The Jaccard similarity index is calculated for the ORFs with mono-annotations (_"Singl_pf"_ or _"Singl_clan"_) and scaled by their proportion. The domains/clans of the members with multi-annotations (_"Multi_pf"_ or _"Multi_clan"_) are transformed into shingle sets (k=2), the Jaccard similarity is calculated on them and scaled by the proportion of ORFs with multi-annotations.

    -   If **no**: The domains/clans of the clusters with multi-annotations (_"Multi_pf"_ or _"Multi_clan"_) are transformed into shingle sets (k=2), the Jaccard similarity index is calculated on them and scaled by the proportion of ORFs with multi-annotations (i.e. the annotated ORFs in the cluster).

The overall higher Jaccard indexes (between domains and clans) are chosen/reported.


*Annotated cluster functional homogeneity validation scheme.*

- **Scripts and description:**: The annotated clusters are processed through the R script [eval_shingl_jacc.r](scripts/Cluster_validation/functional/eval_shingl_jacc.r). The output is a summary tad-formatted table with info about the each cluster functional homogeneity, measured by the median of the jaccard similarity indexes per cluster. Additional info about the scripts and the output can be found in the [README_func.md](scripts/Cluster_validation/functional/README_func.md).


We combined the two validation results and we saved/stored them in the form of a SQLiteDB (database).

- **Scripts:** [validation_res.sh](scripts/Cluster_validation/validation_res.sh), which parse the raw compositional validation results retrieving info about the cluster old representatives and the annotations and [validation_res.r](scripts/Cluster_validation/validation_res.r), R script that combines and summarises the results, saves them in a database and generates some report plots. More info in the [README_val.md](scripts/Cluster_validation/README_val.md).

<h3 class="section-heading  text-primary">Results</h3>

The **compositional homogeneity** evaluation of the clusters confirmed a good cluster quality at the sequence level. Of the ∼3 million clusters 249,506 (8%) contain a rejected sequence (i.e., bad-aligned sequence). We identified the proportion of rejected sequences that defines a cluster as "bad" at 10% of the ORFs in a cluster. About 46K (1.9%) clusters resulted classified as “bad”.

<img alt="Comp_val_prop_non_homolog.png" src="/img/Comp_val_prop_non_homolog.png" width="650" height="" >

<img alt="Comp_val_bad_clu.png" src="/img/Comp_val_bad_clu.png" width="600" height="" >

*Number of clusters as a function of the proportion of rejected ORFs per cluster.*

<img alt="Comp_size_non_homolog.png" src="/img/Comp_size_non_homolog.png" width="450" height="" >

*Size distribution of the kept and rejected clusters.*

We observed an overall high **functional homogeneity** for the set of annotated clusters. Only 1% of the annotated clusters reported a Jaccard similarity index < 1.


The **combination** of the results of both cluster evaluations led to a set of 2,946,845 (98.1%) “good” clusters and 57,052 (1.9%) “bad” clusters. The number of ORFs in the two sets is shown in the following table.

<div class="img_container" style="width:50%; margin:2em auto;">

*Number "good" and "bad" clusters defined after the validation and number of ORFs in them.*

|      Good Clusters     |     Bad Clusters      |
|:----------------------:|:---------------------:|
|     2,946,845 (98.1%)  |       57,052 (1.9%)   |
| **Good Clusters ORFs** | **Bad Clusters ORFs** |
|    263,022,636 (98%)   |     5,445,127 (2%)    |

</div>

The proportion of rejected sequences appears to decrease at the increasing of the intra-cluster average similarity, as shown in the plots of the next figure.

<img alt="Valid_non_homolog_vs_clu_simil.png" src="/img/Valid_non_homolog_vs_clu_simil.png" width="60%" height="" >

*Relationship between the proportion of rejected ORFs identified and the average ORF similarity within each cluster (In red rejected clusters).*

We don’t observe a particular correlation between the number of bad-aligned ORFs and the annotation status of the clusters.

We compared the two validation steps for the set of annotated clusters, and we found that they agree in the identification of homogeneous and non-homogeneous clusters. As reported in the following Table, only 2% of the annotated clusters (and 2% of their ORFs) show discordant results between the two validations.

<div class="img_container" style="width:90%; margin:2em auto;">

*Cluster validation result comparison*

| CLUSTERS           | Functional BAD | Functional GOOD | <span style="color:grey">Not annotated clusters</span> |
| ------------------ |:--------------:|:---------------:|:------------------------------------------------------:|
| Compositional BAD  |    **337**     |      9,006      |         <span style="color:grey">36,288</span>         |
| Compositional GOOD |     11,421     |   **995,160**   |     <span style="color:grey">**1,951,685**</span>      |

| ORFs               | Functional BAD | Functional GOOD | <span style="color:grey">Not annotated clusters</span> |
| ------------------ |:--------------:|:---------------:|:------------------------------------------------------:|
| Compositional BAD  |   **19,956**   |     990,903     |       <span style="color:grey">1,188,266</span>        |
| Compositional GOOD |   3,246,002    | **177,176,680** |     <span style="color:grey">**85,845,956**</span>     |

</div>

<br>
<br>

* * *

<h4 class="section-heading  text-primary">References</h4>

<a name="1"></a>[1]	M. Mirdita, L. von den Driesch, C. Galiez, M. J. Martin, J. Söding, and M. Steinegger, “Uniclust databases of clustered and deeply annotated protein sequences and alignments,” Nucleic Acids Research, vol. 45, no. D1, Jan. 2017.

<a name="2"></a>[2]	S. Deorowicz, A. Debudaj-Grabysz, and A. Gudyś, “FAMSA: Fast and accurate multiple sequence alignment of huge protein families.,” Scientific reports, vol. 6, p. 33964, Sep. 2016.

<a name="3"></a>[3]	R. Vanhoutreve, A. Kress, B. Legrand, H. Gass, O. Poch, and J. D. Thompson, “LEON-BIS: multiple alignment evaluation of sequence neighbours using a Bayesian inference system.,” BMC bioinformatics, vol. 17, no. 1, p. 271, Jul. 2016.

<a name="4"></a>[4]	P. Jehl, F. Sievers, and D. G. Higgins, “OD-seq: outlier detection in multiple sequence alignments.,” BMC bioinformatics, vol. 16, p. 269, Aug. 2015.

<a name="5"></a>[5]	Bennett, K. D. 1996. “Determination of the Number of Zones in a Biostratigraphical Sequence.” The New Phytologist 132 (1): 155–70.

<a name="6"></a>[6] J. Daily, “Parasail: SIMD C library for global, semi-global, and local pairwise sequence alignments.,” BMC bioinformatics, vol. 17, p. 81, Feb. 2016.
