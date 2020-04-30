### Gene prediction

"gene_prediction.sh" (script for gene prediciton, using Prodigal):
  - input: "data/original/\${project}/\${contig}.fasta"
  - output: "data/original/\${project}/\${orf}.aa/nt.fa"; "/data/original/\${project}/\${orf}.gff"

"rename_orfs.awk" (rename Prodigal output ORFs)

The outputs from the different projects were then concatenated together and stored in:
"data/gene_prediction/TARA_OSD_GOS_malaspina_hmpI-II.fasta.gz"
