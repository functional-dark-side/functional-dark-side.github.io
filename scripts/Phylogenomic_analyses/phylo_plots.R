library(tidyverse)
library(data.table)
library(tidytree)
library(ggtree)
library(treeio)
library(ape)
library(ggsci)
library(wesanderson)
library(castor)

# GTDB data
gtdb_data <- fread("data/MG_GTDB_DB/mg_gtdb_kept_cluster_genome_orf_categ.tsv.gz",header = FALSE,
             col.names = c("genome","domain","orf","cl_name"))

gtdb_tree <- read.tree("data/GTDB/gtdb_data/gtdb_r86_bac.tree") #"gtdb_r86_ar.tree"
gtdb_tax <- read_tsv("data/GTDB/gtdb_data/bac_taxonomy_r86.tsv", col_names = c("genome", "lineage")) %>% #"arc_taxonomy_r86.tsv"
            separate(lineage, into=c("domain","phylum","class","order","family","genus","species"), sep = ";")

# Phylo analyses results
load("data/GTDB/phylogenetic_analysis/gtdb_bac_r86_plot.Rda")  #"gtdb_arc_r86_plot.Rda"
#f1score.out_table.cl
#tree
#gtdb_tax
#f1
#cl_annotation_plot.df
#tax_levels

# Plots of lineage specific GU clusters at the different taxonomic levels:
gu_f1 <- f1 %>%
  filter(categ == "GU")
# Example: Phylum level ------------------------------------------------------------------
tax_phylum <- gtdb_tax %>% group_by(phylum) %>% sample_n(1)
tree_phylum <- drop.tip(tree, setdiff(tree$tip.label, tax_phylum$genome %>% as.character()), trim.internal = TRUE)
tree_phylum$tip.label <- plyr::mapvalues(tree_phylum$tip.label, from = as.character(tax_phylum$genome), to = as.character(tax_phylum$phylum))
gu_phylum <- gu_f1 %>%
  ungroup() %>%
  filter(lowest_level == "Phylum") %>%
  group_by(lowest_rank) %>%
  count(sort = T) %>%
  rename(phylum = lowest_rank)
tree_phylum_tips <- map_dfr(gu_phylum$phylum, function(X){treeio::tree_subset(tree_phylum, node = X, levels_back = 5)$tip.label %>% enframe()})$value
tree_phylum <- drop.tip(tree_phylum, setdiff(tree_phylum$tip.label, tree_phylum_tips), trim.internal = TRUE)
phylum_data <- tree_phylum %>%
  as_tibble() %>%
  left_join(gu_f1 %>%
              ungroup() %>%
              filter(lowest_level == "Phylum") %>%
              group_by(lowest_rank) %>%
              count(sort =TRUE) %>%
              rename(phylum = lowest_rank) %>%
              left_join(tax_phylum %>% select(phylum, phylum)) %>%
              rename(label = phylum)) %>%
  mutate(with_gu = ifelse(is.na(n), FALSE, TRUE))
ggtree(tree_phylum, aes(color = with_gu), layout='circular') %<+% phylum_data +
  geom_tippoint(aes(size = n),
                shape = 21,# Make bubbles on edges
                fill = "#E5A454",
                color = "#243643",
                alpha = 0.7) +
  geom_tiplab2(size = 2,
               align = TRUE,
               linesize = 0.2,
               linetype = "dotted") +
  scale_color_manual(values = c("#243643", "#E5A454"), guide = FALSE) +
  theme(legend.position = "top",
        legend.key = element_blank()) # no keys

# Plot number of lineage-specific clusters per category & rank -----------------------------
ggthemr("fresh", layout = "scientific")
f1score.out_table.cl_filt %>%
  inner_join(f1score.out_table.cl_filt %>% select(lineage) %>%
               unique() %>%
               rowwise() %>%
               mutate(lowest_rank = get_rank(as.character(lineage)),
                      lowest_level = get_level(as.character(lineage)))) %>%
  separate(trait, into = "cat", sep = "_", remove = F, extra = "drop") %>%
  mutate( cat = fct_relevel(cat, rev(c("K", "KWP", "GU", "EU")))) %>%
  ggplot(aes(cat)) +
  geom_bar() +
  facet_wrap(lowest_level~.,scales = "free_x", ncol = 1) +
  ggpubr::rotate() +
  xlab("") +
  ylab("Lineage specific clusters")

