library(tidyverse)
library(data.table)
library(stringi)
library(stringr)
library(zoo)
library(igraph)
library(tidygraph)
library(parallel)

pfam_cnames <- read_tsv("data/DBs/pfam_files/Pfam-31_names_mod_01122019.tsv", col_names = TRUE)
ref_annot <- fread("data/OM-RGC-v2/cluster_validation/omrgc2_good_cl.tsv", stringsAsFactors = F, header = T, nThread = 2) %>%
  filter(funct_annot=="annot") %>% select(-funct_annot,-new_repres_annot) %>% rename(rep=new_repres)
clu_annot <- fread("data/OM-RGC-v2/annot_and_clust/omrgc2_clusters_annotated.tsv",
                   stringsAsFactors = F, header = F, nThread = 2,
                   sep="\t", colClasses=c(V6="character")) %>% select(V2,V1,V3,V4,V5,V6)
  setNames(c("old_repres","memb","pfam_name","pfam_acc","clan","partial"))

annot_kept  <- ref_annot %>% inner_join(clu_annot, by="old_repres") %>% select(-old_repres)
rep_annot <- annot_kept %>% filter(rep==orf) %>% select(rep,pfam_name,pfam_clan) %>%
  rename(rep_annot=pfam_name, rep_clan=pfam_clan)
annot_kept <- annot_kept %>% left_join(rep_annot) %>%
  rename(memb=orf,memb_annot=pfam_name)

rm(clu_annot,ref_annot, rep_annot)
gc()

# Function to retrieve the reduced pfam names
rename_pfam <- function(X){
  paste0(plyr::mapvalues(as.vector(str_split(X, "\\|", simplify = TRUE)), from = pfam_cnames$pfam, to = pfam_cnames$cname, warn_missing = FALSE),
         collapse = "|")
}
# Expand domain repeats
expand_repeats <- function(X, rep){
  lapply(X, function(X){
    if (is.element(X, rep$from)) {
      rep(X, rep %>% filter(from == X) %>% .$n + 1)
    }else{
      X
    }
  }) %>% unlist %>% paste(collapse = "|")
}
# Encode domain repeats (ex: AAA|AAA|DUF1 2|1)
encode_repeats <- function(X, rep){
  lapply(X, function(X){
    if (is.element(X, rep$from)) {
      rep %>% filter(from == X) %>% .$n + 1
    }else{
      1
    }
  }) %>% unlist %>% paste(collapse = "|")
}

