---
layout: page
title: Sorting the unknown
---

We defined initially four categories of _unknowns_ (might be more in the future) trying to combine an ecological and a protein domain based approach to their definition. The categories are defined as follow:

-   **KNOWN**: Our knowns are all those ORFs that contains a Pfam domain. We are developing an approach to assign function to the unknown ORFs that relies on Domain Co-cocurrence Networks and uses Pfam as a basic building block.

-   **GENOMIC UNKNOWNS**: The first categories of unknowns are those ORFs with unknown function but associated to a sequenced organism. This category would be an equivalent to the _FUnkFams_ described by [Wyman et al. 2017](https://www.biorxiv.org/content/early/2017/10/23/207985)

-   **ENVIRONMENTAL UNKNOWNS**: The second category of unkwnowns are those  ORFs with unknown function, which cannot be associated to an organism and are found only in environmental metagenomes

-   **GENOMIC POPULATION UNKNOWNS**: The third category of unkwnowns are those environmental unknowns that have been identified in population genomes (aka Metagenome Assembled Genomes) and now we have a genomic context. Those are candidates to become a genomic unknown in the future.

<br />
<h2 class="section-heading  text-primary">A bioinformatic pipeline to classify the unknown</h2>

We have implemented a bioinformatic pipeline that performs the partitioning of metagenomic datasets on the different categories of KNOWNS and UNKNOWNS.

We start from a de-novo clustering of all environmental ORFs and continue through a complex pipeline that validates and characterizes those clusters. For a more detailed explanation of the pipeline check how we [create](Clustering) the protein clusters, how we do the [validation](Validation) or how we [classify](Classification) them.

![](/img/pipeline_overview.png){:class="img-responsive"}
