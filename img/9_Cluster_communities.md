---
layout: page
title: Cluster communities
---

<h3 class="section-heading  text-primary">Methods</h3>

To know how the different clusters created by MMseqs2 aggregate together at the Pfam domain architecture (DA) level we applied a combination of profile vs profile searches and MCL clustering...
1) _HMM vs HMM search._ We performed a profile vs profile search within each category clusters, using the HHblits program [[1]](#1). We ran an iterative search with 2 iterations and an e-value threshold set to 1.
2) _MCL clustering and community inference._ We filtered the Ks HHBLITS all-vs-all results using a probability ≥ 90% and a bidirectional coverage > 60%. The filtered results were then used to build a graph (nodes=clusters; edges=hhblits results, edges-weights=score/aligned-column). On the graph we ran the Markov Cluster Algorithm (MCL algorithm or clustering), using inflation values from 1.2 to 3.0, with steps of 0.1. We contracted the identified MCL communities merging the vertices belonging to the same DA (?). For each community we calculated the modularity, the number of different (DAs), the pfam clan entropy, and inter and intra communities score-per-column mode values. We proceeded then filtering pairwise distances of the non-redundant set of DAs smaller than 0.9. We identified nested DAs and we refined the non-redundant set, taking into account that small DAs can be part of bigger ones, but keeping the small ones present in at least 75% of complete ORFs.
To find the best inflation value we used a combination of five variables: number of clusters (related to the non-redundant set of DAs), clan entropy (proportion of clusters with entropy = 0), intra hhblits score-per-column (normalised by the maximum value), proportion of clusters with 1 community (build a graph inside of cluster using all DAs, then decompose it and count how many communities we have. This way we can take in account fragmented orfs that have parts of the DA. If you have more than one community it means that you might have non related clusters, but this is corrected when we check for entropy, which is based on clans. You can have more than one community but they might belong to the same clan. So there is some homology) and proportion of clusters with more than 1 member.
These variables/properties are calculated for each inflation value between 1.2 and 3 and are used to build radar plots. The best inflation value corresponds to the radar plot with the largest area.
Once determined the best inflation value, we added the missing clusters (nodes) to the MCL communities/communities. We used hhblits results coverage, probability and score per position, to find the best hits in/with a three-step approach:
First we checked if any of the remaining no assigned clusters have any homology to the just classified ones using more relaxed HHBLITS filtering thresholds (probability ≥ 50% and bidirectional coverage > 40%), and keeping just the best hit. Second, we found secondary relationships between the newly assigned clusters and the missing ones. And third, we ran the MCL algorithm on the missing clusters, using the identified best inflation value and we created new MCL communities.
At the end we collected and aggregated all communities.
We repeat the process for the other categories, with the exception that for them we applied/selected the optimal inflation value found for the Ks.

**Scripts:** [community_inference](scripts/Cluster_communities/community_inference). \
Usage: \
[`./community_inference/get_communities.R`](scripts/Cluster_communities/community_inference/get_communities.R)` -c `[`${PWD}/community_inference/config.yml`](scripts/Cluster_communities/community_inference/config.yml)


<h3 class="section-heading  text-primary">Results</h3>

*Number of communities, clusters and ORFs for each category.*

|             |      K      |    KWP     |     GU     |    EU     |      Total      |
| ----------- |:-----------:|:----------:|:----------:|:---------:|:---------------:|
| Communities |   24,181    |   64,938   |  146,100   |  48,095   |   **283,314**   |
| Clusters    |  1,050,166  |  632,453   | 1,121,809  |  135,829  |  **2,940,257**  |
| ORFs        | 172,147,128 | 30,601,694 | 54,052,275 | 3,341,257 | **260,142,354** |

<h2 class="section-heading  text-primary">Cluster communities validation</h2>

<h3 class="section-heading  text-primary">Methods</h3>

