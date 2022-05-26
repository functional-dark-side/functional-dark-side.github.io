---
layout: page
title: Identification of spurious and shadow ORFs
---


Gene prediction algorithms have limitations and can yield inaccurate ORFs predictions leading to spurious proteins, which can lead to spurious protein families. We decided to track the presence and the distribution of both **“spurious”** and **“shadow”** predicted ORFs in our clusters.

<h3 class="section-heading  text-primary">Methods</h3>

- To detect eventual **spurious ORFs**, we screened our data set against the AntiFam database [[1]](#1), which contains Pfam protein families "composed solely of spurious open reading frames (ORFs)”.
- The **shadow ORFs** are artifacts produced during the identification of the coding region that defines an ORF. During this process, constraints are applied that can result in intervals and subintervals that overlap the coding region of the ORF, in one of the five possible reading frames (two on the same strand and three on the opposite strand) [[2]](#2). We identified the shadow ORFs in our dataset using the criteria applied in Yooseph et al., 2018 [[3]](#3).
i) Two ORFs on the same strand are considered shadows if they overlap by at least 60 bps.
ii) ORFs on opposite strands are identified as shadows if they overlap by at least 50 bps, and their ends of 3 'are within the intervals of the others, or if they overlap by at least 120 bps and the end of 5 'of one is in the interval of the other.


<h3 class="section-heading  text-primary">Results</h3>

**Spurious ORFs**

TOTAL: 53,324 (0.02%)

<div class="img_container" style="width:60%; margin:2em auto;">

*Distribution of spurious ORFs in the different data sets.*

| TARA  | Malaspina |  GOS  |  OSD  |  HMP   |
| :---: | :-------: | :---: | :---: | :----: |
| 4,203 |   2,298   | 4,939 | 1,620 | 40,264 |

</div>

**Shadows ORFs**

TOTAL: 611,774 (0.2%)

<div class="img_container" style="width:60%; margin:2em auto;">

*Distribution of shadows ORFs in the different data sets.*

|  TARA   | Malaspina |  GOS   |  OSD   |   HMP   |
| :-----: | :-------: | :----: | :----: | :-----: |
| 157,688 |  40,762   | 66,245 | 70,632 | 276,447 |

</div>

<h4 class="section-heading  text-primary">Spurious and shadow ORFs in the clusters</h4>

We detected a total of 53,324 (0.02%) **spurious ORFs** distributed in 6,228 (0.02%) clusters.

<div class="img_container" style="width:100%; margin:2em auto;">

*Number of spurious ORFs in the clusters and in each project.*

| Spurious in clusters ≥ 10 members | Spurious in clusters < 10 members > 1 | Spurious in singletons |
| :-------------------------------: | :-----------------------------------: | :--------------------: |
|              44,205               |                 6,784                 |         2,335          |

</div>

We identified 611,774 (0.2%) **shadow ORFs** distributed in 357,329 (1%)
clusters.

<div class="img_container" style="width:100%; margin:2em auto;">

*Number of shadow ORFs in the clusters and in each project.*

| Shadows in clusters ≥ 10 members | Shadows in clusters < 10 members > 1 | Shadows in singletons |
| :------------------------------: | :----------------------------------: | :-------------------: |
|             290,077              |               144,571                |        177,126        |

</div>

<br>
<br>

* * *

{% capture code %}

The scripts [spur_shadow_orfs.sh](https://github.com/functional-dark-side/functional-dark-side.github.io/blob/master/scripts/Spurious_shadow/spur_shadow_orfs.sh) and [shadow_orfs.r](https://github.com/functional-dark-side/functional-dark-side.github.io/blob/master/scripts/Spurious_shadow/shadow_orfs.r) identified the spurious and shadow ORFs in our dataset applying the criteria described above. The output is a tab-separated file containing the following fields: 

- orf_name
- orf_length
- cl_name
- cl_size
- prop_shadow_in_the_cluster
- is.shadow
- is.spurious 


More info in the [README](https://github.com/functional-dark-side/functional-dark-side.github.io/blob/master/scripts/Spurious_shadow/README_spur.md).

{% endcapture %}

{% include collapsible.html toggle-name="toggle-code" button-text="Code and description" toggle-text=code %}

{% capture references %}


**[1]**	R. Y. Eberhardt, D. H. Haft, M. Punta, M. Martin, C. O’Donovan, and A. Bateman, “AntiFam: a tool to help identify spurious ORFs in protein annotation.,” Database: the journal of biological databases and curation, vol. 2012, p. bas003, Mar. 2012.

**[2]**	S. Yooseph et al., “The Sorcerer II Global Ocean Sampling expedition: expanding the universe of protein families,” PLoS biology, vol. 5, no. 3, p. 16, 2007.

**[3]**	S. Yooseph, W. Li, and G. Sutton, “Gene identification and protein classification in microbial metagenomic sequence data via incremental clustering.,” BMC bioinformatics, vol. 9, p. 182, Apr. 2008.

{% endcapture %}

<p></p>
{% include collapsible.html toggle-name="toggle-ref" button-text="References" toggle-text=references %}
