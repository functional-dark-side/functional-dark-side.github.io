library(tidyverse)
library(data.table)
library(maditr)
library(entropy)
library(ggridges)

args <- commandArgs(trailingOnly=TRUE)

## Input args
# args[1] Refined clusters
# args[2] Cluster ids categ
# args[3] Cluster taxonomy results
# args[4] Cluster darkness results
# args[5] DPD info
## Output args
# args[6] Output folder


# Refined cluster with size orf length and partial info
ref_clu <- fread(args[1], stringsAsFactors = F, header = F,
                 colClasses = c(V1="character", V6="character")) %>%
  setNames(c("cl_name","rep","orf","size","length","partial"))

# Join with catgeory info
categ <- fread(args[2], stringsAsFactors = F, header = F,
               colClasses = c(V1="character")) %>%
  setNames(c("cl_name","categ"))

ref_clu <- ref_clu %>% dt_inner_join(categ)

#Start caluclating stats per cluster catgory (or first xcluster and then xcategory????)
# cluster ORF length stats
clu_stats <- ref_clu %>% group_by(cl_name) %>%
  mutate(min_len=min(length),mean_len=mean(length),median_len=median(length),max_len=max(length), sd_len=sd(length))
# Cluster size stats
clu_stats <- clu_stats %>% group_by(cl_name) %>%
  mutate(min_size=min(size),mean_size=mean(size),median_size=median(size),max_size=max(size), sd_size=sd(size))
# Cluster completeness stats (then summarize by cluster category)
clu_compl <- clu_stats %>% group_by(cl_name,partial,size) %>% count() %>%
  mutate(p=n/size) %>% ungroup() %>% dt_select(cl_name,partial,p) %>% spread(partial,p, fill=0) %>%
  rename(p00=`00`,p10=`10`,p01=`01`,p11=`11`)
write.table(clu_compl,paste0(args[6],"/clu_completeness.tsv"), col.names = T, row.names = F, sep = "\t")

# HQ cluster set
# Completeness: Percentage of complete ORFs ("00") (tranformed with sinus function to be between 0-0.5) +
# 0.5 if repres is complete or 0 if it's not

pcompl <- clu_stats  %>%
  select(cl_name, p00, rep_compl) %>% mutate(rep_compl_v=ifelse(rep_compl==T,0.5,0), rep.is.compl=ifelse(rep_compl==T,1,0))

# BrokenStick to p00 distribution (where representative is complete)
brStick <- function (X) {
  x <- X[[2]]
  m <- 0
  out <- matrix(NA, ncol = 2, nrow = length(x))
  colnames(out) <- c("Observed", "BSM")

  #colnames(out) <- c("% of Variability", "B-Stick Threshold")
  for (i in 1:length(x)) {
    for (k in i:length(x)) {
      m <- m + ((1 / length(x)) * (1 / k))
    }
    out[i, ] <- c((x[i] / sum(x)), m)
    m <- 0
  }
  out <- as_tibble(out) %>% mutate(thresh = X[[1]])
  out_w <- out %>% gather(class, value, -thresh) %>%
    mutate(thresh = as.character(thresh),
           class = fct_rev(class))
  plot <- ggplot(out_w, aes(thresh, value, fill = class)) +
    geom_col(position = "dodge", color = "black", alpha = 0.7) +
    geom_line(aes(group = class, color = class), position=position_dodge(width=0.9)) +
    geom_point(position=position_dodge(width=0.9), colour="black",  shape = 21) +
    theme_light() +
    theme(legend.position = "top",
          legend.title = element_blank()) +
    scale_y_continuous(labels = scales::percent) +
    xlab("Filtering threshold") +
    ylab("Variability")

  h_bsm <- out %>% filter(Observed > BSM) %>% .$thresh

  return(list(bsm_table = out, plot = plot, thresh_by_bsm = h_bsm))
}
br_compl_cl <- plyr::ldply(seq(0,1,0.05), function(x) {data.frame(threshold = x, clusters = dim(pcompl %>% filter(p00>=x))[1])})
br_compl <- brStick(br_compl_cl)
br_compl$plot
lag <- br_compl$thresh_by_bsm %>% enframe() %>% mutate(lag = round(value - dplyr::lag(value), 2)) %>%
filter(lag > .01) %>% top_n(1) %>% .$name %>% head(1)
if (length(lag)!=0){
  rej_threshold <- br_compl$thresh_by_bsm[lag - 1]
} else {
  rej_threshold <- br_compl$thresh_by_bsm[length(br_compl$thresh_by_bsm)]
}

# We define as HQ clusters the clusters with a percentage of complete ORFs higher than the identified threshold
# and a complete representative
HQ_clusters <- clu_stats %>% filter(p00>=0.35,rep_compl==T) %>% select(cl_name,categ)
write.table(HQ_clusters,paste0(args[6],"/HQ_clusters_categ.tsv"), col.names = T, row.names = F, sep = "\t")

