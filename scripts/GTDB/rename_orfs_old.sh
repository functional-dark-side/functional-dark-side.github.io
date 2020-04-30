#!/bin/bash

wget https://data.ace.uq.edu.au/public/misc_downloads/annotree/r86/gtdb_r86_bac_protein_files.tar.gz

tar -zxf gtdb_r86_bac_protein_files.tar.gz

ls protein_files/ > bac

for file in `cat bac`; do ~/opt/seqkit fx2tab protein_files/$file | awk -v F=$(basename $file _protein.faa) '{print F,$0}' | sed 's/ /\t/g' >> bacterial_sequence_index.tsv; done

awk '{split($10,a,";");split(a[1],b,"_"); if($8==1) print $1"_"$2"_""+""_"$4"_"$6"_""orf-"b[2]"\t"$11; else print $1"_"$2"_""-""_"$4"_"$6"_""orf-"b[2]"\t"$11;}' bacterial_sequence_index.tsv | ~/opt/seqkit tab2fx > bacterial_orfs.fa
