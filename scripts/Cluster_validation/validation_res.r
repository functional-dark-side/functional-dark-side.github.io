#!/home/cvanni/R-3.4.2/bin/Rscript

library(tidyverse)
library(data.table)
library(RSQLite)
library(dbplyr)
library(cowplot)

args <- commandArgs(trailingOnly = TRUE)

# Inizialise the SQLite database for the results
db_file = paste(args[1],"cluster_val_res.sqlite3",sep="/")

con <- dbConnect(SQLite(), db_file)

dbGetQuery(con, 'PRAGMA foreign_keys = ON')
dbGetQuery(con, 'PRAGMA auto_vacuum = ON')

# Functional validation DB table
dbGetQuery(con, 'create table if not exists funct_val
           (old_repres text,
           jacc_median_raw numeric,
           jacc_median_sc numeric,
           annot_type text,
           prop_type numeric,
           prop_partial numeric,
           annot_categ text
         )'
)
dbGetQuery(con,"CREATE INDEX if not exists index_repres ON funct_val (old_repres)")

# Load the table with both validation results
func_val_df <- read_tsv(args[2], col_names = T,
  col_types = cols(old_repres="c",jacc_median_raw="n",jacc_median_sc="n",annot_type="c",
                   prop_type="n",prop_partial="n",annot_categ="c")) %>%

# Write the data frame in the DB table
dbWriteTable(con, "funct_val", funct_val_df, append = TRUE)

# Compostional validation DB table
dbGetQuery(con, 'create table if not exists comp_val
           (cl_name integer primary key,
           new_repres text,
           n_orfs integer,
           n_vertices integer,
           n_edges integer,
           density numeric,
           cut_w numeric,
           connected logic,
           n_compon integer,
           tr_min_id numeric,
           tr_mean_id numeric,
           tr_median_id numeric,
           tr_max_id numeric,
           raw_min_id numeric,
           raw_mean_id numeric,
           raw_median_id numeric,
           raw_max_id numeric,
           min_len integer,
           mean_len numeric,
           median_len numeric,
           max_len integer,
           rejected integer,
           core integer,
           prop_rejected numeric
           )'
)
dbGetQuery(con,"CREATE INDEX if not exists index_cl_name ON comp_val (cl_name)")

# Read the compositional validation result table
comp_val_df <- fread(args[3], stringsAsFactors=F, header=F) %>%
 setNames(c("cl_name","new_repres", "n_orfs","n_vertices","n_edges", "density","cut_w","connected","n_compon","tr_min_id",
            "tr_mean_id","tr_median_id","tr_max_id","raw_min_id","raw_mean_id","raw_median_id","raw_max_id","min_len","mean_len",
            "median_len","max_len","rejected","core","prop_rejected"))

# Write the data frame in the DB table
dbWriteTable(con, "comp_val", comp_val_df, append = TRUE)

# Cluster old new representatives table
old_new_rep_df <- read_tsv(args[4], col_names = F) %>%
setNames(c("cl_name","new_repres","old_repres","new_repres_annot", "funct_annot"))

# Join compositional and functional validation results
cl_val_df <-  comp_val_df %>%
  inner_join(annot_noannot_df,by=c("cl_name","new_repres")) %>%
  left_join(funct_val_df, by=c("old_repres")) %>%
  dplyr::select(cl_name,new_repres,new_repres_annot,funct_annot,old_repres,n_orfs,n_vertices,n_edges,density,cut_w,connected,
    n_compon,tr_min_id,tr_mean_id,tr_median_id,tr_max_id,raw_min_id,raw_mean_id,raw_median_id,raw_max_id,min_len,mean_len,median_len,max_len,
    rejected,core, prop_rejected,jacc_median_raw,jacc_median_sc,annot_type, prop_type,prop_partial,annot_categ)

