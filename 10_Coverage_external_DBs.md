---
layout: page
title: Coverage of external databases
---

<h3 class="section-heading  text-primary">Methods</h3>

We searched seven different state of the art databases against our dataset of cluster profiles. The different searches were all performed using the MMSeqs2 search program (version 8.fac81) [[1]](#1), setting an e-value threshold of 1e-20 and a query coverage threshold of 60%. The results were filtered keeping just the hits within the 90% of the Log(best-evalue). We applied a majority vote function to retrieve the consensus category for each hit. Then, we sorted the results by the smallest E-value and the largest query and target coverage to keep only the best hits.
With this method we searched: the 61,970 FUnkFams genes [[2]](#2), the Pacific Ocean Virome (POV) ~4M predicted genes [[3]](#3) and the Tara Ocean Virome (TOV) ~6.6M ORFs [[4]](#4). The Genome Taxonomy Database (GTDB) predicted genes from archaeal and bacterial genomes [[5]](#5). The ~200M Mgy clusters from the EBI metagenomics database (release 2018_09) [[6]](#6). The collection of MAGs from the TARA metagenomes [[7]](#7) and from the fecal microbiota transplantation study of Lee et al. 2017 [[8]](#8). And the collection of unannotated genes with mutant phenotypes identified in Price et al. 2018 [[9]](#9).

**Scripts and description:** The input consists in a fasta file containing the sequences of the genes from the selected databases and the MMseqs2 database of HMM profiles for our cluster DB. The search and the parsing of the results are perfomed via the script [db_search.sh](scripts/Coverage_ext_dbs/db_search.sh). The search results are parsed to retrieve the best-hits and the consensus cluster category associated with each hit. The basic output is a file containing the best-hits: gene - cluster - category. In addition, the proportion of categories per genome/MAG/biome/contig etc can be retrieved, providing in input an additional file with the correspondance between the searched genes and the genomes/MAGs/biomes/contigs containing them.

<h3 class="section-heading  text-primary">Results</h3>

Summary of the different searches in terms of coverage:

<h4 class="section-heading  text-primary">FUnkFams</h4>

Wyman et al. [[2]](#2) identified 6,668 conserved protein families of unknown function FUnkfams, consisting in total of 61,970 genes.

The 0.7% of the clusters in our database cover 60% of the FUnkfams.

<div class="img_container" style="width:70%; margin:2em auto;">

*FUnkfams vs Clusters search results*

| FUnkfams genes |  FUnkfams   |   Clusters    |
|:--------------:|:-----------:|:-------------:|
|     38,174     | 3,975 (60%) | 19,478 (0.7%) |

</div>

Considering only the search best-hits: 6,854 clusters

<div class="img_container" style="width:50%; margin:2em auto;">

*Results distributed per category*

| CATEG | FUnkFams | clusters |
|:-----:|:--------:|:--------:|
|  EU   |    0     |    0     |
|  GU   |  25,808  |  5,240   |
|  KWP  |  10,403  |  1,246   |
|   K   |  1,963   |   368    |

</div>

Overall, no FUnkfams was found in the EU clusters, and although the majority was found, as expected, in GU clusters, we also found 10K FUnkfams genes in the K clusters  and 2K in the KWPs.

<h4 class="section-heading  text-primary">Viral metagenome-derived protein clusters (POV)</h4>

The POV PCs were downloaded from: <http://datacommons.cyverse.org/browse/iplant/home/shared/imicrobe/pov/clusters/POV_all_clusters.fa>.

The dataset consists of 4,238,638 genes grouped in 455,006 clusters (PCs). However, the reeal PCs are 450,832 (3,365,229 genes). The remaining 4,175 clusters are singletons (4,174 + "NONE" that is a set of 869,235 singletons)

We found 49% of the viral PCs in our clusters. And, as shown in the category distribution table, the majority of the rtrieved viral PCs was found in the GU clusters.

<div class="img_container" style="width:70%; margin:2em auto;">

*POV vs Clusters search results*

| POV genes |   viral PCs   |   Clusters    |
|:---------:|:-------------:|:-------------:|
| 2,104,063 | 222,162 (49%) | 674,948 (23%) |

</div>

Considering only the search best-hits: 204,431 clusters

<div class="img_container" style="width:50%; margin:2em auto;">

*Results distributed per category*

| CATEG | viral PCs | clusters |
|:-----:|:---------:|:--------:|
|  EU   |  19,154   |  16,462  |
|  GU   | 136,041   |  92,009  |
|  KWP  |  28,424   |  22,318  |
|   K   |  60,724   |  73,641  |

</div>

<h4 class="section-heading  text-primary">Tara Ocean Virome (TOV)</h4>

The TOV dataset consists of 43 Tara Ocean viromes (viral-fraction metagenomes), 6,642,187 detected genes grouped in 1,075,761 protein clusters (PCs).

The large majority (70%) of the TOV dataset is covered in our cluster database and the majority of TOV PCs are found in the GU and K clusters.

<div class="img_container" style="width:60%; margin:2em auto;">

*TOV vs Clusters search results*

| TOV genes |    TOV PCs    |    Clusters     |
|:---------:|:-------------:|:---------------:|
| 5,481,108 | 753,558 (70%) | 1,023,061 (34%) |

</div>

Considering only the search best-hits: 434,352 clusters

<div class="img_container" style="width:50%; margin:2em auto;">

*Results distributed per category*

| CATEG | viral PCs | clusters |
|:-----:|:---------:|:--------:|
|  EU   |  91,766   |  39,579  |
|  GU   | 426,282   | 164,141  |
|  KWP  |  99,802   |  45,743  |
|   K   | 238,806   | 131,399  |

</div>

<h4 class="section-heading  text-primary">MAG collections:</h4>

<h4 class="section-heading  text-primary">FMT MAGs</h4>

The nubers for the fecal microbiota transplantation (FMT) MAG dataset are reported in the table below:

<div class="img_container" style="width:50%; margin:2em auto;">

| MAGs | Contigs |   ORFs  |
|:----:|:-------:|:-------:|
|  92  | 12,814  | 188,983 |

</div>

All FMT MAGs are represented in our cluster database and the 91% of their ORFs. The majority of OPRFs are found in the K clusters and in the GU ones.

<div class="img_container" style="width:70%; margin:2em auto;">

*FMT-MAGs vs Clusters search results*

|   FMT ORFs    | FMT MAGs  |   Clusters    |
|:-------------:|:---------:|:-------------:|
| 171,220 (91%) | 92 (100%) | 438,646 (15%) |

</div>

Considering only the search best-hits: 68,400 clusters

<div class="img_container" style="width:50%; margin:2em auto;">

*Results distributed per category*

| CATEG | FMT MAGs | FMT MAG ORFs | clusters |
|:-----:|:--------:|:------------:|:--------:|
|  EU   |    48    |     218      |   218    |
|  GU   |    92    |    25,789    |  18,157  |
|  KWP  |    92    |    6,249     |  4,073   |
|   K   |    92    |   137,663    |  45,951  |

</div>

<h4 class="section-heading  text-primary">Tara Ocean MAGs</h4>

Tara Ocean MAG dataset:

<div class="img_container" style="width:50%; margin:2em auto;">

| MAGs | Contigs |    ORFs   |
|:----:|:-------:|:---------:|
| 957  | 323,552 | 2,288,202 |

</div>

All Tata MAGs are represented in the cluster database with 77% of their ORFs. Again the majority of the ORFs was found in the K and GU clusters.

<div class="img_container" style="width:70%; margin:2em auto;">

*TaraOcean-MAGs vs Clusters search results*

| Tara MAGs ORFs  | Tara MAGs  |    Clusters     |
|:---------------:|:----------:|:---------------:|
| 1,770,048 (77%) | 957 (100%) | 984,642 (33.5%) |

</div>

Considering only the search best-hits: 319,732 clusters

<div class="img_container" style="width:50%; margin:2em auto;">

*Results distributed per category*

| CATEG | Tara MAGs | Tara MAG ORFs | clusters |
|:-----:|:---------:|:-------------:|:--------:|
|  EU   |    691    |     7,661     |  5,420   |
|  GU   |    957    |    278,644    |  92,178  |
|  KWP  |    957    |    60,968     |  22,707  |
|   K   |    957    |   1,422,775   | 199,427  |

</div>

<h4 class="section-heading  text-primary">GTDB</h4>

We downloaded the 93,723,190 genes predicted from the 28,941 genomes (1,569 archaeal and 27,372 bacterial genomes) of the Genome Taxonomy Database (verion r86)  from the Annotree website at <https://data.ace.uq.edu.au/public/misc_downloads/annotree/r86/>.

All GTDB genomes are represented in the cluster database with 70% of the total ORFs.

<div class="img_container" style="width:70%; margin:2em auto;">

*GTDB vs Clusters search results*

| GTDB genomes  |    GTDB ORFs     |    Clusters     |
|:-------------:|:----------------:|:---------------:|
| 28,941 (100%) | 70,949,363 (70%) | 1,814,250 (62%) |

</div>

Considering only the search best-hits: 950,242 clusters

<div class="img_container" style="width:50%; margin:2em auto;">

*Results distributed per category*

| CATEG | GTDB genomes | GTDB ORFs  | clusters  |
|:-----:|:------------:|:----------:|:---------:|
|  EU   |    2,905     |   20,546   |   9,612   |
|  GU   |   28,940     | 6,892,979  |  315,045  |
|  KWP  |   28,856     | 2,662,902  |  156,968  |
|   K   |   29,941     | 63,024,524 |  662,445  |

</div>

<h4 class="section-heading  text-primary">EBI BIOMES</h4>

We search the EBI-metagenomics peptide database (Release 2018_09), downloadable here: ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/peptide_database/2018_09/mgy_clusters.fa.gz. The dataset contains 843,535,611 protein sequences, grouped in 201,273,532 clusters.

Our cluster database covered 48% of the EBI MGY clusters.

<div class="img_container" style="width:60%; margin:2em auto;">

*EBI-MGY vs Clusters search results*

|   Mgy ORFs    |   Mgy clusters   |    Clusters     |
|:-------------:|:----------------:|:---------------:|
| 4,065,229,104 | 97,435,318 (48%) | 2,626,472 (89%) |

</div>

Considering only the search best-hits: 2,154,085 clusters

<div class="img_container" style="width:50%; margin:2em auto;">

*Results distributed per category*

| CATEG |  Mgy ORFs   | Mgy clusters | Clusters |
|:-----:|:-----------:|:------------:|:--------:|
|  EU   |  1,736,494  |   484,622    |  94,193  |
|  GU   | 83,578,118  |  13,902,839  | 763,574  |
|  KWP  |  38,59,382  |  10,021,334  | 483,289  |
|   K   | 498,789,485 |  73,026,523  | 813,029  |

</div>

As shown in the figure below, our clusters are found in each one of the 11 main biome identified by EBI-metagenomics.

<img alt="biome_cl.png" src="/img/biome_cl.png" width="60%" height="">

<h4 class="section-heading  text-primary">Unknown genes with mutant phenotypes</h4>

Price et al. [[9]](#9) identified 37,684 mutant-genes. We covered 85% of them in our cluster database.

<div class="img_container" style="width:50%; margin:2em auto;">

*Mutant-genes vs Clusters search results*

| Mutant-genes |   Clusters   |
|:------------:|:------------:|
| 31,944 (85%) | 199,439 (7%) |

</div>

Considering only the search best-hits: 14,026 clusters

<div class="img_container" style="width:50%; margin:2em auto;">

*Results distributed per category*

| CATEG | Mutant-genes | Clusters |
|:-----:|:------------:|:--------:|
|  EU   |      0       |    0     |
|  GU   |    2,584     |  1,840   |
|  KWP  |     673      |   458    |
|   K   |    22,989    |  11,728  |

</div>

<h4 class="section-heading  text-primary">Summary of the coverage of external databases</h4>

<div class="img_container" style="width:50%; margin:2em auto;">

<img alt="Coverage_ext_DBs_summary.png" src="/img/Coverage_ext_DBs_summary.png" width="" height="" >

</div>
<br>

* * *

<h4 class="section-heading  text-primary">References</h4>

<a name="1"></a>[1]	M. Steinegger and J. Söding, “MMseqs2 enables sensitive protein sequence searching for the analysis of massive data sets.,” Nature biotechnology, vol. 35, no. 11, pp. 1026–1028, Nov. 2017.

<a name="2"></a>[2] Wyman, Stacia K., Aram Avila-Herrera, Stephen Nayfach, and Katherine S. Pollard. 2018. “A Most Wanted List of Conserved Microbial Protein Families with No Known Domains.” PloS One 13 (10).

<a name="3"></a>[3] Hurwitz, Bonnie L., and Matthew B. Sullivan. 2013. “The Pacific Ocean Virome (POV): A Marine Viral Metagenomic Dataset and Associated Protein Clusters for Quantitative Viral Ecology.” PloS One 8 (2).

<a name="4"></a>[4] Brum, Jennifer R., J. Cesar Ignacio-Espinoza, Simon Roux, Guilhem Doulcier, Silvia G. Acinas, Adriana Alberti, Samuel Chaffron, et al. 2015. “Ocean Plankton. Patterns and Ecological Drivers of Ocean Viral Communities.” Science 348 (6237).

<a name="5"></a>[5] Parks, Donovan H., David W. Waite, Adam Skarshewski, Maria Chuvochina, Christian Rinke, Philip Hugenholtz, and Pierre-Alain Chaumeil. 2018. “A Standardized Bacterial Taxonomy Based on Genome Phylogeny Substantially Revises the Tree of Life.” Nature Biotechnology 36 (10).

<a name="6"></a>[6] Mitchell, Alex L., Maxim Scheremetjew, Hubert Denise, Simon Potter, Aleksandra Tarkowska, Matloob Qureshi, Gustavo A. Salazar, et al. 2018. “EBI Metagenomics in 2017: Enriching the Analysis of Microbial Communities, from Sequence Reads to Assemblies.” Nucleic Acids Research 46 (D1): D726–35.

<a name="7"></a>[7] Delmont, Tom O., Christopher Quince, Alon Shaiber, Özcan C. Esen, Sonny Tm Lee, Michael S. Rappé, Sandra L. McLellan, Sebastian Lücker, and A. Murat Eren. 2018. “Nitrogen-Fixing Populations of Planctomycetes and Proteobacteria Are Abundant in Surface Ocean Metagenomes.” Nature Microbiology 3 (7).

<a name="8"></a>[8] Lee, Sonny T. M., Stacy A. Kahn, Tom O. Delmont, Alon Shaiber, Özcan C. Esen, Nathaniel A. Hubert, Hilary G. Morrison, Dionysios A. Antonopoulos, David T. Rubin, and A. Murat Eren. 2017. “Tracking Microbial Colonization in Fecal Microbiota Transplantation Experiments via Genome-Resolved Metagenomics.” Microbiome 5 (1): 1–10.

<a name="9"></a>[9] Price, Morgan N., Kelly M. Wetmore, R. Jordan Waters, Mark Callaghan, Jayashree Ray, Hualan Liu, Jennifer V. Kuehl, et al. 2018. “Mutant Phenotypes for Thousands of Bacterial Genes of Unknown Function.” Nature 557 (7706): 503–9.
