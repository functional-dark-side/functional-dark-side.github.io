library(tidyverse)
library(data.tale)
library(maditr)
library(parallel)

setwd("/bioinf/projects/megx/UNKNOWNS/2017_11/")

gene_annot_all <- fread("data/pfam_annotation/marine_hmp_pfam31_multi_domain_coord.tsv.gz", header = F) %>%
  setNames(c("gene","pfam","start","end"))

# Gene coverage for mono-domain annotation
mono <- gene_annot_all %>% dt_filter(!grepl("\\|",start)) %>%
  mutate(pfam_covered_aa=(as.numeric(end)-as.numeric(start))+1) %>% select(gene,pfam,pfam_covered_aa)
save(mono,file="data/pfam_annotation/marine_hmp_pfam31_mono_coord.rda")

# Gene coverage for mono-domain annotation
multi <- gene_annot_all %>% dt_filter(grepl("\\|",start)) %>%
  separate_rows(start,end,sep="\\|")

list <- split(multi, list(multi$gene), drop=TRUE)

# Function to calculate multi-domain annotations coverage, taking into account eventual coordinates overlaps
overlaps_dt_f <- function(df){
  tbl <- as.data.table(df %>% mutate(start=as.numeric(start),end=as.numeric(end)))

  setkey(tbl, gene, start, end)
  over <- foverlaps(tbl, tbl, nomatch = 0)
  over <- over[start != i.start]
  over[, overlap := abs(over[, ifelse(start > i.start, start, i.start)] - over[, ifelse(end < i.end, end, i.end)])]
  over <- over %>%  mutate(overlap=ifelse(start==i.end,1,overlap)) %>% select(gene,overlap,i.start,i.end) %>% distinct() %>% select(-i.start,-i.end) %>%
    group_by(gene) %>% summarise(overlap=sum(overlap))
  covered_aa <- tbl %>% mutate(covered=(end-start)+1) %>% group_by(gene,pfam) %>%
    summarise(pfam_covered_aa=sum(covered)) %>% select(gene,pfam,pfam_covered_aa) %>% distinct()
  if(identical(over$overlap, integer(0))){
    tbl <- covered_aa
  }else{
    tbl <- covered_aa %>% left_join(over) %>% mutate(pfam_covered_aa=pfam_covered_aa - (overlap+1)) %>%
      select(gene,pfam,pfam_covered_aa) %>% distinct()
  }
}

multi_overlap <- mclapply(list, overlaps_dt_f, mc.cores = getOption("mc.cores",18))
multi_overlap <- plyr::ldply(multi_overlap, data.frame) %>% select(-`.id`)

gene_annot <- bind_rows(mono,multi_overlap)

gene_length <- fread("data/mmseqs_clustering/marine_hmp_orf_length.tsv.gz",header = F,sep="\t") %>%
  setNames(c("gene","length"))

# gene_annot_length <- gene_annot %>% dt_left_join(gene_length) # check

gene_compl <- fread("data/gene_prediction/marine_hmp_orfs_partial_info.tsv.gz",header=F) %>%
  setNames(c("gene","completion")) %>% mutate(completion=ifelse(completion==0,"00",
                                                                ifelse(completion==1,"01",
                                                                       ifelse(completion==10,"10","11"))))

gene_annot_length_coverage <- gene_annot_length %>% dt_left_join(gene_compl) %>%
  mutate(pfam_covered_aa_p=(pfam_covered_aa/length))