#Write results to the database table
dbGetQuery(con, 'create table if not exists cluster_val_res
           (cl_name integer primary key,
           new_repres text,
           new_repres_annot text,
           funct_annot text,
           old_repres text,
           n_orfs integer,
           n_vertices integer,
           n_edges integer,
           density numeric,
           cut_w numeric,
           connected logic,
           n_compon integer,
           tr_min_id numeric,
           tr_mean_id numeric,
           tr_median_id numeric,
           tr_max_id numeric,
           raw_min_id numeric,
           raw_mean_id numeric,
           raw_median_id numeric,
           raw_max_id numeric,
           min_len integer,
           mean_len numeric,
           median_len numeric,
           max_len integer,
           rejected integer,
           core integer,
           prop_rejected numeric,
           jacc_median_raw numeric,
           jacc_median_sc numeric,
           annot_type text,
           prop_type numeric,
           prop_partial numeric,
           annot_categ text
           )'
)
dbGetQuery(con,"CREATE INDEX if not exists index_cl_name ON cluster_val_res (cl_name)")
dbWriteTable(con, "cluster_val_res", cl_val_df, append = TRUE)

## Additional tables (summary)
#Good and bad clusters stats
p_rej_cl <- plyr::ldply(seq(0,1, 0.01), function(x) {data.frame(threshold = x, clusters = dim(cl_val_df %>% filter(rejected>0) %>% filter(prop_rejected >= x))[1])})
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
lag <- brStick(p_rej_cl)$thresh_by_bsm %>% enframe() %>% mutate(lag = round(value - lag(value), 2)) %>%
  filter(lag > .01) %>% top_n(1) %>% .$name
if (length(lag)!=0){
  rej_threshold <- brStick(p_rej_cl)$thresh_by_bsm[lag - 1]
} else {
  rej_threshold <- brStick(p_rej_cl)$thresh_by_bsm[length(brStick(p_rej_cl)$thresh_by_bsm)]
}
val_stats <- data.frame(total_clusters = dim(cl_val_df)[1],
                        total_orfs = sum(cl_val_df$n_orfs),
                        good_cl_n = dim(cl_val_df %>%
                                          filter(funct_annot=="noannot" & prop_rejected < rej_threshold | funct_annot!="noannot" & prop_rejected<rej_threshold & jacc_median_raw==1))[1],
                        good_cl_orfs = sum(cl_val_df %>%
                                          filter(funct_annot=="noannot" & prop_rejected < rej_threshold | funct_annot!="noannot" & prop_rejected<rej_threshold & jacc_median_raw==1) %>%
                                          select(n_orfs)),
                        bad_cl_n = dim(cl_val_df %>%
                                         filter(prop_rejected >= rej_threshold | funct_annot!="noannot" & jacc_median_raw<1))[1],
                        bad_cl_orfs = sum(cl_val_df %>%
                                         filter(prop_rejected >= rej_threshold | funct_annot!="noannot" & jacc_median_raw<1) %>%
                                           select(n_orfs)),
                        cl_with_rej = dim(cl_val_df %>% filter(rejected>0))[1],
                        orfs_cl_with_rej = sum(cl_val_df %>% filter(rejected>0) %>% dplyr::select(n_orfs)),
                        cl_without_rejected = dim(cl_val_df %>% filter(rejected==0))[1],
                        orfs_cl_without_rej = sum(cl_val_df %>% filter(rejected==0) %>% dplyr::select(n_orfs)),
                        rejected_orfs = sum(cl_val_df$rejected),
                        comp_bad = dim(cl_val_df %>% filter(prop_rejected >= rej_threshold))[1],
                        comp_bad_orfs = sum(cl_val_df %>% filter(prop_rejected >= rej_threshold) %>% dplyr::select(n_orfs)),
                        bad_cl_rej_orfs = sum(cl_val_df %>% filter(prop_rejected >= rej_threshold) %>% dplyr::select(rejected)),
                        comp_good = dim(cl_val_df %>% filter(prop_rejected < rej_threshold))[1],
                        comp_good_orfs = sum(cl_val_df %>% filter(prop_rejected < rej_threshold) %>% dplyr::select(n_orfs)),
                        good_cl_rej_orfs = sum(cl_val_df %>% filter(prop_rejected < rej_threshold) %>% dplyr::select(rejected)),
                        func_good = dim(cl_val_df %>% filter(funct_annot!="noannot" & jacc_median_raw==1))[1],
                        func_bad = dim(cl_val_df %>% filter(funct_annot!="noannot" & jacc_median_raw<1))[1],
                        HA = dim(cl_val_df %>% filter(annot_categ=="HA"))[1],
                        MoDA = dim(cl_val_df %>% filter(annot_categ=="MoDA"))[1],
                        MuDA = dim(cl_val_df %>% filter(annot_categ=="MuDA"))[1],
                        stringsAsFactors = F)
