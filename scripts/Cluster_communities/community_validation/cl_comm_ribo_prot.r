library(tidyverse)
library(data.table)
library(maditr)
library(readr)
library(bigreadr)
library(unixtools)
library(aricode)
library(ggtherm)

lo_env <- new.env()
setDTthreads(32)

## Compare HHblits parameters ####################################
lo_env$eu_hhblits_all <- big_fread1("data/cluster_communities/data/eu_hhblits.tsv.gz",
                                   print_timings = FALSE,
                                   every_nlines = 2e9,
                                   data.table = TRUE,
                                   .combine = list,
                                   nThread = 32,
                                   header = FALSE
)

# Let's filter for prob >= 50, and cov > 0.6
eu_hhblits <-  data.table::rbindlist(map(unlist(lo_env$eu_hhblits_all, recursive = FALSE), function(X){
  X <- X %>% dt_filter(V1 != V2, V3 >= 50, V13 > 0.6, V14 > 0.6)
  setnames(X, names(X),
           c("cl_name1", "cl_name2", "probability", "e-value", "Score",
             "Cols", "q_start", "q_stop", "t_start", "t_stop", "q_len",
             "t_len", "q_cov", "t_cov"))
  X %>% maditr::dt_mutate(cl_name1 = as.character(cl_name1),
                          cl_name2 = as.character(cl_name2),
                          score_col = Score/Cols,
                          prob_qcov = probability * q_cov,
                          prob_tcov = probability * t_cov) %>%
    rowwise() %>% mutate(pmax_cov=max(prob_qcov,prob_tcov))
}))

# same for the other categories results (GU,KWP,K)

# gather the results together
eu_hhbl <- eu_hhblits %>% dt_select(cl_name1,cl_name2,probability,score_col,pmax_cov) %>% distinct() %>% mutate(categ="EU")
gu_hhbl <- gu_hhblits %>% dt_select(cl_name1,cl_name2,probability,score_col,pmax_cov) %>% distinct()  %>% mutate(categ="GU")
kwp_hhbl <- kwp_hhblits %>% dt_select(cl_name1,cl_name2,probability,score_col,pmax_cov) %>% distinct()  %>% mutate(categ="KWP")
k_hhbl <- k_hhblits %>% dt_select(cl_name1,cl_name2,probability,score_col,pmax_cov) %>% distinct()  %>% mutate(categ="K")

categ_hhbl_metrics <- bind_rows(eu_hhbl,gu_hhbl,kwp_hhbl,k_hhbl)

write.table(categ_hhbl_metrics,"data/cluster_communities/validation/categ_hhbl_metrics_comparison.tsv",
            col.names=T, row.names=F, sep="\t",quote=F)

save(eu_hhbl,gu_hhbl,kwp_hhbl,k_hhbl,file="data/cluster_communities/validation/categ_hhbl_metrics_comparison_obj.rda")

# Plot
data_r <- categ_hhbl_metrics %>%
  dt_select(probability, score_col, pmax_cov, categ) %>%
  data.table:::unique.data.table() %>%
  let(r_probability = rank(probability), r_score_col = rank(score_col), r_pmax_cov = rank(pmax_cov))
pmax_covProbability_p <- data_r %>%
  ggplot(aes(pmax_cov, probability)) +
  geom_hex(bins = 100) +
  viridis::scale_fill_viridis(trans = "log10") +
  theme_bw() +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        panel.background = element_blank(),
        strip.background = element_blank()) +
  xlab("Méheust et al.") +
  ylab("HHblits-Probability")
score_colProbability_p <- data_r %>%
  ggplot(aes(score_col, probability)) +
  geom_hex(bins = 100) +
  viridis::scale_fill_viridis(trans = "log10") +
  theme_bw() +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        panel.background = element_blank(),
        strip.background = element_blank()) +
  xlab("Vanni et al.") +
  ylab("HHblits-Probability")
pmax_covScore_col_p <- data_r %>%
  ggplot(aes(score_col, pmax_cov)) +
  geom_hex(bins = 100) +
  viridis::scale_fill_viridis(trans = "log10") +
  theme_bw() +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        panel.background = element_blank(),
        strip.background = element_blank()) +
  xlab("Vanni et al.") +
  ylab("Méheust et al.")
ggpubr::ggarrange(pmax_covProbability_p, score_colProbability_p, pmax_covScore_col_p, ncol = 3, nrow = 1, common.legend = TRUE)


# Comparison with methods used in Méheust et al. 2019
## Find orfs annotated to ribosomal proteins
comps <- read_tsv("data/cluster_communities/communities_2019-03/all_communities_2019-03-28-144550.tsv.gz")
accs <- read_tsv("data/DBs/pfam_files/Pfam-A.clans.tsv.gz", col_names = F) %>%
  rename(accession = X1)
das <- read_tsv("data/cluster_classification/annotated_cl/marine_hmp_da_reduced_original_names.tsv.gz")
cl_hq <- read_tsv("data/cluster_category_stats/HQ_clusters.tsv", col_names = c("cl_name", "categ"))


