---
layout: page
title: Gene prediction
---

We used the official assemblies from the metagenomic projects TARA, OSD2014, Malaspina, HMP-I/II and GOS to test our approach. We used Prodigal (v2.6.3) [1] in metagenomic mode to predict the genes from the metagenomic dataset. We identified potential spurious genes using the AntiFam database. Furthermore, we screened for 'shadow' genes using the procedure described in Yooseph et al. [2]

{% include callout.html content="- For more information regarding the identification of spurious and shadow genes, check [here](spurious-shadow-genes.md). <br />- A description of the data used for the manuscript can be found [here](data)." type="primary" %}
  
We identified a total of 322,248,552 predicted ORFs in total for the metagenomic dataset (Table 1) and 93,723,190 genes for GTDB (Table 2).

<p></p>


| Data set  | Number of contigs | Number of genes |
| :-------: | :---------------: | :-------------: |
|   TARA    |    62,404,654     |   111,903,261   |
| Malaspina |     9,330,293     |   20,574,033    |
|    OSD    |     4,127,095     |    7,015,383    |
|    GOS    |    12,672,518     |   20,068,580    |
|    HMP    |    80,560,927     |   162,687,295   |
{: style="margin-left: auto; margin-right: auto; width: 60%"}

**Table 1.** Number of contigs and predicted genes Prodigal
{: style="color:gray; font-size: 90%; text-align: center;"}


<br />

We compiled the gene completion for the metagenomic dataset (Table 2). Where **00** is a complete gene with both start and stop codon identified; **01** has the right boundary incomplete; **10** has the left boundary incomplete; and **11** when both left and right edges are incomplete.


|   Dataset   |    “00”     |    “10”     |    “01”     |    “11”    |    Total    |
| :---------: | :---------: | :---------: | :---------: | :--------: | :---------: |
| Metagenomic | 118,717,690 | 106,031,163 | 102,966,482 | 75,694,123 | 322,248,552 |
{: style="margin-left: auto; margin-right: auto; width: 60%"}

**Table 2.** Number of predicted genes per completeness category. 
{: style="color:gray; font-size: 90%; text-align: center;"}

Prodigal only predicted 37% of complete genes (00) for the metagenomic dataset. After the gene prediction, the workflow proceeds with the [Pfam annotation](pfam-annotation) step. 

<br />
<br />

{% capture code %}

The script <a href="scripts/Gene_prediction/gene_prediction.sh">gene_prediction.sh</a> takes in input contigs from genomes or metagenomes, in fasta format, and returns the predicted ORFs amino acid sequences and a summary in .gff format. The ORFs headers are created using the script <a href="scripts/Gene_prediction/rename_orfs.awk">rename_orfs.awk</a>.

{% endcapture %}

{% include collapsible.html toggle-name="toggle-code" button-text="Code and description" toggle-text=code %}

{% capture references %}

**[1]**	Hyatt, D., Chen, L. G.-L. L.-., LoCascio, F. P., Land, L. M., Larimer, W. F., & Hauser, J. L. (2010). Prodigal: prokaryotic gene recognition and translation initiation site identification. BMC Bioinformatics, 11(1), 119–119.  
**[2]** Yooseph, S., Sutton, G., Rusch, B. D., Halpern, L. A., Williamson, J. S., Remington, K., Eisen, A. J., Heidelberg, B. K., Manning, G., Li, W., Jaroszewski, L., Cieplak, P., Miller, S. C., Li, H., Mashiyama, T. S., Joachimiak, P. M., Van Belle, C., Chandonia, M. J., Soergel, A. D., … Venter, C. J. (2007). The Sorcerer II global ocean sampling expedition: Expanding the universe of protein families. PLoS Biology, 5(3), 0432–0466.

{% endcapture %}

<p></p>
{% include collapsible.html toggle-name="toggle-ref" button-text="References" toggle-text=references %}



