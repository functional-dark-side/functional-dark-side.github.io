# load functions
source("libs/libs_nb.R")

# Needed packages
packages <- c("tidyverse", "spaa", "vegan", "ggpubr", "data.table",
              "sitools", "scales","purrr","unixtools", "batchtools",
              "maditr", "parallelDist", "dynamicTreeCut")

load_libraries(packages = packages)
create_tmp(tmp = "/vol/scratch/nb/tmp")

# Get sample data
# /bioinf/projects/megx/UNKNOWNS/2017_11/DATA/contextual/
sample_list <- read_tsv(file = "listSamplesPaper.tsv")
samples_analyses <- sample_list %>%
  filter(study != "OSD", study != "GOS")

# Read cluster data
# both tables are in /bioinf/projects/megx/UNKNOWNS/2017_11/cl_categories
gCl_smpl <- fread("cl_abund_smpl_grouped.tsv.gz", stringsAsFactors = F, header = F) %>%
  setNames(c("gCl_name","sample_id","abund","categ")) %>%
  dt_filter(sample_id %in% samples_analyses$label) %>%
  mutate(gCl_name = as.character(gCl_name))
gClCo_smpl <- fread("communities_abund_smpl_grouped.tsv.gz", stringsAsFactors = F, header = F) %>%
  setNames(c("gClCo_name","categ","sample_id","abund")) %>%
  dt_filter(sample_id %in% samples_analyses$label) %>%
  mutate(gClCo_name = as.character(gClCo_name))

sample_ids <- gCl_smpl %>% ungroup() %>% select(sample_id) %>% distinct() %>% .$sample_id

# Calulate proportions
gCl_smpl <- gCl_smpl %>% group_by(sample_id) %>% mutate(prop=abund/sum(abund))
gClCo_smpl <- gClCo_smpl %>% group_by(sample_id) %>% mutate(prop=abund/sum(abund))

# Calculate counts per sample
gCl_smpl_abun <- gCl_smpl %>% group_by(sample_id) %>% summarise(N = sum(abund))
gClCo_smpl_abun <- gClCo_smpl %>% group_by(sample_id) %>% summarise(N = sum(abund))

# Get gCl/gClCo  categories
gCl_cat <- gCl_smpl %>%
  ungroup() %>%
  select(gCl_name, categ) %>%
  distinct() %>%
  mutate(gCl_name = as.character(gCl_name))
gClCo_cat <- gClCo_smpl %>%
  ungroup() %>%
  select(gClCo_name, categ) %>%
  distinct() %>%
  mutate(gClCo_name = as.character(gClCo_name))


# Calculate NB ------------------------------------------------------------

# Get basic stats
gCl_data <- get_stats_nb(X = gCl_smpl)
# Calculate NB
gCl_nb_all <- parNB_all(data = gCl_data)
# Save results
save(gCl_nb_all, file = "results/gCL_nb_all.Rda")
# Get majority sign and average observed B
gCl_nb_all_mv <- gCl_nb_all %>%
  bind_rows() %>%
  select(name, sign, observed) %>%
  group_by(name) %>%
  summarise(sign_mv = majority_vote(sign)$majority,
            observed = mean(observed)) %>%
  inner_join(gCl_data %>% select(name, mean_proportion) %>% distinct()) %>%
  rename(gCl_name = name) %>%
  inner_join(gCl_cat)
save(gCl_nb_all_mv, file = "results/gCl_nb_all_mv.Rda")

cat_order <- c("Knowns", "Genomic unknowns", "Environmental unknowns")
sign_order <- c("Narrow", "Non significant", "Broad")
gCl_nb_all_mv_summary <- gCl_nb_all_mv %>%
  mutate(categ_c = case_when(grepl("K", categ) ~ "Knowns",
                             categ == "GU" ~ "Genomic unknowns",
                             TRUE ~ "Environmental unknowns")) %>%
  select(categ_c, sign_mv) %>%
  group_by(categ_c, sign_mv) %>%
  count() %>%
  group_by(categ_c) %>%
  mutate(prop = n/sum(n)) %>%
  ungroup() %>%
  mutate(categ_c = fct_relevel(categ_c, rev(cat_order)),
         sign_mv = fct_relevel(sign_mv, (sign_order)))

dust <- ggthemr::ggthemr(layout = "scientific", palette = "dust", set_theme = FALSE)
ggthemr::ggthemr(layout = "scientific", palette = "greyscale", set_theme = TRUE)
p_nb_gCl <- ggplot(gCl_nb_all_mv_summary, aes(categ_c, prop, fill = sign_mv)) +
  geom_col(width = 0.7, color = "#404040") +
  rotate() +
  scale_y_continuous(labels = scales::percent) +
  dust$scales$scale_fill_discrete(name = "") +
  xlab("") +
  ylab("Proportion") +
  theme(legend.position = "top",
        aspect.ratio = 1/7,
        legend.key.size = unit(3,"mm"))


# For gClCo ---------------------------------------------------------------
# Get basic stats
gClCo_data <- get_stats_nb(X = gClCo_smpl)
# Calculate NB
gClCo_nb_all <- parNB_all(data = gClCo_data)
# Save results
save(gClCo_nb_all, file = "results/gClCo_nb_all.Rda")
# Get majority sign and average observed B
gClCo_nb_all_mv <- gClCo_nb_all %>%
  bind_rows() %>%
  select(name, sign, observed) %>%
  group_by(name) %>%
  summarise(sign_mv = majority_vote(sign)$majority,
            observed = mean(observed)) %>%
  inner_join(gClCo_data %>% select(name, mean_proportion) %>% distinct()) %>%
  rename(gClCo_name = name) %>%
  inner_join(gClCo_cat)
save(gClCo_nb_all_mv, file = "results/gClCo_nb_all_mv.Rda")

cat_order <- c("Knowns", "Genomic unknowns", "Environmental unknowns")
sign_order <- c("Narrow", "Non significant", "Broad")
gClCo_nb_all_mv_summary <- gClCo_nb_all_mv %>%
  mutate(categ_c = case_when(grepl("K", categ) ~ "Knowns",
                             categ == "GU" ~ "Genomic unknowns",
                             TRUE ~ "Environmental unknowns")) %>%
  select(categ_c, sign_mv) %>%
  group_by(categ_c, sign_mv) %>%
  count() %>%
  group_by(categ_c) %>%
  mutate(prop = n/sum(n)) %>%
  ungroup() %>%
  mutate(categ_c = fct_relevel(categ_c, rev(cat_order)),
         sign_mv = fct_relevel(sign_mv, (sign_order)))

dust <- ggthemr::ggthemr(layout = "scientific", palette = "dust", set_theme = FALSE)
ggthemr::ggthemr(layout = "scientific", palette = "fresh", set_theme = TRUE)
p_nb_gClCo <- ggplot(gClCo_nb_all_mv_summary, aes(categ_c, prop, fill = sign_mv)) +
  geom_col(width = 0.7, color = "#404040") +
  rotate() +
  scale_y_continuous(labels = scales::percent) +
  dust$scales$scale_fill_discrete(name = "") +
  xlab("") +
  ylab("Proportion") +
  theme(legend.position = "top",
        aspect.ratio = 1/7,
        legend.key.size = unit(3,"mm"))

ggarrange(p_nb_gCl, p_nb_gClCo, nrow = 2, ncol = 1, common.legend = TRUE)
