---
layout: page
title: Classification of the unknowns
---

The subset of “good” clusters will be further processed to identify the two different categories of unknowns: the **genomic unknowns** and the **environmental unknowns**. As a reminder:

-   **KNOWN**: Our **knowns** are all those ORFs that contains a Pfam domain. We are developing an approach to assign function to the unknown ORFs that relies on Domain Co-cocurrence Networks and uses Pfam as a basic buiding block.

-   **GENOMIC UNKNOWNS**: The first categories of unknowns are those ORFs with unknown function but associated to a sequenced organism. This category would be an equivalent to the _FUnkFams_ described by [Wyman et al. 2017](https://www.biorxiv.org/content/early/2017/10/23/207985)

-   **ENVIRONMENTAL UNKNOWNS**: The second category of unkwnowns are those  ORFs with unknown function, which cannot be associated to an organism and are found only in environmental metagenomes

-   **GENOMIC POPULATION UNKNOWNS**: The third category of unkwnowns are those environmental unknowns that have been identified in population genomes (aka Metagenome Assembled Genomes) and now we have a genomic context. Those are candidates to become a genomic unknown in the future.

We will use a combination of searches against UniRef and NCBI nr protein databases.

<div class="img_container img-responsive">
![](/img/pipeline_classification.jpeg){:height="50%" width="50%"}
</div>

All the searches have the following characteristics:

<div class="img_container img-responsive">
![](/img/pipeline_classification_2bl.png){:height="50%" width="50%"}
</div>

<h2 class="section-heading  text-primary">Genomic unknowns</h2>

In order to relate the filtered “good” subset of clusters (i.e. those with less than 10% rejected sequences and a high functional homogeneity, with no Pram annotation) with the “_hypothetical/uncharacterized_” proteins found in sequenced genomes, we will perform a search against the UniProt Reference Clusters (release 2017_08) from the UniProt Knowledgebase [33]. Specifically we will search UniRef90, which provides clusters of sequences with a sequence similarity > 90%, using as queries all the cluster representative sequences.
The genomic unknowns subset is represented by the queries that report annotated to “\_hypothetical_” or “_uncharacterized_” proteins and by those clusters annotated to Pfam Domains of Unknown Function (DUFs). The search will be performed using the search command of MMSeqs2 (-e 1e-5 —cov-mode 2 -c 0.6). The non-annotated clusters that will report a hit to non-hypothetical proteins will be discarded from the next analyses steps.

> We classified each representative of the cluster as genomic unknown if all the hits that fall in the 90% of the best log10evalue are classified as hypothetical.

<h2 class="section-heading  text-primary">Environmental unknowns</h2>

The sequences that will not report any matches with UniRef90 entries will be searched against the NCBI nr database (latest release) (<http://www.ncbi.nlm.nih.gov>) [34]. The NCBI nr is a database maintained by NCBI that contains sequences from GenBank translations (i.e. GenPept) [35], Refseq [36], PDB (Protein Data Bank) [37], SwissProt [38], PIR (Protein Identification Resource) [39] and PRF (Protein Research Foundation, Japan). It is the single largest publicly available protein resource [40]. For our search we will download the fasta format file from the NCBI ftp site (ftp://ftp.ncbi.nih.gov/blast/db/FASTA/nr.gz), and use MMSeqs2 for the search, using the same parameters as described in the previous section.
The environmental unknowns are represented by those queries without any match to nr entries. The not annotated clusters that will report matches to nr entries will be discarded.
