---
layout: page
title: Gene prediction
---

We decided to collect the data at the assembly state/level and to start our workflow with the gene prediction step. (The metagenomic assembly is rather computationally expensive step and re-do it for all the considered projects would have required too many resources).

<h3 class="section-heading  text-primary">Methods</h3>
To predict our Open Reading Frames (ORFs) we used the Prodigal (Prokaryotic Dynamic Programming Gene-finding Algorithm) (version 2.6.3: February 2016) program, applied in metagenomic mode [[1]](#1). In addiction we mapped pair-end reads back to the assembled contigs using the short-read BWA mapper [[2]](#2), to obtain an estimation of the ORF abundances based on the counts of mapped reads.

**Scripts and description:** The script [gene_prediction.sh](scripts/Gene_prediction/gene_prediction) takes in input contigs from genomes or metagenomes, in fasta format, and returns the predicted ORFs amino acid sequences and a summary in .gff format. The ORFs headers are created using the script [rename_orfs.awk](scripts/Gene_prediction/rename_orfs.awk).

<h3 class="section-heading  text-primary">Results</h3>
We identified a total of 322,248,552 predicted ORFs.
The numbers of contigs and ORFs retrieved for each project are shown in the table below.

**Number of contigs and predicted ORFs retrieved with Prodigal**

| Data set  | Number of contigs  | Number of ORFs |
|:---------:|:------------------:|:--------------:|
| TARA      |      62,404,654    |   111,903,261  |
| Malaspina |       9,330,293    |    20,574,033  |
| OSD       |       4,127,095    |     7,015,383  |
| GOS       | 12,672,518 (reads) |    20,068,580  |
| HMP       |      80,560,927    |   162,687,295  |


<br>
<br>

<h4 class="section-heading  text-primary">References</h4>

<a name="1"></a>[1]	D. Hyatt, G.-L. Chen, P. F. Locascio, M. L. Land, F. W. Larimer, and L. J. Hauser, “Prodigal: prokaryotic gene recognition and translation initiation site identification.,” BMC bioinformatics, vol. 11, p. 119, Mar. 2010.

<a name="2"></a>[2]	H. Li and R. Durbin, “Fast and accurate long read alignment with Burrows-Wheeler transform.,” Bioinformatics, vol. 26, no. 5, pp. 589–595, 2010.
