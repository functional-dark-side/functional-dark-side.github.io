## Singletons

_"Clusters with only one member"_

| Singletons |   Annotated  |   Not-annotated  |
| :--------: | :----------: | :--------------: |
| 19,911,324 | 934,548 (5%) | 18,976,776 (95%) |

| Annotated DUFs | Annotated PF (known function) |
| :------------: | :---------------------------: |
|   82,135 (9%)  |         852,413 (91%)         |

## _Genomic unknowns_: search against UniRef90

From the 18,976,776 not annotated singletons, we were able to retrieve:

|  Hits (unique)  |      No-hits     |
| :-------------: | :--------------: |
| 6,024,464 (32%) | 12,952,312 (68%) |

And from **6,024,464** hits, we were able to map them to unknowns:

|   Hits to hypothetical proteins   | Hits to not-hypothetical prot. |
| :-------------------------------: | :----------------------------: |
| 2,579,709 (14%) (43% of the hits) |   3,444,755 (57% of the hits)  |

<p align="center">
<img width="70%" height="70%" src="https://github.com/ChiaraVanni/unknown_protein_clusters/blob/master/marine_hmp/img/singl_small_cl/UniRef90_res_hypo_singl.jpg">
</p>

## _Environmental unknowns_: search against NCBI nr database

We searched the representatives that reported no matches to the UniRef90 entries (12,952,312) against the NCBI nr database (version 28-08-2017; 130,469,055 non-redundant proteins).

From these 12,952,312 queries we got:

|      Hits      |       No-hits      |
| :------------: | :----------------: |
| 162,038 (1.3%) | 12,790,274 (98.7%) |

We screened the hits for _hypothetical_ or _uncharacterized_ hits:

|          NR hypothetical         |    NR not-hypothetical   |
| :------------------------------: | :----------------------: |
| 101,632 (0.8%) (63% of the hits) | 60,406 (37% of the hits) |

<p align="center">
<img width="70%" height="70%" src="https://github.com/ChiaraVanni/unknown_protein_clusters/blob/master/marine_hmp/img/singl_small_cl/NR_res_hypo_singl.jpg">
</p>

**Singletons categories/classes**

|    Knowns    | Genomic unknowns | Environmental unknowns | Knowns without Pfam |
| :----------: | :--------------: | :--------------------: | :-----------------: |
| 852,413 (4%) |  2,763,476 (14%) |    12,790,274 (64%)    |   3,505,161 (18%)   |

## Cluster with less than 10 members (ORFs)

|  Clusters | Members (ORFs) |
| :-------: | :------------: |
| 9,549,853 |   33,869,465   |

| Clusters with repres. annot | Clusters with other annot. | Clusters with no annot. |
| :-------------------------: | :------------------------: | :---------------------: |
|           775,022           |           253,054          |        8,521,777        |
|        Number of ORFs       |       Number of ORFs       |      Number of ORFs     |
|          3,067,778          |          1,147,533         |        29,654,154       |

| Annotated clusters | Annotated to PF | Annotated to DUFs |
| :----------------: | :-------------: | :---------------: |
|      1,028,076     |  946,112 (92%)  |    81,964 (8%)    |

We retrieved the consensus sequences for the clusters and we proceeded with the classification

## _Genomic unknowns_: search against UniRef90

From the 8,521,777 not annotated small clusters, we were able to retrieve:

|  Hits (unique)  |     No-hits     |
| :-------------: | :-------------: |
| 4,767,685 (56%) | 3,754,092 (44%) |

And from **4,767,685** hits, we were able to map them to unknowns:

|   Hits to hypothetical proteins   | Hits to not-hypothetical prot. |
| :-------------------------------: | :----------------------------: |
| 2,590,710 (30%) (54% of the hits) |  2,176,975  (46% of the hits)  |

<p align="center">
<img width="70%" height="70%" src="https://github.com/ChiaraVanni/unknown_protein_clusters/blob/master/marine_hmp/img/singl_small_cl/UniRef90_small_clu_res_hypo.jpg">
</p>

## _Environmental unknowns_: search against NCBI nr database

We searched the consensus that reported no matches to the UniProtKB entries (3,754,092) against the NCBI nr database (version 28-08-2017; 130,469,055 non-redundant proteins).

From these 3,754,092 queries we got:

|     Hits     |     No-hits     |
| :----------: | :-------------: |
| 108,267 (3%) | 3,645,825 (97%) |

We screened the hits for _hypothetical_ or _uncharacterized_ hits:

|        NR hypothetical        |    NR not-hypothetical   |
| :---------------------------: | :----------------------: |
| 71,588 (2%) (66% of the hits) | 36,679 (33% of the hits) |

<p align="center">
<img width="70%" height="70%" src="https://github.com/ChiaraVanni/unknown_protein_clusters/blob/master/marine_hmp/img/singl_small_cl/NR_small_clu_res_hypo.jpg">
</p>

**Small clusters categories/classes**

|          |    Knowns     | Genomic unknowns | Environmental unknowns | Knowns without Pfam |   Total    |
|:--------:|:-------------:|:----------------:|:----------------------:|:-------------------:|:----------:|
| Clusters | 946,112 (10%) | 2,744,262 (29%)  |    3,645,825 (38%)     |   2,213,654 (23%)   | 9,549,853  |
|   ORFs   |   3,890,895   |    10,281,417    |       11,392,524       |      8,304,629      | 33,869,465 |
