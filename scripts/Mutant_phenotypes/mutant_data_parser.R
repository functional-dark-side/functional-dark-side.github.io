
# To generate basic data for the figure -----------------------------------

library(tidyverse)
library(RSQLite)
library(data.table)
library(maditr)
library(tidyverse)

unixtools::set.tempdir(path.expand("/vol/cloud/SANDBOX/tmp"))

lo_env <- new.env()

setDTthreads(28)
source("lib/colors.R")
mutants_db <- dbConnect(drv=SQLite(), dbname="/vol/cloud/SANDBOX/mutants/analysis/data/fit/cgi_data/feba.db")


experim <-  tbl(mutants_db, "Experiment") %>%
  collect(n = Inf) %>%
  select(orgId, expName, expDesc, expGroup) %>% distinct()

genes <- tbl(mutants_db, "Gene") %>% collect(n = Inf)

organisms <-  tbl(mutants_db, "Organism") %>% collect(n = Inf) %>%
  mutate(name = paste(genus, species, strain))

gene_fit <- tbl(mutants_db, "GeneFitness") %>% collect(n = Inf)

mutants_best_hit <- read_tsv("/vol/cloud/SANDBOX/mutants/analysis/data/mutants_mg_gtdb_best-hits.tsv") %>%
  separate(col = gene, into = c("orgId", "locusId"), sep = ":", remove = TRUE)

# Get phylogenomic info
load("/vol/cloud/SANDBOX/mutants/analysis/data/GTDB/gtdb_bac_r86_plot.Rda", verbose = TRUE)
f1 <- f1 %>%
  separate(trait, into = c("categ", "cl_name"), sep = "_")

# What I want to do -------------------------------------------------------
# I want to show how our approach can help experimental methods
# Lineage specific and non lineage-specific gene clusters
color_comb_cats_I <-c("#22B2DA","#555A60")
names(color_comb_cats_I) <- c("Known", "Unknown")

mutant_genes_cls <- genes %>%
  inner_join(mutants_best_hit %>% mutate(cl_name = as.character(cl_name))) %>% #filter(cl_name == 4995669) %>% View
  inner_join(gene_fit) %>%
  inner_join(experim) %>%
  mutate(cat = ifelse(category == "K" | category == "KWP", "Known", "Unknown")) %>%
  select(orgId, locusId, cl_name, cat, expDesc, expGroup, fit) %>%
  group_by(orgId, locusId, cl_name, cat, expDesc, expGroup) %>%
  summarise(fit = mean(fit)) %>%
  ungroup() %>%
  left_join(f1) %>%
  mutate(is_specific = ifelse(is.na(lowest_rank), "non-specific", "specific"))

# Read OM-RGCv2 data
lo_env$omrgc_unk_gu_gtdb <- read_tsv(file = "/vol/cloud/SANDBOX/mutants/analysis/data/om-rgc_v2/om-rgc_v2.unks.unk-gu.gtdb.tsv.gz") %>%
  mutate(cl_name = as.character(cl_name))

lo_env$omrgc <- read_tsv(file = "/vol/cloud/SANDBOX/mutants/analysis/data/om-rgc_v2/OM-RGC_v2_genes_class_categ.tsv.gz")

lo_env$omrgc_pairs <- read_tsv(file = "/vol/cloud/SANDBOX/mutants/analysis/data/om-rgc_v2/OM-RGC_v2_genes_class_categ_pairs.tsv.gz")

mutant_genes_cls_omrgc <- mutant_genes_cls %>%
  inner_join(lo_env$omrgc %>%
               mutate(cl_name = as.character(cl_name)) %>%
               filter(dataset == "MG_G_OMRGC2") %>%
               mutate(cat = ifelse(categ == "K" | categ == "KWP", "Known", "Unknown")) %>%
               filter(cat == "Unknown")
  )


mutant_genes_cls_omrgc %>% select(orgId, cl_name, expGroup, fit) %>%
  group_by(orgId, cl_name, expGroup) %>%
  summarise(fit = mean(fit)) %>%
  group_by(orgId) %>% mutate(n = n_distinct(cl_name))

organisms %>% print(n=50)

# We select Pseudomonas fluorescens FW300-N2C3 as examples
org <- "pseudo5_N2C3_1"

# We will compare LB media vs STRESS conditions
mutant_genes_cls %>%
  filter(orgId == org) %>% select(expDesc, expGroup) %>% distinct() %>% arrange(expGroup) %>% print(n = 200)