To prove the biological significance of the cluster communities, we explored how they distribute within the phylogeny of Proteorhodopsin (PR), a common/prevalent marine microbial functional protein. The hypothesis/idea is that one community should encompass all PR reads and the clusters should subdivide the phylogeny by genus. WE used the PR tree from Olson et al. [[2]](#2).
1.    Searching proteorhodopsin HMM profiles against the K and KWP consensus sequences.
2.    Placing query sequences into the MicRhode [[3]](#3) PR tree.
3.    Assigning PR Supercluster affiliation to query sequences.

**Scripts:** [community_validation](https://github.com/ChiaraVanni/unknowns_wkfl/tree/master/scripts/Cluster_communities/community_validation). \
 Usage: \
  `bash`[`./scripts/place_PR.sh`](scripts/Cluster_communities/community_validation/place_PR.sh)` ${PWD}/all_sequences_names_to_extract.fasta ${PWD}/all_communities_2019-03-28-144550.tsv`


In addition we explored how the cluster communities and the subset of high quality (HQ) clusters and their communtities distributes among a bacterial set of ribosomal protein families [[4]](#4). For the analysis we used the set 16 ribosomal proteins used in Méheust et al. [[4]](#4) ([ribo_markers.tsv](scripts/Cluster_communities/community_validation/ribo_markers.tsv)) in combination with the collection of bacterial single copy genes (scg) of Anvi'o [[5]](#5), that can be dowloaded from [here](https://github.com/merenlab/anvio/blob/master/anvio/data/hmm/Bacteria_71/genes.txt).

**Script:** The ribosomal protein analysis was performed using the R script [cl_comm_ribo_prot.r](scripts/communities/community_validation/cl_comm_ribo_prot.r).
The output files: "ribo_com_cl.tsv" and "ribo_com_cl_hq.tsv" can be visualised/plotted usaing the [RawGraphs](https://rawgraphs.io/about) visualization framework.

<h3 class="section-heading  text-primary">Results</h3>

<img alt="alluvial_PR.png" src="assets/alluvial_PR.png" width="" height="" >

*Cluster communities distribution within the microbial rhodopsin phylogeny.*

<img alt="alluvial_ribo_all.png" src="assets/alluvial_ribo_all.png" width="350" height="" >

*Ribosomal protein distribution in our cluster communties.*

Because these proteins are highly conserved, we expect one protein family per ribosomal subunit. However, we observe the same ribosomal protein falling in different communities and this is likely due to the fragmented nature of metagenomic data. In fact, this effect almost disappear when we subset for the communities containing only [HQ clusters](8.1_Cluster_categories_overview) (high percentage of complete ORFs), as shown in the following figure:


<img alt="alluvial_ribo_hq.png" src="assets/alluvial_ribo_hq.png" width="400" height="" >

*Ribosomal protein distribution in HQ cluster communities.*

<br>
<br>

* * *

<h4 class="section-heading  text-primary">References</h4>

<a name="1"></a>[1]	M. Remmert, A. Biegert, A. Hauser, and J. Söding, “HHblits: lightning-fast iterative protein sequence searching by HMM-HMM alignment.,” Nat Methods, Nov. 2011.
<a name="2"></a>[2] Olson, Daniel K., Susumu Yoshizawa, Dominique Boeuf, Wataru Iwasaki, and Edward F. DeLong. 2018. “Proteorhodopsin Variability and Distribution in the North Pacific Subtropical Gyre.” The ISME Journal 12 (4): 1047–60.
<a name="3"></a>[3] Boeuf, Dominique, Stéphane Audic, Loraine Brillet-Guéguen, Christophe Caron, and Christian Jeanthon. 2015. “MicRhoDE: A Curated Database for the Analysis of Microbial Rhodopsin Diversity and Evolution.” Database: The Journal of Biological Databases and Curation 2015 (August).
<a name="4"></a>[4] Méheust, Raphaël, David Burstein, Cindy J. Castelle, and Jillian F. Banfield. 2019. “The Distinction of CPR Bacteria from Other Bacteria Based on Protein Family Content.” Nature Communications 10 (1): 4173.
<a name="5"></a>[5] Murat, E. A., Özcan C. Esen, Christopher Quince, Joseph H. Vineis, Hilary G. Morrison, Mitchell L. Sogin, and Tom O. Delmont. 2015. “Anvi’o: An Advanced Analysis and Visualization Platform for ‘omics Data.” PeerJ 3 (October): e1319.
