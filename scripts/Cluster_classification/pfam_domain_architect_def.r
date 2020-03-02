#!/usr/bin/env Rscript
library(data.table)
library(tidyverse)
library(stringr)
library(stringi)
library(tidygraph)
library(zoo)
library(igraph)
library(parallel)

args <- commandArgs(TRUE)

pfam_cnames <- read_tsv("../../../2017_11/Pfam_annotation/pfam_files/Pfam-31_names_mod_01122019.tsv", col_names = TRUE)
annot_kept  <- fread(paste0("gzip -dc ", args[1]), colClasses = c(V1 = "character", V8="character"),
                     stringsAsFactors = F, header = F) %>%
  dplyr::select(V1,V2,V3,V5,V6,V7,V8) %>%
  setNames(c("cl_name","repres","rep_annot","memb","memb_annot","clan","partial")) %>%
  as_tibble()

rename_pfam <- function(X){
  paste0(plyr::mapvalues(as.vector(str_split(X, "\\|", simplify = TRUE)), from = pfam_cnames$pfam, to = pfam_cnames$cname, warn_missing = FALSE),
         collapse = "|")
}
expand_repeats <- function(X, rep){
  lapply(X, function(X){
    if (is.element(X, rep$from)) {
      rep(X, rep %>% filter(from == X) %>% .$n + 1)
    }else{
      X
    }
  }) %>% unlist %>% paste(collapse = "|")
}

encode_repeats <- function(X, rep){
  lapply(X, function(X){
    if (is.element(X, rep$from)) {
      rep %>% filter(from == X) %>% .$n + 1
    }else{
      1
    }
  }) %>% unlist %>% paste(collapse = "|")
}

