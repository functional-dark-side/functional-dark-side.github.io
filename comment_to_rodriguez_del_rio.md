---
layout: page_no_construction
title: Comment to Rodríguez del Río et al.
---
{% include callout.html content="BioRxiv marked this comment as spam. This is a temporary solution until it is fixed.<br/>Please leave any comments at the Rodríguez del Río et al. preprint [here](https://www.biorxiv.org/content/10.1101/2022.01.26.477801)" type="primary" %}


In their manuscript, "Functional and evolutionary significance of unknown genes from uncultivated taxa", Rodríguez del Río et al. share a comprehensive analysis of gene families of unknown functions by identifying such genes in publicly available Metagenome Assembled Genomes. Genes of unknown functions represent a critical gap in microbiology as they prevent deeper insights into the ecology and evolution of key microbial traits and their impact on microbial phenotypes, thus, the purpose and findings of the study are of great interest.
While we commend their efforts to unify known and unknown gene families and generate community resources such as [https://novelfams.cgmlab.org/](https://novelfams.cgmlab.org/), we regretfully report that the manuscript by Rodríguez del Río et al. fails to acknowledge extensive previous work on this topic such as FUnkFams by Wyman et al. [[1]](#1), and our recent study by Vanni et al. [[2]](#2), which has made available a similar resource, AGNOSTOS-DB [[3]](#3). Even though studies mentioned here have already reported many of the major findings reported in Rodríguez del Río et al., the current manuscript does not cite FUnkFams, and cites Vanni et al. only once from the Introduction, without highlighting significant parallels between the approaches and findings of the two studies, which we find unfortunate.

Here we highlight key similarities between [Rodríguez del Río et al.](https://www.biorxiv.org/content/10.1101/2022.01.26.477801) (first posted on bioRxiv on **January 27, 2022**) and [Vanni et al.](https://www.biorxiv.org/content/10.1101/2020.06.30.180448) (first posted on bioRxiv on **July 01, 2020**):

- Both studies report that the largest number of gene clusters with unknown function or novel protein families (hereafter referred to as unknowns) are found in uncultivated taxa. Rodríguez del Río et al. describe their findings in the section "*High content of unknown protein families in the genomes of uncultivated taxa*". Vanni et al. report the same observation, "*the phyla with a larger number of MAGs are enriched in GCs of unknown function*" and are mainly composed of "*newly described phyla such as Cand. Riflebacteria and Cand. Patescibacteria (Anantharaman et al., 2018; Brown et al., 2015; Rinke et al., 2013), both with the largest unknown to known ratio*" (Figure 5D, Supp. Note 14) and that "*metagenome-assembled genomes are not only unveiling new regions of the microbial universe (42% of the reference genomes in GTDB_r86), but they are also enriching the tree of life with genes of unknown function*".

- Both studies identify unknowns that are lineage-specific.  Rodríguez del Río et al. identify "*a core set of 980 protein family clusters synapomorphic for entire uncultivated lineages —that is, present in nearly all MAGs/SAGs from a given lineage (90% coverage) but never detected in other taxa (...) these newly discovered protein families can accurately distinguish 16 uncultivated phyla, 19 classes, and 90 orders, involving 179, 104, and 697 novel protein families, respectively.*". Vanni et al. provide more than 600K lineage-specific gene clusters of unknown function within the domain Bacteria (36 at the phylum level, 428 at the class level, and 1,641 at the order level (Supp. Table 10)) and Archaea (1 phylum, 25 classes, and 378 orders (Supp. Table 13-1)).

- Both studies conclude that there is an increase in the number of lineage-specific unknowns towards the lower levels of taxonomy (i.e., genus, and species).  Rodríguez del Río et al. report these results in Figure 3C and Vanni et al. in Figure 5A. 

- Both studies report that the unknowns could be considered relevant from an evolutionary perspective. Rodríguez del Río et al. provide a set of novel gene families that are *phylogenetically conserved and under purifying selection*, which parallels an observation that has been described in Vanni et al. based on phylogenetic conservatism of traits: "*the unknown GCs are more phylogenetically conserved (GCs shared among members of deep clades) than the known (Fig. 5B, p < 0.0001), revealing the importance of the genome's uncharacterized fraction. However, the lineage-specific unknown GCs are less phylogenetically conserved (Fig. 5B) than the known, agreeing with the large number of lineage-specific GCs observed at Genus and Species level (Fig. 5A).*"

- Both studies find unknowns that are widely distributed in the environment. Rodríguez del Río et al. report that  *"the majority of the new protein families (55%) are detected in more than ten samples, span at least two habitats*", indicating a possible role as "*core molecular functions from widespread microbial lineages, or derive from promiscuous mobile elements.*". Similarly, Vanni et al. report the existence of a "*pool of broadly distributed environmental unknowns*", which "*identified traces of potential ubiquitous organisms left uncharacterized by traditional approaches*". Furthermore, the results reported by Vanni et al. also support the findings observed by Coelho et al. [[4]](#4) and mentioned by Rodríguez del Río et al. “*This result contrasts with the habitat-specific pattern observed for the majority of individual species-level genes*” where Vanni et al. also show the narrow ecological distribution of the unknown fraction reported in Figure 4D. In addition, as shown by our colleagues in Holland-Moritz et al. [[5]](#5) the majority of these dominant unknown genes are associated with mobile genetic elements in the soil.

- Both studies report a collection of small proteins of unknown function. In Rodríguez del Río et al. they report  "*13,456 families of proteins shorter than 50 residues, 486 of which have been reported previously as novel functional genes*" in Sberro et al. (2019). Vanni et al. report a similar  finding: "*12,313 high-quality gene clusters [..] encoding for small proteins (<= 50 amino acids)", the majority of which are "unknown (66%), which agrees with recent findings on novel small proteins from metagenomes (Sberro et al., 2019).*"

Parallels in major scientific insights between the two studies likely stem from parallels in computational strategies implemented to study datasets of similar nature. Overlaps between computational approaches implemented and described by Vanni et al. and Rodríguez del Río et include the following:

- Both studies apply strict quality and novelty filters to generate the basic dataset. In  Rodríguez del Río et al.  Figure 1A shows the basic workflow used to compile “*a collection of high-quality novel protein families from uncultivated taxa*”. Similarly, Vanni et al. workflow (Supp. Fig 1) produce “*highly conserved intra-homogeneous*” gene clusters (Figure 1B), “*both in terms of sequence similarity and domain architecture homogeneity; it exhausts any existing homology to known genes and provides a proper delimitation of the unknown genes” to provide “the best representation of the unknown space*”.

- Both studies group the predicted genes into gene clusters using the clustering workflow of the software MMseqs2 [[6]](#6) with a minimum identity threshold of 30%. 

- Both studies detect and remove spurious genes searching the AntiFam [[7]](#7) database.

- Both studies use a multi-search approach with different sensitivity levels to confidently identify unknowns.

- Both studies search the unknowns against a database generated by Price et al. [[8]](#8) using RB-TnSeq experiments.  Rodríguez del Río et al. wrote “*we mapped the protein family signatures derived from our catalog against the set of 11,779 unknown genes recently annotated based on genome-wide mutant fitness experiments, and found 69 matches to genes associated with specific growth conditions*”. Vanni et al. wrote, “*We searched the 37,684 genes of unknown function associated with mutant phenotypes from Price et al. (2018) [...] to identify genes of unknown function that are important for fitness under certain experimental conditions*”.

- Rodríguez del Río et al. identify “*Synapomorphic protein families*”, “*by calculating the clade specificity and coverage of each protein family across all GTDB v202 lineages*”. “*Coverage was calculated as the number of genomes containing a specific protein family over the total number of genomes under the target clade. Specificity was estimated as the percentage of protein members within a family that belonged to the target clade. We considered protein families as synapomorphic if they contained at least 10 members (i.e., protein sequences from different genomes) and had a coverage higher than 0.9 and a specificity of 1.0 for a given lineage.*” Vanni et al. similarly identify a gene cluster as lineage-specific if present in less than half of all genomes and at least 2 with F1-score > 0.95 using the methods described in Mendler et al. [[9]](#9), where the F1-score is calculated combining trait precision and sensitivity, where Precision indicates the degree to which a trait is conserved within a lineage, and sensitivity the exclusivity of that trait to a lineage.

Indeed, both studies also included novel findings that are not covered by either. We recognize the following findings as novel findings that are unique to the study by Rodríguez del Río et al., and are not covered by recent literature to the best of our knowledge:

- Rodríguez del Río et al. calculate the dN/dS ratio for each protein family, showing that the majority of unknown families are under a strong purifying selection (Figure 1B).

- Rodríguez del Río et al. also investigate the presence of potential antimicrobial peptides in their novel families and “*found 965 unknown protein families in the genomic context of well-known antibiotic resistance genes, 25 of which are embedded in clear genomic islands with more than 3 resistance-related neighbor genes (as predicted by CARD) (Figure 2C).*”

- Rodríguez del Río et al. report that “*unknown protein families are slightly enriched in transmembrane and signal peptide-containing proteins (being 7.6% and 7.9% more frequent than in eggNOG, respectively), which suggests that they may play an important role in mediating interactions with the environment.*”

- Vanni et al. pinpoint the potential of genomic context analyses to generate functional hypotheses both in Supp. Note 12 (“*Next, we examined the genomic neighborhood of the broad distributed EU on the MAG contigs. Investigating the genomic neighborhood can lead to the inference of a possible function of the EU.”, Figure 12-1 C*) and in the genomic neighborhood analysis shown in Figure 6D. However, Rodríguez del Río et al. provide a much more exhaustive analysis of the genomic context of protein families of unknown function. They provide a summary of unknown protein families linked to metabolic marker genes (“*Presence/absence matrix of unknown protein families forming operon-like structures with marker genes involved in energy and xenobiotic degradation KEGG pathways in Figure 2A.*” and “*unknown protein families tightly coupled with genes for every nitrogen cycling step (Figure 2B).*”). Overall, they identify “*74,356 (17.98%) novel protein families in phylogenetically conserved operon regions”, and a total of 1,344 families sharing a genomic context with “genes related to energy production or xenobiotic compound degradation pathways*”.

- Moreover, Rodríguez del Río et al. identify unknown families probability involved in “*cell-cell or cell-environment interactions*” and reported “*502 novel families from the Patescibacteria group potentially involved in molecular transportation, 34 in adhesion, and 13 in cytokinesis*”.

Science is incremental, and significant overlaps between different studies can be seen as an opportunity to address the reproducibility crisis in science. However, failure to recognize previous work appropriately has serious implications. Not only does it make it difficult for future generations to trace the origins of novel ideas, but also impacts the careers and well-being of ECRs. We hope the authors will reconsider their omission of the previous work and cite novel findings that are already published.

Antonio Fernandez-Guerra, \
On behalf of all authors of Vanni et al.

**References**

<a name="1"></a>[1]	Wyman SK, Avila-Herrera A, Nayfach S, Pollard KS. A most wanted list of conserved microbial protein families with no known domains. PLoS One. 2018;13: e0205749. 

<a name="2"></a>[2]Vanni C, Schechter MS, Acinas SG, Barberán A, Buttigieg PL, Casamayor EO, et al. Unifying the known and unknown microbial coding sequence space. bioRxiv. 2021. p. 2020.06.30.180448. doi:10.1101/2020.06.30.180448

<a name="3"></a>[3]	Vanni C, Schechter MS, Delmont TO, Murat Eren A, Steinegger M, Gloeckner FO, et al. AGNOSTOS-DB: a resource to unlock the uncharted regions of the coding sequence space. bioRxiv. 2021. p. 2021.06.07.447314. doi:10.1101/2021.06.07.447314

<a name="4"></a>[4] Coelho LP, Alves R, Del Río ÁR, Myers PN, Cantalapiedra CP, Giner-Lamia J, et al. Towards the biogeography of prokaryotic genes. Nature. 2022;601: 252–256.

<a name="5"></a>[5] Holland-Moritz H, Vanni C, Fernandez-Guerra A, Bissett A, Fierer N. An ecological perspective on microbial genes of unknown function in soil. bioRxiv. 2021. p. 2021.12.02.470747. doi:10.1101/2021.12.02.470747

<a name="6"></a>[6] Steinegger M, Söding J. MMseqs2 enables sensitive protein sequence searching for the analysis of massive data sets. Nat Biotechnol. 2017;35: 1026–1028.

<a name="7"></a>[7] Eberhardt RY, Haft DH, Punta M, Martin M, O’Donovan C, Bateman A. AntiFam: a tool to help identify spurious ORFs in protein annotation. Database. 2012;2012: bas003.

<a name="8"></a>[8] Price MN, Wetmore KM, Waters RJ, Callaghan M, Ray J, Liu H, et al. Mutant phenotypes for thousands of bacterial genes of unknown function. Nature. 2018;557: 503–509.

<a name="9"></a>[9] Mendler K, Chen H, Parks DH, Lobb B, Hug LA, Doxey AC. AnnoTree: visualization and exploration of a functionally annotated microbial tree of life. Nucleic Acids Res. 2019;47: 4442–4448.