write.table(val_stats, paste(args[1],"validation_stats.tsv",sep="/"), col.names = T, row.names = F, quote = F, sep = "\t")

# Good clusters name and representatives
good_cl <- cl_val_df %>%
  filter(funct_annot=="noannot" & prop_rejected < rej_threshold | funct_annot!="noannot" & prop_rejected < rej_threshold & jacc_median_raw==1) %>%
  dplyr::select(cl_name, new_repres, new_repres_annot,funct_annot, old_repres)
write.table(good_cl, paste(args[7],"/",args[9],"_good_cl.tsv",sep=""), col.names = T, row.names = F, quote = F, sep = "\t")

# PLOTS
# Functional validation results
cl_val_func <- cl_val_df %>% filter(funct_annot != "noannot")

#plot with trasparent background (change color parameters for white background)
#tiff("clstr_jacc_shingl_raw.tiff", width=2500,height=2000,units = 'px',res = 500, compression = 'lzw', bg = "transparent")
f_raw <- ggplot(cl_val_func, aes(jacc_median_raw)) +
  theme(axis.title.x  = element_text(size = 22),
        axis.text.x  = element_text(size = 20)) +
  theme_bw() + xlab("Similarity") + ylab("Density") +
  geom_density(fill="#18BE8C", colour="#068666", alpha=.8, adjust=0.4) +
  theme(axis.title = element_text(size = 16, colour="white"),
        axis.text = element_text(size=14, colour="white"),
        panel.border = element_rect(colour = "grey"),
        panel.background = element_rect(fill = "transparent",colour = NA), # or theme_blank()
        plot.background = element_rect(fill = "transparent",colour = NA))
#print(all)
#dev.off()
f_sc <- ggplot(cl_val_func, aes(jacc_median_sc)) +
  theme(axis.title.x  = element_text(size = 22),
        axis.text.x  = element_text(size = 20)) +
  theme_bw() + xlab("Similarity") + ylab("Density") +
  geom_density(fill="#18BE8C", colour="#068666", alpha=.8, adjust=0.4) +
  theme(axis.title = element_text(size = 16, colour="black"),
        axis.text = element_text(size=14, colour="black"))
        # panel.border = element_rect(colour = "grey"),
        # panel.background = element_rect(fill = "transparent",colour = NA), # or theme_blank()
        # plot.background = element_rect(fill = "transparent",colour = NA))
#ggsave("../MPI_notes/Projects/Marine_HMP/clstr_jacc_shingl_all.png", width = 5, height = 4)
save(f_raw,f_sc,file=paste(args[1],"funct_val_plots.rda",sep="/"))

# Compositional validation results
#With numbers in the labels
rej_desc <- data.frame(class = c("With rejected (249,506)", "Without rejected (2,754,391)"), num = c(dim(cl_val_df %>% filter(rejected>0))[1], dim(cl_val_df %>% filter(rejected==0))[1]))
#Without numbers
rej_desc1 <- data.frame(class = c("With rejected", "Without rejected"), num = c(dim(cl_val_df %>% filter(rejected>0))[1], dim(cl_val_df %>% filter(rejected==0))[1]))

# Number of clusters with and without rejected ORFs
p_desc <- ggplot(rej_desc, aes(class, num)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = scales::comma) +
  ylab("Number of clusters") +
  xlab("") +
  ggtitle("Clusters with rejected ORFs") +
  theme_light() +
  theme(plot.title = element_text(size=13),
        axis.text = element_text(size=11),
        axis.title = element_text(size=12))

# Prop. rejected ORFs vs number of clusters
# Number of remaining clusters after applying different thresholds
# based on the number of bad aligned ORFs per cluster.
p_rej_cl <- plyr::ldply(seq(0,1, 0.1), function(x) {data.frame(threshold = x, clusters = dim(cl_val_df %>% filter(rejected>0) %>% filter(prop_rejected >= x))[1])}) %>%
  ggplot(aes(threshold, clusters)) +
  geom_line() +
  geom_point() +
  ggrepel::geom_label_repel(aes(label = clusters), size = 3, box.padding = unit(0.4, "lines"),point.padding = unit(0.3, "lines")) +
  theme_light() +
  xlab("Proportion of rejected ORFs per cluster") +
  ylab("Number of clusters") +
  scale_y_continuous(labels = scales::comma) +
  scale_x_continuous(breaks = seq(0,1, 0.1), labels = scales::percent)

