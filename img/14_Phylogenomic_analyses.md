---
layout: page
title: Phylogenomic - specificity
---

<h2 class="section-heading  text-primary">Phylogenomic distribution of our Clusters in the Genome Taxonomy Database tree</h2>

To understand the occurrence and distribution of the Clusters of Unknowns (CUs) in genomes, we analyzed the phylogenetic distribution of our clusters on the bacterial and archaeal genomes from the Genome Taxonomy Database (GTDB), following a similar approach as the one used in Annotree [[1]](#1). Besides finding lineage-specific CUs at lower taxonomic levels, we identified lineage-specific CUs on high taxonomic levels (class and family) that can represent functional innovations that will help to get a better understanding of the diversification processes. And second, we explored the environmental occurrence of the CUs, which revealed that a large proportion of the CUs present a narrow distribution across sites, suggesting potential adaptive value and supporting their ecological relevance. The same analysis revealed the existence of a ubiquitous fraction of CUs that have the potential to uncover new phylogenetic markers and essential functions.

<h3 class="section-heading  text-primary">Methods</h3>

*Cluster phylogenetic conservation:*
We used the phylogenetic conservation score (tauD), which is a measure of the clade depth at which traits are conserved (“It calculates the mean depth of clades containing above 90% of members sharing a trait”) and was calculated using the *consenTRAIT* function implemented in the R package *castor* [[2]](#2) and [[3]](#3).
*Cluster lineage specificity:*
Gather data: gtdb clusters, gtdb_metadata, gtdb tree and taxonomy (version 03-RS86). Prepare taxonomic and cluster data (functions adapted from https://bitbucket.org/doxeylabcrew/annotree-manuscript-scripts/src).
The lineage-specificity of a trait/cluster within a clade was measured, as in Chen et al. 2019, using standard binary classification methods. For each trait we calculated precision, which indicates the degree to which the trait is conserved within a lineage ([number of T-containing genomes in clade C] ÷ [number of genomes in clade C]), and specificity, which is the exclusivity of the trait to a lineage ([number of T-containing genomes in clade C] ÷ [number of T-containing genomes in tree P]). Then, we combined these two measures, in the F1 score to assess the ability of a clade to predict the occurrence of a trait within a phylogenetic tree:
F1 = 2 × [precision × sensitivity] / [precision + sensitivity]
We calculated the F1 score for a particular phylogenetic node and for all nodes on the tree using the given trait distribution.
A tarit/cluster was identified as lineage-specific if there was at least one node whose precision and sensitivity were both ≥95%. The node with the greatest F1 score was assigned the root of the lineage-specific clade for that trait.
We screened the resulted lineage-specific clusters, belonging to the GU category, against the set of essential DUFs (eDUFs) from [[4]](#4). For the same clusters we also investigated the environmental occurrence in terms of narrow or broad distribution. At the end we deepened the investigation of the lineage specific clusters focusing on the *Patescibacteria* phylum, and analysing their distribution in both the Human and marine (TARA and Malaspina) metagenomes.

**Scripts and description**: The script used to explore the phylogenomic distribution of our cluster in the GTDB are stored in the [Phylogenomic_analyses](scripts/Phylogenomic_analyses) folder. The main phylogenetic functions are contained in the [phylo_functions.R](scripts/Phylogenomic_analyses/phylo_functions.R) scripts, that is sourced in the main script [GTDB_phylo.R](scripts/Phylogenomic_analyses/GTDB_phylo.R). The input consists in a tab separated file containing info about clusters found in the GTDB genomes: "all_gtdb_genome_orf_cl_categ.tsv.gz" and the GTDB verion r86 contextual and taxonomic data for archaeal and bacterial genomes (bac_metadata_r86, bac_taxonomy_r86, gtdb_r86_bac.tree). This data is downloadable from the Annotree website (https://data.ace.uq.edu.au/public/misc_downloads/annotree/r86/). The plots were generated using the script [phylo_plots.R](scripts/Phylogenomic_analyses/phylo_plots.R).
The screening of the lineage specific GUs against the list of eDUFs was performed using the R script [GUs_and_eDUFs.r](scripts/Phylogenomic_analyses/GUs_and_eDUFs.r). The scripts takes as input the list of GUs with their annotations, then filter the list for the lineage-specific GUs annotated to eDUFs.
The eDUF list can be found in the paper [[4]](#4) supplementary materials [here](https://mbio.asm.org/highwire/filestream/23865/field_highwire_adjunct_files/5/mbo006131694st1.xls).

<h3 class="section-heading  text-primary">Results</h3>

Phylogenetic conservation analysis:

**Bacteria**

<img alt="phylo_conservation_bac.png" src="assets/phylo_conservation_bac.png" width="" height="" >

**Archaea**

<img alt="phylo_conservation_arc.png" src="assets/phylo_conservation_arc.png" width="" height="" >

Number of lineage specific clusters divided by category for each rank

**Bacteria**



| Category | Domain | Phylum | Class | Order | Family |  Genus  | Species |
|:--------:|:------:|:------:|:-----:|:-----:|:------:|:-------:|:-------:|
|    K     |   8    |   24   |  445  | 1,536 | 12,903 | 40,959  | 66,377  |
|   KWP    |   0    |   2    |  19   |  54   |  959   |  8,712  | 33,225  |
|    GU    |   10   |   36   |  423  | 2,378 | 28,197 | 169,885 | 377,760 |
|    EU    |   0    |   1    |   7   |  55   |  599   |  7,080  | 30,488  |

<img alt="Lineage_spec_bac.png" src="assets/Lineage_spec_bac.png" width="550" height="" >

<img alt="Lineage_spec_bac_barplot.png" src="assets/Lineage_spec_bac_barplot.png" width="350" height="" >


**Archaea**

| Category | Domain | Phylum | Class | Order | Family | Genus  | Species |
|:--------:|:------:|:------:|:-----:|:-----:|:------:|:------:|:-------:|
|    K     |   0    |   4    |  16   |  210  | 1,233  | 3,032  |  4,485  |
|   KWP    |   0    |   0    |   0   |   8   |   82   |  413   |  1,753  |
|    GU    |   0    |   1    |  25   |  377  | 2,915  | 12,482 | 18,697  |
|    EU    |   0    |   0    |   0   |   2   |   42   |  494   |  2,305  |

<img alt="Lineage_spec_arc.png" src="assets/Lineage_spec_arc.png" width="550" height="" >

<img alt="Lineage_spec_arc_barplot.png" src="assets/Lineage_spec_arc_barplot.png" width="350" height="" >
<br>
<br>
<br>
<br>

**General analysis panel (Bacteria)**

<img alt="Phylo_analysis_bac.png" src="assets/Phylo_analysis_bac.png" width="" height="" >

a) Number of lineage specific clusters as a function of the relative evolutionary divergence (RED) in the context of the GTDB bacteria tree.
b) GTDB bacterial phyla ordered based on the number of clusters of unknowns and clusters of knowns/ratio of CUs and CKs (calculated for each phylum as the sum(total unknown/known ORFs)/sum(all genome-ORFs). The size shows the number of genomes per phyla. The gradient indicates the proportion of MAGs per phylum. (Nuber of MAGs/total number of genomes)
c) Phylogenetic tree of GTDB bacterial phyla. We colored in green the phyla enriched in non-classified clusters, and in pink the phyla with a high percentage of MAGs and unknowns. The grey dots represent the number of phylum-specific clusters of unknowns. The branches are colored by the percentage of MAGs per phylum. Around the tree we drew a heatmap showing the proportion of unknowns per phylum.

**Patescibacteria example**

<img alt="Phylo_analysis_bac_patesci.png" src="assets/Phylo_analysis_bac_patesci.png" width="" height="" >

Patescibacteria metagenomic lineage specific clusters. a) Phylogenetic tree of Patescibacteria genera, grouped/colored by classes. The heatmaps around the tree show the proportion of lineage specific cluster of knowns and unknowns in the metagenomes from TARA, Malaspina and the HMP. b) Metagenomic lineage specific clusters in the class of Gracilibacteria.

<br>
<br>
<br>
<br>

**General analysis panel (Archaea)**
<img alt="Phylo_analysis_arc.png" src="assets/Phylo_analysis_arc.png" width="" height="" >

a) Number of lineage specific clusters as a function of the relative evolutionary divergence (RED) in the context of the GTDB archaea tree.
b) GTDB archaeal phyla ordered based on the number of clusters of unknowns and clusters of knowns/ratio of CUs and CKs (calculated for each phylum as the sum(total unknown/known ORFs)/sum(all genome-ORFs). The size shows the number of genomes per phyla. The gradient indicates the proportion of MAGs per phylum. (Nuber of MAGs/total number of genomes)
c) Phylogenetic tree of GTDB archaea phyla. We colored in green the phyla enriched in non-classified clusters, and in pink the phyla with a high percentage of MAGs and unknowns. The grey dots represent the number of phylum-specific clusters of unknowns. The branches are colored by the percentage of MAGs per phylum. Around the tree we drew a heatmap showing the proportion of unknowns per phylum.

<br>
<br>

* * *

<h4 class="section-heading  text-primary">References</h4>

<a name="1"></a>[1] Chen, Han; Parks, Donovan H; Hug, Laura A; Doxey, Andrew C, "AnnoTree: visualization and exploration of a functionally annotated microbial tree of life". Nucleic Acids Research, 2019.
<a name="2"></a>[2] Martiny, Adam C., Kathleen Treseder, and Gordon Pusch. 2013. “Phylogenetic Conservatism of Functional Traits in Microorganisms.” The ISME Journal 7 (4): 830–38.
<a name="3"></a>[3] Louca, Stilianos, and Michael Doebeli. 2018. “Efficient Comparative Phylogenetics on Large Trees.” Bioinformatics  34 (6): 1053–55.
<a name="4"></a>[4] Goodacre, Norman F., Dietlind L. Gerloff, and Peter Uetz. 2013. “Protein Domains of Unknown Function Are Essential in Bacteria.” mBio 5 (1): e00744–13.
