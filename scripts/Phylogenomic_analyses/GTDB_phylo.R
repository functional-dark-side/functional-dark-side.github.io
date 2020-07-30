# Scripts adapted from https://bitbucket.org/doxeylabcrew/annotree-manuscript-scripts/src
library(tidyverse)
library(data.table)
library(maditr)
library(ape)
library(phangorn)
library(pbmcapply)
library(unixtools)

# Script setup used to run the analyses in the de.NBI cloud
#setwd("/vol/cloud/gtdb/phylo_analyses/data")
#set.tempdir("/vol/cloud/gtdb/phylo_analyses/tmp")

# Set some variable -------------------------------------------------------
setDTthreads(28)
# Get dedup files
lo_env <- new.env()

# Gather data -------------------------------------------------------------
# Data stored in data/GTDB
# All GTDB ORFs, included those in MG clusters (3,270,101 clusters, and 75,297,319 ORFs)
lo_env$cl_data <-
  fread(
    "/vol/scratch/gtdb/mg_gtdb_kept_cluster_genome_orf_categ.tsv.gz",
    header = FALSE,
    col.names = c(
      "genome",
      "domain",
      "orf",
      "cl_name"
    )
  )

# GTDB contextual data (the example is for bacterial genomes, same data are available also for the archaea)
gtdb_cdata <-
  fread("gtdb_data/arc_metadata_r86.tsv", #"gtdb_data/bac_metadata_r86.tsv"
        header = TRUE,
        sep = "\t")

# GTDB tree
tree <- read.tree("gtdb_data/gtdb_r86_ar.tree") #"gtdb_data/gtdb_r86_bac.tree"
node_depths <- node.depth.edgelength(tree)

# GTDB taxonomy
gtdb_tax <-
  read.delim(
    "gtdb_data/arc_taxonomy_r86.tsv", #"gtdb_data/bac_taxonomy_r86.tsv"
    row.names = NULL,
    header = FALSE,
    col.names = c("genome", "taxonomy_string")
  )

# Prepare taxonomy data
gtdb_tax <- gtdb_tax[match(tree$tip.label,
                           gtdb_tax$genome), ]
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
gtdb_tax <- cbind(gtdb_tax, parsed_ranks)

tax_levels <- colnames(gtdb_tax)[4:ncol(gtdb_tax)]
# order: "phylum"  "class"   "order"   "family"  "genus"   "species"
get_level_index <- function(level) {
  return(which(level == tax_levels))
}

# Get number of taxa below each node
leaf_counts <-
  setNames(sapply(prop.part(tree), length), 1:tree$Nnode)

node_tax_levels <- read_tsv("gtdb_data/node_tax_levels_arc_r86.tsv", col_names = TRUE) #"gtdb_data/node_tax_levels_bac_r86.tsv"
tax_levels <-
  c(
    d = "Domain",
    p = "Phylum",
    c = "Class",
    o = "Order",
    f = "Family",
    g = "Genus",
    s = "Species"
  )

########################
## Optional Prep
########################

# Get all tip ancestors to speed up F1 score computation
tip_ancestors <-
  sapply(1:length(tree$tip.label), function(tip_index) {
    return(phangorn::Ancestors(tree, tip_index, type = "all"))
  })

# Prepare cluster data ----------------------------------------------------
# Get number of ORFs per genome
orf_genome <- lo_env$cl_data %>%
  dt_select(genome) %>%
  dt_mutate(n_orfs = .N, by = genome) %>%
  unique()

orf_genome$n_orfs %>% summary()

lo_env$cl_data <- lo_env$cl_data %>%
  dt_mutate(categ=tstrsplit(cl_name, "_", fixed=TRUE)[1]) %>%
  dt_select(genome, cl_name, categ) %>%
  dt_mutate(categ = ifelse((categ != "K" &
                              categ != "KWP" &
                              categ != "GU" & categ != "EU"),
                           "NO_HIT",
                           categ
  )) %>%
  dt_filter(genome %in% tree$tip.label)

# check we have all tips in our data set
all.equal((lo_env$cl_data$genome %>% unique() %>% sort),
          (tree$tip.label %>% sort()))

cl_to_keep <- lo_env$cl_data %>%
  dt_filter(categ != "NO_HIT") %>%
  dt_summarise(nobs = .N, by = cl_name) %>%
  dt_filter(nobs >= 1)

cl_data_kept <-
  lo_env$cl_data %>%
  dt_filter(cl_name %in% cl_to_keep$cl_name) %>%
  dt_summarise(n = .N, by = list(genome, cl_name))


#################################################
## Prepare tree and taxonomy
#################################################