# GTDB phyla analysis
# Proportion of MAGs, unknowns and lineage-specific clusters per phylum
# MAGs in GTDB:
gtdb_mag <- fread("data/GTDB/gtdb_data/gtdb_genome_mags.tsv.gz", stringsAsFactors = F, header = F) %>% setNames(c("genome","mag"))
# Number of ORFs per genome
genome_info <- fread("data/GTDB/gtdb_data/gtdb_genome_info.tsv.gz", stringsAsFactors = F, header = T) %>% select("genome","n_orfs")
# Add lineage-specificity and taxonomic info to the GTDB data table
gtdb_data <- gtdb_data %>% select(genome,cl_name) %>%
  dt_left_join(gtdb_tax, by="genome") %>%
  dt_left_join(f1 %>% select(trait,lineage,lowest_level), by=c("cl_name"="trait")) %>%
  dt_mutate(type=ifelse(is.na(lowest_level),"not_spec","spec"))
# Focus at the phylum level
# Add genome size information
phylum_size <- gtdb_data %>% select(phylum,genome) %>%
  dt_left_join(genome_info) %>% distinct() %>%
  group_by(phylum) %>%
  summarise(sum_genome_size=sum(n_orfs), n_genome=length(genome))
# Add mag information
phylum_mags <- gtdb_tax %>% select(genome,phylum) %>% left_join(gtdb_mag) %>%
  mutate(mag=ifelse(is.na(mag),"GENOME",mag)) %>% group_by(phylum) %>% add_count() %>% rename(all=n) %>%
  group_by(phylum,mag) %>% add_count() %>% mutate(p_mag=n/all) %>% filter(mag=="MAG") %>% select(phylum,mag,p_mag) %>% distinct()
# Put together stats for phylum genomes
phylum_stats <- gtdb_data %>% separate(cl_name,into=c("categ","cl_name"), sep="_", remove=T) %>%
  dt_select(phylum,categ,type) %>% ungroup() %>%
  left_join(phylum_size) %>% group_by(phylum,categ,type) %>% add_count() %>% rename(sum_cat_phylum_type=n) %>%
  dt_mutate(p_cat_phylum_type=sum_cat_phylum_type/sum_genome_size) %>% distinct()
phylum_stats <- phylum_stats %>% ungroup() %>%
  mutate(class=ifelse(grepl('GU|EU',categ) & type=="spec","Unknowns spec",
                      ifelse(grepl('GU|EU',categ) & type=="not_spec","Unknowns not_spec","Knowns"))) %>%
  select(phylum,p_cat_phylum_type,sum_cat_phylum_type,sum_genome_size,class) %>% distinct() %>%
  group_by(phylum,class) %>% mutate(phylum_prop=sum(p_cat_phylum_type),phylum_n=sum(as.numeric(sum_cat_phylum_type))) %>%
  ungroup() %>% select(phylum,class,phylum_prop,phylum_n) %>% distinct() %>%
  mutate(s_class=ifelse(grepl('Unkn',class),"unk","kno")) %>%
  group_by(phylum,s_class) %>% mutate(new_prop=sum(phylum_prop), new_n=sum(phylum_n))
phylum_stats_mag_p <- phylum_stats %>% select(phylum,s_class,new_prop) %>% distinct() %>%
  mutate(phylum=gsub('p__','',phylum)) %>% spread(s_class,new_prop) %>%
  left_join(phylum_mags) %>% select(-mag) %>% mutate(p_mag=ifelse(is.na(p_mag),0,p_mag)) %>% ungroup() %>%
  left_join(phylum_size %>% select(phylum,n_genome)) %>% mutate(uncl=1-(unk+kno))
phylum_stats_mag_n <- phylum_stats %>% select(phylum,s_class,new_n) %>% distinct() %>%
  mutate(phylum=gsub('p__','',phylum)) %>% spread(s_class,new_n) %>%
  left_join(phylum_mags) %>% select(-mag) %>% mutate(p_mag=ifelse(is.na(p_mag),0,p_mag)) %>% ungroup() %>%
  left_join(phylum_size %>% select(phylum,sum_genome_size, n_genome)) %>% mutate(uncl=sum_genome_size-(unk+kno))
save(phylum_stats_mag_p,phylum_stats_mag_n,file="gtdb_phylum_mag_data_bac.rda")

# Prepare taxonomy data
gtdb_tax <- gtdb_tax[match(gtdb_tree$tip.label,
                              gtdb_tax$tip), ]
parsed_ranks <- data.frame(t(sapply(gtdb_tax$taxonomy_string,
                                    function(s) {
                                          ranks <- strsplit(as.character(s), split = ";")[[1]]
                                          return(sapply(ranks, function(rank) {
                                          strsplit(rank, split = "__")[[1]][2]
                                          }))
                                      })))
