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

needed = c("ape", "tidyverse", "pbmcapply", "phangorn", "maditr", "data.table")

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
  make_option(c("-t", "--tree"), type="character", default=NULL,
              help="Tree file name", metavar="character"),
  make_option(c("-d", "--data"), type="character", default=NULL,
              help="Contextual data filename", metavar="character"),
  make_option(c("-p", "--threads"), type="integer", default=1,
              help="Number of threads [default= %default]", metavar="integer"),
  make_option(c("-o", "--out"), type="character", default="annotation.tsv",
              help="Iutput file name [default= %default]", metavar="character")
)

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);


if (is.null(opt$tree) || is.null(opt$data)){
  print_help(opt_parser)
  stop("At least two arguments must be supplied (tree file and contextual data files).n", call.=FALSE)
}

suppressMessages(library(ape))
suppressMessages(library(tidyverse))
suppressMessages(library(pbmcapply))
suppressMessages(library(maditr))
suppressMessages(library(data.table))


# Do stuff ----------------------------------------------------------------

ncores <- opt$threads

cat(paste0("\nReading tree ",  opt$tree, "..."))
pr_tree <- read.tree(file = opt$tree)
cat(green(" done\n"))

cat(paste("   Tree in file", opt$tree, "has", yellow(scales::comma(Ntip(pr_tree))), "tips and", yellow(scales::comma(Nedge(pr_tree))), "edges\n\n"))
cat(paste0("\nReading contextual data ",  opt$data, "..."))
suppressMessages(pr_cdata <- read_tsv(opt$data, col_names = FALSE) %>%
                   rename(tip.label = X1, supercluster = X2))
cat(paste("done\n   File", opt$data, "has", yellow(scales::comma(nrow(pr_cdata))), "rows and", yellow(scales::comma(ncol(pr_cdata))), "columns\n"))

cat("\nExtracting inserted sequences from tree...")
pr_inserted <- tibble(tip.label = pr_tree$tip.label) %>%
  filter(grepl("seq", tip.label))

cat(paste0("done\n   ", yellow(scales::comma(nrow(pr_inserted)))," sequencs extracted\n\n"))

pairs <- (Ntip(pr_tree) * (Ntip(pr_tree) - 1))/2


cat(paste0("Calculating cophenetic distance (", yellow(scales::comma(pairs))," pairs)... "))
coph <- cophenetic.phylo(pr_tree) %>%
  as.dist() %>%
  broom::tidy()
cat(green("done\n"))

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

assign_orfs <- function(X, phy = phy, data = tips, coph = coph, n_mrca = n_mrca){
  top <- coph %>%
    dt_filter(item1 == X | item2 == X) %>%
    dt_mutate(item1 = as.character(item1), item2 = as.character(item2)) %>%
    as_tibble() %>%
    rowwise() %>%
    mutate(item2 = ifelse(item1 != X, item1, item2), item1 = X) %>%
    inner_join(data, by = c( "item2" = "tip.label")) %>%
    arrange((distance)) %>%
    head(n_mrca)
  # top <- coph %>%
  #   dt_filter(item1 == X | item2 == X)
  # f_q <- quantile(top$distance)[[2]]
  # top <- top %>%
  #   dt_filter(distance <= f_q) %>%
  #   dt_mutate(item1 = as.character(item1), item2 = as.character(item2))
  # top <- top[, c("item1", "item2") := list(X, ifelse(item1 != X, item1, item2)), by = .I] %>%
  #   dt_inner_join(data, by = c( "item2" = "tip.label")) %>%
  #   arrange((distance)) %>%
  #   as_tibble() %>%
  #   head(n_mrca)
  bestmrca <- getMRCA(phy, unique(c(top$item1, top$item2)))
  mrcatips <- phy$tip.label[unlist(phangorn::Descendants(phy, bestmrca, type = "tips"))]
  if(length(data %>% filter(tip.label %in% mrcatips) %>% .$supercluster %>% unique()) != 1){
    annot <- majority_vote(data %>% filter(tip.label %in% mrcatips) %>% .$supercluster)$majority
    majority <- TRUE
  }else{
    annot <- data %>% filter(tip.label %in% mrcatips) %>% .$supercluster %>% unique()
    majority <- FALSE
  }
  tibble(tip.label = X, supercluster = annot, majority = majority)
}

cat(paste0("Annotating ORFs with ", yellow(ncores) ," cores...\n"))
orf_annotation <- pbmcapply::pbmclapply(pr_inserted$tip.label,
                                        assign_orfs,
                                        phy = pr_tree,
                                        data = pr_cdata,
                                        coph = coph %>% as.data.table(),
                                        n_mrca = 1,
                                        mc.cores = ncores,
                                        ignore.interactive = T,
                                        max.vector.size = 1e7) %>%
  bind_rows()

cat(paste0("Exporting annotations to file ", silver(opt$out), "... "))
write_tsv(orf_annotation, path = opt$out, col_names = FALSE)
cat(green("done\n\n"))