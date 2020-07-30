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

-   **Phylogenetic conservation analysis results:**

We found 15% of clusters with a significant (P<0.05) [[2]](#2) non-random distribution in the bacterial tree (figure below). This fraction of clusters show a τD ranging from 0.0002759 - 0.0123298. Overall the KNOWN fraction appear to be more conserved than the UNKNOWN one. This result suggests that the unknowns tend to be more represented at the low taxonomic ranks, and may code for recently evolved and potential adaptive functions.

**Bacteria**

<div class="img_container" style="width:70%; margin:2em auto;">

<img alt="phylo_conservation_bac.png" src="/img/phylo_conservation_bac.png" width="70%" height="" >

*Phylogenetic conservation analysis. a) proportion of known and unknown clusters with a significant non-random distribution. We observed 15% of clusters with a significant non-random distribution (P<0.05) in the Bacterial phylogeny. b) letter-value plot showing the maximum clade depth (maximum tauD) distribution for the non-randomly distributed clusters of knowns and unknowns. TauD was calculated with consenTRAIT. The maximum tauD is ranging from 0.0003 - 0.012.*

</div>

*Bacteria phylogenetically conserved GCs*

| Category | Type of GCs  | Number of GCs |
| -------- |:------------:|:-------------:|
| Known    |     All      |    238,861    |
| Known    | Non-specific |    205,919    |
| Known    |   Specific   |    32,942     |
| Unknown  |     All      |    226,062    |
| Unknown  | Non-specific |    147,443    |
| Unknown  |   Specific   |    78,619     |

Similar results are observed for the archaea tree.

**Archaea**

<div class="img_container" style="width:70%; margin:2em auto;">

<img alt="phylo_conservation_arc.png" src="/img/phylo_conservation_arc.png" width="70%" height="" >

*Phylogenetic conservation analysis. a) proportion of known and unknown clusters with a significant non-random distribution. We observed 15% of clusters with a significant non-random distribution (P<0.05) in the Archaeal phylogeny. b) letter-value plot showing the maximum clade depth (maximum tauD) distribution for the non-randomly distributed clusters of knowns and unknowns. TauD was calculated with consenTRAIT. The maximum tauD is ranging from 0.05 - 0.99.*

</div>


*Archaea phylogenetically conserved GCs*

| Category | Type of GCs  | Number of GCs |
| -------- |:------------:|:-------------:|
| Known    |     All      |    19,693     |
| Known    | Non-specific |    17,445     |
| Known    |   Specific   |     2,248     |
| Unknown  |     All      |    15,200     |
| Unknown  | Non-specific |     9,535     |
| Unknown  |   Specific   |     5,665     |


-   **Lineage-specificity analysis results:**

Lineage-specific clusters were found at both broad taxonomic levels (e.g. Phylum, Order) and narrow taxonomic levels (e.g. class and family). However, as we can see in Figure 4a, we observe a trend in which lineage-specific protein families increase in frequency from higher (e.g. phylum) to lower (e.g. species) taxonomic levels. At higher resolution we observed a majority of lineage-specific unknowns. This suggests that the diversification process at this high resolution levels is mainly guided by family of unknowns functions, probably with an adaptive potential. Although lineage-specific families are relatively rare at high taxonomic levels, these cases often represent ancient, clade-defining bacterial innovations. We found 35 phylum- and 421 class-specific GUs that can be potential candidates to hypothesize clade diversification.

**Bacteria**

<div class="img_container" style="width:90%; margin:2em auto;">

*Number of lineage specific clusters divided by category for each rank*

| Category | Domain | Phylum | Class | Order | Family |  Genus  | Species |
|:--------:|:------:|:------:|:-----:|:-----:|:------:|:-------:|:-------:|
|    K     |   8    |   22   |  444  | 1,532 | 12,847 | 40,914  | 66,375  |
|   KWP    |   0    |   2    |  19   |  54   |  955   |  8,707  | 33,225  |
|    GU    |   10   |   35   |  421  | 2,366 | 28,106 | 169,788 | 377,755 |
|    EU    |   0    |   1    |   7   |  55   |  599   |  7,080  | 30,487  |