colnames(parsed_ranks) <-
  c("domain",
    "phylum",
    "class",
    "order",
    "family",
    "genus",
    "species")
gtdb_tax <- cbind(gtdb_tax, parsed_ranks) %>% as_tibble()
tax_phylum <- gtdb_tax %>% group_by(phylum) %>% sample_n(1)
tree_phylum <- drop.tip(gtdb_tree, setdiff(gtdb_tree$tip.label, tax_phylum$tip %>% as.character()), trim.internal = TRUE)
tree_phylum$tip.label <- plyr::mapvalues(tree_phylum$tip.label, from = as.character(tax_phylum$tip), to = as.character(tax_phylum$phylum))
tree_phylum_tips <- map_dfr(tax_phylum$phylum, function(X){
      treeio::tree_subset(tree_phylum, node = X, levels_back = 5)$tip.label %>% enframe()})$value
tree_phylum <- drop.tip(tree_phylum, setdiff(tree_phylum$tip.label, tree_phylum_tips), trim.internal = TRUE)
specific <- f1 %>% filter(lowest_level == "Phylum") %>%
      group_by(lowest_rank) %>% count() %>%
      rename(label = lowest_rank)
phylum_data <- tree_phylum %>%
      as_tibble() %>%
      inner_join(gtdb_phylum_stats_mag_p %>% mutate(phylum=gsub('p__',"", phylum)) %>% rename(label = phylum)) %>%
      left_join(specific)
# Plot phylogenetic tree (phylum-level) --------------------------------------------------
pal <- wes_palette("Zissou1", 100, type = "continuous")
p <- ggtree(tree_phylum, aes(color = p_mag), layout='circular') %<+% phylum_data +
     geom_tippoint(aes(size = n),
                  shape = 21,# Make bubbles on edges
                  fill = "#022641",
                  color = "#243643",
                  alpha = 0.7) +
      geom_tiplab2(size = 2.1,
                  align = TRUE,
                  linesize = 0.2,
                  linetype = "dotted",
                  color = "black") +
      scale_color_gradientn(colours = pal, name="Percentage of MAGs", labels=scales::percent) +
      scale_size_continuous(range = c(1,3), name="Lineage specific unknowns") +
      theme(legend.position = "top",
            legend.key = element_blank()) # no keys

# Prepare data for gheatmap plot showing the proportion of unknown x phylum
data <- gtdb_phylum_stats_mag_p %>% select(-p_mag) %>% as.data.frame() %>% column_to_rownames("phylum") %>% select(unk)
p1 <- gheatmap(p, data, width=.05, offset=0.5, color = "black") +
      scale_fill_material("blue-grey", trans = "log10", name="Proportion of unknowns",labels=scales::percent)  +
      guides(fill = guide_colourbar(nbin=300, raster=FALSE, barwidth = 0.8, barheight = 5, ticks.colour = "black", frame.colour = "black"),
             color= guide_colourbar(nbin=300, raster=FALSE, barwidth = 0.8, barheight = 5, ticks.colour = "black", frame.colour = "black"))
p1 + theme(axis.title = element_text(size=7),
          axis.text = element_text(size=6),
          legend.text = element_text(size=6),
          legend.title = element_text(size=7))

# Phyla distribution in the Known and Unknown space plot
# Bubbles size based on the number of genomes x phylum
# Colors based on the proportion of MAGs x phylum
data_1 <- gtdb_phylum_stats_mag_n %>% mutate(phylum=gsub("p__","",phylum)) %>%
          mutate(ncK = kno/(uncl+unk), ncU = unk/(uncl+kno))
p2 <- ggplot(data_1, aes(x = ncK, y = ncU, z = p_mag, size = n_genome,label=phylum, fill=p_mag)) +
      geom_point(shape = 21,  color = "black", alpha = 0.9) +
      scale_fill_gradientn(colours = pal, name="Percentage of MAGs") +
      scale_size_continuous(range = c(1.3,6), trans = "log10", name="Number of genomes") +
      guides(fill = guide_colourbar(nbin=300, raster=FALSE, barwidth = 0.8, barheight = 5, ticks.colour = "black", frame.colour = "black")) +
      xlab("[ known ] / [ NC + unknown ]") +
      ylab("[ unknown ] / [ NC + known ]") +
      theme(axis.title = element_text(size=7),
                    axis.text = element_text(size=6),
                    legend.position = "right",
                    legend.title = element_text(size=7),
                    legend.text = element_text(size=6))