cl_data_kept <-
  cl_data_kept %>% setnames(old = "genome",
                            new = "tip",
                            skip_absent = TRUE)

cls <- cl_data_kept$cl_name %>% unique()

# Let's create a table with the genomes and the clusters
# As the number of columns are very high we will do in
# multiple steps

# Split cluster in 10K lists
list_cls <- split(cls, (seq(length(cls)) - 1) %/% 1e2)

# Get lineage specificity score (F1-score) function:
# Source functions contained in the file phylo_functions.R
get_f1 <- function(x) {
  require(maditr)
  require(ape)
  require(tidyverse)
  library(pbmcapply)
  library(castor)
  library(furrr)

  source("phylo_functions.R")

  message("Creating incidence matrix...")

  tip_labels <- tree$tip.label

  X <- list_cls[[x]]

  tips <-
    expand.grid(tip_labels, X) %>%
    as.data.table() %>%
    setnames(old = c("Var1", "Var2"), new = c("tip", "cl_name"))

  tips$tip <- as.character(tips$tip)
  tips$cl_name <- as.character(tips$cl_name)

  tmp <- cl_data_kept %>%
    dt_filter(cl_name %in% X) %>%
    dt_right_join(tips) %>%
    dt_mutate(n = case_when(n >= 1 ~ 1,
                            is.na(n) ~ 0,
                            TRUE ~ 0)) %>%
    data.table::dcast(tip ~ cl_name, fill = 0, value.var = "n") %>%
    as.data.frame()

  tmp <- tmp[match(tree$tip.label, tmp$tip),]

  rownames(tmp) <- tmp$tip
  tmp$tip <- NULL
  cols <- (intersect(X, colnames(tmp)))
  tmp <- subset(tmp, cols %in% colnames(tmp))

  message("Calculating F1...")
  f1scores.max.cl <-
    pbmclapply(colnames(tmp), function(trait_profile) {
      return(
        f1score.trait(
          trait_profile,
          tree,
          reduced = TRUE,
          tip_ancestors = tip_ancestors,
          states = tmp
        )
      )
    },
    mc.cores = 6,
    mc.preschedule = TRUE)

  names(f1scores.max.cl) <- colnames(tmp)
  message("Gathering F1 results...")
  # Combine scores
  f1scores.max.cl <-
    do.call(rbind,
            pbmclapply(
              f1scores.max.cl,
              data.frame,
              mc.cores = 6,
              mc.preschedule = TRUE
            ))
  message("Calculating TauD...")

  Y <- tmp[,1]

  tauD <-
    pbmclapply(colnames(tmp), function(trait_profile) {
      get_trait_depth(tip_states = tmp[, trait_profile], tree = tree, Npermutations = 1000)
    },
    mc.cores = 6,
    mc.preschedule = TRUE)

  names(tauD) <- colnames(tmp)

  tauD <- map_dfr(tauD, `[`, c("mean_depth", "var_depth", "min_depth", "max_depth", "P", "mean_random_depth"), .id = "cl_name")

  results <- f1scores.max.cl %>%
    as_tibble(rownames = "cl_name") %>%
    mutate(f1_score = round(f1_score, 6)) %>%
    inner_join(tauD) %>%
    rename(trait = cl_name)
  message("done...")
  return(results)
}

# Distribute jobs in the cluster nodes (de.NBI cloud) using batchtools
library(batchtools)
# Create the job registry
reg_dir_f1 <- file.path(getwd(), paste(format(Sys.Date()), format(Sys.time(), "%H%M%S"), sep = "-"))
reg_data_f1 <- makeRegistry(reg_dir_f1, seed=123, conf.file = ".batchtools.conf.R")
# Define number of jobs (here 4)
Njobs <- 1:length(list_cls)
ids <- batchMap(fun=get_f1, x=Njobs)
# two chunks of 5 jobs each
ids[, chunk := chunk(job.id, chunk.size = 100)]
batchExport(export = list(tree = tree,
                          cl_data_kept = cl_data_kept,
                          list_cls = list_cls,
                          tip_ancestors = tip_ancestors),
            reg = reg_data_f1)

done <- submitJobs(ids,
                   reg=reg_data_f1,
                   resources=list(partition = "debug",
                                  ncpus=5,
                                  walltime = "100:00:00",
                                  memory = "36G",
                                  ntasks = 1,
                                  chunks.as.arrayjobs = TRUE,
                                  omp.threads = 6),
)
waitForJobs(reg = reg_data_f1) # Wait until jobs are completed
getStatus(reg = reg_data_f1) # Summarize job status
f1scores.max.cl <- map_dfr(Njobs, loadResult, reg = reg_data_f1) %>% as_tibble()

