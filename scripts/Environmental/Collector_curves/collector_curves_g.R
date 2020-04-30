library(tidyverse)
library(data.table)
library(maditr)
library(pbmcapply)
library(unixtools)
library(profmem)

# Genomic (GTDB) data collector curves -------------------------------------------------------------
# Create batchtools job registry
reg_dir_accum <- file.path(getwd(), paste(format(Sys.Date()), format(Sys.time(), "%H%M%S"), sep = "-"))
reg_data_accum <- makeRegistry(reg_dir_accum, seed=123, conf.file = ".batchtools.conf.R")

# Files are stored in data/collector_curves
# GTDB cluster data
lo_env$cl_data <-
  fread(
    "all_gtdb_genome_orf_cl_categ.tsv.gz",
    header = FALSE,
    col.names = c(
      "genome",
      "domain",
      "orf",
      "cl_name"
    )
  )

# GTDB cluster community data
lo_env$com_data <-
  fread(
    "all_gtdb_genome_orf_comm_categ.tsv.gz",
    header = FALSE,
    col.names = c(
      "genome",
      "domain",
      "orf",
      "comm"
    )
  )

# Increase in number of clusters with the nummber of genomes
## for the commmunity curves just replace "cl_name" with "comm"
cl_data_kept <-
  lo_env$cl_data %>%
  dt_select(genome, cl_name) %>%
  dt_summarise(n = .N, by = list(cl_name, genome))

cl_data_kept <-
  cl_data_kept %>% setnames(old = "genome",
                            new = "tip",
                            skip_absent = TRUE)

ngenomes <- cl_data_kept$tip %>% unique()

cl_data_kept_idx <- ngenomes %>%
  enframe(name = "idx", value = "tip") %>%
  as.data.table() %>% dt_inner_join(cl_data_kept) %>%
  dt_mutate(cat = tstrsplit(cl_name "_", fixed=TRUE)[1]) %>%
  select(-tip, -n)

setkey(cl_data_kept_idx, idx, verbose = TRUE)
permat <- vegan:::getPermuteMatrix(10, ngenomes)
rm(cl_data_kept) # Make space...
gc()

# Collector curves function
col_curv <- function(X){
  setDTthreads(8)

  s <- permat[X,]
  p <- seq(from=1, to=length(ngenomes), by = 10)
  l1 <- pbmclapply(p, function(Y){
    l <- cl_data_kept_idx %>%
      dt_filter(idx %in% s[1:Y]) %>%
      dt_select(cl_name, cat) %>%
      data.table:::unique.data.table()  %>%
      dt_summarise(n = .N, by = c("cat")) %>%
      dt_select(cat, n) %>%
      data.table:::unique.data.table()

      l %>% add_row(cat = "all", n = sum(l$n)) %>% mutate(perm = X, size = Y)
  }, mc.cores = 8, mc.preschedule = TRUE)

  bind_rows(l1) %>% as_tibble()

}

clearRegistry()
Njobs <- 1:100
ids <- batchMap(fun=col_curv, X=Njobs, reg = reg_data_accum)
# two chunks of 5 jobs each
ids[, chunk := chunk(job.id, chunk.size = 10)]
batchExport(export = list(cl_data_kept_idx = cl_data_kept_idx,
                          ngenomes = ngenomes,
                          permat = permat),
            reg = reg_data_accum)

done <- submitJobs(ids,
                   reg=reg_data_accum,
                   resources=list(partition = "default",
                                  ncpus=9,
                                  walltime = "100:00:00",
                                  memory = "75G",
                                  ntasks = 1,
                                  chunks.as.arrayjobs = TRUE,
                                  omp.threads = 8),
)
waitForJobs(reg = reg_data_accum) # Wait until jobs are completed
getStatus(reg = reg_data_accum) # Summarize job status

cum_curve_res <- lapply(findDone()$job.id, loadResult, reg = reg_data_accum) %>% bind_rows() %>% as_tibble()

# Get genome stats of each permutation ------------------------------------
genome_stats <- fread("gtdb_genomes_info.tsv.gz")

genome_stats <- cl_data_kept %>% group_by(tip) %>%
  count(name = "n_clusters") %>%
  inner_join(genome_stats %>% dplyr::rename(tip = genome))

genome_stats <- ngenomes %>%
  enframe(name = "idx", value = "tip") %>%
  dt_inner_join(genome_stats) %>% as.data.table()

setkey(genome_stats, idx, verbose = TRUE)

col_stats <- function(X){
  setDTthreads(6)

  l1 <- pbmclapply(1:nrow(permat), function(Y){
    perm <- permat[Y,]
    genome_stats %>%
      dt_filter(idx %in% perm[1:p[X]]) %>%
      mutate(perm = Y, size = p[X]) %>% as_tibble()
  }, mc.cores = 6, mc.preschedule = TRUE)

  bind_rows(l1) %>%
    as_tibble() %>%
    select(n_clusters, n_orfs, gc_content, gc_percentage, genome_size) %>%
    summarise_all(list(~min(.), ~max(.), ~mean(.), ~median(.), ~sd(.), ~mad(.))) %>%
    mutate(size = p[X]) %>% as_tibble()
}

