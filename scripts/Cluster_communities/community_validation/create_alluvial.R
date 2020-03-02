#!/usr/bin/env Rscript

# Check if basic packages are installed -----------------------------------

is.installed <- function(pkg){
  is.element(pkg, installed.packages()[,1])
}

if (!is.installed("crayon") || !is.installed("optparse")){
  cat("We will try to install the packages crayon and optparse... (this will be only be done once)\n")
  Sys.sleep(5)
  if (!is.installed("crayon")){
    suppressMessages(install.packages("crayon", repos = "http://cran.us.r-project.org"))
  }
  suppressMessages(library(crayon))
  if (!is.installed("optparse")){
    suppressMessages(install.packages("optparse", repos = "http://cran.us.r-project.org"))
  }
}

suppressMessages(library(crayon))
suppressMessages(library(optparse))


# Check if packaged are installed -----------------------------------------

cat("\nChecking if all packages are installed...\n\n")

needed = c("magrittr", "tidyverse", "pbmcapply", "maditr", "data.table")

missing_package <- FALSE
# For loop to run through each of the packages
for (p in 1:length(needed)){
  if(is.installed(needed[p])){
    cat(sprintf("%-10s: %s", needed[p], green("Installed\n")))
  }else{
    cat(sprintf("%-10s: %s", needed[p], red("Not installed\n")))
    missing_package <- TRUE
  }
}

quit_not_installed <- function(){
  cat("\nMissing packages, please install them.\n")
  quit(save = "no", status = 1)
}

if (missing_package) {
  quit_not_installed()
}else{
  cat("\nAll packages installed.\n")
}

Sys.sleep(2)
system("clear")


# Script command line options ---------------------------------------------

option_list = list(
  make_option(c("-d", "--data"), type="character", default=NULL,
              help="ORF data filename", metavar="character"),
  make_option(c("-p", "--threads"), type="integer", default=1,
              help="Number of threads [default= %default]", metavar="integer"),
  make_option(c("-c", "--components"), type="character", default=NULL,
              help="Iutput file name [default= %default]", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="alluvial.tsv",
              help="Output file name [default= %default]", metavar="character")
)

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);


if (is.null(opt$data)){
  print_help(opt_parser)
  stop("At least one arguments must be supplied (tree file and contextual data files).n", call.=FALSE)
}

suppressMessages(library(magrittr))
suppressMessages(library(tidyverse))
suppressMessages(library(pbmcapply))
suppressMessages(library(maditr))
suppressMessages(library(data.table))

ncores <- opt$threads

cat(paste0("\nReading file ", opt$data, "..."))
suppressMessages(cl_tax_orfs <- read_tsv(opt$data, col_names = TRUE) %>%
                   mutate(cl_name = as.character(cl_name)))
cat(green(" done\n"))
cat(paste("   File", opt$data, "has", nrow(cl_tax_orfs), "rows and", ncol(cl_tax_orfs), "columns\n\n"))

cat(paste0("\nReading file ", opt$components, "..."))
suppressMessages(cl_components <- read_tsv(opt$components, col_names = TRUE) %>%
                   mutate(cl_name = as.character(cl_name)))
cat(green(" done\n"))
cat(paste("   File", opt$components, "has", nrow(cl_components), "rows and", ncol(cl_components), "columns\n\n"))

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

# Analyse annotations -----------------------------------------------------
# cl_tax_orfs %>%
#   group_by(cl_name, category) %>%
#   count() %>%
#   arrange(desc(n)) %>%
#   group_by(category) %>%
#   skimr::skim()

propagate_annotation <-function(X, data = data){
  cls <- data %>%
    dplyr::filter(cl_name == X)

  consensus_superkingdom <- cls %>%
    dplyr::filter(!is.na(superkingdom)) %>%
    summarise(consensus_superkingdom = ifelse(n() < 1, NA,  majority_vote(superkingdom)$majority)) %>% .$consensus_superkingdom

  consensus_phylum <- cls %>%
    dplyr::filter(superkingdom == consensus_superkingdom,
                  !is.na(phylum)) %>%
    summarise(consensus_phylum = ifelse(n() < 1, paste(consensus_superkingdom, "NA", sep = "_"), majority_vote(phylum)$majority)) %>% .$consensus_phylum

  consensus_class <- cls %>%
    dplyr::filter(superkingdom == consensus_superkingdom,
                  phylum == consensus_phylum,
                  !is.na(class)) %>%
    summarise(consensus_class = ifelse(n() < 1, paste(consensus_phylum, "NA", sep = "_"), majority_vote(class)$majority)) %>% .$consensus_class

  consensus_order <- cls %>%
    dplyr::filter(superkingdom == consensus_superkingdom,
                  phylum == consensus_phylum,
                  class == consensus_class,
                  !is.na(order)) %>%
    summarise(consensus_order = ifelse(n() < 1, paste(consensus_class, "NA", sep = "_"), majority_vote(order)$majority)) %>% .$consensus_order

  consensus_family <- cls %>%
    dplyr::filter(superkingdom == consensus_superkingdom,
                  phylum == consensus_phylum,
                  class == consensus_class,
                  order == consensus_order,
                  !is.na(family)) %>%
    summarise(consensus_family = ifelse(n() < 1, paste(consensus_order, "NA", sep = "_"), majority_vote(family)$majority)) %>% .$consensus_family

  consensus_genus <- cls %>%
    dplyr::filter(superkingdom == consensus_superkingdom,
                  phylum == consensus_phylum,
                  class == consensus_class,
                  order == consensus_order,
                  family == consensus_family,
                  !is.na(genus)) %>%
    summarise(consensus_genus = ifelse(n() < 1, paste(consensus_family, "NA", sep = "_"), majority_vote(genus)$majority)) %>% .$consensus_genus

  tibble(cl_name = X, consensus_superkingdom, consensus_phylum, consensus_class,
         consensus_order, consensus_family, consensus_genus)
}


