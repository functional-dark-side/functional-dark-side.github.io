library(data.table)
library(tidyverse)
library(stringr)
library(splitstackshape)

args <- commandArgs(TRUE)

print(args)

annot_kept  <- fread(args[1], stringsAsFactors = F, header = F) %>% 
	select(V1,V4) %>% setNames(c("cl_name","annot"))

annot_pf <- annot_kept %>% cSplit("annot","|",'long') %>% group_by(cl_name) %>% 
	mutate(pfam_categ=ifelse(any(!grepl('DUF',annot)),"pf","duf"))

annot_K <- annot_kept %>% filter(cl_name %in% (annot_pf %>% filter(pfam_categ=="pf") %>% .$cl_name %>% unique))
write.table(annot_K,paste(args[2],"/",args[3],"_new_k_ids_annot.tsv",sep=""), 
	col.names = T, row.names = F, quote = F, sep = "\t")
annot_GU <- annot_kept %>% filter(!cl_name %in% annot_K$cl_name)
write.table(annot_GU,paste(args[2],"/",args[3],"_new_gu_ids_annot.tsv",sep=""), 
	col.names = T, row.names = F, quote = F, sep = "\t")
