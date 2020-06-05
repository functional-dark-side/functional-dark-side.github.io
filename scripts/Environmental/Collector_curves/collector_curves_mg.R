library(tidyverse)
library(data.table)
library(maditr)
library(pbmcapply)
library(unixtools)
library(profmem)
library(batchtools)

# MG (TARA, Malaspina, HMP) collector curves --------------------------------------------------------
# Create batchtools job registry
reg_dir_accum <- file.path(getwd(), paste(format(Sys.Date()), format(Sys.time(), "%H%M%S"), sep = "-"))
reg_data_accum <- makeRegistry(reg_dir_accum, seed=123, conf.file = "~/.batchtools.conf.R")

# Collector curves x sample/metagenome
# MG clusters x samples (input data: sample"\t"categ"_"cl_name)
cl_data_smpl <- fread("data/collector_curves/marine_hmp_smpl_cl_categ.tsv.gz", stringsAsFactors = F, header = F, nThread = 28) %>%
  setNames(c("sample","cl_name"))
# Filter for sample with at least 1K clusters
ok_smpl <- fread("data/collector_curves/listSamplesPaper.tsv")
cl_data_smpl <- cl_data_smpl %>% dt_filter(sample %in% ok_smpl$label)

# Prepare data
nsamples <- cl_data_smpl$sample %>% unique()
cl_data_smpl_idx <- nsamples %>%
  enframe(name = "idx", value = "sample") %>%
  as.data.table() %>% dt_inner_join(cl_data_smpl) %>%
  dt_mutate(cat = tstrsplit(cl_name, "_", fixed=TRUE)[1]) %>%
  select(-sample)

setkey(cl_data_smpl_idx, idx, verbose = TRUE)
permat <- vegan:::getPermuteMatrix(1000, nsamples)

# Collector curves function
col_curv <- function(X){
  setDTthreads(6)
  s <- permat[X,]
  p <- seq(from=0, to=length(nsamples), by = 10)
  p[1] <- 1
  p <- c(p, length(nsamples))
  l1 <- pbmclapply(p, function(Y){
    l <- cl_data_smpl_idx %>%
      dt_filter(idx %in% s[1:Y]) %>%
      dt_select(cl_name, cat) %>%
      data.table:::unique.data.table()  %>%
      dt_summarise(n = .N, by = c("cat")) %>%
      dt_select(cat, n) %>%
      data.table:::unique.data.table()

    l %>% add_row(cat = "all", n = sum(l$n)) %>% mutate(perm = X, size = Y)
  }, mc.cores = 6, mc.preschedule = TRUE)

  bind_rows(l1) %>% as_tibble()

}

# Run the collector curves function in parallel using batchtools to distribute jobs in the de.NBI cloud nodes
clearRegistry()
Njobs <- 1:1000
ids <- batchMap(fun=col_curv, X=Njobs, reg = reg_data_accum)
# two chunks of 5 jobs each
ids[, chunk := chunk(job.id, chunk.size = 10)]
batchExport(export = list(cl_data_smpl_idx = cl_data_smpl_idx,
                          nsamples = nsamples,
                          permat = permat),
            reg = reg_data_accum)

done <- submitJobs(ids,
                   reg=reg_data_accum,
                   resources=list(partition = "default",
                                  ncpus=5,
                                  walltime = "100:00:00",
                                  memory = "36G",
                                  ntasks = 1,
                                  chunks.as.arrayjobs = TRUE,
                                  omp.threads = 6),
)
waitForJobs(reg = reg_data_accum) # Wait until jobs are completed
getStatus(reg = reg_data_accum) # Summarize job status

# Collect and parse the results
cum_curve_res <- lapply(findDone()$job.id, loadResult, reg = reg_data_accum) %>%
bind_rows() %>% as_tibble() %>%
add_row(cat=c("EU","GU","KWP","K","all"),n=c(0,0,0,0,0),perm=c(0,0,0,0,0),size=c(0,0,0,0,0))

# Apply same function on communities
# MG communities x samples (input data: sample"\t"categ"_"comm_name)
com_data_smpl <- fread("data/collector_curves/marine_hmp_smpl_comm_categ.tsv.gz", stringsAsFactors = F, header = F, nThread = 28) %>%
  setNames(c("sample","comm"))

# Apply the same function using the number of ORFs instead of the samples
# MG cluster per orfs
cl_data_orfs <- fread("data/collector_curves/marine_hmp_orfs_cl_categ.tsv.gz", stringsAsFactors = F, header = F, nThread = 28) %>%
  setNames(c("cl_name","orf"))

norfs <- cl_data_smpl$orfs %>% unique()

cl_data_orf_idx <- norfs %>%
  enframe(name = "idx", value = "orf") %>%
  as.data.table() %>% dt_inner_join(cl_data_orfs) %>%
  dt_mutate(cat = tstrsplit(cl_name, "_", fixed=TRUE)[1]) %>%
  select(-orf)

setkey(cl_data_orf_idx, idx, verbose = TRUE)
permat <- vegan:::getPermuteMatrix(10, norfs)

# Collector curves function, same commands, only different p and different resources for the batch jobs (due to the large number of ORFs)
col_curv <- function(X){
  setDTthreads(6)
  s <- permat[X,]
  p <- exp(seq(log(1), log(length(norfs)), length.out = 9))
  l1 <- pbmclapply(p, function(Y){
    l <- cl_data_orf_idx %>%
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
batchExport(export = list(cl_data_smpl_idx = cl_data_orf_idx,
                          nsamples = norfs,
                          permat = permat),
            reg = reg_data_accum)

done <- submitJobs(ids,
                   reg=reg_data_accum,
                   resources=list(partition = "default",
                                  ncpus=7,
                                  walltime = "100:00:00",
                                  memory = "60G",
                                  ntasks = 1,
                                  chunks.as.arrayjobs = TRUE,
                                  omp.threads = 6),
)

waitForJobs(reg = reg_data_stats) # Wait until jobs are completed
getStatus(reg = reg_data_stats) # Summarize job status

# Plotting
# (Example with the increase in the number of clusters with metagenomic samples)
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
  xlab("Number of samples") + ylab("Mean number of clusters") + ggtitle("MG clusters") +
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