cat(paste("Propagating taxonomic annotations at cluster level using", cyan(ncores), "cores...\n"))

cl_tax_consensus <- pbmcapply::pbmclapply(cl_tax_orfs$cl_name %>% unique(),
                             propagate_annotation, data = cl_tax_orfs,
                             mc.cores = ncores,
                             ignore.interactive = T,
                             max.vector.size = 1e7) %>%
  bind_rows()

tax_ranks <- c("consensus_superkingdom", "consensus_phylum", "consensus_class", "consensus_order", "consensus_family", "consensus_genus")

cat(paste0("Propagation at taxonomic annotations at cluster level... ", green("done\n\n")))

# Quick look to the consensus annotations ---------------------------------


#map(tax_ranks, function(X){cl_tax_consensus %>% group_by_(X) %>% count(sort = TRUE) %>% ungroup()})

#cl_tax_consensus %>% filter(is.na(consensus_phylum))


# Write results -----------------------------------------------------------

# cl_tax_orfs %>%
#   select(supercluster, cl_name) %>%
#   inner_join(cl_tax_consensus %>% select(cl_name, consensus_class, consensus_phylum, consensus_superkingdom)) %>%
#   write_tsv("~/Downloads/pr2alluvial.tsv")


# Annotate at the ORF level -----------------------------------------------
# Uses the data generated above

propagate_annotation_na <-function(X, data = data){
  cls <- data[X,] %>%
    select(genus, family, order, class, phylum, superkingdom, orf, cl_name, supercluster)

  consensus_superkingdom <- cls %>%
    summarise(consensus_superkingdom = ifelse(is.na(superkingdom), NA, superkingdom))%>% .$consensus_superkingdom

  consensus_phylum <- cls %>%
    summarise(consensus_phylum = ifelse(is.na(phylum), paste(consensus_superkingdom, "NA", sep = "_"), phylum)) %>% .$consensus_phylum

  consensus_class <- cls %>%
    summarise(consensus_class = ifelse(is.na(class), paste(consensus_phylum, "NA", sep = "_"), class)) %>% .$consensus_class

  consensus_order <- cls %>%
    summarise(consensus_order = ifelse(is.na(order), paste(consensus_class, "NA", sep = "_"), order)) %>% .$consensus_order

  consensus_family <- cls %>%
    summarise(consensus_family = ifelse(is.na(family), paste(consensus_order, "NA", sep = "_"), family)) %>% .$consensus_family

  consensus_genus <- cls %>%
    dplyr::filter(superkingdom == consensus_superkingdom,
                  phylum == consensus_phylum,
                  class == consensus_class,
                  order == consensus_order,
                  family == consensus_family,
                  !is.na(genus)) %>%
    summarise(consensus_genus = ifelse(n() < 1, paste(consensus_family, "NA", sep = "_"), majority_vote(genus)$majority)) %>% .$consensus_genus

  tibble(supercluster = cls$supercluster, orf = cls$orf, cl_name = cls$cl_name, consensus_superkingdom, consensus_phylum, consensus_class,
         consensus_order, consensus_family, consensus_genus)
}

cat("Collecting consensus annotations... ")
pr_clusters_consensus <- cl_tax_orfs %>%
  select(supercluster, cl_name) %>%
  inner_join(cl_tax_consensus %>% select(cl_name, consensus_superkingdom, consensus_phylum, consensus_class, consensus_order, consensus_family, consensus_genus), by = "cl_name")

cat(green("done"),"\nCollecting ORFs with taxonomic annotations... ")
pr_clusters_no_na <- cl_tax_orfs %>%
  filter(!(is.na(superkingdom) | is.na(phylum)))

cat(green("done"), "\nCollecting ORFs without taxonomic annotations... ")
cl_tax_consensus_na  <- cl_tax_orfs %>%
  filter(is.na(superkingdom) | is.na(phylum)) %>%
  select(supercluster, cl_name, orf) %>%
  unique() %>%
  as.data.table() %>%
  dt_inner_join(pr_clusters_consensus %>% select(-supercluster), by = "cl_name") %>% unique() %>% as_tibble()

cat(green("done"),"\nPropagating taxonomic annotations at the ORF level using", cyan(ncores), "cores... ")
cl_tax_consensus_no_na <- pbmclapply(1:nrow(pr_clusters_no_na),
                                   propagate_annotation_na,
                                   data = pr_clusters_no_na,
                                   mc.cores = ncores,
                                   ignore.interactive = T,
                                   max.vector.size = 1e7) %>%
  bind_rows() 
cat(paste0("Propagation of taxonomic annotations at the ORF level... ", green("done"), "\n\nExporting data for alluvial plot drawing to file ", silver(opt$out), "... "))

bind_rows(cl_tax_consensus_no_na,
          cl_tax_consensus_na) %>%
  left_join(cl_components, by = "cl_name") %>%
  write_tsv(opt$out)
cat(green("done\n"))