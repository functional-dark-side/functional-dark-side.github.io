#!/bin/bash

# cd  data/GTDB/gtdb_data/

# Download protein data

wget https://data.ace.uq.edu.au/public/misc_downloads/annotree/r86/gtdb_r86_bac_protein_files.tar.gz

tar -zxf gtdb_r86_bac_protein_files.tar.gz

# list of genomes

ls protein_files/ > bac

# Concatenate and rename ORFs

for file in `cat bac`; \
  do /home/cvanni/opt/seqkit fx2tab protein_files/$file | \
    awk -v F=$(basename $file _protein.faa) \
    '{split($9,a,";"); split(a[1],b,"_"); if($7==1) print F"_"$1"_""+""_"$3"_"$5"_""orf-"b[2]"\t"$10; else print F"_"$1"_""-""_"$3"_"$5"_""orf-"b[2]"\t"$10;}' | \
  /home/cvanni/opt/seqkit tab2fx >> gtdb_bac_orfs.fasta; done

rm -rf protein_files/ bac gtdb_r86_bac_protein_files.tar.gz

# Repeat same steps for archaea
wget https://data.ace.uq.edu.au/public/misc_downloads/annotree/r86/gtdb_r86_ar_protein_files.tar.gz

tar -zxf gtdb_r86_ar_protein_files.tar.gz

# list of genomes

ls protein_files/ > arc

# Concatenate and rename ORFs

for file in `cat arc`; \
  do /home/cvanni/opt/seqkit fx2tab protein_files/$file | \
    awk -v F=$(basename $file _protein.faa) \
    '{split($9,a,";"); split(a[1],b,"_"); if($7==1) print F"_"$1"_""+""_"$3"_"$5"_""orf-"b[2]"\t"$10; else print F"_"$1"_""-""_"$3"_"$5"_""orf-"b[2]"\t"$10;}' | \
  /home/cvanni/opt/seqkit tab2fx >> gtdb_arc_orfs.fasta; done

rm -rf protein_files/ arc gtdb_r86_ar_protein_files.tar.gz

cat gtdb_bac_orfs.fasta gtdb_arc_orfs.fasta > gtdb_orfs.fasta

gzip gtdb_bac_orfs.fasta
gzip gtdb_arc_orfs.fasta
gzip gtdb_orfs.fasta

## Tabular file with ORF info:
for file in `cat arc`; \
  do /home/cvanni/opt/seqkit fx2tab protein_files/$file | \
    awk -v F=$(basename $file _protein.faa) \
    '{split($10,a,";");split(a[1],b,"_"); if($8==1) print $1"_"$2"_""+""_"$4"_"$6"_""orf-"b[2]"\t"$1"\t"$2"\t"$4"\t"$6"\t"$8"\t"$11; else print $1"_"$2"_""-""_"$4"_"$6"_""orf-"b[2]"\t"$1"\t"$2"\t"$4"\t"$6"\t"$8"\t"$11;}' \
  >> gtdb_sequence_index.tsv; done

for file in `cat bac`; \
  do /home/cvanni/opt/seqkit fx2tab protein_files/$file | \
    awk -v F=$(basename $file _protein.faa) \
    '{split($10,a,";");split(a[1],b,"_"); if($8==1) print $1"_"$2"_""+""_"$4"_"$6"_""orf-"b[2]"\t"$1"\t"$2"\t"$4"\t"$6"\t"$8"\t"$11; else print $1"_"$2"_""-""_"$4"_"$6"_""orf-"b[2]"\t"$1"\t"$2"\t"$4"\t"$6"\t"$8"\t"$11;}' \
  >> gtdb_sequence_index.tsv; done