# Size distribution of the kept and rejected clusters.
p_size_rej <- ggplot(cl_val_df %>% filter(rejected>0,prop_rejected >= 0.1), aes(n_orfs, fill = "Rejected")) +
    geom_histogram(data = cl_val_df %>% filter(prop_rejected < 0.1), aes(n_orfs, fill = "Kept"), color = "white", size = 0.1) +
    geom_histogram(color = "white", size = 0.1) +
    theme_light() +
    xlab("Cluster size (log10)") +
    ylab("Number of clusters") +
    scale_x_log10() +
    scale_y_continuous(labels = scales::comma) +
    scale_fill_manual(values = c("#4A4A4A", "#F0D999"), name = "") +
    theme(legend.position = c(0.88, 0.85),
          axis.title = element_text(size=13),
          axis.text = element_text(size=11))

# Both validations results combined
cl_val_df$funct_annot <- factor(cl_val_df$funct_annot, levels = c("annot", "noannot"))
cl_val_df$annot_categ <- factor(cl_val_df$annot_categ, levels = c("HA", "MoDA", "MuDA", NA))

class_names <- c(
  `annot` = "Annotated",
  `noannot` = "Not annotated"
)

# Prop. rejected ORFs vs cluster size (divided by annotation type)
p_rej_size <- ggplot(cl_val_df, aes(prop_rejected,n_orfs)) +
  geom_jitter(alpha = 0.5) +
  geom_rug(data = cl_val_df, aes(color=funct_annot), alpha = 1/2, position = "jitter") +
  theme_light() +
  xlab("Proportion of rejected ORFs per cluster") +
  ylab("Cluster size (# of ORFs)") +
  scale_y_continuous(labels = scales::comma) +
  scale_x_continuous(labels = scales::percent)
  facet_wrap(~funct_annot)#, scales = "free", labeller = as_labeller(class_names), nrow = 1) +
  ggsci::scale_color_jco(name = "Cluster type", guide=FALSE)

# Prop. rejected ORFs vs average ORFs similarity (divided by annotation type)
# Relationship between the proportion of rejected ORFs identified by LEON-BIS
# and the average ORF similarity in each cluster (In red rejected clusters).
p_rej_simil <- ggplot(cl_val_df, aes(raw_mean_id/100, prop_rejected)) +
    geom_jitter(alpha = 0.5) +
    geom_jitter(data = cl_val_df %>% filter(prop_rejected >= 0.1), aes(raw_mean_id/100, prop_rejected, size = n_orfs), color = "#C84359", alpha = 0.5) +
    geom_rug(data = cl_val_df, aes(color=funct_annot), alpha = 1/2, position = "jitter") +
    theme_light() +
    ylab("Proportion of rejected ORFs per cluster") +
    xlab("Average ORF similarity per cluster") +
    scale_x_continuous(labels = scales::percent) +
    scale_y_continuous(labels = scales::percent) +
    facet_wrap(~annot_categ, scales = "free", nrow = 1) +
    ggsci::scale_color_jco(name = "Cluster type", labels = c("Annot.","Not annot.")) +
    scale_size_continuous(name = "Number of ORFs") +
    theme(axis.title = element_text(size = 13),
        axis.text = element_text(size = 11),
        strip.text = element_text(size=13),
        legend.text = element_text(size=11),
        legend.key.size = unit(1,"cm"),
        legend.title = element_text(size=13))

# Plots together
p_panel <- ggdraw() +
          draw_plot(p_desc, x = 0, y = .5, width = .30, height = .5) +
          draw_plot(p_rej_cl, x = .30, y = .5, width = .40, height = .5) +
          draw_plot(p_size_rej, x = .70, y = .5, width = .30, height = .5) +
          draw_plot(p_rej_simil, x = 0, y = 0, width = 1, height = .5) +
          draw_plot_label(label = c("a", "b", "c", "d"), size = 15,
                  x = c(0, 0.30, 0.70, 0), y = c(1, 1, 1, 0.53))

save(p_desc,p_size_rej, p_rej_cl, p_rej_simil, p_panel, file=paste(args[1],"comp_val_plots.rda",sep=""))