write_tsv(
  f1scores.max.cl,
   "new_results/max_f1_scores_per_node.gtdb_arc_r86.tsv"
)
saveRegistry(reg = reg_data_f1)

# Make a descriptive table with F1 scores and taxonomic info
get_lineages <- function(x) {
  library(tidyverse)
  source("phylo_functions.R")
  map_dfr(list_nodes[[x]], function(X){
    node_index <- X
    node_lineage_vec <- node_tax_levels[match(node_index,
                                              node_tax_levels$node_index),
                                        2:ncol(node_tax_levels)]
    node_lineage_vec <- as.vector(unlist(node_lineage_vec))
    names(node_lineage_vec) <-
      colnames(node_tax_levels)[2:ncol(node_tax_levels)]
    lineage_string <- vector2lineage_string(node_lineage_vec)
    return(tibble(node_index = node_index, lineage = lineage_string))
  })
}

reg_dir_lin <- file.path(getwd(), paste(format(Sys.Date()), format(Sys.time(), "%H%M%S"), sep = "-"))
reg_data_lin <- makeRegistry(reg_dir_lin, seed=123, conf.file = ".batchtools.conf.R")

node_indices <- f1scores.max.cl$node_index %>% unique()
list_nodes <- split(node_indices, (seq(length(node_indices)) - 1) %/% 1e4)
# Define number of jobs (here 4)
Njobs <- 1:length(list_nodes)
ids <- batchMap(fun=get_lineages, x=Njobs, reg = reg_data_lin)
# two chunks of 5 jobs each
ids[, chunk := chunk(job.id, chunk.size = 50)]
batchExport(export = list(node_tax_levels = node_tax_levels,
                          list_nodes = list_nodes),
            reg = reg_data_lin)

done <- submitJobs(ids,
                   reg=reg_data_lin,
                   resources=list(partition = "debug",
                                  ncpus=1,
                                  walltime = "100:00:00",
                                  memory = "36G",
                                  ntasks = 1,
                                  chunks.as.arrayjobs = TRUE),
)
waitForJobs(reg = reg_data_lin) # Wait until jobs are completed
getStatus(reg = reg_data_lin) # Summarize job status

cl_lineages <- map_dfr(Njobs, loadResult, reg = reg_data_lin)

f1score.out_table.cl <- f1scores.max.cl %>%
  inner_join(cl_lineages) %>%
  arrange(desc(f1_score))

write_tsv(
  f1score.out_table.cl,
  "new_results/f1_scores.gtdb_arc_r86.tsv"
)


f1score.out_table.cl_filt <- f1score.out_table.cl %>%
  as_tibble() %>%
  filter(
   (n_present_tips.phylo < (length(tree$tip.label) / 2)),
      (n_present_tips.phylo > 1),
      (f1_score > 0.95)
  )

get_rank_level <- function(lineage) {
  lineage_vector <- strsplit(lineage, split = "__|;")[[1]]
  lowest_rank <- lineage_vector[length(lineage_vector)]
  lowest_level <-
    tax_levels[lineage_vector[length(lineage_vector) - 1]]
  return(tibble(lineage = lineage, lowest_rank = lowest_rank, lowest_level = lowest_level))
}

f1score.out_table.cl_filt_rank_level <- pmap_dfr(f1score.out_table.cl_filt %>%
                                                   select(lineage) %>%
                                                   distinct(), get_rank_level)

f1score.out_table.cl_filt_lowest_rank_level <- f1score.out_table.cl_filt %>%
  inner_join(f1score.out_table.cl_filt_rank_level) %>%
  separate(
    trait,
    into = "categ",
    sep = "_",
    remove = F,
    extra = "drop"
  )

write_tsv(
  f1score.out_table.cl_filt_lowest_rank_level,
  "new_results/filtered_f1_scores_lowest_levels_ranks.gtdb_arc_r86-1.tsv"
)
nrow(f1score.out_table.cl_filt_lowest_rank_level)
read_tsv("new_results/filtered_f1_scores_lowest_levels_ranks.gtdb_arc_r86-1.tsv") %>% nrow()

write_tsv(
  f1score.out_table.cl_filt,
  "new_results/filtered_f1_scores.gtdb_arc_r86-1.tsv"
)

# save(
#   f1score.out_table.cl,
#   tree,
#   gtdb_tax,
#   f1,
#   cl_annotation_plot.df,
#   tax_levels,
#   file = "new_results/gtdb_arc_r86_plot.Rda"  #"gtdb_bac_r86_plot.Rda"
# )
