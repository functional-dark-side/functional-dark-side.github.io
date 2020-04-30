load_libraries <- function(packages){
  lapply(packages, library, character.only = TRUE)
}

create_tmp <- function(tmp){
  TMP <- file.path(tmp, "R")
  if(!dir.exists(path.expand(TMP))) dir.create(path.expand(TMP), recursive = TRUE)
  unixtools::set.tempdir(path.expand(TMP))
}

msg <- function(X){
  cat(crayon::white(paste0("[",format(Sys.time(), "%T"), "]")), X)
}

msg_sub <- function(X){
  cat(crayon::white(paste0("  [",format(Sys.time(), "%T"), "]")), X)
}

get_stats_nb <- function(X){
  msg("Getting global stats...")
  Y <- X %>%
    ungroup() %>%
    setNames(c("name", "categ", "label", "abund", "prop")) %>%
    group_by(label) %>%
    mutate(relative_abund = (abund/sum(abund))) %>%
    ungroup() %>%
    group_by(name) %>%
    mutate(mean_proportion = mean(relative_abund), occurrence = n()) %>%
    ungroup()
  cat(" done\n")
  
  # Rounding function
  myround <- function(x) { trunc(x + 0.5) }
  # Round scale and round component abunddances
  msg("Rounding count values...")
  data <- Y %>% mutate(abund = myround(abund))
  # Filter for mean_prop > 2e-5
  cat(" done\n")
  return(data)
}

majority_vote <- function (x, seed = 12345) {
  set.seed(seed)
  whichMax <- function(x) {
    m <- seq_along(x)[x == max(x, na.rm = TRUE)]
    if (length(m) > 1)
      sample(m, size = 1)
    else m
  }
  x <- as.vector(x)
  tab <- table(x)
  m <- whichMax(tab)
  out <- list(table = tab, ind = m, majority = names(tab)[m])
  return(out)
}

get_nb <- function(Z){
  library(pbmcapply)
  library(tidyverse)
  library(spaa)
  library(vegan)
  get_random <- function(X, Y){
    y <- Y[rand_samples[[S]]$samples, as.character(X)]
    y <- y[ ,which(colSums(y) > 0)]
    y <- y[which(rowSums(y) > 0), ]
    
    cat(paste0("Number of samples in the reduce set: ", nrow(y), "\n"))
    cat(paste0("Number of variable in the reduce set: ", ncol(y), "\n\n"))
    
    null <- nullmodel(y, method = "quasiswap_count")
    res <- simulate(null, nsim=1)
    l <- niche.width(res,  method = "levins") %>%
      t() %>% 
      as.data.frame() %>% 
      as_tibble(rownames = "name") %>%
      mutate(name = gsub(".sim_1", "", name)) %>% 
      rename(value = V1)
    return(l)
  }
  pbmclapply(list_cls, get_random, Y = comm.tab, mc.cores = 28) %>% bind_rows() %>% mutate(iter = Z)
}

# Calculate Levin's niche breadth -----------------------------------------

# Filter low abundance gCl/gClCo
# Group samples based on BC
# Find clusters of samples
# Random pick sample one member for each the clusters (x100)
# Split matrices by gcCl/gCLCo
# Build null model [quasiswap] (x100)
# Calculate lNB
# Reduce results
# Get summaries
# Assign by majority vote Narrow, NS, Broad

