library(tidyverse)
library(data.table)

# eDUFs (Goodacre, Gerloff, and Uetz 2013)
# many DUFs are essential DUFs (eDUFs) based on their presence in essential proteins. We also show that eDUFs are often essential even if they are found in relatively few genomes. However, in general, more common DUFs are more often essential than rare DUFs.
# more than 20% of all domains in the Pfam database, the ~3,600 so-called domains of unknown function (DUFs) (Pfam31 ~4K DUFs still 20%)
# the 19 bacterial species represented in the Database of Essential Genes (DEG) (14), more than 10,000 essential genes have been identified (including redundancies). We found 393 of these proteins to contain at least one of 255 different DUFs While 83 of those proteins contain multiple domains, the remaining appears to contain only the eDUF.
# While highly conserved DUFs are more likely to be essential, poorly conserved DUFs (as measured by the number of genomes they are found in) are still essential in many cases

gu <- fread("GU_annotations.tsv", stringsAsFactors = F, header = T)
s <- strsplit(gu$annot, split = "\\|")
gu_long <- data.frame(cl_name = rep(gu$cl_name, sapply(s, length)), annot = unlist(s)) %>% mutate(annot=as.character(annot))

# essenzial DUFs in GUs
# List of eDUFs obtained from Goodacre et al. 2013
# https://mbio.asm.org/highwire/filestream/23865/field_highwire_adjunct_files/5/mbo006131694st1.xls
# Sheet F-eDUF converted to tsv 
eduf <- fread("essential_DUFs.tsv", stringsAsFactors = F, header = F) %>% setNames(c("pfam","annot"))

eduf_gu <- eduf %>% left_join(gu_long)

eduf_only_gu <- eduf_gu %>% drop_na %>% select(annot) %>% distinct()
length(unique(eduf_only_gu$annot))

eduf_gu_ids <- duf_only_gu %>% select(cl_name) %>% distinct()
write.table(eduf_gu_ids,"eDUF_GUs.txt", col.names = F, row.names = F, quote = F, sep = "\t")

#Lineage specific eDUF GUs:
load("gtdb_bac_r86_plot.Rda")
f1b <- f1
load("gtdb_arc_r86_plot.Rda")
f1a <- f1

f1_gu <- rbind(f1a,f1b) %>% filter(categ=="GU") %>% select(-categ) %>%
separate(trait,into=c("categ","cl_name"), sep="_", drop=T)

lineage_sp_eduf_gu <- eduf_gu %>% left_join(f1_gu)
write.table(lineage_sp_eduf_gu,"Lineage_sp_eDUF_GUs.tsv", col.names = F, row.names = F, quote = F, sep = "\t")
