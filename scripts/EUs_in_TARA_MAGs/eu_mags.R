library(tidyverse)
library(data.table)
library(RSQLite)
library(genoPlotR)
library(gggenes)

#Main directory: data/

# Search results
mags_vs_eus <- read_tsv("coverage_ext_DBs/mag_best-hits.tsv", col_names = TRUE, progress = TRUE) %>%
  dplyr::select(-con_cat) %>%
  dplyr::rename(gene_callers_id = gene, clstr_ID = cl_name) %>%
  mutate(gene_callers_id = as.character(gene_callers_id),
         clstr_ID = as.character(clstr_ID))

# Broad-distributed EU cluster communities
load("niche_breadth/gClCo_nb_all_mv.Rda")
broad_eus <- gClCo_nb_all_mv %>% filter(sign=="Broad", categ=="EU") %>%
    select(-categ) %>% rename(com_ID=gClCo_name)

# Link cluster community ids to cluster ids
cl_com <- fread("cluster_communities/marine_hmp_cluster_communities.tsv.gz",header=F) %>%
 setNames(c("clstr_ID","com_ID"))
broad_eus <- broad_eus %>% left_join(cl_com, by="com_ID")

# Gene_callers_ID is a unique idenitifier for a contigs for ANVIO
m_genes <- read_tsv("EUs_vs_TARA_MAGs/orf2mag.tsv", col_names = TRUE, progress = TRUE) %>%
  dplyr::select(gene_callers_id, contig) %>%
  mutate(gene_callers_id = as.character(gene_callers_id))

# Anvio MAG statistics
mag_cdata <- read_tsv("EUs_vs_TARA_MAGs/TARA_MAGs_v3_metadata.txt", col_names = TRUE) %>% rename(MAG = MAG_Id)

# MAG Taxonomy
mag_tax <- read_csv("EUs_vs_TARA_MAGs/tara_delmont_taxids.csv", col_names = FALSE) %>%
  separate(X3,into = c("domain","phylum","class", "order", "family", "genus"), sep = ";", fill = "right", extra = "drop") %>%
  dplyr::rename(MAG=X1)

# MAG abundance
mag_abun <- read_tsv("EUs_vs_TARA_MAGs/Table_S12.txt", col_names =  TRUE) %>%
  rename(MAG = `1077 MAGs`) %>% gather(key = sample, value = abun, -MAG) %>% arrange(desc(abun))

# Join datasets
mags_vs_eus_comb <- mags_vs_eus %>%
    left_join(m_genes) %>% # Join with Anvio gene-caller-ids
    tidyr::extract(contig,
                   into = paste("V", 1:4, sep = ""),
                   regex = "([[:alnum:]]+)_([[:alnum:]]+)_([[:alnum:]]+)_([[:alnum:]]+)") %>% # clean contig names
    tidyr::unite(col = MAG, V1,V2,V3,V4, sep = "_", remove = TRUE)

# How many ORFs does each MAG have?
mag_n_orfs <- m_genes %>%
    tidyr::extract(contig, into = paste("V", 1:4, sep = ""), regex = "([[:alnum:]]+)_([[:alnum:]]+)_([[:alnum:]]+)_([[:alnum:]]+)") %>%
    unite(col = MAG, V1,V2,V3,V4, sep = "_", remove = TRUE) %>%
    group_by(MAG) %>%
    count() %>%
    rename(n_orf = n)

# Proportion of EUs per MAG
mag_prop_of_eus <- mags_vs_eus_comb %>%
    dplyr::select(MAG, clstr_ID, category) %>%
    unique %>%
    group_by(MAG,category) %>%
    count() %>% # count how many EUs are in each MAG
    rename(n_categ = n) %>%
    left_join(mag_n_orfs) %>%
    mutate(prop_categ = n_categ/n_orf)

#How many EU components and clusters were found in the TARA MAGs?
mags_vs_eus_comb %>% dplyr::select(com_ID) %>% unique %>% nrow()
#4,365
mags_vs_eus_comb %>% dplyr::select(clstr_ID) %>% unique %>% nrow()
#5,420