base_exp <- "LB"

conds <- mutant_genes_cls %>%
  #filter(orgId == org) %>% filter(expDesc == base_exp | grepl("Chloramphenicol", expDesc)) %>%
  filter(orgId == org, expGroup == "stress") %>%
  select(expDesc) %>%
  distinct()

locuId_area <- mutant_genes_cls %>%
  #filter(orgId == org) %>% filter(expDesc == base_exp | grepl("Spectino", expDesc)) %>%
  filter(orgId == org) %>% filter(expDesc == base_exp | (expDesc %in% conds$expDesc)) %>%
  mutate(expDesc = gsub("LB ", "", expDesc)) %>%
  select(locusId, cat, cl_name, expDesc, fit) %>%
  pivot_wider(names_from = expDesc, values_from = fit) %>%
  pivot_longer(cols = c(-contains(base_exp), -contains('locusId'), -contains('cat'), -contains('cl_name')), names_to = "treat", values_to = "fit") %>%
  #unite(cl_name, c(cl_name, locusId), sep = ' - ') %>%
  filter(fit < -1) %>%
  rowwise() %>%
  mutate(ratio = as.numeric((dist(rbind(abs(fit),0))*dist(rbind(abs(LB),0)))/2)) %>%
  ungroup() %>%
  arrange((ratio)) %>%
  #filter(grepl("Spectino", treat)) %>%
  filter(cl_name %in% lo_env$omrgc$cl_name)

#Spectino
p <- mutant_genes_cls %>%
  filter(orgId == org) %>% filter(expDesc == base_exp | expDesc == "Spectinomycin 0.025 mg/ml") %>%
  #filter(orgId == org) %>% filter(expDesc == base_exp | (expDesc %in% conds$expDesc)) %>%
  mutate(expDesc = gsub("LB ", "", expDesc)) %>%
  select(locusId, cat, cl_name, expDesc, fit) %>%
  pivot_wider(names_from = expDesc, values_from = fit) %>%
  pivot_longer(cols = c(-contains(base_exp), -contains('locusId'), -contains('cat'), -contains('cl_name')), names_to = "treat", values_to = "fit") %>%
  unite(cl_name, c(cl_name, locusId), sep = ' - ') %>%
  ggplot(aes_(as.name(base_exp), ~fit, fill = ~cat, label = ~cl_name)) +
  geom_abline(intercept = 0, size = 0.1, color = "#2F2F2B") +
  geom_hline(yintercept = 0, size = 0.1, color = "#2F2F2B") +
  geom_vline(xintercept = 0, size = 0.1, color = "#2F2F2B") +
  geom_point(shape = 21, alpha = 0.8, color = "#2F2F2B") +
  scale_fill_manual(values = color_comb_cats_I) +
  facet_wrap(~treat)
p
plotly::ggplotly(p)


# Gene glyphs for pseudo5_N2C3_1
gene_id <- mutant_genes_cls %>%
  filter(orgId == org) %>% filter(expDesc == "Spectinomycin 0.025 mg/ml", cl_name == 19737823)

genes_int <- genes %>%
  filter(orgId == "pseudo5_N2C3_1") %>%
  mutate(idx = row_number())

gene_int <- genes_int %>%
  filter(locusId == gene_id$locusId)

idx <- genes_int %>%
  mutate(diff_start = abs(gene_int$begin - begin), diff_end = abs(gene_int$end - end)) %>%
  slice(which.min(diff_start)) %>%
  select(idx, locusId, begin, end, strand, desc)

locus <- idx$locusId
idxs <- seq(idx$idx - 3, idx$idx + 3)
genes_int <- genes_int %>%
  filter(idx %in% idxs) %>%
  select(idx, locusId, begin, end, strand, desc) %>%
  mutate(molecule = gene_int$orgId,
         target = locus,
         id_col = ifelse(desc == target, "GENE", desc),
         gene = ifelse(locusId == target, "GENE", "OTHER"),
         direction = ifelse(strand == "-", -1, 1),
         strand = ifelse(strand == "-", "reverse", "forward")) %>%
  mutate(gene = case_when(desc == "30S ribosomal protein S18" ~ "30S ribosomal protein S18",
                          desc == "30S ribosomal protein S6" ~ "30S ribosomal protein S6",
                          desc == "50S ribosomal protein L9" ~ "50S ribosomal protein L9",
                          desc == "replicative DNA helicase" ~ "replicative DNA helicase",
                          gene == "GENE" ~ "GU_19737823",
                          TRUE ~ gene)) %>%
  mutate(gene = fct_relevel(gene, c("GU_19737823", "30S ribosomal protein S6", "30S ribosomal protein S18", "50S ribosomal protein L9", "replicative DNA helicase", "OTHER")))


