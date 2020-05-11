---
layout: page
title: Environment - constraints
---

<h2 class="section-heading  text-primary">Rate of accumulation of known and unknown clusters and cluster communities</h2>

<h3 class="section-heading  text-primary">Methods</h3>

We calculated the cumulative number of known and unknown ORF clusters as a function of both the number of metagenomes or genomes and ORFs.
For each metagenomic sample, we generated 1000 random metagenome sets and we calculated the total number of clusters found in the set. We performed the analysis independently for the 1,246 HMP metagenomes and the 358 marine metagenomes, from the combination of the TARA (242) and Malaspina (116) samples.
We repeated the same estimation for the GTDB clusters as a function of the number of genomes, generating 100 random genome sets/using 100 permutations. To calculate the rate of cluster accumulation as a function of the number of ORFs we generated 10 random ORF sets.
In addition, we computed the rate of accumulation for the cluster communities of both the metagenomic and the GTDB/genomic dataset, as a function of the number of metagenomes, genomes and ORFs. For each case, we applied the same number of permutations described above.

**Script and description:** The scripts to retrieve and plot the rarefaction curves are: [collector_curves_mg.R](scripts/Environmental/Collector_curves/collector_curves_mg.R) for the metagenomic dataset and [collector_curves_g.R](scripts/Environmental/Collector_curves/collector_curves_g.R) for the genomic dataset. For the metagenomic dataset we used the data from TARA, Malaspina and HMP. The input tables are: "marine_hmp_smpl_cl_categ.tsv.gz", "marine_hmp_smpl_comm_categ.tsv.gz", "marine_hmp_orfs_cl_categ.tsv.gz" and "marine_hmp_orfs_comm_categ.tsv.gz". For the genomic dataset the input tables are: "all_gtdb_genome_orf_cl_categ.tsv.gz" for the clusters and "all_gtdb_genome_orfs_comm_categ.tsv.gz" for the cluster communities, both to be subsetted for genomes or ORFs.
The output are r-objects containg the data to plot the collector curves (ex: "cum_curve_res_marine_hmp_cl1K.rda", for the metagenomic clusters vs samples).

```{r}
# A tibble: 6 x 4
  cat        n  perm  size
  <chr>  <dbl> <dbl> <dbl>
1 GU     26158     1     1
2 K      66911     1     1
3 EU      9730     1     1
```

<h3 class="section-heading  text-primary">Results</h3>

We estimated the rate of accumulation of ORF clusters as a function of the number of metagenomes and genomes.
The KNOWNS (K+KWP) accumulation curves in both marine and human-associated metagenomes, and GTDB genomes, are closer to saturation compared to the all ORFs and the set of unknown ORFs (GU+EU). The functional microbial space and, in particular the UNKNOWN space, result still largely uncharacterised. We obtained equivalent results considering the cluster accumulation rates with increased number of predicted ORFs. The rate of new cluster community discovery, reaches saturation in the metagenomic samples, but not in the genomes.
The rarefaction curves plots are shown below.

<h4 class="section-heading  text-primary">Collector curve plots</h4>

**Clusters**

<img alt="Accumulation_curves-7a848e48.png" src="/img/Accumulation_curves-7a848e48.png" width="350" height="" ><img alt="Accumulation_curves-14a96b53.png" src="/img/Accumulation_curves-14a96b53.png" width="350" height="" ><img alt="Accumulation_curves-d293f987.png" src="/img/Accumulation_curves-d293f987.png" width="350" height="" >

**Communities**

<img alt="Accumulation_curves-20bb8f95.png" src="/img/Accumulation_curves-20bb8f95.png" width="350" height="" ><img alt="Accumulation_curves-23161b2e.png" src="/img/Accumulation_curves-23161b2e.png" width="350" height="" ><img alt="Accumulation_curves-2be69289.png" src="/img/Accumulation_curves-2be69289.png" width="350" height="" >