# Category stats
# category ORF length stats
cat_stats <- ref_clu %>% group_by(categ) %>%
  mutate(min_len=min(length),mean_len=mean(length),median_len=median(length),max_len=max(length), sd_len=sd(length))
# category size stats
cat_stats <- cat_stats %>% group_by(categ) %>%
  mutate(min_size=min(size),mean_size=mean(size),median_size=median(size),max_size=max(size), sd_size=sd(size))
# category completeness stats
cat_compl <- cat_stats %>% group_by(categ,partial) %>% add_count() %>%
  mutate(p=n/sum(size)) %>% ungroup() %>% dt_select(categ,partial,p) %>% distinct() %>% spread(partial,p, fill=0) %>%
  rename(p00=`00`,p10=`10`,p01=`01`,p11=`11`)

# Cluster taxonomy stats
cl_tax <- fread(args[3],
                stringsAsFactors = F, header = F, fill = T) %>%
  setNames(c("orf","cl_name","categ","taxid","rank","classific","lineage"))
# Filter out the unclassified ones and split the taxonomic levels in the lineage
cl_tax <- cl_tax %>% filter(classific!="unclassified") %>%
  mutate(lineage=gsub("-_cellular__organisms;","",lineage)) %>%
  mutate(domain=str_match(lineage,"^d_(.*?);.*")[,2],
         phylum=str_match(lineage,";p_(.*?);.*")[,2],
         class=str_match(lineage,";c_(.*?);.*")[,2],
         order=str_match(lineage,";o_(.*?);.*")[,2],
         family=str_match(lineage,";f_(.*?);.*")[,2],
         genus=str_match(lineage,";g_(.*?);.*")[,2],
         species=str_match(lineage,";s_(.*?)$")[,2])

# Taxonomic homogeneity
homo_tax <- cl_tax %>% select(-orf,-taxid,-classific,-rank,-lineage) %>%
  group_by(cl_name,categ) %>%
  summarise(homo_d=length(unique(domain[!is.na(domain)])),
            homo_p=length(unique(phylum[!is.na(phylum)])),
            homo_o=length(unique(`order`[!is.na(`order`)])),
            homo_c=length(unique(class[!is.na(class)])),
            homo_f=length(unique(family[!is.na(family)])),
            homo_g=length(unique(genus[!is.na(genus)])),
            homo_s=length(unique(species[!is.na(species)])))

### Plot:
plot_tax <- gather(homo_tax,ranks,n,homo_p:homo_s) %>%
  mutate(ranks=case_when(ranks=="homo_p"~"Phylum",
                         ranks=="homo_c"~"Class",
                         ranks=="homo_o"~"Order",
                         ranks=="homo_f"~"Family",
                         ranks=="homo_g"~"Genus",
                         TRUE  ~ "Species")) %>%
  mutate(n=as.numeric(n),ranks=as.factor(ranks)) %>% as_tibble()
plot_tax$categ <- factor(as.factor(plot_tax$categ), levels=c("K","KWP","GU","EU"))
plot_tax$ranks <- factor(as.factor(plot_tax$ranks), levels=c("Phylum","Class","Order","Family","Genus","Species"))
# joy_div plot
taxp <- ggplot(plot_tax %>% filter(n<=50 & n>0),aes(y=categ,x=n, fill=categ)) +
  geom_density_ridges(scale = 4, bandwidth=.3, alpha=.8,size=.3) +
  scale_x_continuous(breaks = c(1,5,10, 15, 20)) +
  coord_cartesian(xlim = c(0, 20)) +
  facet_wrap(.~ ranks) +
  scale_fill_manual(values=c("#233B43","#556c74","#65ADC2","#E84646")) + ##4B636A K
  theme_light() + xlab("Number of different taxonomies inside each cluster") + ylab("") +
  theme(axis.text.x = element_text(size=6),
        axis.text.y = element_text(size=6),
        axis.title.x = element_text(size=7),
        legend.text = element_text(size=6),
        legend.title = element_blank(),
        legend.key.size = unit(.39,"cm"),
        strip.text = element_text(size=7, colour = "white"),
        strip.background = element_rect(fill = "#273133"))
save(taxp , file=paste0(args[6],"/taxonomy/taxonomy_plot.rda"))

# Calculate cluster taxonomic entropy
p <- cl_tax %>% group_by(cl_name, categ,phylum) %>%
  summarise (n=n()) %>%
  mutate(pf = n / sum(n)) %>%
  group_by(cl_name, categ) %>%
  mutate(pe = entropy.empirical(pf, unit="log2")) %>%
  select(1,2,6) %>% distinct()
o <- cl_tax %>% group_by(cl_name, categ,order) %>%
  summarise (n=n()) %>%
  mutate(of = n / sum(n)) %>%
  group_by(cl_name, categ) %>%
  mutate(oe = entropy.empirical(of, unit="log2")) %>%
  select(1,2,6) %>% distinct()