# New registry
reg_dir_stats <- file.path(getwd(), paste(format(Sys.Date()), format(Sys.time(), "%H%M%S"), sep = "-"))
reg_data_stats <- makeRegistry(reg_dir_stats, seed=123, conf.file = "~/.batchtools.conf.R")

# execute over the vector with genome indices
p <- seq(from=1, to=length(ngenomes), by = 99)

Njobs <- 1:length(p) # Define number of jobs (here 4)

ids <- batchMap(fun=col_stats, X=Njobs, reg = reg_data_stats)
# two chunks of 5 jobs each
ids[, chunk := chunk(job.id, chunk.size = 100)]
batchExport(export = list(cl_data_kept_idx = cl_data_kept_idx,
                          permat = permat,
                          genome_stats = genome_stats,
                          p = p),
            reg = reg_data_stats)

done <- submitJobs(ids,
                   reg=reg_data_stats,
                   resources=list(partition = "default",
                                  ncpus=5,
                                  walltime = "100:00:00",
                                  memory = "36G",
                                  ntasks = 1,
                                  chunks.as.arrayjobs = TRUE,
                                  omp.threads = 6),
)
waitForJobs(reg = reg_data_stats) # Wait until jobs are completed
getStatus(reg = reg_data_stats) # Summarize job status

cum_stats_res <- lapply(findDone()$job.id, loadResult) %>% bind_rows() %>% as_tibble()


## GTDB ORFs
cl_data_kept <-
  lo_env$cl_data %>%
  dt_select(orf, cl_name) %>%
  dt_summarise(n = .N, by = list(cl_name, orf))

cl_data_kept <-
  cl_data_kept %>% setnames(old = "orf",
                            new = "tip",
                            skip_absent = TRUE)

norfs <- cl_data_kept$tip %>% unique()

cl_data_kept_idx <- norfs %>%
  enframe(name = "idx", value = "tip") %>%
  as.data.table() %>% dt_inner_join(cl_data_kept) %>%
  dt_mutate(cat = tstrsplit(cl_name "_", fixed=TRUE)[1]) %>%
  select(-tip, -n)

setkey(cl_data_kept_idx, idx, verbose = TRUE)
permat <- vegan:::getPermuteMatrix(10, norfs)
rm(cl_data_kept) # Make space...
gc()

# Collector curves function
col_curv <- function(X){
  setDTthreads(8)

  s <- permat[X,]
  p <- exp(seq(log(1), log(length(norfs)), length.out = 9))
  l1 <- pbmclapply(p, function(Y){
    l <- cl_data_kept_idx %>%
      dt_filter(idx %in% s[1:Y]) %>%
      dt_select(cl_name, cat) %>%
      data.table:::unique.data.table()  %>%
      dt_summarise(n = .N, by = c("cat")) %>%
      dt_select(cat, n) %>%
      data.table:::unique.data.table()

      l %>% add_row(cat = "all", n = sum(l$n)) %>% mutate(perm = X, size = Y)
  }, mc.cores = 8, mc.preschedule = TRUE)

  bind_rows(l1) %>% as_tibble()
}

# Plotting
# (Example with the increase in the number of clusters with genomes)
cum_curve_res %>%
  mutate(cat = case_when(cat == "all" ~ "All",
                         cat == "K" | cat == "KWP" ~ "Known",
                         TRUE ~ "Unknown")) %>%
  group_by(cat, size, perm) %>%
  summarise(n = sum(n)) %>%
  ungroup() %>%
  group_by(cat, size) %>%
  summarise(N = n(),
            mean = mean(n),
            median = median(n),
            min = min(n),
            max = max(n),
            sd = sd(n)) %>%
  mutate(sem = sd / sqrt(N - 1),
         CI_lower = mean + qt((1-0.95)/2, N - 1) * sem,
         CI_upper = mean - qt((1-0.95)/2, N - 1) * sem) %>%
ggplot(aes(x=size, y=mean, color = cat, group = cat)) +
  xlab("Number of genomes") + ylab("Mean number of clusters") + ggtitle("Genomic clusters") +
  geom_ribbon(aes(x=size,ymin=mean-sd,ymax=mean+sd, group = cat,fill=cat), alpha = 0.3,  color = "grey70", size=.2) +
  geom_line(aes(x=size, y=mean, color = cat), size = 0.5) +
  scale_fill_manual(values = c("#439E7D","#233B43","#E84646")) +
  scale_color_manual(values = c("#439E7D","#233B43","#E84646")) +
  scale_x_continuous(labels=scales::comma) +
  scale_y_continuous(labels = scales::comma) +
  theme(legend.text = element_text(size = 7),
        legend.position = "right",
        legend.key.size = unit(.3,"cm"),
        legend.title = element_blank(),
        axis.text = element_text(size=7),
        axis.title = element_text(size=7),
        plot.title = element_text(size=8))