get_cluster_da_red <- function(X) {
  df_multi_process <- NULL
  df_mono_process <- NULL
  # Conditions
  # 1. First we check if we have complete ORFs
  # 2. We always will try to use the complete data, if not we will use the partial

  #X <- cls_mu[["1281746"]]
  df <- X %>% filter(!is.na(memb_annot))
  memb_annot <- df$memb_annot
  df <- as.data.table(df)
  df <- df[, memb_annot_reduced := rename_pfam(memb_annot),by=seq_len(nrow(df))] %>% as.tibble() %>%
    mutate(number_multi=stri_count_fixed(memb_annot_reduced,"|"))
  df %>% group_by(memb_annot_reduced,partial) %>% count() %>% View()
  if(max(df$number_multi)>1){
  df_rep <- df %>% filter(number_multi==max(number_multi)) %>% select(memb_annot_reduced) %>% distinct() %>%
    mutate(numb_rep=sapply(strsplit(memb_annot_reduced,"\\|"),function(x){length(unique(x))}))
    if(max(df$number_multi)>2 && df_rep$numb_rep == 1){
      df_rep <- df_rep %>% mutate(type_rep=sapply(strsplit(memb_annot_reduced,"\\|"), function(x){unique(x)}))
      df <- df %>% mutate(memb_annot_reduced=ifelse(grepl(df_rep$type_rep,memb_annot_reduced),df_rep$memb_annot_reduced,memb_annot_reduced)) %>%
        mutate(partial=ifelse(grepl(df_rep$type_rep,memb_annot_reduced),"00",partial))
    }
  }
  df_multi <- df %>% filter(number_multi > 0)

  df_multi_complete <- df_multi %>% filter(partial == "00")
  df_multi_partial <- df_multi %>% filter(partial != "00")

  df_multi_complete_n <- nrow(df_multi_complete)
  df_multi_partial_n <- nrow(df_multi_partial)

  df_mono <- df %>% mutate(number_multi = stri_count_fixed(memb_annot_reduced, "|")) %>% filter(number_multi == 0)
  df_mono_complete <- df_mono %>% filter(partial == "00")
  df_mono_partial <- df_mono %>% filter(partial != "00")

  df_mono_complete_n <- nrow(df_mono_complete)
  df_mono_partial_n <- nrow(df_mono_partial)


  # can we use the complete data:
  if (df_mono_complete_n < 1) {
    df_mono_process <- df_mono_partial %>% select(memb_annot_reduced) %>%
      group_by(memb_annot_reduced) %>% count() %>% rename(archit = memb_annot_reduced) %>% ungroup()
  }else{
    df_mono_process <- df_mono_complete %>% select(memb_annot_reduced) %>%
      group_by(memb_annot_reduced) %>% count() %>% rename(archit = memb_annot_reduced) %>% ungroup()
  }

# can we use the complete data:
  if (df_multi_complete_n < 1) {
    if (df_multi_partial_n > 0){
      df_multi_process <- df_multi_partial
    }
  }else{
    df_multi_process <- df_multi_complete
  }

  if (!is.null(df_multi_process)){
    c <- map(df_multi_process %>% .$memb_annot_reduced %>% strsplit("\\|") %>% unique(),
             function(x) {
               g <- rollapply(data = x, 2, by=1, c) %>%
                 graph_from_data_frame(directed = TRUE)

             })

    c <- graph.union(c) %>% as_tbl_graph() %>% mutate(degree = centrality_degree(loops = TRUE))


    archits <- do.call("rbind",lapply(
      df_multi_process %>% .$memb_annot_reduced %>% strsplit("\\|"),
      function(Y) {
        Y_g <- rollapply(data = Y, 2, by=1, c)  %>% graph_from_data_frame(directed = TRUE)
        g1 <- graph.intersection(c, Y_g) %>% as_tbl_graph() %>% activate(nodes) %>% filter(!(node_is_isolated()))
        #induced_subgraph(c,vids = Y,)#c %>% filter(name %in% Y)
        if (is_connected(g1)){
          # Identify loops
          E(g1)$is_loop <- which_loop(g1)
          # Identify repeats
          repeats <- g1 %>%
            igraph::as_data_frame() %>%
            as_tibble() %>%
            filter(is_loop == TRUE) %>%
            group_by(from) %>%
            count()
          arch <- topo_sort(g1) %>% as_ids()
          exp <- expand_repeats(arch, repeats)
          enc <- encode_repeats(arch, repeats)
          da <- data_frame(archit = paste0(topo_sort(g1) %>% as_ids(),collapse = "|"),
          exp_rep = exp,
          enc_rep = enc)
        }
      })) %>%
      as_tibble() %>% group_by(archit) %>% add_count(sort = TRUE) %>% distinct() %>%
      rename(n_in_path = n) %>% ungroup() %>%
      dplyr::top_n(n = 1, wt = n_in_path) %>% select(-n_in_path)
  }
  #path seen more time in the big cluster (c) add colum with number of reduced ex: AAA|P.... 2|1 etc...original..original one
  if(archits$exp_rep != ""){
  archits <- archits %>%
    mutate(class = "multi") %>%
    bind_rows(df_mono_process %>% select(-n) %>% mutate(class = "mono")) %>%
    #group_by(archit) %>%
    #summarise(n = sum(n)) %>%
    bind_cols(map_df(.$exp_rep, function(X) {
      d <- df %>% filter(memb_annot_reduced == X)
      tibble(complete = d %>% filter(partial == "00") %>% nrow,
             partial = d %>% filter(partial != "00") %>% nrow)
    }
    )) %>%
    arrange(desc(complete), desc(partial))
  }else{
    archits <- archits %>%
      mutate(class = "multi") %>%
      bind_rows(df_mono_process %>% select(-n) %>% mutate(class = "mono")) %>%
      #group_by(archit) %>%
      #summarise(n = sum(n)) %>%
      bind_cols(map_df(.$archit, function(X) {
        d <- df %>% filter(memb_annot_reduced == X)
        tibble(complete = d %>% filter(partial == "00") %>% nrow,
               partial = d %>% filter(partial != "00") %>% nrow)
      }
      )) %>%
      arrange(desc(complete), desc(partial))
  }
  list(g = c, domains = c %>% as_tibble() %>% .$name, n_comps = components(c)$no, archit = archits %>% ungroup(),
       mono_complete = df_mono_complete_n, mono_partial = df_mono_partial_n,
       multi_complete = df_multi_complete_n, multi_partial = df_multi_partial_n)
}