</div>


<div class="img_container" style="width:60%; margin:2em auto;">

<img alt="bac_rank_ls_clusters.png" src="/img/bac_rank_ls_clusters.png" width="80%" height="" >

*Number of lineage specific clusters as a function of the relative evolutionary divergence (RED) in the context of the GTDB bacteria tree.*

</div>

**Archaea**

*Number of lineage specific clusters divided by category for each rank*

| Category | Domain | Phylum | Class | Order | Family | Genus  | Species |
|:--------:|:------:|:------:|:-----:|:-----:|:------:|:------:|:-------:|
|    K     |   0    |   4    |  15   |  208  | 1,210  | 3,032  |  4,485  |
|   KWP    |   0    |   0    |   0   |   8   |   81   |  413   |  1,753  |
|    GU    |   0    |   1    |  25   |  376  | 2,895  | 12,472 | 18,697  |
|    EU    |   0    |   0    |   0   |   2   |   42   |  494   |  2,305  |


<div class="img_container" style="width:60%; margin:2em auto;">

<img alt="arc_rank_ls_clusters.png" src="/img/arc_rank_ls_clusters.png" width="80%" height="" >

*Number of lineage specific clusters as a function of the relative evolutionary divergence (RED) in the context of the GTDB archaea tree.*
<br>

</div>

**General analysis panel (Bacteria)**

<div class="img_container" style="width:90%; margin:2em auto;">

<img alt="Phylo_analysis_bac.png" src="/img/Phylo_analysis_bac.png" width="80%" height="" >

*a) Number of lineage specific clusters as a function of the relative evolutionary divergence (RED) in the context of the GTDB bacteria tree. b) GTDB bacterial phyla ordered based on the number of clusters of unknowns and clusters of knowns/ratio of CUs and CKs (calculated for each phylum as the sum(total unknown/known ORFs)/sum(all genome-ORFs). The size shows the number of genomes per phyla. The gradient indicates the proportion of MAGs per phylum. (Nuber of MAGs/total number of genomes) c) Phylogenetic tree of GTDB bacterial phyla. We colored in green the phyla enriched in non-classified clusters, and in pink the phyla with a high percentage of MAGs and unknowns. The grey dots represent the number of phylum-specific clusters of unknowns. The branches are colored by the percentage of MAGs per phylum. Around the tree we drew a heatmap showing the proportion of unknowns per phylum.*

</div>