c <- cl_tax %>% group_by(cl_name, categ,class) %>%
  summarise (n=n()) %>%
  mutate(cf = n / sum(n)) %>%
  group_by(cl_name, categ) %>%
  mutate(ce = entropy.empirical(cf, unit="log2")) %>%
  select(1,2,6) %>% distinct()
f <- cl_tax %>% group_by(cl_name, categ,family) %>%
  summarise (n=n()) %>%
  mutate(ff = n / sum(n)) %>%
  group_by(cl_name, categ) %>%
  mutate(fe = entropy.empirical(ff, unit="log2")) %>%
  select(1,2,6) %>% distinct()
g <- cl_tax %>% group_by(cl_name, categ,genus) %>%
  summarise (n=n()) %>%
  mutate(gf = n / sum(n)) %>%
  group_by(cl_name, categ) %>%
  mutate(ge = entropy.empirical(gf, unit="log2")) %>%
  select(1,2,6) %>% distinct()
s <- cl_tax %>% group_by(cl_name, categ,species) %>%
  summarise (n=n()) %>%
  mutate(sf = n / sum(n)) %>%
  group_by(cl_name, categ) %>%
  mutate(se = entropy.empirical(sf, unit="log2")) %>%
  select(1,2,6) %>% distinct()
tax_entropy <- p %>% left_join(c) %>% left_join(o) %>%
  left_join(f) %>% left_join(g) %>% left_join(s)
rm(p,c,o,f,g,s)
write.table(tax_entropy, paste0(args[6],"/cluster_categ_taxonomy_entropy.tsv"), col.names = T, row.names = F, quote =  F, sep = "\t")

## Retrieve the prevalent taxa for each cluster
prev_tax <- cl_tax %>% group_by(cl_name,categ,domain,phylum,class,order,family,genus,species) %>%
  count() %>% ungroup() %>% group_by(cl_name,categ) %>% arrange(desc(n)) %>% slice(1) %>% select(-n)
write.table(prev_tax,paste0(args[6],"/cluster_categ_prevalent_tax.tsv"), col.names = T, row.names = F, quote = F, sep = "\t")

# Cluster darkness stats
dpd_res <- fread(args[4],
                 stringsAsFactors = F, header = F) %>%
  setNames(c("orf","dpd_acc","cl_name","categ"))

dpd_info <- fread(args[5], stringsAsFactors = F, header = T, sep="\t", fill=T) %>%
    mutate(Darkness=Darkness/100,Disorder=Disorder/100,Compositional_Bias=Compositional_Bias/100,Transmembrane=Transmembrane/100)

cl_dark <- dpd_res %>% left_join(dpd_info, by=c("dpd_acc"="Primary_Accession")) %>% group_by(cl_name,categ) %>%
  summarise(mean_darkness=mean(Darkness),median_darkness=median(Darkness),
         mean_disorder=mean(Disorder), median_disorder=median(Disorder))
write.table(cl_dark,paste0(args[6],"/darkness/cluster_dpd_perc.tsv"),
            col.names=T,row.names=F,quote=F,sep="\t")
cat_dark <- dpd_res %>% left_join(dpd_info, by=c("dpd_acc"="Primary_Accession")) %>% group_by(categ) %>%
  summarise(mean_darkness=mean(Darkness),median_darkness=median(Darkness),
            mean_disorder=mean(Disorder), median_disorder=median(Disorder))
write.table(cat_dark,paste0(args[6],"/darkness/cluster_category_dpd_perc.tsv"),
            col.names=T,row.names=F,quote=F,sep="\t")

## Cluster general stats
clu_stats <- clu_stats %>% dt_left_join(clu_compl) %>% mutate(rep_compl=ifelse(rep==orf & partial=="00", TRUE,FALSE)) %>%
  dt_left_join(tax_entropy %>% ungroup() %>% mutate(cl_name=as.character(cl_name))) %>%
  dt_left_join(prev_tax %>% ungroup() %>% mutate(cl_name=as.character(cl_name))) %>%
  dt_left_join(cl_dark %>% ungroup() %>% mutate(cl_name=as.character(cl_name))) %>%
  dt_left_join(HQ_clusters %>% mutate(is.HQ=TRUE))
write.table(clu_compl,paste0(args[6],"/cluster_general_stats.tsv"), col.names = T, row.names = F, sep = "\t")

## Category general stats
cat_stats <- cat_stats %>% dt_left_join(cat_compl) %>%
  dt_select(-cl_name,-orf,-rep,-size,-length,-partial) %>% distinct() %>%
  dt_left_join(tax_entropy %>% ungroup() %>% select(-cl_name) %>% group_by(categ) %>% summarise_all(sum)) %>%
  dt_left_join(cat_dark)
write.table(clu_compl,paste0(args[6],"/cluster_categ_stats.tsv"), col.names = T, row.names = F, sep = "\t")
