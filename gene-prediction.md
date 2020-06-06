---
layout: page
title: Gene prediction
---

We decided to collect the data at the assembly state/level and to start our workflow with the gene prediction step. (The metagenomic assembly is rather computationally expensive step and re-do it for all the considered projects would have required too many resources).

<h3 class="section-heading  text-primary">Methods</h3>

To predict our Open Reading Frames (ORFs) we used the Prodigal (Prokaryotic Dynamic Programming Gene-finding Algorithm) (version 2.6.3: February 2016) program, applied in metagenomic mode [[1]](#1). In addiction we mapped pair-end reads back to the assembled contigs using the short-read BWA mapper [[2]](#2), to obtain an estimation of the ORF abundances based on the counts of mapped reads.

**Scripts and description:** The script <a href="scripts/Gene_prediction/gene_prediction.sh">gene_prediction.sh</a> takes in input contigs from genomes or metagenomes, in fasta format, and returns the predicted ORFs amino acid sequences and a summary in .gff format. The ORFs headers are created using the script <a href="scripts/Gene_prediction/rename_orfs.awk">rename_orfs.awk</a>.

<h3 class="section-heading  text-primary">Results</h3>
We identified a total of 322,248,552 predicted ORFs.
The numbers of contigs and ORFs retrieved for each project are shown in the table below.

<div class="img_container" style="width:70%; margin:2em auto;">

*Number of contigs and predicted ORFs retrieved with Prodigal*

| Data set  | Number of contigs  | Number of ORFs |
|:---------:|:------------------:|:--------------:|
| TARA      |      62,404,654    |   111,903,261  |
| Malaspina |       9,330,293    |    20,574,033  |
| OSD       |       4,127,095    |     7,015,383  |
| GOS       | 12,672,518 (reads) |    20,068,580  |
| HMP       |      80,560,927    |   162,687,295  |

</div>

Metagenomic gene completness information retrieved with the Prodigal gene prediction.

<div class="img_container" style="width:70%; margin:2em auto;">

*Number of predicted genes per completeness category.*

|    Total    |    “00”     |    “10”     |    “01”     |    “11”    |
|:-----------:|:-----------:|:-----------:|:-----------:|:----------:|
| 322,248,552 | 118,717,690 | 106,031,163 | 102,966,482 | 75,694,123 |

Note: “00”=complete, both start and stop codon identified. “01”=right boundary incomplete. “10”=left boundary incomplete. “11”=both left and right edges incomplete.

</div>

<br>
<br>

* * *

<h4 class="section-heading  text-primary">References</h4>

<a name="1"></a>[1]	D. Hyatt, G.-L. Chen, P. F. Locascio, M. L. Land, F. W. Larimer, and L. J. Hauser, “Prodigal: prokaryotic gene recognition and translation initiation site identification.,” BMC bioinformatics, vol. 11, p. 119, Mar. 2010.

<a name="2"></a>[2]	H. Li and R. Durbin, “Fast and accurate long read alignment with Burrows-Wheeler transform.,” Bioinformatics, vol. 26, no. 5, pp. 589–595, 2010.