get_cluster_da_or <- function(X) {
  df_multi_process <- NULL
  df_mono_process <- NULL
  # Conditions
  # 1. First we check if we have complete ORFs
  # 2. We always will try to use the complete data, if not we will use the partial

  # X <- "10000404"
  df <- X %>% filter(!is.na(memb_annot))
  memb_annot <- df$memb_annot
  df <- df %>% rowwise() %>% mutate(memb_annot_reduced = rename_pfam(memb_annot)) %>% ungroup() %>%
    mutate(number_multi=stri_count_fixed(memb_annot,"|"))
  df_rep <- df %>% filter(number_multi==max(number_multi)) %>% select(memb_annot) %>% distinct() %>%
    mutate(numb_rep=sapply(strsplit(memb_annot,"\\|"),function(x){length(unique(x))}),type_rep=sapply(strsplit(memb_annot,"\\|"), unique))
  if(max(df$number_multi)>2 && df_rep$numb_rep == 1){
    df <- df %>% mutate(memb_annot=ifelse(grepl(df_rep$type_rep,memb_annot),df_rep$memb_annot,memb_annot))
   }
  df_multi <- df %>% mutate(number_multi = stri_count_fixed(memb_annot, "|")) %>% filter(number_multi > 0)
  df_multi_complete <- df_multi %>% filter(partial == "00")
  df_multi_partial <- df_multi %>% filter(partial != "00")

  df_multi_complete_n <- nrow(df_multi_complete)
  df_multi_partial_n <- nrow(df_multi_partial)

  df_mono <- df %>% mutate(number_multi = stri_count_fixed(memb_annot, "|")) %>% filter(number_multi == 0)
  df_mono_complete <- df_mono %>% filter(partial == "00")
  df_mono_partial <- df_mono %>% filter(partial != "00")

  df_mono_complete_n <- nrow(df_mono_complete)
  df_mono_partial_n <- nrow(df_mono_partial)


  # can we use the complete data:
  if (df_mono_complete_n < 1) {
    df_mono_process <- df_mono_partial %>% select(memb_annot) %>%
      group_by(memb_annot) %>% count() %>% rename(archit = memb_annot) %>% ungroup()
  }else{
    df_mono_process <- df_mono_complete %>% select(memb_annot) %>%
      group_by(memb_annot) %>% count() %>% rename(archit = memb_annot) %>% ungroup()
  }

  # can we use the complete data:
  if (df_multi_complete_n < 1) {
    if (df_multi_partial_n > 0){
      df_multi_process <- df_multi_partial
    }
  }else{
    df_multi_process <- df_multi_complete
  }

  if (!is.null(df_multi_process)){
    c <- map(df_multi_process %>% .$memb_annot %>% strsplit("\\|") %>% unique(),
             function(x) {
               g <- rollapply(data = x, 2, by=1, c) %>%
                 graph_from_data_frame(directed = TRUE)

             })

    c <- graph.union(c) %>% as_tbl_graph() %>% mutate(degree = centrality_degree(loops = TRUE))

    archits_or <- do.call("rbind",lapply(
      df_multi_process %>% .$memb_annot %>% strsplit("\\|"),
      function(Y) {
        g1 <- c %>% filter(name %in% Y)
        if (is_connected(g1)){
          arch <- paste0(topo_sort(g1) %>% as_ids(), collapse = "|")
          if(!grepl("\\|", arch)){
            dg <- g1 %>% activate(nodes) %>% as.tibble() %>% filter(name %in% arch) %>% .$degree
            if(dg>1){
              paste(rep(arch, dg+1), collapse = "|")
            }else{
              arch
            }
          }else{
            arch
          }
        }
      })) %>%
      as_tibble() %>% group_by(V1) %>% count(sort = TRUE) %>%
      rename(archit = V1, n_in_path = n) %>%
      top_n(n = 1, wt = n_in_path) %>% select(-n_in_path)
  }
  # archits <- df_multi_process %>% as_tibble() %>% group_by(cl_name,memb_annot) %>%
  #   count(sort = TRUE) %>% rename(archit=memb_annot, n_in_path = n) %>% ungroup() %>%
  #   dplyr::top_n(1, wt = n_in_path) %>% select(-n_in_path)
  archits <- archits_or %>%
    mutate(class = "multi") %>%
    bind_rows(df_mono_process %>% select(-n) %>% mutate(class = "mono")) %>%
    #group_by(archit) %>%
    #summarise(n = sum(n)) %>%
    bind_cols(map_df(.$archit, function(X) {
      d <- df %>% filter(memb_annot == X)
      tibble(complete = d %>% filter(partial == "00") %>% nrow,
             partial = d %>% filter(partial != "00") %>% nrow)
    }
    )) %>%
    arrange(desc(complete), desc(partial)) #%>% dplyr::slice(1)

  list(g = c, domains = c %>% as_tibble() %>% .$name, n_comps = components(c)$no, archit = archits %>% ungroup(),
        mono_complete = df_mono_complete_n, mono_partial = df_mono_partial_n,
        multi_complete = df_multi_complete_n, multi_partial = df_multi_partial_n)
}