<h2 class="section-heading  text-primary">Cluster distribution and abundance in genomes and metagenomes</h2>

<h4 class="section-heading  text-primary">Contextual data for each project:</h4>

The contextual data for the metagenomic projects we considered, are all publicy available. We combined the data from the different projects in one [SQLite database](files/contextual_data/contextual_data.db), containing one parsed and tidied table for each project.

The original contextual data for each project was retrieved from the sources described below, and gathered into one database with the script [mg_contextual_data.r](scripts/Environment/mg_contextual_data.r).

**GOS:** http://datacommons.cyverse.org/browse/iplant/home/shared/imicrobe/projects/26/CAM_PROJ_GOS.csv

**Malaspina:** "Malaspina_Metadata_20170703.xls"

**TARA:** http://ocean-microbiome.embl.de/data/OM.CompanionTables.xlsx

This spreadsheet file contains the following tables:

Table W1: Tara Oceans sample description

Table W2: Sequencing statistics

Table W3: Reference genomes

Table W4: Source and statistics of genes used to generate the OM-RGC

Table W5: Descriptive statistics for miTAG-based analyses

Table W6: List of functional marker genes

Table W7: List of clusters of orthologous groups

Table W8: Associated metadata used for analysis

**OSD:** http://mb3is.megx.net/osd-files/download?path=/2014/samples&files=OSD2014-env_data_2017-11-23.csv