parNB_all <- function(data, thresh = 1e-5){
  msg(paste0("Filtering variables with mean proportion <= ", thresh, "..."))
  data_filtered <- data %>%
    filter(mean_proportion > thresh)
  cat(" done\n")
  # Spread into matrix
  msg("Creating data frame with counts...")
  data_filtered_df <- data_filtered %>%
    select(label, name, abund) %>%
    #setNames(c("label", "name", "abund")) %>%
    spread(name, abund, fill = 0) %>%
    as.data.frame()
  # make label the rownames
  rownames(data_filtered_df) <- data_filtered_df$label
  data_filtered_df$label <- NULL
  
  # fix up matrix
  comm.tab <- data_filtered_df
  comm.tab <- comm.tab[ ,which(colSums(comm.tab) > 0)]
  comm.tab <- comm.tab[which(rowSums(comm.tab) > 0), ]
  cat(" done\n")
  msg("Creating data frame with proportions...")
  data_filtered_p_df <- data_filtered %>%
    select(label, name, relative_abund) %>%
    #setNames(c("label", "name", "relative_abund")) %>%
    spread(name, relative_abund, fill = 0) %>%
    as.data.frame()
  # make label the rownames
  rownames(data_filtered_p_df) <- data_filtered_p_df$label
  data_filtered_p_df$label <- NULL
  data_filtered_p_df <- data_filtered_p_df[ ,which(colSums(data_filtered_p_df) > 0) ]
  data_filtered_p_df <- data_filtered_p_df[which(rowSums(data_filtered_p_df) > 0 ), ]
  cat(" done\n\n")
  
  cat(paste0("Number of samples: ", nrow(comm.tab), "\n"))
  cat(paste0("Number of variable: ", ncol(comm.tab), "\n\n"))
  # Calculate sample dissimilarity and get clusters
  msg("Calculating Bray-Curtis dissimilarity between samples...")
  bc <- parDist(as.matrix(data_filtered_p_df), method = "bray", threads = 28)
  cat(" done\n")
  
  msg("Finding clusters of samples using Dynamic Cut Tree...")
  dTC <- cutreeDynamic(dendro = hclust(bc, method = "average"), 
                       distM = as.matrix(bc), 
                       minClusterSize = 2, 
                       pamStage = TRUE,
                       deepSplit = 4)
  
  smpl_cl <- data.frame(label = colnames(as.matrix(bc)), group = dTC) %>% as_tibble()
  n_smpl_cl <- smpl_cl$group %>% uniqueN()  
  cat(" done\n")
  
  msg(paste0("Found ", n_smpl_cl, " clusters\n"))
  # Sample 1 random member of the sample clusters
  nsamp <- 10
  msg(paste0("Generating ", nsamp, " random set of samples from the sample-clusters..."))
  rand_samples <- map(1:nsamp, function(X) {
    samples <- smpl_cl %>% 
      group_by(group) %>% 
      sample_n(1) %>% 
      .$label %>% 
      droplevels()
    sample_counts <- samples_analyses %>% filter(label %in% samples) %>% group_by(study) %>% count()
    list(samples = samples, sample_counts = sample_counts)
  })
  cat(" done\n")
  

  msg("Starting Niche Breadth analysis...\n")
  res <- map(1:nsamp, function(S){
    
    block <- 1000
    msg(paste0("Splitting variables in blocks of ", block, "...\n"))
    # Split the clusters in blocks of 1000
    msg_sub(paste0("Randomizing order of variables..."))
    cls <- sample(colnames(comm.tab))
    cat(" done\n")
    list_cls <- split(cls, (seq(length(cls)) - 1) %/% block)
    msg(paste0("Splitting variables in blocks of ", block, "... done\n"))
    
    library(batchtools)
    msg(paste0("Runing set of samples ", S,"...\n"))
    reg_dir <- file.path(getwd(), "tmp" ,paste(format(Sys.Date()), format(Sys.time(), "%H%M%S"), sep = "-"))
    reg_data <- makeRegistry(reg_dir, seed=123, conf.file = "~/.batchtools.conf.R")
    #clearRegistry()
    
    Njobs <- 1:100 # Define number of jobs (here 4)
    ids <- batchMap(fun = get_nb, Z = Njobs)
    
    # two chunks of 5 jobs each
    ids[, chunk := chunk(job.id, chunk.size = 25)]
    batchExport(export = list(comm.tab = comm.tab,
                              list_cls = list_cls,
                              rand_samples = rand_samples,
                              S = S),
                reg = reg_data)
    
    done <- submitJobs(ids,
                       reg=reg_data,
                       resources=list(partition = "debug",
                                      ncpus=28,
                                      walltime = "100:00:00",
                                      memory = "200G",
                                      ntasks = 1,
                                      chunks.as.arrayjobs = TRUE,
                                      omp.threads = 28),
    )
    waitForJobs() # Wait until jobs are completed
    getStatus() # Summarize job status
    nb <- map_dfr(Njobs, loadResult) 
    
    # calculate the real niche breadth from the original response matrix
    z <- comm.tab[rand_samples[[S]]$samples,]
    z <- z[ ,which(colSums(z) > 0)]
    z <- z[which(rowSums(z) > 0), ]
    
    nb_emp <- niche.width(z, method = "levins") %>%
      t() %>% 
      as.data.frame() %>% 
      as_tibble(rownames = "name") %>%
      rename(observed = V1)
    
    # Calculate mean
    results <- nb %>% 
      group_by(name) %>% 
      summarise(mean = mean(value),
                lowCI = quantile(value, probs = 0.025)[1],
                upCI = quantile(value, probs = 0.0975)[1]) %>%
      inner_join(nb_emp) %>% 
      mutate(sign = case_when(observed > upCI ~ 'Broad',
                              observed < lowCI ~ 'Narrow',
                              observed >= lowCI & observed <= upCI ~ 'Non significant'),
             set = S)
    msg(paste0("Runing set of samples ", S,"... done\n"))
    return(results)
  })
  msg("Niche Breadth analysis... done\n")
  return(res)
}
