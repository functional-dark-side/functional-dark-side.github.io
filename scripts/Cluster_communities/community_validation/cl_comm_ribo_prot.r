library(tidyverse)
library(data.table)

# Load data
comps <- read_tsv("/bioinf/projects/megx/UNKNOWNS/2017_11/cl_components/components_2019-03/all_components_2019-03-28-144550.tsv.gz")
accs <- read_tsv("ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam31.0/Pfam-A.clans.tsv.gz", col_names = F) %>%
  rename(accession = X1)
das <- read_tsv("/bioinf/projects/megx/UNKNOWNS/chiara/architect/DA/da_reduced_original_names_fix.tsv.gz")
cl_hq <- read_tsv("/bioinf/projects/megx/UNKNOWNS/2017_11/cluster_stats/HQ_clusters.tsv", col_names = c("cl_name", "categ"))

ribo <- fread("/bioinf/projects/megx/UNKNOWNS/chiara/ribo_prot/ribo_markers.tsv", stringsAsFactors = F, header = T) %>%
 inner_join(accs) %>%
 mutate(archit = gsub("_C$", "",X4))
ribo1 <- ribo %>% .$archit
ribo1 <- paste(ribo1,collapse = "|")

bac_scg <- read_tsv("https://raw.githubusercontent.com/merenlab/anvio/master/anvio/data/hmm/Bacteria_71/genes.txt")

ribo_prot <- bac_scg %>% filter(grepl("Ribosomal", gene)) %>%
  separate(accession, into = "accession", sep = '\\.', extra = "drop") %>%
  left_join(accs) %>% filter(grepl(ribo1,X4)) %>% mutate(archit = gsub("_C$", "",X4))

cl_ribo <- comps %>% filter(category == "k") %>%
  inner_join(das) %>%
  left_join(ribo) %>%
  filter(archit %in% ribo_prot$archit, class == "mono") %>%
  select(cl_name, com, archit,riboprot) %>% group_by(com, riboprot) %>% add_count() %>% unique()
write_tsv(cl_ribo %>% drop_na(), "/bioinf/projects/megx/UNKNOWNS/chiara/ribo_prot/ribo_com_cl.tsv")

# cl_ribo_hq <- cl_ribo %>% select(-n) %>%
#   filter(cl_name %in% cl_hq$cl_name) %>% group_by(com, riboprot) %>% add_count() %>% unique()

cl_ribo_hq <- comps %>% filter(category == "k") %>%
  inner_join(das) %>%
  left_join(ribo) %>%
  filter(archit %in% ribo_prot$archit, class == "mono", cl_name %in% cl_hq$cl_name) %>%
  select(cl_name,com, archit, riboprot) %>% group_by(com, riboprot) %>% add_count() %>% unique()
write_tsv(cl_ribo_hq %>% drop_na(),"/bioinf/projects/megx/UNKNOWNS/chiara/ribo_prot/ribo_com_cl_hq.tsv")
