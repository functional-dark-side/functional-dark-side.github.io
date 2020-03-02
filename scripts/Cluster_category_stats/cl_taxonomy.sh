#!/bin/#!/usr/bin/env bash

# To retrieve the last common ancestor for our clusters we used MMseqs2(version: b43de8b7559a3b45c8e5e9e02cb3023dd339231a)
# and we follow their method: https://github.com/soedinglab/mmseqs2/wiki#taxonomy-assignment-using-mmseqs-taxonomy
# Download the NCBI taxids
mkdir ncbi-taxdump && cd ncbi-taxdump
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
tar xzvf taxdump.tar.gz
cd ..

#Download UniprotKB database
wget ftp://ftp.expasy.org/databases/uniprot/current_release/knowledgebase/complete/uniprot_trembl.fasta.gz
wget wget ftp://ftp.expasy.org/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
zcat uniprot_trembl.fasta.gz uniprot_sprot.fasta.gz > uniprotKB.fasta

# Create mmseqs database
mmseqs createdb uniprotKB.fasta uniprotDB

# Download the latest UniProt Knowledgebase:
wget ftp://ftp.expasy.org/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.dat.gz
wget ftp://ftp.expasy.org/databases/uniprot/current_release/knowledgebase/complete/uniprot_trembl.dat.gz
cat uniprot_sprot.dat.gz uniprot_trembl.dat.gz > uniprot_sprot_trembl.dat.gz

# Generate annotation mapping DB (target DB IDs to NCBI taxa, line type OX)
mmseqs convertkb uniprot_sprot_trembl.dat.gz uniprotDB.mapping --kb-columns OX --mapping-file uniprotDB.lookup

# Reformat targetDB.mapping_OX DB into tsv file
mmseqs prefixid uniprotDB.mapping_OX uniprotDB.mapping_OX_pref
tr -d '\000' < uniprotDB.mapping_OX_pref > uniprotDB.tsv_tmp

# Cleanup: taxon format:  "NCBI_TaxID=418404 {ECO:0000313|EMBL:AHX25609.1};"
# Only the numerical identifier "418404" is required.
awk '{match($2, /=([^ ;]+)/, a); print $1"\t"a[1]; }' uniprotDB.tsv_tmp > uniprotDB.tsv

# Create database from each cluster category set of ORFs:
# the files are in: /bioinf/projects/megx/UNKNOWNS/2017_11/cl_categories/ffindex_files/"${categ}"_cl_orfs.fasta.gz
mmseqs createdb eu_cl_orfs.fasta.gz queryDB
# retrieve taxonomy
mmseqs taxonomy queryDB uniprotDB uniprotDB.tsv ncbi-taxdump queryLcaDB tmp --threads 64 -e 1e-05 --cov-mode 0 -c 0.6 --lca-mode 2
# Create standard (BLAST) search output: 1) query accession 2) target accession and search parameters (evalue,bitscore,coverage etc..)
mmseqs convertalis queryDB uniprotDB queryLcaDB queryLcaDB.m8 --therads 64 --format-mode 2
# Create taxonomy output table: 1) query accession, 2) LCA NCBI taxon ID, 3) LCA rank name, and 4) LCA scientific name
mmseqs createtsv queryDB queryLcaDB queryLca_c06.tsv

#Filter the hits within the 60%Log(best-evalue)
awk -f /home/cvanni/opt/scripts/evalue_06_filter.awk <(sort -k1,1 -k11,11g queryLcaDB.m8 | awk '!seen[$1,$2]++') > queryLcaDB_e60.m8

join -12 -21 <(sort -k2,2 --parallel 10 -S25% queryLcaDB_e60.tsv) <(sort -k1,1 --parallel 20 -S25% <(zcat uniprot_prot.tsv.gz )) > queryLca_e60_prot.tsv

LC_ALL=C rg -j 6 -i -f ~/opt/scripts/unknown_grep.tsv queryLca_e60_prot.tsv | awk '{print $0"\thypo"}' > queryLca_e60_prot_hypo
LC_ALL=C rg -j 6 -i -v -f ~/opt/scripts/unknown_grep.tsv queryLca_e60_prot.tsv | awk '{print $0"\tchar"}' >> queryLca_e60_prot_hypo

sed -i 's/ /\t/g' queryLca_c06_prot_hypo

awk -v P=1.0 'BEGIN{FS="\t"}{a[$2][$6]++}END{for (i in a) {N=a[i]["hypo"]/(a[i]["hypo"]+a[i]["char"]); if (N >= P){print i}}}' queryLca_c06_hypo > queryLca_c06_hypo1

awk '!seen[$2]++{print $2}' queryLca_c06.tsv > queryLca_c06_hits

join -11 -21 -v1 <(sort queryLca_c06_hits ) <(sort queryLca_c06_hypo1) > queryLca_c06_nothypo

cat <(awk '{print $1"\t""hypo}' queryLca_c06_hypo1) <(awk '{print $1"\t""char"}' queryLca_c06_nothypo) > queryLca_c06_hypo_char

rm queryLca_c06_hits queryLca_c06_hypo1 queryLca_c06_nothypo

# Add protein characterization info to taxonomy result Table
join -11 -21 <(sort -k1,1 queryLca_c06.tsv) <(sort -k1,1 queryLca_c06_hypo_char) > queryLca_c06_info.tsv

# Add cluster IDs
# The file is in: /bioinf/projects/megx/UNKNOWNS/2017_11/cl_categories/
join -13 -21 <(zcat cl_ids_categ_orfs.tsv.gz | sort -k3,3) <(sort -k1,1 queryLca_c06_info.tsv) > eu_queryLca_c06_info.tsv

# Repeat sam steps for the other categories (gu,kwp,k)

# Import the data in R ("cluster_categ_stats.r") to retrieve info about taxonomic lineage and taxonomic homogeneity of the clusters
