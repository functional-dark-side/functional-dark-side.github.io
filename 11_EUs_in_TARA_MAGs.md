---
layout: page
title: EU clusters in the TARA Ocean MAGs
---


<h2 class="section-heading  text-primary">Environmental unknown in the context of Metagenome assembled genomes</h2>

<h3 class="section-heading  text-primary">Methods</h3>

We searched the manually curated collection of 957 MAGs from TARA metagenomes [[1]](#1) against our dataset of cluster profiles.
The search was performed using the MMSeqs2 search program [[2]](#2), setting an e-value threshold of 1e-20 and a query coverage threshold of 60%. The results were filtered keeping just the hits within the 90% of the Log(best-evalue). We applied a majority vote function to retrieve the consensus category for each hit. Then, we sorted the results by the smallest E-value and the largest query and target coverage to keep only the best hits.
We filtered the results of the search against the 957 TARA Ocean MAGs for the EUs, to test their presence in populations of genomes and therefore provide them with a context.
From the mapping EUs, we filtered those showing a broad distribution.
MAG contigs containing the interesting ORFs were retrieved from the Anvi’o profiles using the program anvi-export-gene-calls from Anvi’o v4 [[3]](#3). We functionally annotated the contigs using Prokka [[4]](#4) in metagenomic mode.
We then selected the contig with the lowest percentage of hypothetical proteins and drew the gene plots with the R package geno-PlotR [[5]](#5).

In addition, we used Muscle [[6]](#6) to create multiple sequence alignments of the EU communities of interest/found in the selected contig, and we plotted the conserved consensus sequence logos using the WebLogo webserver [[7]](#7).

**Scripts and description:** The search against the TARA Ocean MAG collection was perfomed using the scripts in [Coverage_ext_dbs/](scripts/Coverage_ext_dbs/), as described in [Coverage_external_DBs](Coverage_external_DBs.md). The results were then parsed to select the EUs classified as broadly distributed by the niche breadth ananlysis (you can find a description in the [Environmental_analyses](14_Environmental_analyses) report), and to explore these EU neighbours on the MAG contigs. The script used to explore the EUs in the context of MAGs is [eu_mags.R](scripts/EUs_in_TARA_MAGs/eu_mags.R).


<h3 class="section-heading  text-primary">Results</h3>

TARA Ocean collection of MAGs, manually curated by Delmont et al. [[1]](#1):

| MAGs | Contigs |    ORFs   |
|:----:|:-------:|:---------:|
| 957  | 323,552 | 2,288,202 |

<div class="img_container" style="width:70%; margin:2em auto;">

*TO-MAGs vs Clusters search results (no filtering for best-hit)*

|    MAG ORFs     |    MAGs    |    Clusters     |
|:---------------:|:----------:|:---------------:|
| 1,770,048 (77%) | 957 (100%) | 984,642 (33.5%) |

*TO-MAGs vs Clusters search results (filtered for best-hit)*

|    MAG ORFs     |    MAGs    |   Clusters    |
|:---------------:|:----------:|:-------------:|
| 1,770,048 (77%) | 957 (100%) | 319,733 (10%) |

</div>

When we filtered the results for the EUs, we obtained 7,661 MAG ORFs in 691 MAGs, and 5,420 EU clusters.

<div class="img_container" style="width:60%; margin:2em auto;">

| MAG ORFs | MAGs |  EU   |
|:--------:|:----:|:-----:|
|  7,661   | 691  | 5,420 |

</div>


The 5,420 EUs found in the MAGs, are grouped in 4,365 cluster communities.

Then, we focused on the 71 EU cluster communities broadly distributed in the TARA samples (3,119 clusters), which are found in 83 MAGs.

The methods used to identify the broadly distributed cluster communties can be found in the [Environmental_analyses](13_Environmental_analyses).

We then selected the MAG with the higher number of broadly-distributed EUs, which resulted to be the Atlantic North West MAG "TARA_ANW_MAG_00076". This MAG contains 23 EUs (0.3%) of its ORFs, and it has a completion of 21%. It belongs to the Bacteria domain. Of its 1,283 contigs, 317 contain at least an EU. These contigs were functionally annotated with Prokka (and Pfam).
The contig with less hypothetical proteinresulted to be "TARA_ANW_MAG_00076_000000000672", with 13 annotated genes, of which 7 to characterised proteins. The second contig in terms of percentage of characterised proteins is "TARA_ANW_MAG_00076_000000001247", with 9 characterised ORFs over 20.

The contig "TARA_ANW_MAG_00076_000000000672" (or "-672") contains 2 EU clusters,"24852200" and "18683007", of 286 and 251 ORFs respectively. They belong to two different communities, c_769 the first and c_5081 the second. The average length of the ORFs is 144aa and for the second 109aa. The ORFs they match in the MAGs are 331nt and 436nt long.

In the contig we found four hypothetial proteins annotated to four different GU clusters (cluster IDs ordered as found on the contig: "20218868", "16730303", "19865874", "22085915")

The characterised proteins are Laminin_G_3, dUTPase (Deoxyuridine 5'-triphosphate nucleotidohydrolase), PhoH, Zn-ribbon_8, and Protein RecA

PhoH is a cytoplasmic protein and predicted ATPase that is induced by phosphate starvation and belongings to the phosphate regulon (pho) in Escherichia coli

ORFs length stats for the two found EU cluster communities:
**eu_c_769:** min=112     mean=142.3826    median=144      max=173
**eu_c_5081:** min=84      mean=107.6189    median=109      max=139

<div class="img_container" style="width:90%; margin:2em auto;">

<img alt="MAG_perc_EU_completion.png" src="/img/MAG_perc_EU_completion.png" width="42%" height="" > &emsp;&emsp;&emsp;  <img alt="MAG_hypo_char.png" src="/img/MAG_hypo_char.png" width="35%" height="" >

*Left figure: histogram of TARA MAG percent completeness (checkM). Red line represents the number of EUs found in the MAGs. Right figure: contigs from TARA MAGs TARA_ANW_MAG_00076 in descending order of highest proportion of non-hypothetical ORF content.*

</div>

<div class="img_container" style="width:80%; margin:2em auto;">

<img alt="TARA_ANW_MAG_00076_contig672_genes.png" src="/img/TARA_ANW_MAG_00076_contig672_genes.png" width="" height="" >

*Contig genomic neighborhood around a two EU communties.*

</div>


<br>

<div class="img_container" style="width:70%; margin:2em auto;">

<img alt="MAG_EU_comm_LOGO.png" src="/img/MAG_EU_comm_LOGO.png" width="" height="" >

*Conserved consensus sequence logos of eu_com_769 and eu_com_5081.*

</div>

<br>

* * *

<h4 class="section-heading  text-primary">References</h4>

<a name="1"></a>[1] Delmont, Tom O., Christopher Quince, Alon Shaiber, Özcan C. Esen, Sonny Tm Lee, Michael S. Rappé, Sandra L. McLellan, Sebastian Lücker, and A. Murat Eren. 2018. “Nitrogen-Fixing Populations of Planctomycetes and Proteobacteria Are Abundant in Surface Ocean Metagenomes.” Nature Microbiology 3 (7): 804–13.
<a name="2"></a>[2] Steinegger, Martin, and Johannes Söding. 2017. “MMseqs2 Enables Sensitive Protein Sequence Searching for the Analysis of Massive Data Sets.” Nature Biotechnology
<a name="3"></a>[3] Murat Eren, A., Özcan C. Esen, Christopher Quince, Joseph H. Vineis, Hilary G. Morrison, Mitchell L. Sogin, and Tom O. Delmont. 2015. “Anvi’o: An Advanced Analysis and Visualization Platform for ‘omics Data.” PeerJ 3 (October): e1319.
<a name="4"></a>[4] Seemann, Torsten. 2014. “Prokka: Rapid Prokaryotic Genome Annotation.” Bioinformatics  30 (14): 2068–69.
<a name="5"></a>[5] Guy, Lionel, Jens Roat Kultima, and Siv G. E. Andersson. 2010. “genoPlotR: Comparative Gene and Genome Visualization in R.” Bioinformatics  26 (18): 2334–35.
<a name="6"></a>[6] Edgar, Robert C. 2004. “MUSCLE: Multiple Sequence Alignment with High Accuracy and High Throughput.” Nucleic Acids Research 32 (5): 1792–97.
<a name="7"></a>[7] Crooks, G. E. 2004. “WebLogo: A Sequence Logo Generator.” Genome Research.
