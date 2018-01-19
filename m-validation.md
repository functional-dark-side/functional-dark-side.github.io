---
layout: page
title: Cluster validation
---

<div class="img_container img-responsive">
![](/img/pipeline_validation.png){:height="80%" width="80%"}
</div>

The ORF clusters represent the basis of all the further analyses; hence we need to assure a good clustering quality in terms of high intra-cluster homogeneity. We will follow two different strategies to evaluate the clusters: We will evaluate clusters homogeneity at the sequences level, based on a Bayesian estimation of the homologous relations between sequences in a protein multiple alignment; and we will measure the functional homogeneity within the clusters, based on the members functional annotations. Even though MMseqs2 is doing an awesome job, implementing these extra validation steps will add an extra layer of robustness for the _de novo_ clustering results.

<h2 class="section-heading  text-primary">Compositional homogeneity</h2>

The idea behind this first validation approach is to identify the cluster homogeneity in terms of sequence composition and similarity. We try to identify rogue sequences inside each cluster. In addition we will refine the cluster representative selection.  

<div class="img_container img-responsive">
![](/img/pipeline_validation_ch.png){:height="50%" width="50%"}
</div>

First we use MMSeqs2 (—cov-mode 0 -c 0.8) to retrieve cluster similarity scores among all members to create a sequence similarity network (SSN). In this network, the nodes are the ORFs and the edges the identities. Once we have this SSN, we will trim it using an algorithm that removes edges while maintaining the structural integrity,  and we will use a measure of centrality (eigenvector centrality) to identify the representative (more details [here](Protein-cluster-representative-refinement)). Being able to infer the best representative is crucial to evaluate the cluster compositional homogeneity; in addition, this representative is going to be used on all downstream analyses.  
Once the representative has been identified, we perform a multiple sequence alignment within each cluster, using the FAMSA fast multiple alignment program. The alignments are evaluated by LEON-BIS, a method that allows the accurate detection of conserved regions in multiple sequence alignments, via Bayesian statistics, identifying the non-homologous sequences with respect to the cluster representative. In the end, we will define as “bad” these clusters with more than 10% of bad aligned ORFs.

<h2 class="section-heading  text-primary">Functional homogeneity</h2>

Since our predicted ORFs can present multiple annotations, in different orders, we investigated the inside of the clusters applying a combination of text mining and Jaccard similarity index.

<div class="img_container img-responsive">
![](/img/pipeline_validation_fh_cases.png){:height="50%" width="50%"}
</div>

As text mining technique we chose Shingling, a method commonly used, in the field of language processing, to represent documents as sets. It takes consecutive words and groups them as a single object. A k-shingle is a consecutive set of k words. Once transformed the protein domain annotations, of each cluster member, into shingle sets, we used the Jaccard Similarity to measure the similarity between sets of shingles. Jaccard Similarity was calculated for each cluster as the ratio between distinct shared shingles and distinct unshared shingles between two members, (without taking into account the domains abundance). The median Jaccard score was calculated for each cluster and scaled by the percentage of annotated members.

Since different Pfam domains can be grouped into the same clan (_"A collection of related Pfam entries. The relationship may be defined by similarity of sequence, structure or profile-HMM."_), we decided to consider completely homogeneous those clusters annotated to the same clan.  
In addition Pfam contains both C-terminal, N-terminal and few times the M-(middle) domains of some proteins, hence (since we are dealing with fragmented ORFs) we decided to consider completely homogeneous those clusters annotated to different domains of the same protein.

> **Note:** Now we are going to use the representatives that we inferred when validation the compositional homogeneity.

<h3 class="section-heading  text-primary">Logic behind the evaluation</h3>

The evaluation of the functional homogeneity is based on the following decisions:

<div class="img_container img-responsive">
![](/img/pipeline_validation_fh.jpeg){:height="80%" width="80%"}
</div>

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
