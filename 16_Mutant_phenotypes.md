---
layout: page
title: Mutant phenotypes and the unknown coding sequence space
---

<h2 class="section-heading  text-primary">Augmenting RB-TnSeq experiment data through a structured coding sequence space</h2>


<div class="img_container" style="width:50%; margin:2em auto;">

| Genes | Archaea | Bacteria |
|:-------:|:-------:|:--------:|
| 127,318 |  2,075  | 125,243  |

*Release 03-RS86 (19th August 2018)*

</div>

<h3 class="section-heading  text-primary">Methods</h3>

We searched the 37,684 genes of unknown function associated with mutant phenotypes from Price et al.[[1]](#1) against our gene cluster profiles. We kept the hits with e-value ≤ 1e-20 and a query coverage > 60%. Then we filtered the results to keep the hits within 90% of the Log(best-e-value), and we used a majority vote function to retrieve the consensus category for each hit. Lastly, we selected the best-hits based on the smallest e-value and the largest query and target coverage values. We used the fitness values from the RB-TnSeq experiments from Price et al. to identify genes of unknown function that are important for fitness under certain experimental conditions.


**Scripts and description:** The search script can be found in [db_search.sh](scripts/Coverage_ext_dbs/db_search.sh). The results were then parsed with the following R script [mutant_data_parser.R](scripts/Mutant_phenotypes/mutant_data_parser.R) and plotted with [mutant_plots.R](scripts/Mutant_phenotypes/mutant_plots.R)


<h3 class="section-heading  text-primary">Results</h3>

One of the most promising approaches to unveil the function of unknown coding sequences is the study of phenotypic mutants across many experimental conditions using RB-TnSeq13. We selected one of the experimental conditions tested in Price et al. [[1]](#1) to show the potential of combining RB-TnSeq experiments with our integrated dataset to augment experimental data. We compared the fitness values in plain rich medium with added Spectinomycin dihydrochloride pentahydrate to the fitness in plain rich medium (LB) in Pseudomonas fluorescens FW300-N2C3 (Figure A).

<div class="img_container" style="width:70%; margin:2em auto;">

<img alt="mutant_A.png" src="/img/mutant_A.png" width="80%" height="" >

*Here we compare the fitness in rich medium with added Spectinomycin dihydrochloride pentahydrate to the fitness in plain rich medium (LB) in Pseudomonas fluorescens FW300-N2C3. The selected gene belongs to the genomic unknown GC GU_19737823 and presents a strong phenotype (fitness = -3.1; t = -9.1).*

</div>


This antibiotic inhibits protein synthesis and elongation by binding to the bacterial 30S ribosomal subunit and interferes with the peptidyl tRNA translocation. We identified the gene with locus id AO356_08590 that presents a strong phenotype (fitness = -3.1; t = -9.1) and has no known function. This gene belongs to the genomic unknown GC GU_19737823. We can track this GC into the environment and explore the occurrence in the different samples we have in our database. As expected, the GC is mostly found in non-human metagenomes (Figure B) as Pseudomonas are common inhabitants of soil and water environments.

<div class="img_container" style="width:70%; margin:2em auto;">

<img alt="mutant_B.png" src="/img/mutant_B.png" width="80%" height="" >

*We explored the occurrence of the GC GU_19737823 in the metagenomes used in this study.*

</div>

We can add another layer of information to the selected GC by looking at the associated remote homologs in the GCC GU_c_21103 (Figure C).

<div class="img_container" style="width:60%; margin:2em auto;">

<img alt="mutant_C.png" src="/img/mutant_C.png" width="70%" height="" >

*GU_19737823 is a member of the gene cluster community GU_c_21103. The network shows the relationships between the different GCs members of the gene cluster community GU_c_21103. The size of the node corresponds to the node degree of each GC. Edge thickness corresponds to the HHblits-score/column metric. Highlighted in red is the GC GU_19737823.*

</div>

The GU_c_21103 contains 469 genes, 233 genes are found in the GTDB.

We identified all the genes in the GTDB r86 genomes that belong to the GCC GU_c_21103 and explored their genomic neighborhoods. All members from GU_c_21103 are constrained to the class Gammaproteobacteria, and interestingly GU_19737823 is mostly exclusive to the order Pseudomonadales (Figure D). The gene order in the different genomes analyzed is highly conserved (Figure D), finding GU_19737823 after the rpsF::rpsR operon and before rpll. rpsF and rpsR encode for 30S ribosomal proteins, the prime target of spectinomycin.

<div class="img_container" style="width:90%; margin:2em auto;">

<img alt="mutant_D.png" src="/img/mutant_D.png" width="90%" height="" >

*We identified all the genes in the GTDB r86 genomes that belong to the GCC GU_c_21103 and explored their genomic neighborhoods. GU_c_21103 members were constrained to the class Gammaproteobacteria, and GU_19737823 is mostly exclusive to the order Pseudomonadales. The GTDB r86 subtree only shows RefSeq genomes. Branch colors correspond to the different GCs found in GU_c_21103. Bubble plot depicts the number of genomes with a gene that belongs to GU_c_21103. On the right we have the gene order in the different genomes analyzed is highly conserved, finding GU_19737823 after the rpsF::rpsR operon and before rpll. rpsF and rpsR encode for the 30S ribosomal protein S6 and 30S ribosomal protein S18 respectively.*

</div>

The combination of the experimental evidence and the associated data inferred by our approach provides strong support to generate the hypothesis that the gene AO356_08590 might be involved in the resistance to spectinomycin.

<br>
<br>

* * *

<h4 class="section-heading  text-primary">References</h4>

<a name="1"></a>[1] Price, M. N. et al. Mutant phenotypes for thousands of bacterial genes of unknown function. Nature 557, 503–509 (2018)
