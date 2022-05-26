---
layout: page
title: Gene Cluster category refinement
---

<h2 class="section-heading  text-primary">Clusters of unknowns refinement</h2>

The EUs represent the most critical of our cluster categories since we expected them to be clusters of entirely novel/unknown ORFs. To ensure their novelty, we further processed them searching eventual remote homologies to annotated proteins.

<h3 class="section-heading  text-primary">Methods</h3>

We screened the EUs using HHblits [[1]](#1) against the Uniclust database (release 30_2017_10) using the HMM comparison method since it is currently considered one of the most sensitive approaches for homology detection [[2]](#2).
The results were parsed using a probability threshold of 90% and then processed with the same system used for the classification of the unknowns to retrieve the hits annotated to hypothetical or characterised proteins. The firsts were then moved to the class of GU and the second to the KWP. The clusters with no matches, i.e., no homologies, represented the refined set of EU.


<h3 class="section-heading  text-primary">Results</h3>

We found that the 61% of the EUs have/show a remote homology to a Uniclust entry/protein. Of the matching clusters, 171,183 resulted in distant homologs of hypothetical proteins and were moved to the GUs category, whereas 38,333 clusters matched characterized proteins and were transferred to the KWPs set. Hence, after this refinement step, the number of EUs has reduced to 135,829 clusters, and the whole dataset results now dominated by the GU clusters.

<div class="img_container" style="width:90%; margin:2em auto;">

*Unknown refinement steps in terms of number of clusters.*

|                                |       K       |      KWP      |       GU        |      EU      |
| :----------------------------: | :-----------: | :-----------: | :-------------: | :----------: |
| Clusters (pre-EUs_refinement)  |    912,551    |    753,718    |     928,643     |   345,345    |
|         EUs refinement         |       -       |    +38,333    |    +171,183     |   -209,516   |
| Clusters (post-EUs_refinement) | 912,551 (31%) | 792,051 (27%) | 1,099,826 (37%) | 135,829 (5%) |


<br>

*First step refined **cluster categories** and ORFs content.*

|          |      K      |    KWP     |     GU     |    EU     |      Total      |
| -------- | :---------: | :--------: | :--------: | :-------: | :-------------: |
| Clusters |   912,551   |  792,051   | 1,099,826  |  135,829  |  **2,940,257**  |
| ORFs     | 164,720,321 | 39,188,198 | 52,892,578 | 3,341,257 | **260,142,354** |

</div>

<div class="img_container" style="width:60%; margin:2em auto;">

<img alt="Unknown_refinement_barplot.png" src="/img/Unknown_refinement_barplot.png" width="80%" height="" >

*Percentage of clusters in the different category before and after the refinement.*

</div>

<h2 class="section-heading  text-primary">Clusters of knowns refinement</h2>

The KWPs set may contain clusters with remote homologies to Pfam protein domains.

<h3 class="section-heading  text-primary">Methods</h3>

We screened the KWPs using HHblits [[1]](#1) against the Pfam database (version 31, http://wwwuser.gwdg.de/~compbiol/data/hhsuite/databases/hhsuite_dbs/pfamA_31.0.tgz) using the HMM comparison method since it is currently considered one of the most sensitive approaches for homology detection [[2]](#2).
The results were parsed using a probability threshold of 90%, a target coverage ≥ 0.6, and we selected only non overlapping domains.
The KWPs returning remote homologies to Pfam domain of known function were then moved to the Ks set, and those showing remote homologies to DUFs to the GUs.

<!---
We added the pfam names and clans and we converted the table in the multi-domain format (dA|dB)
--->


<h3 class="section-heading  text-primary">Results</h3>

We found that about 20% of the KWP clusters show a remote homology to Pfam protein domains. Of the matching clusters, 137,615 (86%) resulted distant homologs of Pfam domain of known function and were moved to the Ks category, and 21,983 (14%) clusters matched DUFs and were transferred to the GUs set. Hence, after this refinement step, the number of KWPs was reduced to 632,453 clusters.

_Refinement of the K's DAs._ Updating the Ks implies also updating the cluster representative DAs.
Considering both Pfam domain of known function and DUFs we now have 32,616 original DAs (29,341 with reduced names and 26,272 with reduced names and contracted repeats). The Ks DAs are now 29,379 (23,365 reduced), composed of 19,927 multi-domain and 9,453 mono-domain annotations. The clusters with multi-domain annotations are 133,253, and those with mono-domain annotations 916,914.

<div class="img_container" style="width:90%; margin:2em auto;">

*Known refinement steps in terms of number of clusters.*

|                                 |        K        |      KWP      |       GU        |      EU      |
| :-----------------------------: | :-------------: | :-----------: | :-------------: | :----------: |
| Clusters (pre-KWPs_refinement)  |     912,551     |    792,051    |    1,099,826    |   135,829    |
|         KWPs refinement         |    +137,615     |   -159,598    |     +21,983     |      -       |
| Clusters (post-KWPs_refinement) | 1,050,166 (36%) | 632,453 (21%) | 1,121,809 (38%) | 135,829 (5%) |

<br>

_Refined **cluster categories** and ORFs content._

|          |      K      |    KWP     |     GU     |    EU     |      Total      |
| -------- | :---------: | :--------: | :--------: | :-------: | :-------------: |
| Clusters |  1,050,166  |  632,453   | 1,121,809  |  135,829  |  **2,940,257**  |
| ORFs     | 172,147,128 | 30,601,694 | 54,052,275 | 3,341,257 | **260,142,354** |

</div>


An overview of the metagenomic cluster categories, including additional information about their taxonomy, level of darkness, completeness and set of HQ-clusters can e found [here](8.1_Cluster_categories_overview).


* * *

<h3 class="section-heading  text-primary">Finalization of the cluster categories</h3>

After the refinement we combined together the annotations for the categories with annotated clusters (K,KWP and GU). We also created two summary files: one mapping all the clusters with the respective category, "cluster_ids_categ.tsv" and one with an additional field containing the cluster ORFs: "cluster_ids_categ_orfs.tsv".
The commands used to gather this information are stored in the script [clu_categ_summary.sh](https://github.com/functional-dark-side/functional-dark-side.github.io/blob/master/scripts/Cluster_category_refinement/clu_categ_summary.sh).

In the end, we build an HH-suite database (ffindex dbs) for each category, using the script [categ_ffindex_files.sh](https://github.com/functional-dark-side/functional-dark-side.github.io/blob/master/scripts/Cluster_category_refinement/categ_ffindex_files.sh).

<br>
<br>

* * *
<br />
<br />

{% capture code %}


**Refinement of the unknown:** 

The main script, [unkn_refinement.sh](https://github.com/functional-dark-side/functional-dark-side.github.io/blob/master/scripts/Cluster_category_refinement/unkn_refinement.sh), takes as input the EUs cluster ids, searches them against the Uniclust HMM DB, and parse the results through the codes [hh_parser.sh and hh_reader.py](https://github.com/functional-dark-side/functional-dark-side.github.io/blob/master/scripts/Cluster_category_refinement/hh_parser.sh). The output are updated sets of cluster ids reported in a file for each category.
For more detailed info check the [README.md](https://github.com/functional-dark-side/functional-dark-side.github.io/blob/master/scripts/Cluster_category_refinement/README_kuref.md) file.

**Refinement of the known:** 

The main script, [known_refinement.sh](https://github.com/functional-dark-side/functional-dark-side.github.io/blob/master/scripts/Cluster_category_refinement/known_refinement.sh), takes as input the KWPs cluster ids, searches them against the Pfam HMM DB, through the code [hhparse_kwp.sh](https://github.com/functional-dark-side/functional-dark-side.github.io/blob/master/scripts/Cluster_category_refinement/hhparse_kwp.sh), and then parse the results. The output are updated sets of cluster ids divided in a file for each category.
For more detailed info check the [README.md](https://github.com/functional-dark-side/functional-dark-side.github.io/blob/master/scripts/Cluster_category_refinement/README_kuref.md) file.

{% endcapture %}

{% include collapsible.html toggle-name="toggle-code" button-text="Code and description" toggle-text=code %}


{% capture references %}

**[1]**	M. Remmert, A. Biegert, A. Hauser, and J. Söding, “HHblits: lightning-fast iterative protein sequence searching by HMM-HMM alignment.,” Nat Methods, Nov. 2011.

**[2]**	B. Lobb, D. A. Kurtz, G. Moreno-Hagelsieb, and A. C. Doxey, “Remote homology and the functions of metagenomic dark matter.,” Frontiers in genetics, vol. 6, p. 234, Jul. 2015.


{% endcapture %}

<p></p>
{% include collapsible.html toggle-name="toggle-ref" button-text="References" toggle-text=references %}