get_cluster_da_mono <- function(X) {
  df_multi_process <- NULL
  df_mono_process <- NULL
  # Conditions
  # 1. First we check if we have complete ORFs
  # 2. We always will try to use the complete data, if not we will use the partial

  # X <- "10000404"
  df <- X %>% filter(!is.na(memb_annot))
  memb_annot <- df$memb_annot
  df <- df %>% rowwise() %>% mutate(memb_annot_reduced = rename_pfam(memb_annot)) %>% ungroup()
  if(length(unique(df$memb_annot))==1){
    homog = TRUE
  } else {
    homog = FALSE
  }
  df_mono <- df
  df_mono_complete <- df_mono %>% filter(partial == "00")
  df_mono_partial <- df_mono %>% filter(partial != "00")

  df_mono_complete_n <- nrow(df_mono_complete)
  df_mono_partial_n <- nrow(df_mono_partial)

  # can we use the complete data:
  if (df_mono_complete_n < 1) {
    df_mono_process <- df_mono_partial %>% select(memb_annot) %>%
      group_by(memb_annot) %>% count() %>% rename(archit = memb_annot) %>% ungroup()
  }else{
    df_mono_process <- df_mono_complete %>% select(memb_annot) %>%
      group_by(memb_annot) %>% count() %>% rename(archit = memb_annot) %>% ungroup()
  }

  archits <- df_mono_process %>% select(-n) %>% mutate(class = "mono") %>%
    #group_by(archit) %>%
    #summarise(n = sum(n)) %>%
    bind_cols(map_df(.$archit, function(X) {
      d <- df %>% filter(memb_annot == X)
      tibble(complete = d %>% filter(partial == "00") %>% nrow,
             partial = d %>% filter(partial != "00") %>% nrow)
    }
    )) %>% mutate(homog=homog) %>%
    arrange(desc(complete), desc(partial))

  list(archit = archits %>% ungroup(),
       mono_complete = df_mono_complete_n, mono_partial = df_mono_partial_n)
}

# we get the ones that are multidomain
h <- annot_kept %>% filter(grepl("\\|", memb_annot)) %>% mutate(number_multi = stri_count_fixed(memb_annot, "|"))
multi <- h %>% select(cl_name,number_multi) %>% distinct() %>% left_join(annot_kept)
# we create a list out of the different groups
cls_mu <- multi %>% split(.$cl_name)

## Reduced Pfam names
da_results_red <- mclapply(cls_mu_left, get_cluster_da_red, mc.cores = 20)
names(da_results_red) <- names(da_results_red)
# we select the first archtecture entry, it has been sorted the number of complete and partial oRFs
da_best_red <- map_df(da_results_red, function(X) X$archit %>% dplyr::slice(1), .id = "cl_name")

## Original Pfam names
da_results_or <- mclapply(cls_mu, get_cluster_da_or, mc.cores = 18)
names(da_results_or) <- names(da_results_or)
# we select the first archtecture entry, it has been sorted the number of complete and partial oRFs
da_best_or <- map_df(da_results_or, function(X) X$archit %>% dplyr::slice(1), .id = "cl_name")
da_best <- da_best_red1 %>% select(cl_name,archit) %>% left_join(da_best_or %>% rename(original=archit))

# we get the ones that are monodomain
multi_cl_name <- multi %>% select(cl_name) %>% distinct
m <- annot_kept %>% filter(!cl_name %in% multi_cl_name$cl_name)
# we create a list out of the different groups
cls_mo <- m %>% split(.$cl_name)
da_results_m1 <- mclapply(cls_mo[1:200000], get_cluster_da_mono, mc.cores = 18)
names(da_results_m1) <- names(da_results_m1)
da_best_m1 <- map_df(da_results_m1, function(X) X$archit %>% slice(1), .id = "cl_name")

da_results_m2 <- mclapply(cls_mo[200001:400000], get_cluster_da_mono, mc.cores = 18)
names(da_results_m2) <- names(da_results_m2)
da_best_m2 <- map_df(da_results_m2, function(X) X$archit %>% slice(1), .id = "cl_name")

da_results_m3 <- mclapply(cls_mo[400001:600000], get_cluster_da_mono, mc.cores = 18)
names(da_results_m3) <- names(da_results_m3)
da_best_m3 <- map_df(da_results_m3, function(X) X$archit %>% slice(1), .id = "cl_name")