# Plot lineage-specific cluster in the context of GTDB standardised taxonomy (RED) -----------------------------------------------------------
# To get the RED:
# You need python 2.7
# cd gtdb_data/
# git clone https://github.com/dparks1134/PhyloRank.git
# conda install matplotlib=2.0.0
# python setup.py install
# phylorank outliers gtdb_r86_bac.tree bac_taxonomy_r86.tsv gtdb_r86_red --verbose_table
red_path <- "gtdb_data/gtdb_r86_bac_red/"
red_files <- list.files(path = red_path, pattern = "rank_distribution.tsv", recursive = TRUE, full.names = TRUE)
red_df <- purrr::map_dfr(red_files, read_tsv, col_names = T)
red_ranks <- red_df %>% mutate(rank = case_when(grepl("p__", Taxa) ~ "Phylum",
                                                grepl("c__", Taxa) ~ "Class",
                                                grepl("o__", Taxa) ~ "Order",
                                                grepl("f__", Taxa) ~ "Family",
                                                grepl("g__", Taxa) ~ "Genus",
                                                grepl("s__", Taxa) ~ "Species")) %>%
    group_by(rank) %>%
    summarise(red = median(`Relative Distance`)) %>%
    ungroup()
# RED-lineage-specific plot
    p3 <- f1 %>% filter(grepl('d__Bacteria',lineage)) %>%
      group_by(lowest_level, categ) %>%
      count() %>%
      ungroup() %>%
      spread(categ, value = n) %>%
      replace_na(list(EU = 0, GU = 0, KWP = 0, K = 0)) %>%
      mutate(known = KWP + K, unknown = EU + GU) %>%
      select(lowest_level, known, unknown) %>%
      rename(rank = lowest_level) %>%
      gather(categ, n, -rank) %>%
      inner_join(red_ranks) %>%
      ggplot(aes(red, n, fill = categ, color = categ, group = categ)) +
      geom_vline(xintercept=red_ranks$red, color = "black", alpha = 0.6, size = 0.3, linetype = "dotdash") +
      geom_smooth(size=.5) +
      geom_point(shape = 21, color = "black", size = 2,stroke=0.4, alpha = 0.8) +
      geom_text(aes(x=red, y=60000, label=rank),
                hjust=1.1,size=2, color = "black") +
      expand_limits(x = 0.25, y = 0) +
      scale_y_continuous(labels = scales::comma) +
      scale_color_manual(values=c("#E5A92A","#4B1561"), labels=c("Known","Unknown")) +
      scale_fill_manual(values=c("#E5A92A","#4B1561"),labels=c("Known","Unknown")) +
      ylab("Lineage specific communities") +
      xlab("Relative evolutionary divergence") +
      theme(axis.title = element_text(size=7),
            axis.text = element_text(size=6),
            legend.title = element_blank(),
            legend.text = element_text(size=6),
            legend.key.size = unit(0.3,"cm"))


# Trait Depth (tauD): phylogenetic conservation score ------------------------------------------------------
# Read: https://www.nature.com/articles/ismej2012160

gtdb_sig_tauD <-
  f1score.out_table.cl %>% as_tibble() %>% filter(P < 0.05) %>%
  mutate(categ = fct_relevel(categ, (c("K", "KWP", "GU", "EU"))))

l0 <- gtdb_sig_tauD %>%
  ggplot(aes(mean_depth, fill = categ)) +
  geom_density() +
  scale_x_reverse() +
  scale_fill_manual(values = c("#c7d4b6", "#a3aabd", "#a0d0de", "#97b5cf")) +
  facet_wrap(~categ) +
  theme_light() +
  labs(x=expression(paste("Clade mean depth (", tau[D], ")")),
       y = "Density") +
  theme(legend.position = "none")


l1 <- gtdb_sig_tauD %>%
  group_by(categ) %>%
  count() %>%
  ungroup() %>%
  mutate(categ = fct_relevel(categ, rev(c("K", "KWP", "GU", "EU"))),
         prop = n/sum(n)) %>%
  ggplot(aes(categ, prop, fill = categ)) +
  geom_col() +
  scale_fill_manual(values = rev(c("#c7d4b6", "#a3aabd", "#a0d0de", "#97b5cf"))) +
  theme_light() +
  ggpubr::rotate() +
  theme(legend.position = "none") +
  labs(y=expression(paste("Proportion of clusters with significant ", tau[D], " (P < 0.05)"))) +
  xlab("") +
  scale_y_continuous(labels = scales::percent)

ggpubr::ggarrange(l1,l0, nrow = 1, ncol = 2, align = "h")