gene_colors <- c("#732210", "#587364", "#25261E", "#8C5B3E", "#A67F68", "#777C82")
names(gene_colors) <- c("GU_19737823", "30S ribosomal protein S6", "30S ribosomal protein S18", "50S ribosomal protein L9", "replicative DNA helicase", "OTHER")



dummies <- make_alignment_dummies(
  gene_int,
  aes(xmin = begin, xmax = end, y = locusId, id = gene),
  on = "GU_19737823"
)


plot_gene_int <- ggplot(gene_int, aes(xmin = begin, xmax = end, y = molecule, fill = gene, forward = direction)) +
  geom_gene_arrow() +
  #geom_blank(data = dummies, aes(forward = 1)) +
  #facet_wrap(~ molecule, scales = "free", ncol = 1) +
  theme_genes() +
  scale_fill_manual(values = gene_colors)

# OM-RGCv2 genes
omrgc_genes <- lo_env$omrgc %>% filter(cl_name == 19737823)

# In how many samples do we find it
lo_env$mg_cl <- fread(input = "/vol/cloud/UNK_SANDBOX/mg_all_cl_categ_smpl_abund_norfs.tsv.gz", header = TRUE, verbose = TRUE)

samp_sel_cls <- lo_env$mg_cl %>%
  filter(cl_name == 19737823) %>%
  mutate(study = case_when(grepl("TARA", sample) ~ "TARA",
                           grepl("SRS", sample) ~ "HMP",
                           grepl("^MP", sample) ~ "MALASPINA",
                           grepl("^OSD", sample) ~ "OSD",
                           TRUE ~ "GOS"))

save(samp_sel_cls, file = "/vol/cloud/UNK_SANDBOX/samp_sel_cls.Rda")

samp_sel_cls %>%
  group_by(study) %>%
  count()


# Get GTDB data, identify genomes, get gene glyphs and plot tree with number of genomes at R rank
lo_env$orf_cl <- fread(input = "/vol/cloud/SANDBOX/all_mg_gtdb_genome_orf_cl_categ.tsv.gz", verbose = TRUE, header = FALSE)
lo_env$orf_cl_parsed <- lo_env$orf_cl %>%
  setNames(c("genome", "domain", "orf", "cl_name")) %>%
  separate(cl_name, c("categ", "cl_name"), sep = "_") %>%
  mutate(strand = gsub(".*_(\\+|-)_(\\d+)_(\\d+)_orf-.*", "\\1", orf),
         start = as.numeric(gsub(".*_(\\+|-)_(\\d+)_(\\d+)_orf-.*", "\\2", orf)),
         end = as.numeric(gsub(".*_(\\+|-)_(\\d+)_(\\d+)_orf-.*", "\\3", orf)),
         orf_n = as.numeric(gsub(".*_(\\+|-)_(\\d+)_(\\d+)_orf-(\\d+)", "\\4", orf))) %>%
  arrange(genome, orf_n) %>%
  as_tibble()

sel_genomes <- lo_env$orf_cl_parsed %>%
  filter(cl_name == 19737823) %>%
  select(genome) %>%
  distinct()

load("/vol/cloud/SANDBOX/gtdb_bac_r86_plot.Rda", verbose = TRUE)


gtdb_tax %>%
  as_tibble() %>%
  filter(genome %in% sel_genomes$genome) %>%
  group_by(family) %>%
  count()

f1score.out_table.cl %>%
  as_tibble() %>%



  gtdb_tree <- tree

cl_counts <- gtdb_tax %>%
  as_tibble() %>%
  filter(genome %in% sel_genomes$genome) %>%
  group_by(family) %>%
  count()

tax_family <- gtdb_tax %>% filter(genome %in% sel_genomes$genome) %>% filter(family %in% cl_counts$family) %>% group_by(family) %>% sample_n(1)
tree_family <- drop.tip(gtdb_tree, setdiff(gtdb_tree$tip.label, tax_family$genome %>% as.character()), trim.internal = TRUE)
tree_family$tip.label <- plyr::mapvalues(tree_family$tip.label, from = as.character(tax_family$genome), to = as.character(tax_family$family))
tree_family_tips <- map_dfr(tax_family$family, function(X){
  treeio::tree_subset(tree_family, node = X, levels_back = 5)$tip.label %>% enframe()})$value