da_results_m4 <- mclapply(cls_mo[600001:800000], get_cluster_da_mono, mc.cores = 18)
names(da_results_m4) <- names(da_results_m4)
da_best_m4 <- map_df(da_results_m4, function(X) X$archit %>% slice(1), .id = "cl_name")

da_results_m5 <- mclapply(cls_mo[800001:855345], get_cluster_da_mono, mc.cores = 18)
names(da_results_m5) <- names(da_results_m5)
da_best_m5 <- map_df(da_results_m5, function(X) X$archit %>% slice(1), .id = "cl_name")

# we select the first archtecture entry, it has been sorted the number of complete and partial oRFs
da_best_m_or <- rbind(da_best_m1,da_best_m2, da_best_m3, da_best_m4, da_best_m5)
da_best_m_or <- da_best_m_or[-6]
da_best_m <- da_best_m_red %>% select(cl_name,archit) %>% left_join(da_best_m_or %>% rename(original=archit))
#da_best_m <- da_best_m %>% filter(!cl_name %in% da_orig$cl_name)

da_best_all <- rbind(da_best_m,da_best)

fix_or <- function(X){
  df <- X %>% filter(!is.na(memb_annot))
  memb_annot <- df$memb_annot
  arch <- da_best_all %>% filter(cl_name %in% unique(df$cl_name)) %>% .$exp_rep
  n_multi <- stri_count_fixed(arch,"|")
  df <- df %>% rowwise() %>% mutate(memb_annot_reduced = rename_pfam(memb_annot)) %>% ungroup() %>%
    mutate(number_multi=stri_count_fixed(memb_annot,"|"))
  df %>% group_by(memb_annot) %>%
    filter(grepl(arch,memb_annot) & number_multi==n_multi) %>%
    mutate(complete=length(which(partial == "00")),partial1=length(which(partial != "00"))) %>%
    select(cl_name,memb_annot,complete,partial1) %>% rename(original=memb_annot,partial=partial1) %>% distinct() %>% ungroup() %>%
    arrange(desc(complete),desc(partial)) %>% dplyr::slice(1) %>% mutate(archit=arch)
}

da_res_or_mo <- mclapply(cls_mo, fix_or, mc.cores = 16)
da_res_or_mo <- plyr::ldply(da_res_or_mo,as.data.frame)
da_res_or_mo <- da_res_or_mo[-1]

da_res_or_mu <- mclapply(cls_mu_left, fix_or, mc.cores = 16)
da_res_or_mu <- plyr::ldply(da_res_or_mu,as.data.frame)
da_res_or_mu <- da_res_or_mu[-1]

da_res_mono <- da_best_all %>% filter(cl_name %in% names(cls_mo)) %>%
  left_join(da_res_or_mo %>% select(cl_name,archit,original), by="cl_name")
da_res_multi <- da_best_all %>% filter(cl_name %in% names(cls_mu)) %>%
  left_join(da_res_or_mu %>% select(cl_name,archit,original), by="cl_name")
da_best_all <- rbind(da_best_mono,da_best_multi)

#Define DUFs and PFs clusters (A cluster is consider annotated to DUFs if 100% of its annotated members are DUFs)
#Combine results and define DUFs and PFs clusters:
# A cluster is consider annotated to DUFs if the original consensus DA is 100% DUF
da_best_all <- rbind(da_best_multi,da_best_mono %>% mutate(exp_rep=NA,enc_rep=NA)) %>%
  separate_rows(original,sep="\\|") %>% group_by(cl_name) %>%
  mutate(type=ifelse(all(!grepl('^DUF',original)),"PF","DUF")) %>%
  group_by(cl_name,type) %>% mutate(original=paste(original,collapse = "|")) %>% distinct()
write.table(da_best_all, paste(args[2],"cluster_pfam_domain_architect.tsv",sep="/"), col.names = T, row.names = F, quote = F, sep = "\t")

#write.table(da_best_all %>% filter(type=="DUF"), paste(args[2],"kept_DUF.tsv",sep="/"), col.names = T, row.names = F, quote = F, sep = "\t")
#write.table(da_best_all %>% filter(type=="PF"), paste(args[2],"kept_PF.tsv",sep="/"), col.names = T, row.names = F, quote = F, sep = "\t")
