---
layout: page
title: A workflow to unify the Known and Unknown
---
We implemented a computational workflow ([Agnostos](https://www.encyclopedia.com/environment/encyclopedias-almanacs-transcripts-and-maps/agnostos-theos)) to structure and explore the large pool of genes with unknown functions found in microbial genomes and metagenomes. We used a protein domain-based approach to partition more than 400 million predicted genes from 1,628 metagenomes and ~29,000 genomes into the different categories of known and unknown.


![workflow.jpg](img/workflow.png#center){:height="50%" width="50%" align="center"} 
*Brief schematic of the workflow*


The workflow is based on Snakemake for the easy processing of large datasets in a reproducible manner. It provides three different strategies to analyze the data. The module **DB-creation** creates the gene cluster database, validates and partitions the gene clusters (GCs) in the main functional categories. The module **DB-update** allows the integration of new sequences (either at the contig or predicted gene level) in the existing gene cluster database. In addition, the workflow has a **profile-search** function to quickly screen the gene cluster PSSM profiles in the database

Follow the links for a detailed description of the methods and results for each of the steps in the workflow:

1. [Gene prediction](gene-prediction)
2. [Pfam annotations](pfam-annotation)
3. [Deep clustering](deep-clustering)
4. [Gene cluster validation](cluster-validation)
5. [Gene cluster refinement](cluster-refinement)
6. [Gene cluster classification](cluster-classification)
7. [Gene cluster category refinement](category-refinement)
8. [Gene cluster communities inference](cluster-communities)


{: .info title="Info"}
You can try the workflow [here](https://github.com/functional-dark-side/agnostos-wf). A description of the data used for the manuscript can be found [here](data)

<div class="alert alert-primary" role="alert">
  This is a primary alert—check it out!
</div>