We focused on these higher ranks and we investigated the bacterial phyla distribution in the KNOWN and UNKNOWN space. In the above figure, panel b), we observe the GTDB bacterial phyla ordered based on the proportion of clusters of unknowns and clusters of knowns. The size shows the number of genomes per phyla and the gradient indicates the proportion of MAGs per phylum (number of MAGs over the total number of genomes). We observed a positive correlation between the proportion of MAGs and the proportion of unknowns and this again suggests a more environmentally related role for the UNKNOWN fraction. We also observe a group of phyla enriched in “non-classified” data (NC), i.e. singletons of cluster discarded during the validation process, and represented by only one or two MAGs. To gain a more detailed view on these phyla we combined the results from this analysis with the phylum-specific GU clusters on the bacterial phyla tree (in the above figure, panel c)). We found that these phyla enriched in NC are recently discovered/newly proposed phyla derived from metagenomes. Among them we have *Candidatus Coatesbacteria bacterium RBG_13_66_14*, from a sediment metagenome [[5]](#5), *BRC1*, from a deep subsurface aquifer metagenome [[5]](#5)[[6]](#6), and members of the candidate phyla consisting only of UBA genomes are shown in red and have been named *Uncultured Bacterial Phylum 1 to 17* (*UBP1–UBP17*) [[7]](#7). The group of phyla highly enriched in unknowns and represented mainly by MAGs includes yet-uncultured microorganism phyla already seen in different environments, like *Desantibacteria* [[8]](#8), *Eremiobacterota* [[9]](#9), *Margulisbacteria* [[5]](#5) and the superphylum of *Patescibacteria* [[10]](#10). The latter is particularly interesting, since is the newly proposed superphylum encompassing the candidate phyla within the previously called Candidate Phyla Radiation (CPR). *Patescibacteria* is the GTDB phylum most enriched in unknowns, and contains two phylum-specific GUs. We decided to focus on this phylum and to use it to prove how we can now from a genomic context go back to the metagenomes and hence the environment.

**_Patescibacteria_ example**

We investigated the distribution in the human and marine (TARA and Malaspina) metagenomes of all the clusters lineage specific inside the *Patescibacteria* phylum (Figure below). We then chose to have a closer look at the class of *Gracilibacteria*, which shows to be present in both human and marine environment.
*Gracilibacteria* are particularly poorly understood microorganisms, due mostly to undersampling and the incompleteness of the available genomes. The first genome was retrieved in a hydrothermal vent environment in the deep sea ([[10]](#10). Was then also identified in an oil degrading community [[10]](#10)[[11]](#11) and as a part of the oral microbiome [[12]](#12). As shown in the figure below, panel b), we found both known and unknown lineage-specific clusters in this class, distributed in both human and marine metagenomes. We observe 3 clusters of unknowns only seen in the HMP, they could represent a nice target for human-health study, since *Gracilibacteria* was found enriched in healthy individuals. There are then lineage-specific clusters of knowns and unknowns only specific to the marine environment. In general these data can now lead to the generation of hypotheses and open the way for further/new investigations.
In the context of this paper we want to use the example of *Gracilibacteria* to show the potential of our approach, which brings/leads to a unification of the KNOWN and UNKNOWN functional space and it can be used indifferently to explore both metagenomic and genomic data.


<div class="img_container" style="width:90%; margin:2em auto;">

<img alt="Phylo_analysis_bac_patesci.png" src="/img/Phylo_analysis_bac_patesci.png" width="80%" height="" >

*Patescibacteria metagenomic lineage specific clusters. a) Phylogenetic tree of Patescibacteria genera, grouped/colored by classes. The heatmaps around the tree show the proportion of lineage specific cluster of knowns and unknowns in the metagenomes from TARA, Malaspina and the HMP. b) Metagenomic lineage specific clusters in the class of Gracilibacteria.*

</div>

The Patescibacteria (CPR) lineage-specific gene clusters analysed in the above section can be found in Figshare in [agnostosDB_dbf02445-20200519_CPR-GCs](https://doi.org/10.6084/m9.figshare.12562676).

<br>

**General analysis panel (Archaea)**

<div class="img_container" style="width:90%; margin:2em auto;">

<img alt="Phylo_analysis_arc.png" src="/img/Phylo_analysis_arc.png" width="80%" height="" >

*a) Number of lineage specific clusters as a function of the relative evolutionary divergence (RED) in the context of the GTDB archaea tree. b) GTDB archaeal phyla ordered based on the number of clusters of unknowns and clusters of knowns/ratio of CUs and CKs (calculated for each phylum as the sum(total unknown/known ORFs)/sum(all genome-ORFs). The size shows the number of genomes per phyla. The gradient indicates the proportion of MAGs per phylum. (Nuber of MAGs/total number of genomes) c) Phylogenetic tree of GTDB archaea phyla. We colored in green the phyla enriched in non-classified clusters, and in pink the phyla with a high percentage of MAGs and unknowns. The grey dots represent the number of phylum-specific clusters of unknowns. The branches are colored by the percentage of MAGs per phylum. Around the tree we drew a heatmap showing the proportion of unknowns per phylum.*

</div>

<br>

* * *

<h4 class="section-heading  text-primary">References</h4>

<a name="1"></a>[1] Chen, Han; Parks, Donovan H; Hug, Laura A; Doxey, Andrew C, "AnnoTree: visualization and exploration of a functionally annotated microbial tree of life". Nucleic Acids Research, 2019.

