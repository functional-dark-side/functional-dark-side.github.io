#!/usr/bin/env Rscript
library(tidyverse)
library(data.table)
library(parallel)
library(maditr)

# Functions
majority_vote <- function (x, seed = 12345) {
  set.seed(seed)
  whichMax <- function(x) {
    m <- seq_along(x)[x == max(x, na.rm = TRUE)]
    if (length(m) > 1)
      sample(m, size = 1)
    else m
  }
  x <- as.vector(x)
  tab <- table(x)
  m <- whichMax(tab)
  out <- list(table = tab, ind = m, majority = names(tab)[m])
  return(out)
}

apply_majority <- function(X){
  DT.1 <- X[,majority:=majority_vote(category)$majority, by="gene"]
  df <- DT.1 %>% as_tibble() %>% distinct()
}

get_majority <- function(X){

  list_genes <- X %>%                                        # Split into groups by gene-caller-id
    split(.$gene)

  maj_l <- mclapply(list_genes,apply_majority, mc.cores=8) # run majority_vote function
  maj_df <- plyr::ldply(maj_l, data.frame) %>%  # bind list rowwise and get distint votes for gene category
    select(gene,majority) %>%
    distinct() %>%
    as_tibble()
}

cos_cat <- function(X){
  paste(str_split(X, pattern = "_") %>% unlist() %>% unique() %>% sort , collapse = "_")
}

concat_results <- function(e,tbl){
# evalue 90%
res <- fread(paste("zcat ", getwd, "/", tbl, e,".tsv.gz",sep=""), stringsAsFactors = F, header = F) %>% dt_select(V1,V2,V11,V13,V14,V15) %>%
  setNames(c("cl_name","gene","evalue","qcov","tcov","category"))
}

# Arguments from terminal: tsv-table with seaerch results

args = commandArgs(trailingOnly=TRUE)

res=basename(args[1])
res=gsub("_e90.tsv.gz","",res)

# Compare different evalue filtering for consensus category consisntency
evalues=c("e60","e70","e80","e90")
# 1. read e-value filtered results
efilters <- mclapply(evalues,concat_results,tbl=res,mc.cores = 8)
# get major categories
votes <- mclapply(X = efilters, get_majority, mc.cores = 8)

# Create dt with combined cluster category assignment
dt <- bind_cols(votes[[1]], votes[[2]], votes[[3]], votes[[4]]) %>% select(contains("majori"), gene) %>%
 unite(majority, majority1, majority2,  majority3, col = comb, sep = "_") %>% as.data.table()
#
dt[,con_cat:=cos_cat(comb), by=seq_len(nrow(dt))]
dt$con_cat = map(dt$comb, cos_cat) %>% unlist()
save(dt, file = paste0(getwd(),"/",res,"_consesus_category.rda"))

dt %>% filter(grepl("_", con_cat)) %>% select(gene, con_cat) %>% unique() %>%
  group_by(con_cat) %>% count() %>% mutate(p=n/tot) %>% arrange(desc(p))