ribo <- fread("data/cluster_communities/validation/ribosomal_prot/ribo_markers.tsv", stringsAsFactors = F, header = T) %>%
 inner_join(accs) %>%
 mutate(archit = gsub("_C$", "",X4))
ribo1 <- ribo %>% .$archit
ribo1 <- paste(ribo1,collapse = "|")

genes <- read_tsv("https://raw.githubusercontent.com/merenlab/anvio/master/anvio/data/hmm/Bacteria_71/genes.txt")
# list of ribosomal proteins
ribo_prot <- genes %>% filter(grepl("Ribosomal", gene)) %>%
  separate(accession, into = "accession", sep = '\\.', extra = "drop") %>%
  left_join(accs) %>% filter(grepl(ribo1,X4)) %>% mutate(archit = gsub("_C$", "",X4))
# select the mg clusters annotated to ribosomal proteins
cl_ribo <- comps %>% filter(category == "k") %>%
  inner_join(das) %>%
  left_join(ribo) %>%
  filter(archit %in% ribo_prot$archit, class == "mono") %>%
  select(cl_name, com, archit,riboprot) %>% group_by(com, riboprot) %>% add_count() %>% unique()
write_tsv(cl_ribo %>% drop_na(), "data/cluster_communities/validation/ribosomal_prot/ribo_com_cl.tsv")

# The HQ cluster set
cl_ribo_hq <- comps %>% filter(category == "k") %>%
  inner_join(das) %>%
  left_join(ribo) %>%
  filter(archit %in% ribo_prot$archit, class == "mono", cl_name %in% cl_hq$cl_name) %>%
  select(cl_name,com, archit, riboprot) %>% group_by(com, riboprot) %>% add_count() %>% unique()
write_tsv(cl_ribo_hq %>% drop_na(),"data/cluster_communities/validation/ribosomal_prot/ribo_com_cl_hq.tsv")

# Get the cluster ORFs
k_orfs <- fread("data/cluster_categories/ffindex_files/k_cl_orfs.tsv.gz")
k_orfs <- setNames(k_orfs,c("cl_name","orf"))
ribo_orfs <- k_orfs %>% left_join(cl_ribo %>% select(unique(cl_name)))
wite.tsv(ribo_orfs,"data/cluster_communities/validation/ribosomal_prot/ribo_com_cl_orfs.tsv")

```{bash}
filterbyname.sh in=data/cluster_categories/ffindex_files/k_cl_orfs.fasta.gz out=ribo_com_cl_orfs.fasta names=<(awk '{print $2}' ribo_com_cl_orfs.tsv) include=t
```
# Process/cluster them using the methods in Méheust et al. 2019
family <- fread("data/cluster_communities/validation/ribosomal_prot/ribo_com_cl_fam_subfam.tsv", stringsAsFactors = F, header = F,sep="\t") %>%
  setNames(c("cl_name","orf","subfam","fam","com","archit","riboprot","n"))
family %>% group_by(com,fam,riboprot) %>% count()%>% View()
family_hq <- family %>% inner_join(cl_ribo_hq %>% select(cl_name))
family_hq %>% group_by(com,fam,riboprot,archit) %>% count()%>% View()

write_tsv(family_hq,"data/cluster_communities/validation/ribosomal_prot/ribo_hq_cl_fam_subfam.tsv")

# check the results
data_cls <- read_tsv("data/cluster_communities/validation/ribosomal_prot/ribo_com_cl_fam_subfam.tsv",
 col_names = c("cl_name", "orf", "subfam", "fam", "com_name", "name", "name_s", "len"))


# Compare between clustering methods
clustComp(as.factor(data_cls$fam) %>% as.numeric(), as.factor(data_cls$com_name) %>% as.numeric()) %>%
  unlist() %>%
  enframe()
# Compare between Méheust et al. and the ground truth
clustComp(as.factor(data_cls$name_s) %>% as.numeric(), as.factor(data_cls$fam) %>% as.numeric()) %>%
  unlist() %>%
  enframe()
# Compare between Vanni et al. and the ground truth
clustComp(as.factor(data_cls$name_s) %>% as.numeric(), as.factor(data_cls$com_name) %>% as.numeric()) %>%
  unlist() %>%
  enframe()
ggthemr::ggthemr(layout = "scientific", palette = "fresh")
data_cls %>%
  select(name_s, com_name) %>%
  distinct() %>%
  group_by(name_s) %>%
  count(name = "unk") %>%
  inner_join(data_cls %>%
               select(name_s, fam) %>%
               distinct() %>%
               group_by(name_s) %>%
               count(name = "fam")) %>%
  ggplot(aes(unk, fam, label = name_s)) +
  geom_abline() +
  ggrepel::geom_text_repel(size = 3, nudge_x = 0.8, nudge_y = 0.3) +
  geom_point(color = "black", fill = "grey", shape = 21, size = 3) +
  expand_limits(x = 0, y = 0) +
  xlab("Number of communities (Vanni et al.)") +
  ylab("Number of families (Méheust et al.)")
ggthemr::reset()