<a name="2"></a>[2] Martiny, Adam C., Kathleen Treseder, and Gordon Pusch. 2013. “Phylogenetic Conservatism of Functional Traits in Microorganisms.” The ISME Journal 7 (4): 830–38.

<a name="3"></a>[3] Louca, Stilianos, and Michael Doebeli. 2018. “Efficient Comparative Phylogenetics on Large Trees.” Bioinformatics  34 (6): 1053–55.

<a name="4"></a>[4] Goodacre, Norman F., Dietlind L. Gerloff, and Peter Uetz. 2013. “Protein Domains of Unknown Function Are Essential in Bacteria.” mBio 5 (1): e00744–13.

<a name="5"></a>[5] Anantharaman, Karthik, Christopher T. Brown, Laura A. Hug, Itai Sharon, Cindy J. Castelle, Alexander J. Probst, Brian C. Thomas, et al. 2016. “Thousands of Microbial Genomes Shed Light on Interconnected Biogeochemical Processes in an Aquifer System.” Nature Communications 7 (October): 13219.

<a name="6"></a>[6] Kadnikov, Vitaly V., Andrey V. Mardanov, Alexey V. Beletsky, Andrey L. Rakitin, Yulia A. Frank, Olga V. Karnachuk, and Nikolai V. Ravin. 2019. “Phylogeny and Physiology of Candidate Phylum BRC1 Inferred from the First Complete Metagenome-Assembled Genome Obtained from Deep Subsurface Aquifer.” Systematic and Applied Microbiology 42 (1): 67–76.

<a name="7"></a>[7] Parks, Donovan H., Christian Rinke, Maria Chuvochina, Pierre-Alain Chaumeil, Ben J. Woodcroft, Paul N. Evans, Philip Hugenholtz, and Gene W. Tyson. 2017. “Recovery of Nearly 8,000 Metagenome-Assembled Genomes Substantially Expands the Tree of Life.” Nature Microbiology 2 (11): 1533–42.

<a name="8"></a>[8] Probst, Alexander J., Cindy J. Castelle, Andrea Singh, Christopher T. Brown, Karthik Anantharaman, Itai Sharon, Laura A. Hug, et al. 2017. “Genomic Resolution of a Cold Subsurface Aquifer Community Provides Metabolic Insights for Novel Microbes Adapted to High CO2 Concentrations.” Environmental Microbiology 19 (2): 459–74.

<a name="9"></a>[9] Ji, Mukan, Chris Greening, Inka Vanwonterghem, Carlo R. Carere, Sean K. Bay, Jason A. Steen, Kate Montgomery, et al. 2017. “Atmospheric Trace Gases Support Primary Production in Antarctic Desert Surface Soil.” Nature 552 (7685): 400–403.
<a name="10"></a>[10] Rinke, Christian, Patrick Schwientek, Alexander Sczyrba, Natalia N. Ivanova, Iain J. Anderson, Jan-Fang Cheng, Aaron Darling, et al. 2013. “Insights into the Phylogeny and Coding Potential of Microbial Dark Matter.” Nature 499 (7459): 431–37.

<a name="11"></a>[11] Sieber, Christian M. K., Blair G. Paul, Cindy J. Castelle, Ping Hu, Susannah G. Tringe, David L. Valentine, Gary L. Andersen, and Jillian F. Banfield. 2019. “Unusual Metabolism and Hypervariation in the Genome of a Gracilibacteria (BD1-5) from an Oil Degrading Community.” bioRxiv. https://doi.org/10.1101/595074.

<a name="12"></a>[12] Espinoza, Josh L., Derek M. Harkins, Manolito Torralba, Andres Gomez, Sarah K. Highlander, Marcus B. Jones, Pamela Leong, et al. 2018. “Supragingival Plaque Microbiome Ecology and Functional Potential in the Context of Health and Disease.” mBio 9 (6).
