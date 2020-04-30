Notes
-----

Sequences and annotations from the 2018_09 release of the MGnify protein database.

In the fasta files the header includes fields UP (observed in UniprotKB), PL (partial category)
and BIOMES (membership of one of a reduced set of biomes). Full information on biomes is available in
the 'biomes' and 'clusters' files. Sequences observed in multiple runs/samples may exist in more than
one biome.

Fasta headers
-------------

* UniProtKB (UP)

1 for a match to UniProtKB version 2018_09

* Partial (PL)

This is an indicator of whether a gene extends to the full length of the sequence or is truncated:

00 - full length
01 - C-term truncated
10 - N-term truncated
11 - truncated at both ends

* Biomes (BIOMES)

A string of 1/0 for membership of one of these 11 categories:

Engineered
Environmental:Aquatic
Environmental:Aquatic:Marine
Environmental:Aquatic:Freshwater
Environmental:Terrestrial:Soil
Host-associated:Plants
Host-associated:Human
Host-associated:Human:Digestive system
Host-associated:Human but not root:Host-associated:Human:Digestive system
Host-associated:Animal
None of the above

Statistics
----------

	Sequence	Cluster
Sequences:
Total	843535611	201273532
00	202929598	70619781
01	257950728	53146186
10	257949990	52961800
11	124705295	24545765
Matches:
Swiss-Prot	60274	14981
TrEMBL	5125348	1166833
Residues	172011349391	37263829412

Files
-----

mgy_biomes.tsv.gz
- biomes for each seqeunce
mgy_counts.tsv
- number of occurences of each sequence
mgy_runs.tsv
- accessions of runs/samples in which each sequence is found
mgy_cluster_seqs.tsv
- list of cluster representatives (column 1) with member sequences (column 2)
mgy_clusters.fa
- fasta file of cluster representative sequences
mgy_clusters.tsv
- cluster statistics and biomes. for each cluster:
    number of sequences in cluster
    number of identical sequences
    total redundant sequences
    biomes (sequence)
    biomes (cluster)
  Columns 3 and 5 are thus aggregated over all sequences in the cluster
mgy_proteins.fa
- fasta file of all sequences (split to reduce file sizes)
mgy_swissprot.tsv
- exact matches of sequences to UniProtKB/Swiss-Prot
mgy_trembl.tsv
- exact matches of sequences to UniProtKB/TrEMBL


Cite us
-------

To cite MGnify, please refer to the following publication:

Alex L. Mitchell, Maxim Scheremetjew, Hubert Denise, Simon Potter, Aleksandra Tarkowska, Matloob Qureshi,
Gustavo A. Salazar, Sebastien Pesseat, Miguel A. Boland, Fiona M. I. Hunter, Petra ten Hoopen, Blaise Alako,
Clara Amid, Darren J. Wilkinson, Thomas P. Curtis, Guy Cochrane, Robert D. Finn (2017).

EBI Metagenomics in 2017: enriching the analysis of microbial communities, from sequence reads to assemblies.

Nucleic Acids Research (2017) doi: 10.1093/nar/gkx967
