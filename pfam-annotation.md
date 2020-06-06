---
layout: page
title: Pfam functional annotation
---

<h3 class="section-heading  text-primary">Methods</h3>

The predicted ORFs in the metagenomic samples were functionally annotated using the Pfam database of protein domain families (version 31.0) [[1]](#1), with the hmmsearch program from the HMMER package (version: 3.1b2) [[2]](#2). Only matches exceeding the internal gathering threshold (–cut_ga) were retained.
The results were then parsed to remove overlapping/redundant matches and to select hits with an independent E-value &lt; 1e-05 (_Independent E-value: the significance of the sequence in the whole database search, if this were the only domain we had identified. It’s exactly the same as the “best 1 domain” E-value in the sequence top hits list._) and coverage > 0.4.

For each ORF we considered the possibility of multi-domain annotations and we took into account their order of occurrence on the sequence.

- **Scripts and description:** The input for the functional annotation script [hmmsearch_pfam.sh](scripts/Pfam_annotation/hmmsearch_pfam.sh) is the multi-fasta file containing the predicted ORFs sequences (amino acids). The output is a tab-separated file called _domain hits table_, for more information check the [HMMER user guide](http://eddylab.org/software/hmmer3/3.1b2/Userguide.pdf). This table is then parsed to remove overlapping hits and to filter out the matches showing an iE-value greater than 1e-05 and a coverage smaller than 40%. This is done calling the script [hmmsearch_res_parser.sh](scripts/Pfam_annotation/hmmsearch_res_parser.sh) and passing it the result table and the E-value and coverage parameters/values. For more information check the [README_annot.md](scripts/Pfam_annotation/README_annot.md) file.

<h3 class="section-heading  text-primary">Results</h3>

We were able to annotate to a Pfam protein domain barely over 40% (44%) of the total (number of the) initial ~322 million ORFs.

<div class="img_container" style="width:50%; margin:2em auto;">

*Pfam functional annotation results*

| Original dataset | Annotated ORFs | Not-annotated ORFs |
| :--------------: | :------------: | :----------------: |
|    322,248,552   |   140,352,580  |     181,895,972    |

</div>

The distribution of Pfam annotations in the clusters can be found [here](4.2_Cluster_annotation#annotations-in-the-clusters)

* * *

<h4 class="section-heading  text-primary">References</h4>

<a name="1"></a>[1]	R. D. Finn et al., “The Pfam protein families database: towards a more sustainable future,” Nucleic Acids Research, vol. 44, no. D1, Jan. 2016.

<a name="2"></a>[2]	R. D. Finn, J. Clements, and S. R. Eddy, “HMMER web server: interactive sequence similarity searching.,” Nucleic acids research, vol. 39, no. Web Server issue, pp. W29–W37, Jul. 2011.