# Retrieve thew consensus reduced domain architecture for multi-domain ORFs
get_cluster_da_red <- function(X) {
  df_multi_process <- NULL
  df_mono_process <- NULL
  # Conditions
  # 1. First we check if we have complete ORFs
  # 2. We always will try to use the complete data, if not we will use the partial
  df <- X %>% filter(!is.na(memb_annot))
  memb_annot <- df$memb_annot
  df <- as.data.table(df)
  df <- df[, memb_annot_reduced := rename_pfam(memb_annot),by=seq_len(nrow(df))] %>% as.tibble() %>%
    mutate(number_multi=stri_count_fixed(memb_annot_reduced,"|"))
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
# Retrieve thew consensus reduced domain architecture for mono-domain ORFs
get_cluster_da_mono <- function(X) {
  df_multi_process <- NULL
  df_mono_process <- NULL
  # Conditions
  # 1. First we check if we have complete ORFs
  # 2. We always will try to use the complete data, if not we will use the partial

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
# Retrieve the original consensus DA
get_cluster_da_or <- function(X) {
  df_multi_process <- NULL
  df_mono_process <- NULL
  # Conditions
  # 1. First we check if we have complete ORFs
  # 2. We always will try to use the complete data, if not we will use the partial
  df <- X %>% filter(!is.na(memb_annot))
  memb_annot <- df$memb_annot
  df <- df %>% rowwise() %>% mutate(memb_annot_reduced = rename_pfam(memb_annot)) %>% ungroup() %>%
    mutate(number_multi=stri_count_fixed(memb_annot,"|"))
  if(max(df$number_multi)>1){
    df_rep <- df %>% filter(number_multi==max(number_multi)) %>% select(memb_annot_reduced) %>% distinct() %>%
      mutate(numb_rep=sapply(strsplit(memb_annot_reduced,"\\|"),function(x){length(unique(x))}))
    if(max(df$number_multi)>2 && df_rep$numb_rep == 1){
      df_rep <- df_rep %>% mutate(type_rep=sapply(strsplit(memb_annot_reduced,"\\|"), function(x){unique(x)}))
      df <- df %>% mutate(memb_annot_reduced=ifelse(grepl(df_rep$type_rep,memb_annot_reduced),df_rep$memb_annot_reduced,memb_annot_reduced)) %>%
        mutate(partial=ifelse(grepl(df_rep$type_rep,memb_annot_reduced),"00",partial))
    }
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

  if(dim(df_multi)[1]==0){
    archits <- data_frame(archit=memb_annot, class="mono", complete=df_mono_complete_n,partial=df_mono_partial_n)
    list(archit=archits)
  } else {

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
}

# we get the ones that are multidomain
h <- clu_annot %>% filter(grepl("\\|", memb_annot)) %>% mutate(number_multi = stri_count_fixed(memb_annot, "|"))
multi <- h %>% select(cl_name,number_multi) %>% distinct() %>% left_join(clu_annot)
# we create a list out of the different groups
cls_mu <- multi %>% split(.$cl_name)

## Reduced Pfam names
da_multi_red <- mclapply(cls_mu, get_cluster_da_red, mc.cores = 8)
names(da_multi_red) <- names(da_multi_red)
# we select the first archtecture entry, it has been sorted the number of complete and partial oRFs
da_best_mu_red <- map_df(da_multi_red, function(X) X$archit %>% dplyr::slice(1), .id = "cl_name")

## Original Pfam names
da_multi_or <- mclapply(cls_mu, get_cluster_da_or, mc.cores = 2)
names(da_multi_or) <- names(da_multi_or)
# we select the first archtecture entry, it has been sorted the number of complete and partial oRFs
da_best_mu_or <- map_df(da_multi_or, function(X) X$archit %>% dplyr::slice(1), .id = "cl_name")
da_best_multi <- da_best_mu_red %>% select(cl_name,archit,exp_rep,enc_rep) %>% left_join(da_best_mu_or %>% rename(original=archit))

# we get the ones that are monodomain
multi_cl_name <- multi %>% select(cl_name) %>% distinct
m <- clu_annot %>% filter(!cl_name %in% multi_cl_name$cl_name)
# we create a list out of the different groups
cls_mo <- m %>% split(.$cl_name)
# Reduced Pfam names
da_mono_red <- mclapply(cls_mo, get_cluster_da_mono, mc.cores = 12)
names(da_mono_red) <- names(da_mono_red)
da_best_mo_red <- map_df(da_mono_red, function(X) X$archit %>% slice(1), .id = "cl_name")
# Original Pfam names
da_mono_or <- mclapply(cls_mo, get_cluster_da_or, mc.cores = 2)
names(da_mono_or) <- names(da_mono_or)
da_best_mo_or <- map_df(da_mono_or, function(X) X$archit %>% slice(1), .id = "cl_name")
# we select the first archtecture entry, it has been sorted the number of complete and partial oRFs
da_best_mono <- da_best_mo_red %>% select(cl_name,archit) %>% left_join(da_best_mo_or %>% rename(original=archit))

#Combine results and define DUFs and PFs clusters:
# A cluster is consider annotated to DUFs if the original consensus DA is 100% DUF
da_best_all <- rbind(da_best_mu_red,da_best_mo_red %>% select(-homog) %>% mutate(exp_rep=NA,enc_rep=NA)) %>%
  left_join(clu_annot %>% select(-partial) %>% rename(original=memb_annot)) %>%
  separate_rows(original,sep="\\|") %>% group_by(cl_name) %>%
  mutate(type=ifelse(all(!grepl('^DUF',original)),"PF","DUF")) %>%
  group_by(cl_name,type) %>% mutate(original=paste(original,collapse = "|")) %>% distinct()

write.table(da_best_all, "data/OM-RGC-v2/cluster_classification/omrgc2_clu_pfam_dom_archit.tsv", col.names = T, row.names = F, quote = F, sep = "\t")