tree_family <- drop.tip(tree_family, setdiff(tree_family$tip.label, tree_family_tips), trim.internal = TRUE)

family_data <- tree_family %>%
  as_tibble() %>%
  inner_join(cl_counts %>% rename(label = family))

# Plot phylogenetic tree --------------------------------------------------
library(wesanderson)
library(ggtree)
pal <- wes_palette("Zissou1", 100, type = "continuous")
p <- ggtree(tree_family, layout='rectangular') %<+% family_data +
  geom_tippoint(aes(size = n),
                shape = 21,# Make bubbles on edges
                fill = "#022641",
                color = "#243643",
                alpha = 0.7) +
  geom_tiplab(size = 2.1,
              align = TRUE,
              linesize = 0.2,
              linetype = "dotted",
              color = "black") +
  #scale_color_gradientn(colours = pal, name="Percentage of MAGs", labels=scales::percent) +
  scale_size_continuous(range = c(1,5), name="Lineage specific unknowns", trans = "sqrt", breaks = c(10, 100, 200, 300)) +
  theme(legend.position = "top",
        legend.key = element_blank()) # no keys
p

# Get gene glyphs


library(gggenes)
assm_summary_rs <- read_tsv("ftp://ftp.ncbi.nlm.nih.gov/genomes/ASSEMBLY_REPORTS/assembly_summary_refseq.txt", col_names = TRUE, skip = 1, quote = "|")
assm_summary_gb <- read_tsv("ftp://ftp.ncbi.nlm.nih.gov/genomes/ASSEMBLY_REPORTS/assembly_summary_genbank.txt", col_names = TRUE, skip = 1, quote = "|")

assm_summary <- bind_rows(assm_summary_rs, assm_summary_gb)

get_genes_cls <- function(X, cls = cls){

  cat(paste("Processing genome", X, "\n"))

  orf_sel <- lo_env$orf_cl_parsed  %>%
    filter(cl_name == cls, genome == X)

  sel <- orf_sel %>%
    as_tibble() %>%
    separate(genome, into = c("db", "acc"), sep = "_", extra = "merge") %>%
    group_by(cl_name) %>%
    #sample_n(n) %>%
    mutate(strand = gsub(".*_(\\+|-)_(\\d+)_(\\d+)_orf-.*", "\\1", orf),
           start = gsub(".*_(\\+|-)_(\\d+)_(\\d+)_orf-.*", "\\2", orf),
           end = gsub(".*_(\\+|-)_(\\d+)_(\\d+)_orf-.*", "\\3", orf))

  library(stringi)
  acc <- gsub("RS_(\\w+)\\.(\\d+)", "\\1", X)
  links <- assm_summary %>%
    filter(grepl(acc, `# assembly_accession`)) %>%
    select(ftp_path, `# assembly_accession`) %>%
    mutate(genome = gsub(".*/(\\S+)", "\\1", ftp_path),
           ftp_path = paste0(ftp_path, "/", gsub(".*/(\\S+)", "\\1", ftp_path), "_feature_table.txt.gz")) %>%
    setNames(c("ftp_path", "acc", "genome")) %>%
    mutate()

  gen <- map_dfr(seq(1, nrow(sel)), function(X){
    data <- sel[X,] %>%
      mutate(start = as.numeric(start),
             end = as.numeric(end))
    cat(paste("Getting genome", links$acc, "from", links$ftp_path, "\n"))
    feat <- read_tsv(links$ftp_path, quote = "||", col_types = cols()) %>%
      filter(`# feature` == "CDS") %>%
      mutate(idx = row_number())
    idx <- feat %>%
      mutate(diff_start = abs(data$start -start), diff_end = abs(data$end-end)) %>%
      slice(which.min(diff_start)) %>%
      select(idx, locus_tag, start, end, strand, name)

    locus <- idx$locus_tag
    idxs <- seq(idx$idx - 3, idx$idx + 3)
    feat <- feat %>%
      filter(idx %in% idxs) %>%
      select(idx, locus_tag, start, end, strand, name) %>%
      mutate(cl_name = data$cl_name,
             molecule = data$acc,
             target = locus,
             id_col = ifelse(name == target, "GENE", name),
             gene = ifelse(locus_tag == target, "GENE", "OTHER"),
             direction = ifelse(strand == "-", -1, 1),
             strand = ifelse(strand == "-", "reverse", "forward")) %>%
      mutate(diff_start = abs(data$start - start), diff_end = abs(data$end - end))

    if (any(grepl("30S", feat$id_col))) {
      return(feat)
    }else
    {
      NULL
    }

  })

  dummies <- make_alignment_dummies(
    gen,
    aes(xmin = start, xmax = end, y = molecule, id = gene),
    on = "GENE"
  )

  plot_genes <- ggplot(gen, aes(xmin = start, xmax = end, y = molecule, fill = gene, forward = direction)) +
    geom_gene_arrow() +
    geom_blank(data = dummies, aes(forward = 1)) +
    facet_wrap(~ molecule, scales = "free", ncol = 1) +
    theme_genes()

  return(list(genes = gen, dummies = dummies, plot_genes = plot_genes))

}