#Select MAG with most broad EUs and highest abundance for extracting contig
mag_prop_of_eus_broad <- mags_vs_eus_comb %>%
  inner_join(broad_eus) %>%
  dplyr::select(MAG, clstr_ID) %>%
  unique %>% # How many clusters!? Without the unique a cluster can hit a MAG more than once
  group_by(MAG) %>%
  count() %>% # count how many EUs are in each MAG
  rename(n_eus = n) %>%
  left_join(mag_n_orfs) %>%
  mutate(prop_eus = n_eus/n_orf)

# Add MAG completion
eu_mag_data <- mag_prop_of_eus_broad %>% left_join(mag_cdata)
num_of_eu_hits %>% left_join(mag_cdata)
# Plot number of EUs and MAG completion
mag_complet <- eu_mag_data %>% ungroup() %>% filter(`Anvio-Comp` < 80, n_eus > 1) %>%
  mutate(MAG = fct_reorder(MAG, (`Anvio-Comp`))) %>%
  ggplot(aes(MAG, `Anvio-Comp`/4)) +
  geom_bar(stat = "identity", fill = "#4A4A4A") +
  geom_line(aes(y = n_eus), group = 1, color = "#AD303E") +
  geom_point(aes(y = n_eus), color = "#AD303E", shape = 21, fill = "#AD303E") +
  coord_flip() +
  theme_light() +
  ylab("Number of broad EUs") +
  scale_y_continuous(sec.axis = sec_axis(~.*4, name = "Anvi'o completion", labels = function(x) paste0(x,"%"))) +
  theme(axis.text = element_text(size = 7),
        axis.title = element_text(size=7))

#Download selected contig (TARA_ANW_MAG_00076) from https://figshare.com/articles/TARA-NON-REDUNDANT-MAGs-SPLIT/4902941:
#Process MAGs to extract contigs
#Extract gene calls from MAG (using Anvi'o)
# cd TARA_ANW_MAG_00076
# Update DB
#anvi-migrate-db -t 10 CONTIGS.db
# Grab gene calls
#anvi-export-gene-calls -c CONTIGS.db -o gene_calls
# Get contigs from MAG
#anvi-export-contigs -c CONTIGS.db -o CONTIGS.fa

#Alternative
TARA_ANW_MAG_00076_index <- mags_vs_eus_comb %>% filter(MAG == "TARA_ANW_MAG_00076") %>% select(clstr_ID, gene_callers_id)

TARA_ANW_MAG_00076_genecalls <- read_tsv("EUs_vs_TARA_MAGs/bin_by_bin/TARA_ANW_MAG_00076/TARA_ANW_MAG_00076-gene_calls.txt")

TARA_ANW_MAG_00076_contigs_with_eus <- TARA_ANW_MAG_00076_genecalls %>%
  filter(gene_callers_id %in% TARA_ANW_MAG_00076_index$gene_callers_id) %>%
  select(contig) %>% unique()

write_tsv(TARA_ANW_MAG_00076_contigs_with_eus,
          path = "EUs_vs_TARA_MAGs/TARA_ANW_MAG_00076_contigs_with_eus.tsv", col_names = FALSE)

# The following commands need to be executed in bash
#Filter for only contigs of interest
#filterbyname.sh in=EUs_vs_TARA_MAGs/bin_by_bin/TARA_ANW_MAG_00076/TARA_ANW_MAG_00076-contigs.fa out=TARA_ANW_MAG_00076_eu_CONTIGS.fa names=TARA_ANW_MAG_00076_contigs_with_eus.tsv include=T

# [Installing Prokka on local Mac with Brew](https://github.com/tseemann/prokka)
#git clone https://github.com/tseemann/prokka.git ~/opt/
#~/opt/prokka/bin/prokka --setupdb

#Run Prokka on list of eu contigs
#~/opt/prokka/bin/prokka eu_CONTIGS.fa --metagenome --compliant --centre XXX

#Create index between gene-caller-ID and gbk
#cut -f1,4 EUs_vs_TARA_MAGs/bin_by_bin/TARA_ANW_MAG_00076/TARA_ANW_MAG_00076-gene_calls.txt | while read LINE; do ID=$(echo $LINE | cut -f1 -d ' '); END=$(echo $LINE | cut -f2 -d ' '); grep CDS PROKKA_08082018.gff | awk -v E=$END -v I=$ID '$5 == E{split($9,a,";");print I"\t"a[1]}'; done | sed -e 's|ID=||' > genecallerID_to_gbk_index.tsv