(Documentations: https://github.com/MicroB3-IS/osd-analysis/wiki/OSD-2014-environmental-data-csv-documentation)

**HMP(I-II):** HMP-I https://www.hmpdacc.org/hmp/catalog/grid.php?dataset=metagenomic (and save to csv)
         HMP-II ... "HMP_phase2017_cdata.txt"

<h4 class="section-heading  text-primary">Cluster abundance calculation (for metagenomic clusters):</h4>

We mapped pair-end reads back to the assembly contigs using the short-read BWA mapper (H. Li and Durbin 2010), to obtain an estimation of the ORF abundances based on the counts of mapped reads. The coverage for each gene was calculated as:

*coverage_orfA = sum(depth_of_coverage * fraction_covered)*

and it was obtained by mapping the reads against the metagdenomic assemblies using the script [mg_read_mapping.sh](scripts/MG_read_mapping/mg_read_mapping.sh).
The main output file contains the ORF ids the coverage per contig and fraction covered (we use this last value as our proxy for ORF abundance).
We combine the mapping results for all the considered metagenomic project in one file ("marine_hmp_orfs_coverage.tsv.gz").

For the GTDB genomes we used ORF counts.

<h4 class="section-heading  text-primary">Cluster category proportion distributions</h4>

The proportion distribution of the cluster categories in the marine and human metagenomes in Figure 2, shows that the UNKNOWN fraction is mainly represented by GUs. The UNKNOWN fraction goes up to 95% in the Human microbiome metagenomes and to 75% in the marine ones.

<div class="img_container" style="width:90%; margin:2em auto;">

<img alt="Cluster_categ_prop_ditrib_mg.png" src="/img/Cluster_categ_prop_ditrib_mg.png" width="80%" height="" >

*The proportion distribution of the cluster category in the metagenomes. The KNOWN fraction is represented by the Knowns (K) and the Knowns without Pfam (KWP). The UNKNOWN fraction by the Genomic unknowns (GU) and the Environmental unknowns (EU). The gray fraction represents the pool of non classified data, containing the singletons, and the clusters discarded during the validation step.*

</div>

<h2 class="section-heading  text-primary">Environment - specificity</h2>

<h3 class="section-heading  text-primary">Niche breadth analysis of cluster and cluster communities in the metagenomic samples</h3>

<h3 class="section-heading  text-primary">Methods</h3>

To quantify the niche specialization of our cluster communities in the sampling sites we applied the Levin's Niche Breadth [[1]](#1), which is the theoretical, multidimensional range of resources and habitats a species can occupy and access. Levin's Niche Breadth (B) is used in macroecology to assess if an organism is generalist or a specialist and is calculated as B = 1/Sum(P^2ij) from 1 to N (B is one divided by the sum of all proportions of a biological entity (P) from 1 to N sites of biological entity i through biological entity j).
We applied this method to find wheater a cluster community is broadly distributed (found in many samples) or just present in a restrict set of samples (i.e it's more sample specific).
To classify clusters as having a “broad" or “narrow", we created a null distribution of each cluster B score. We randomized the original cluster abundance matrix 100 times using the *Vegan* package with the *quasiswap* count method in the function *nullmodel* [[2]](#2) and [[3]](#3). This method randomizes abundance matrices by mixing up numbers of 2x2 matrix subsets within the larger matrix. Additionally, the method maintains the abundance matrix column and row sums to preserve the original attributes of the matrix in the new randomized matrices. Once the distribution for each component is calculated, if a component score was in the top 2.5% of its distribution, we classified it as “broad". If it was in the bottom 2.5% of the distribution, we classified it as “narrow".

**Script and description:** The script used to performed the Niche Breadth analysis can be found in the [NicheBreadth](scripts/Environment/NicheBreadth) folder, in the form of an R project: [NB_unks.Rproj](scripts/Environment/NicheBreadth/NB_unks.Rproj). The input data are: a list of samples sites ("listSamplesPaper.tsv") and the cluster and cluster communities abundances in the samples ("cl_abund_smpl_grouped.tsv.gz" and communities_abund_smpl_grouped.tsv.gz).

<h3 class="section-heading  text-primary">Results</h3>

We observed that the Ks are more evenly distributed between narrow and wide communities. The majority of the GU communities show a narrow niche breadth, as well as more than 99% of the EUs. In these samples the unknown fraction shows a distinct narrow distribution suggesting an adaptive and environmental-related potential.
We observed the presence of a group of EU communities that are narrow and with mean proportions greater than 1e-04. This indicates that they are found in relatively high abundance in only a few samples. These communities may be truly adaptive and could be providing the microbes with a selective advantage. However, more surprisingly, we observed also 73 EU communities that showed a broad distribution.
The signal of broad distributed EU communities may demonstrate that these groups of genes/functions, which have no functional annotation or are found in sequenced or draft genomes, share core microbial functions with the other community categories in the world’s oceans. This is a surprising result because it could infer that a set of proteins from a ubiquitous domain of life and or function in the ocean have been left uncharacterized by metagenomics. On a broader level, considering all TARA samples, we still observed a higher number of narrow distributed communities in the unknown fraction, but the differences are smaller/smoother. In the HMP samples instead the narrow-distributed fraction of communities seems to decrease from the Ks to the EUs in favor of the increase of the intermediate fraction, without a significant distribution pattern.

<div class="img_container" style="width:70%; margin:2em auto;">

<img alt="NicheBreadth.png" src="/img/NicheBreadth.png" width="80%" height="" >

*Levins Niche Breadth scores of the clusters (A) and cluster communities (B) categories in the metagenomic samples. On the bars is reported the percentage of clusters (A), communities (B) with a broad, narrow or non-significant distribution.*

</div>

<br>

**HMP outlier samples**

| label     | organ  | body_site                   | HPV_type                                                                |
| --------- | ------ | --------------------------- | ----------------------------------------------------------------------- |
| SRS013234 | Mouth  | Tongue dorsum               | HPV20,HPV135,HPV147                                                     |
| SRS024580 | Mouth  | Tongue dorsum               | HPV20,HPV135,HPV17                                                      |
| SRS043646 | Mouth  | Buccal mucosa               | HPV32                                                                   |
| SRS046623 | Mouth  | Buccal mucosa               | HPV32,HPV107                                                            |
| SRS045127 | Mouth  | Tongue dorsum               | HPV32                                                                   |
| SRS055426 | Mouth  | Tongue dorsum               | HPV32,HPV5                                                              |
| SRS022158 | Vagina | Posterior fornix            | HPV18,HPV34,HPV39,HPV56,HPV90                                           |
| SRS048536 | Vagina | Posterior fornix            | HPV18,HPV34,HPV39,HPV56,HPV90,HPV103,HPV106,HPV51,HPV6,HPV73,HPV74      |
| SRS014465 | Vagina | Vaginal introitus           | HPV90                                                                   |
| SRS015071 | Vagina | Vaginal introitus           | HPV90                                                                   |
| SRS014494 | Vagina | Posterior fornix            | HPV90,HPV45                                                             |
| SRS015073 | Vagina | Posterior fornix            | HPV90                                                                   |
| SRS023850 | Vagina | Posterior fornix            | HPV91                                                                   |
| SRS075419 | Vagina | Posterior fornix            | HPV91                                                                   |
| SRS014343 | Vagina | Posterior fornix            | HPV89,HPV131,HPV134,HPV52                                               |
| SRS054962 | Vagina | Posterior fornix            | HPV89,HPV118                                                            |
| SRS014235 | Gut    | Stool                       | HPV47                                                                   |
| SRS019685 | Gut    | Stool                       | HPV47                                                                   |
| SRS057717 | Gut    | Stool                       | HPV68                                                                   |
| SRS023346 | Gut    | Stool                       | HPV101                                                                  |
| SRS019019 | Skin   | Anterior nares              | HPV107,HPV23                                                            |
| SRS014682 | Skin   | Anterior nares              | HPV124,HPV14                                                            |
| SRS019039 | Skin   | Anterior nares              |                                                                         |
| SRS019033 | Skin   | Right retroauricular crease | HPV24,HPV75,HPV144,HPV92,HPV121,HPV130                                  |
| SRS019016 | Skin   | Right retroauricular crease | HPV24,HPV75,HPV144,HPV92,HPV120,HPV104,HPV119,HPV147,HPV149,HPV153,HPV8 |
| SRS015430 | Skin   | Anterior nares              | HPV148,HPV127,HPV149,HPV131                                             |
| SRS015450 | Skin   | Anterior nares              | HPV148,HPV127,HPV144,HPV132,HPV141                                      |
| SRS019067 | Skin   | Anterior nares              | HPV148,HPV122,HPV149,HPV10,HPV115,HPV147                                |
| SRS019064 | Skin   | Right retroauricular crease | HPV126,HPV14                                                            |
| SRS019081 | Skin   | Right retroauricular crease | HPV126                                                                  |
| SRS018585 | Skin   | Anterior nares              | HPV112,HPV132,HPV136,HPV148                                             |
| SRS051600 | Skin   | Anterior nares              | HPV119,HPV130                                                           |
| SRS017044 | Skin   | Anterior nares              | HPV12,HPV19,HPV28                                                       |
| SRS044474 | Skin   | Anterior nares              | HPV12,HPV19,HPV142,HPV17,HPV19,HPV88,HPV119,HPV134,HPV147               |


<h4 class="section-heading  text-primary">References</h4>

<a name="1"></a>[1] Levins, Richard. 1966. “THE STRATEGY OF MODEL BUILDING IN POPULATION BIOLOGY.” American Scientist 54 (4): 421–31

<a name="2"></a>[2] Miklós, I., and J. Podani. 2004. “RANDOMIZATION OF PRESENCE–ABSENCE MATRICES: COMMENTS AND NEW ALGORITHMS.” Ecology.

<a name="3"></a>[3] Oksanen, Jari, F. Guillaume Blanchet, Michael Friendly, Roeland Kindt, Pierre Legendre, Dan McGlinn, Peter R. Minchin, et al. 2019. “Vegan: Community Ecology Package.”
