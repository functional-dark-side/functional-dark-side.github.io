#!/home/cvanni/R-3.4.2/bin/Rscript
library(data.table)
args <- commandArgs(trailingOnly = TRUE)
dt <- fread(input = args[1], sep = " ", header = FALSE, showProgress = FALSE)
s <- summary(dt$V3)
cat(s, "\n")
