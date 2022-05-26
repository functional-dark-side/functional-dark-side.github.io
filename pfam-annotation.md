---
layout: page
title: Pfam functional annotation
---


We annotated the predicted genes using the **hmmsearch** program from the HMMER package (version: 3.1b2) [1] in combination with the **Pfam database v31** [2]. We kept the matches exceeding the internal gathering threshold and presenting an *independent e-value < 1e-5* and *coverage > 0.4*. In addition, we took in account multi-domain annotations and we removed overlapping annotations when the overlap is larger than 50%, keeping the ones with the smaller e-value. In addition, we took into account their order of occurrence on the sequence. We assigned a Pfam annotation to 44% of the initial ~322 million genes (Table 1).

<br />
<br />


| Original dataset | Annotated ORFs | Not-annotated ORFs |
| :--------------: | :------------: | :----------------: |
|    322,248,552   |   140,352,580  |     181,895,972    |
{: style="margin-left: auto; margin-right: auto; width: 60%"}

**Table 1.** Annotated genes with Pfam. 
{: style="color:gray; font-size: 90%; text-align: center;"}  


 The next step in the workflow is [deep clustering](deep-clustering) of the genes. 

<br />
<br />

{% capture code %}

The input for the functional annotation script [hmmsearch_pfam.sh](https://github.com/functional-dark-side/functional-dark-side.github.io/blob/master/scripts/Pfam_annotation/hmmsearch_pfam.sh) is the multi-fasta file containing the predicted ORFs sequences (amino acids). The output is a tab-separated file called _domain hits table_, for more information check the [HMMER user guide](http://eddylab.org/software/hmmer3/3.1b2/Userguide.pdf). This table is then parsed to remove overlapping hits and to filter out the matches showing an iE-value > 1e-05 and a coverage < 40%. This is done calling the script [hmmsearch_res_parser.sh](https://github.com/functional-dark-side/functional-dark-side.github.io/blob/master/scripts/Pfam_annotation/hmmsearch_res_parser.sh) and passing it the result table and the E-value and coverage parameters/values.  
<br />
An example of the script usage can be found here:

```bash
"hmmsearch_pfam.sh":
  - input: "data/gene_prediction/TARA_OSD_GOS_malaspina_hmpI-II.fasta.gz"
  - output: "data/pfam_annotation/marine_hmp_pfam31_results.tsv"

"hmmsearch_res_parser.sh":
  - input: "data/pfam_annotation/marine_hmp_pfam31_results.tsv", e-value=1e-05, coverage=0.4
  - output: "data/pfam_annotation/marine_hmp_pfam31_1e-5_c04.tsv"

```

{% endcapture %}

{% include collapsible.html toggle-name="toggle-code" button-text="Code and description" toggle-text=code %}

{% capture references %}

**[1]**	Finn, R. D., Clements, J., & Eddy, S. R. (2011). HMMER web server: interactive sequence similarity searching. Nucleic Acids Research, 39(Web Server issue), W29–W37.  
**[2]** El-Gebali, S., Mistry, J., Bateman, A., Eddy, S. R., Luciani, A., Potter, S. C., Qureshi, M., Richardson, L. J., Salazar, G. A., Smart, A., Sonnhammer, E. L. L., Hirsh, L., Paladin, L., Piovesan, D., Tosatto, S. C. E., & Finn, R. D. (2019). The Pfam protein families database in 2019. Nucleic Acids Research, 47(D1), D427–D432.  

{% endcapture %}

<p></p>
{% include collapsible.html toggle-name="toggle-ref" button-text="References" toggle-text=references %}