## Read in PROKKA results
annotations <- read_tsv("EUs_vs_TARA_MAGs/sel_contigs/PROKKA_08202019/PROKKA_08202019.tsv")

annotation_index <- read_tsv("EUs_vs_TARA_MAGs/sel_contigs/TARA_ANW_MAG_00076_genecallerID_to_gbk_index.tsv", col_names = FALSE) %>%
  rename(genecallerID = X1, locus_tag = X2)

annotations_for_contig <- annotations %>% left_join(annotation_index) %>% select(genecallerID, product) %>% drop_na()

# You can additional search the genes against the Pfam database of protein families
# Read Pfam annotations
genes_pfam_annot <- fread("EUs_vs_TARA_MAGs/sel_contigs/tara_anw_76_pfam_name_acc_clan_multi.tsv",
                          stringsAsFactors = F, header = F) %>% select(V1,V2) %>% setNames(c("gene_callers_id","pfam")


gff_genes_comb_geno <- TARA_ANW_MAG_00076_genecalls %>%
      full_join(annotations_for_contig %>% rename(gene_callers_id = genecallerID)) %>%
      full_join(genes_pfam_annot) %>%
      mutate(product=ifelse(is.na(product),pfam,product)) %>%
      mutate(product=ifelse(grepl('hypo',product) & !is.na(pfam),pfam,product)) %>%
      select(-pfam) %>% drop_na() %>%
      mutate(strand = case_when(direction == "r" ~ "-1",
                                direction == "f" ~ "1")) %>%
      mutate(strand = as.numeric(strand)) %>%
      select(gene_callers_id,contig, product, start, stop, strand) %>%
      rename(name = product, end = stop) %>%
      mutate(col = "gray", lty = 1 , lwd = 1 , pch = 8 , cex = 1, gene_type = "arrows")

sel_mag_1 <- gff_genes_comb_geno %>%
    mutate(hypo = ifelse(grepl("hypoth", name), "hypo",
                  ifelse(is.na(name),"hypo","non_hypo"))) %>%
    group_by(contig, hypo) %>% count() %>% ungroup() %>%
    group_by(contig) %>% mutate(N = sum(n), prop = n/N) %>% ungroup()

# Plot percentage of hypo and char proteins
sel_mag_1_order <- sel_mag_1 %>% filter(hypo != "hypo") %>% arrange((prop)) %>% mutate(contig=gsub("TARA_ANW_MAG_00076_","",contig)) %>% .$contig %>% unique
sel_mag_1_plot <- ggplot(sel_mag_1 %>% mutate(contig=gsub("TARA_ANW_MAG_00076_","",contig)) %>%
                        mutate(contig = fct_relevel(contig, c(purrr::discard(sel_mag_1$contig, sel_mag_1$contig %in% sel_mag_1_order), sel_mag_1_order))) %>%
                        filter(hypo=="hypo" & prop<=.85 & N > 12 | hypo=="non_hypo" & prop>=0.15 & N > 12),
                        aes(contig, prop, fill = hypo)) +
      geom_bar(stat = "identity", alpha = 0.9) +
      scale_y_continuous(labels = scales::percent, position = "right") +
      ggpubr::rotate() +
      theme_light() +
      ylab("Proportion") +
      xlab("TARA_ANW_MAG_00076") +
      scale_fill_manual(values = c("#A77A84","#233B43"),labels=c("Hypothetical protein","Characterised protein")) +
      theme( axis.title = element_text(size =7, colour = "black"),
             axis.text.x = element_text(size=6,colour = "black"),
             axis.text.y = element_text(size=6, colour = "black"),
             legend.position = "bottom",
             legend.title = element_blank(),
             legend.text = element_text(size=7),
             legend.key.size = unit(.4,"cm"))

# Gene plots
#retrive the position of the EU
sel_mag_eu <- mags_vs_eus_comb %>% filter(MAG=="TARA_ANW_MAG_00076") %>%
  select(gene_callers_id, clstr_ID) %>%
  right_join(TARA_ANW_MAG_00076_genecalls %>% mutate(gene_callers_id=as.character(gene_callers_id))) %>%
  select(clstr_ID,contig,start,stop) %>% rename(end=stop) %>%
  right_join(gff_genes_comb_geno, by=c("contig","start","end"))

sel_mag_eu1 <- sel_mag_eu %>% mutate(name=ifelse(is.na(clstr_ID),name,"EU")) %>%
  select(-clstr_ID) %>% distinct() %>%
  select(contig,gene_callers_id,name,start,end,strand,col,lty,lwd,pch,cex,gene_type) %>%
  mutate(size=abs(end-start+1))

# Plotting using genoPlotR
labelS <- 17L

df <- list(TARA_ANW_MAG_00076_000000001247 = as.dna_seg(sel_mag_eu1 %>% select(-gene_callers_id) %>%
                                                          filter(contig == "TARA_ANW_MAG_00076_000000001247") %>%
                                                          select(-contig) %>% as.data.frame()),
           TARA_ANW_MAG_00076_000000000672 = as.dna_seg(sel_mag_eu1 %>% select(-gene_callers_id) %>%
                                                         filter(contig == "TARA_ANW_MAG_00076_000000000672") %>%
                                                         select(-contig) %>% as.data.frame()))

annot<-lapply(df,function(x){annot<-annotation(x1=x$start+10,
                                               x2=x$end-10,
                                               text=x$name,
                                               rot=replicate(nrow(x),35));
annot$text<-paste(substr(x$name,start = 0,stop = labelS),"...")
annot})

uniqnames<-unique(do.call(rbind.data.frame, df)["name"])
uniqnames<-sort(uniqnames[,1])
color <- grDevices::colors()[grep('gr(a|e)y', grDevices::colors(), invert = T)]
colors<-sample(color, length(uniqnames))
df2color<-data.frame(as.matrix(uniqnames),as.matrix(colors))
df2color<-t(df2color)
colnames(df2color)<-df2color[1,]
df2color<- df2color[-1,]
df<-lapply(df,function(x){x["col"]<-"black";x})
df<-lapply(df,function(x){x["fill"]<-df2color[x$name];x})
uniqnames<-gsub(pattern = "_",x = as.matrix(uniqnames),replacement = " ")
uniqnames<-gsub(pattern = "[.]",x = as.matrix(uniqnames),replacement = ",")

plot(c(0,2000), c(0,2000), type="n", axes=FALSE, xlab="", ylab="")
legend("center", legend = c(as.matrix(uniqnames)),ncol = 1,xpd = NA, cex = 0.8,
       bty="n",fill=c(as.matrix(colors)),border = c("white"),title = "Genes")
plot_gene_map(dna_segs = df, dna_seg_label_cex = 0.4, fixed_gap_length = TRUE, annotations = annot, annotation_cex = 0.4)

# Plotting using ggenes
sel_mag_eu2 <- sel_mag_eu1 %>% filter(contig == "TARA_ANW_MAG_00076_000000000672") %>% filter(start <= 71000) %>%
  mutate(contig_coord=case_when(start>=140 & start < 23011 ~ paste(contig,"_1",sep=""),
                                start>=23011 & start < 42103 ~ paste(contig,"_2",sep=""),
                                start>=42103 & start <= 57656 ~ paste(contig,"_3",sep=""),
                                TRUE ~ paste(contig,"_4",sep="")))
sel_mag_eu2 <- sel_mag_eu1 %>% filter(contig =="TARA_ANW_MAG_00076_000000000672") #%>% filter(start <= 22120, start >=5434)

n <- length(unique(sel_mag_eu2$name))
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
col_vector[8] <- "dark blue"
col_vector[11] <- "#666666"
col_vector[16] <- "#7570B3"
#pie(rep(1,n), col=sample(col_vector, n))
mycolors <- colorRampPalette(brewer.pal(12, "Set3"))(n)

gene_plot <- ggplot(sel_mag_eu2, aes(xmin = start, xmax = end, y = contig, fill = name)) +
  geom_gene_arrow() +
  #facet_wrap(~ reorder(contig_coord,start), scales = "free", ncol=1) +
  scale_fill_manual(values = col_vector) +
  theme_genes() +
  theme(legend.position = "bottom") +
  ylab("") + xlab("")
