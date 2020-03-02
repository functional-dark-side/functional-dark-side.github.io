library(tidyverse)
library(data.table)
library(maditr)
library(unixtools)

set.tempdir("/scratch/cvanni/")

setwd("/bioinf/projects/megx/UNKNOWNS/2017_11/")

setDTthreads(32)

# Combine cluster category files with sample ids and with the ORF abundances
# Cluster ids - categ - orfs
cl_cat <- fread("cl_categories/cl_ids_categ_orfs.tsv.gz", stringsAsFactors = F, header = F, sep="\t") %>% select(-V2) %>%
  setNames(c("cl_name","categ","orf"))
# Results from read mapping (ORF coverage)
orf_cov <- fread("DATA/ORFs/mapping/marine_hmp_orfs_coverage.tsv.gz", stringsAsFactors = F, header = F) %>%
  setNames(c("orf","contig_cov","cov"))
# Good quality samples, containing a number of ORFs larger than the first ORF-distribution quartile
ok_samples <- fread("DATA/contextual/listSamplesPaper.tsv", stringsAsFactors = F, header = T)
# Correspondence ORF-sample
orf_smpl <- fread("DATA/contextual/marine_hmp_smpl_orfs.tsv.gz", stringsAsFactors = F, header = F, sep="\t") %>%
  setNames(c("sample","orf")) %>% dt_filter(sample %in% ok_samples$label)

# Join tables:
cl_smpl_cov <- cl_cat %>% dt_left_join(orf_smpl) %>%
  dt_left_join(orf_cov %>% dt_select(-contig_cov))

## Investigate cluster distributions (maybe better all in R..data.table)
# Example plot:
## Investigate cluster distributions (maybe better all in R..data.table)
distr <- cl_smpl_cov %>% group_by(sample) %>% mutate(total_abund=sum(abund)) %>%
  group_by(categ,sample,smpl_abund) %>% summarise(abund=sum(abund)) %>% ungroup() %>%
  group_by(sample) %>% spread(categ,abund) %>% mutate(NC=smpl_abund-(EU+GU+K+KWP)) %>%
  gather(categ,abund,EU:NC) %>% mutate(prop=abund/smpl_abund) %>% mutate(biome=ifelse(grepl('SRS',sample),"Human","Marine"))
distr$categ <- factor(as.factor(distr$categ),levels=c("NC","EU","GU","KWP","K"))
distr$biome <- factor(as.factor(distr$biome),levels = c("Marine","Human"))
# Plot
distr %>% drop_na() %>%
  ggplot(aes(x = sample, y = prop, fill = categ)) +
  geom_bar(aes(color=categ),stat = "identity", width = 1) +
  scale_fill_manual(values = c("#bcc8cc","#E84646","#65ADC2","#556c74", "#233B43")) +
  scale_y_continuous(labels = scales::percent, position = "left", expand = c(0,0)) +
  facet_grid (.~ biome, scales = "free_x", space = "free_x") +
  theme_light() +
  ylab("Proportion") +
  xlab("Metagenomes (1,829)") +
  theme(axis.title = element_text(size = 7, colour = "black"),
        axis.text.x = element_text(size=2,colour = "white"),
        axis.text.y = element_text(size=6, colour = "black"),
        axis.ticks.x=element_blank(),
        strip.text = element_text(size=7,colour = "black"),
        strip.background = element_blank(),
        legend.position="bottom",
        legend.title=element_blank(),
        legend.key.size = unit(0.35,"cm"),
        legend.text = element_text(size=7),
        legend.spacing.x = unit(0.1,"cm") ) 