genomes_rs <- gtdb_tax %>%
  filter(genome %in% sel_genomes$genome) %>%
  filter(family %in% cl_counts$family) %>% filter(grepl("GCF", genome)) %>% group_by(family) %>% sample_n(1)

#[1] "RS_GCF_000423345.1" "RS_GCF_900156225.1" "RS_GCF_900174585.1" "RS_GCF_001971685.1" "RS_GCF_000192865.1" "RS_GCF_000008325.1"
#[7] "RS_GCF_000383855.1" "RS_GCF_000691225.1" "RS_GCF_000374645.1" "RS_GCF_001444425.1" "RS_GCF_900110925.1" "RS_GCF_000422345.1"

data_glyphs <- pbmcapply::pbmclapply(genomes_rs$genome %>% as.character(), get_genes_cls, cls = 19737823)
names(data_glyphs) <- genomes_rs$genome %>% as.character()
all_genes <- map_dfr(data_glyphs, "genes") %>%
  mutate(gene = case_when(name == "30S ribosomal protein S18" ~ "30S ribosomal protein S18",
                          name == "30S ribosomal protein S6" ~ "30S ribosomal protein S6",
                          name == "50S ribosomal protein L9" ~ "50S ribosomal protein L9",
                          name == "replicative DNA helicase" ~ "replicative DNA helicase",
                          gene == "GENE" ~ "GU_19737823",
                          TRUE ~ gene)) %>%
  mutate(gene = fct_relevel(gene, c("GU_19737823", "30S ribosomal protein S6", "30S ribosomal protein S18", "50S ribosomal protein L9", "replicative DNA helicase", "OTHER")))


gene_colors <- c("#732210", "#587364", "#25261E", "#8C5B3E", "#A67F68", "#777C82")
names(gene_colors) <- c("GU_19737823", "30S ribosomal protein S6", "30S ribosomal protein S18", "50S ribosomal protein L9", "replicative DNA helicase", "OTHER")



dummies <- make_alignment_dummies(
  all_genes,
  aes(xmin = start, xmax = end, y = molecule, id = gene),
  on = "GU_19737823"
)

plot_genes <- ggplot(all_genes, aes(xmin = start, xmax = end, y = molecule, fill = gene, forward = direction)) +
  geom_gene_arrow() +
  geom_blank(data = dummies, aes(forward = 1)) +
  facet_wrap(~ molecule, scales = "free", ncol = 1) +
  scale_fill_manual(values = gene_colors) +
  theme_genes()




# Plots
# 1. Scatter plot
save(mutant_genes_cls, file = "/vol/cloud/UNK_SANDBOX/mutants_gu19737823/mutant_genes_cls_gu19737823.Rda")

# 2. INteresting genes in metagenomes
save(omrgc_genes, file = "/vol/cloud/UNK_SANDBOX/mutants_gu19737823/omrgc_genes_gu19737823.Rda")
save(samp_sel_cls, file = "/vol/cloud/UNK_SANDBOX/mutants_gu19737823/samp_sel_cls_gu19737823.Rda")

# 3. Interesting genes in genomes
save(tax_family, tree_family, family_data, cl_counts, file = "/vol/cloud/UNK_SANDBOX/mutants_gu19737823/family_data_gu19737823.Rda" )
save(data_glyphs, file = "/vol/cloud/UNK_SANDBOX/mutants_gu19737823/data_glyphs_gu19737823.Rda")
save(genes_int, file = "/vol/cloud/UNK_SANDBOX/mutants_gu19737823/genes_int_gu19737823.Rda")
