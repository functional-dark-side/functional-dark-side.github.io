library(tidyverse)
library(data.table)
library(sqldf)
library(RSQLite)

# setwd("/bioinf/projects/megx/UNKNOWNS/2017_11/DATA/contextual")
# List of samples obtained from the actual used metagenomes and orfs

samples <- fread("marine_hmp_samples.txt", stringsAsFactors = F, header = F) %>% setNames(c("sample_ID"))

# Retrieve and parse contextual data from different metagenomic projects:
#####################################
# GOS data upload
#####################################
# upload raw data
# wget http://datacommons.cyverse.org/browse/iplant/home/shared/imicrobe/projects/26/CAM_PROJ_GOS.csv
GOS_contexual_data <- read_csv("CAM_PROJ_GOS.csv", col_names = TRUE) %>%
  rename(sample_ID = SAMPLE_NAME, latitude = LATITUDE, longitude = LONGITUDE, depth = SITE_DEPTH, temperature = "temperature - (C)", salinity = "salinity - (psu)")
# Removing sample redundancy from GOS
# take mean of repeated sample data
GOS.numeric <- GOS_contexual_data %>%
  group_by(sample_ID) %>%
  select_if(is.numeric) %>%
  summarise_all(mean)
# only take one string from repeated sample data
GOS.character <- GOS_contexual_data %>%
  dplyr::select(-BIOMATERIAL_NAME, -MATERIAL_ACC, -SITE_NAME, -LIBRARY_ACC) %>%
  select_if(is.character) %>%
  group_by(sample_ID) %>%
  unique
# Join two lists of non-redundant GOS data
GOS_contexual_data <- inner_join(GOS.character, GOS.numeric, "sample_ID")

# remove unsequenced samples
GOS_unsequenced <- read_tsv("GOS_samples_unsequenced.txt", col_names = TRUE) %>%
    rename(sample_ID = "label")
GOS_contexual_data <- GOS_contexual_data %>% anti_join(GOS_unsequenced)
GOS_contexual_data <- GOS_contexual_data %>% anti_join(samples %>% filter(grepl("GS|MOVE", sample_ID)))
GOS_contexual_data <- GOS_contexual_data %>%
mutate(project = "GOS") %>%
  filter(!is.na(latitude)) # removed a strange row with a label without data

####################################
# Malaspina data upload
#####################################
# Changes were made to the titles of columns with aspects that could not be uploaded to R from Malaspina_Metadata_20170703.xls
# and made to Malaspina_Metadata_20170703_ed.txt. These are the header changes:
## - Nº OF REPLICATE -> # OF REPLICATE
## - Temp (°C) -> Temp
# Upload edited data
Malaspina_contexual_data <- read_tsv("Malaspina_Metadata_20170703_ed.txt", col_names = TRUE) %>%
  rename(sample_ID = "Code MP####", latitude = Lat, longitude = Long, depth = "DEPTH Megafile", temperature = "Temp", salinity = "Sal (PSU)") %>%
  dplyr::select(-Project) %>%
  mutate(project = "Malaspina")

Malaspina_header_corrections <- read_tsv("malaspina_header_corrections.txt", col_names = TRUE) %>% dplyr::select("contex", "orf") %>% drop_na()
# Add "MP" to every sample_ID
Malaspina_contexual_data$sample_ID <- paste0("MP", Malaspina_contexual_data$sample_ID)
# Headers that do not need to be corrected
Malaspina_contexual_data_1 <- Malaspina_contexual_data %>% filter(sample_ID %in% samples$sample_ID)
# Headers that need to be changed
Malaspina_contexual_data_2 <- Malaspina_contexual_data %>% filter(!sample_ID %in% samples$sample_ID)
# Replace headers that need to be changed with headers that match ORFs
Malaspina_contexual_data_2 <- Malaspina_contexual_data_2 %>% mutate(sample_ID = plyr::mapvalues(x = sample_ID, from = Malaspina_header_corrections$contex, to = Malaspina_header_corrections$orf))
# Bind rows headers that did not need to be changed and headers that were corrected
Malaspina_contexual_data <- bind_rows(Malaspina_contexual_data_1, Malaspina_contexual_data_2)

####################################
# TARA data upload
####################################
# Changes made from original TARA_metadata_pangaea.xlsx -> TARA_metadata_pangaea_ed.txt
# - removed "From http://doi.pangaea.de/10.1594/PANGAEA.853810" from first line
# - Tpot [°C] -> Tpot [degreesC]
# - 2 identical columns of OXYGEN [µmol/kg] (calculated from sensors calib...) -> deleted 1
# -OXYGEN [µmol/kg] (calculated from sensors calib...) -> OXYGEN_1 [micromol/kg]
# -OXYGEN [µmol/kg] (calculated from sensors calib...) -> OXYGEN_2 [micromol/kg]
# -NO3 [µmol/l] -> NO3 [micromol/l]
# -[NO2]-[µmol/l] -> [NO2]- [micromol/l]
# -PO4 [µmol/l] -> PO4 [micromol/l]
# -NO3+NO2 [µmol/l] -> NO3+NO2 [micromol/l]
# -Si(OH)4 [µmol/l] -> Si(OH)4 [micromol/l]
# -Chl a [mg/m**3] (calculated from sensors calib...) -> Chl a [mg/m**3]_1
# -Chl a [mg/m**3] (calculated from sensors calib...) -> Chl a [mg/m**3]_2
# -beta470 [m/sr] (in the selected environmental...) -> beta470 [m/sr]_1
# -beta470 [m/sr] (in the selected environmental...) -> beta470 [m/sr]_2
# -beta470 [m/sr] (in the selected environmental...) -> beta470 [m/sr]_3
# -bb470 [1/m] -> bb470 [1/m]_1
# -bb470 [1/m] -> bb470 [1/m]_2
# -Depth max Brunt V√§is√§l√§ freq [m] -> Depth max Brunt freq [m]
# -SST grad h [°C/100 km] -> SST grad h [degreesC/100 km]

# Upload edited TARA
TARA_contexual_data <- read_tsv("TARA_metadata_pangaea_ed.txt", col_names = TRUE) %>%
  mutate(project = "TARA") %>%
  rename(sample_ID = "ena_read_no", latitude = latitude_verb, longitude = longitude_verb, depth = "depth_verb", temperature = "Tpot [degreesC]", salinity = "Sal", oxygen = "OXYGEN_1 [micromol/kg]", sampleID_tara = SampleID)
TARA_contexual_data <- TARA_contexual_data %>% filter(sample_ID %in% samples$sample_ID)
# load Halpern data for TARA
load("halpern_data.Rda")
TARA_contexual_data <- TARA_contexual_data %>% left_join(out_rescaled_2013 %>% rename("sample_ID" = label))

####################################
# OSD data upload
####################################
# Upload and clean OSD
# These samples need to be removed from the OSD data set: (OSD10_2014-06-21_1m_NPL022,
#                                                         OSD18_2014-06-20_75m_NPL022,
#                                                         OSD72_2014-07-21_0.8m_NPL022,
#                                                         OSD96_2014-06-21_0m_NPL022,
#                                                         OSD168_2014-06-21_2m_NPL022)
OSD_contexual_data <- read_tsv("osd2014_metadata_18-01-2017.tsv", col_names = TRUE) %>%
  mutate(project = "OSD") %>%
  rename(sample_ID = "label", latitude = start_lat, longitude = start_lon, depth = "water_depth", temperature = "water_temperature", salinity = "salinity")
OSD_header_corrections <- read_tsv("OSD_header_corrections.txt", col_names = TRUE) %>% dplyr::select("contex", "orf") %>% drop_na()
OSD_headerstoberemoved <- c("OSD10_2014-06-21_1m_NPL022","OSD18_2014-06-20_75m_NPL022","OSD72_2014-07-21_0.8m_NPL022","OSD96_2014-06-21_0m_NPL022","OSD168_2014-06-21_2m_NPL022")
# there should be a false for each header to be removed
OSD_headerstoberemoved %in% OSD_contexual_data$sample_ID
# Headers that do not need to be changed
OSD_contexual_data_1 <- OSD_contexual_data %>% filter(sample_ID %in% samples$sample_ID)
# Headers that do need to be changed
OSD_contexual_data_2 <- OSD_contexual_data %>% filter(!sample_ID %in% samples$sample_ID)
# Replace headers that need to be changed with headers that match ORFs
OSD_contexual_data_2 <- OSD_contexual_data_2 %>% mutate(sample_ID = plyr::mapvalues(x = sample_ID, from = OSD_header_corrections$contex, to = OSD_header_corrections$orf))
# Bind rows headers that did not need to be changed and headers that were corrected
OSD_contexual_data <- bind_rows(OSD_contexual_data_1, OSD_contexual_data_2)

###################################
# Add Longhurst Province data
###################################
# get ecoregions
library(rgdal)
library(raster)
# for shapefiles, first argument of the read/write/info functions is the
# directory location, and the second is the file name without suffix
# optionally report shapefile details
ogrInfo(dsn = path.expand("Longhurst_world_v4_2010.shp"), layer = "Longhurst_world_v4_2010")
regions <- readOGR(dsn = path.expand("Longhurst_world_v4_2010.shp"), layer = "Longhurst_world_v4_2010")
#let's see the map
#plot(regions, axes=TRUE, border="gray")
# Function to add Longhurst ecoregion and province
getRegionalInfo  <- function(lat1, long1){
   #lat1 <- c(50.09444)
    #long1 <- c(-127.5589)
  #first, extract the co-ordinates (x,y - i.e., Longitude, Latitude)
  coords <- cbind(long1, lat1)

  FB.sp <- SpatialPointsDataFrame(coords,data.frame(value = c(4)))

  proj4string(FB.sp) <- CRS("+proj=longlat +datum=WGS84 +no_defs")

  #plot(regions)
  #plot(FB.sp, add=T)
  dsdat <- over(regions, FB.sp, add=T, fn = base::mean)

  ret <- data.frame(ProvCode = regions$ProvCode[which(dsdat$value==4)],
                    ProvDescr = regions$ProvDescr[which(dsdat$value==4)])

  if(nrow(ret)==0) ret <- data.frame(ProvCode = NA,
                                     ProvDescr = NA)
  return(ret)

}
# Name empty lists for each dataset
eco_regions_OSD <- vector(mode = "list")
eco_regions_TARA <- vector(mode = "list")
eco_regions_GOS <- vector(mode = "list")
eco_regions_Malaspina <- vector(mode = "list")
# populate the lists with province and ecoregion
for (i in 1:dim(OSD_contexual_data)[1]){
  lat <- OSD_contexual_data[i,]$latitude
  lon <- OSD_contexual_data[i,]$longitude
  eco_regions_OSD[[i]] <- cbind(OSD_contexual_data[i,]$sample_ID, getRegionalInfo(lat, lon))
}
for (i in 1:dim(TARA_contexual_data)[1]){
  lat <- TARA_contexual_data[i,]$latitude
  lon <- TARA_contexual_data[i,]$longitude
  eco_regions_TARA[[i]] <- cbind(TARA_contexual_data[i,]$sample_ID, getRegionalInfo(lat, lon))
}
for (i in 1:dim(GOS_contexual_data)[1]){
  lat <- GOS_contexual_data[i,]$latitude
  lon <- GOS_contexual_data[i,]$longitude
  eco_regions_GOS[[i]] <- cbind(GOS_contexual_data[i,]$sample_ID, getRegionalInfo(lat, lon))
}
for (i in 1:dim(Malaspina_contexual_data)[1]){
  lat <- Malaspina_contexual_data[i,]$latitude
  lon <- Malaspina_contexual_data[i,]$longitude
  eco_regions_Malaspina[[i]] <- cbind(Malaspina_contexual_data[i,]$sample_ID, getRegionalInfo(lat, lon))
}
# Bind data
# adding Longhurst to OSD
OSD_contexual_data <- bind_rows(eco_regions_OSD) %>%
  as_tibble() %>%
  rename(label = "OSD_contexual_data[i, ]$sample_ID", ecoregion = ProvCode, province = ProvDescr) %>%
  left_join(OSD_contexual_data %>% rename("label" = "sample_ID")) %>%
  rename(sample_ID = label)
# adding Longhurst to TARA
TARA_contexual_data <- bind_rows(eco_regions_TARA) %>%
  as_tibble() %>%
  rename(label = "TARA_contexual_data_1[i, ]$sample_ID", ecoregion = ProvCode, province = ProvDescr) %>%
  left_join(TARA_contexual_data %>% rename("label" = "sample_ID")) %>%
  rename(sample_ID = label)
# adding Longhurst to Malaspina
Malaspina_contexual_data <- bind_rows(eco_regions_Malaspina) %>%
  as_tibble() %>%
  rename("label" = "Malaspina_contexual_data_4[i, ]$sample_ID", ecoregion = ProvCode, province = ProvDescr) %>%
  left_join(Malaspina_contexual_data %>% rename("label" = "sample_ID")) %>%
  rename(sample_ID = label)
# adding Longhurst to GOS
GOS_contexual_data <- bind_rows(eco_regions_GOS) %>%
  as_tibble() %>%
  rename("label" = "GOS_contexual_data_3[i, ]$sample_ID", ecoregion = ProvCode, province = ProvDescr) %>%
  left_join(GOS_contexual_data %>% rename("label" = "sample_ID")) %>%
  rename(sample_ID = label)

######################
# HMP data upload
######################
HMP_contextual_data <- fread("HMP_phase2017_cdata.txt") %>% select(-V10) %>%
  setNames(c("sample_ID","NCBI_project_id" ,"HMP_isolation_body_site","HMP_isolation_body_subsite","gene_count",
             "IMG_HMP_ID","sequencing_center","addition_date","last_modification_date"))

################################################
#  Upload contextual data to SQLite
#################################################
# Create SQL database
db <- dbConnect(SQLite(), dbname = "contextual_data.db")
# Print characteristics of database
str(db)
# add table to database
# - conn = database you want to put the table into
# - value equal R datatable you want to upload to SQLite
dbWriteTable(conn = db, name = "OSD_contex", value = OSD_contexual_data)
dbWriteTable(conn = db, name = "TARA_contex", value = TARA_contexual_data)
dbWriteTable(conn = db, name = "Malaspina_contex", value = Malaspina_contexual_data)
dbWriteTable(conn = db, name = "GOS_contex", value = GOS_contexual_data)
dbWriteTable(conn = db, name = "HMP_contex", value = HMP_contexual_data)

# Query and modify SQL database
db <- dbConnect(SQLite(), dbname = "~/Desktop/MarMic/msc_thesis/matt_msc/databases/contextual_data.db")
# SQL query to make new table within the db
dbFetch(dbSendQuery(db, "CREATE TABLE mg_contextual_data_all AS
  SELECT sample_ID, project, longitude, latitude, ecoregion, province, depth, temperature, salinity FROM OSD_contex UNION
  SELECT sample_ID, project, longitude, latitude, ecoregion, province, depth, temperature, salinity FROM TARA_contex UNION
  SELECT sample_ID, project, longitude, latitude, ecoregion, province, depth, temperature, salinity FROM Malaspina_contex UNION
  SELECT sample_ID,  project, longitude, latitude, ecoregion, province, depth, temperature, salinity FROM GOS_contex"))
# Read a SQL table inside database db
contexual_data_all <- dbReadTable(db, "mg_contextual_data_all")
# list all tables inside database db
dbListTables(db)
# Always disconnect from the SQL database
dbDisconnect(db)

##########################################################################
## Set of High-quality samples to use for the environmental analyses
#########################################################################
# Functions for pretty histograms
nclass.all <- function(x, fun = median)
{
  fun(c(
    nclass.Sturges(x),
    nclass.scott(x),
    nclass.FD(x)
  ))
}
​
calc_bin_width <- function(x, ...)
{
  rangex <- range(x, na.rm = TRUE)
  (rangex[2] - rangex[1]) / nclass.all(x, ...)
}
​
StatPercentileX <- ggproto("StatPercentileX", Stat,
                           compute_group = function(data, scales, probs) {
                             percentiles <- quantile(data$x, probs=probs)
                             data.frame(xintercept=percentiles)
                           },
                           required_aes = c("x")
)
​
stat_percentile_x <- function(mapping = NULL, data = NULL, geom = "vline",
                              position = "identity", na.rm = FALSE,
                              show.legend = NA, inherit.aes = TRUE, ...) {
  layer(
    stat = StatPercentileX, data = data, mapping = mapping, geom = geom,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}
​
StatPercentileXLabels <- ggproto("StatPercentileXLabels", Stat,
                                 compute_group = function(data, scales, probs) {
                                   percentiles <- quantile(data$x, probs=probs)
                                   data.frame(x=percentiles, y=Inf,
                                              label=paste0("p", probs*100, ": ",
                                                           scales::comma(round(10^percentiles, digits=1))))
                                 },
                                 required_aes = c("x")
)
​
stat_percentile_xlab <- function(mapping = NULL, data = NULL, geom = "text",
                                 position = "identity", na.rm = FALSE,
                                 show.legend = NA, inherit.aes = TRUE, ...) {
  layer(
    stat = StatPercentileXLabels, data = data, mapping = mapping, geom = geom,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}

### Collect and gather metagenomic projects contextual data:

​#######################################################################
​# Create the final set of sample to use for the environmental analyses
#######################################################################
# Get assemblies
HMP1_I_assm <- read_csv("~/Downloads/HMASM.csv") %>%
  select(1:2) %>%
  setNames(c("label", "body_site"))
​
# Read data
data <- read_tsv("/DATA/contextual/marine_hmp_smpl_norfs.tsv.gz", col_names = FALSE) %>%
  setNames(c("label", "norfs")) %>%
  mutate(study = case_when(grepl("^TARA", label) ~ "TARA",
                           grepl("^MP", label) ~ "MALASPINA",
                           grepl("^OSD", label) ~ "OSD",
                           grepl("^SRS", label) ~ "HMP",
                           TRUE ~ "GOS"))
​
# Read HMP QC samples
HMP_qc <- read_tsv("~/Downloads/HMP_qc_passed.txt", col_names = FALSE) %>%
  setNames("label")
# Get all cdata
# HMP1-I date = 2011
# HMP1-II date = 2014
HMP_cdata <- read_csv("~/Downloads/HMP_phase2017_cdata.txt", col_names = FALSE) %>%
  mutate(phase = case_when(grepl("2011", X8) ~ "HMP1-I",
                           TRUE ~ "HMP1-II")) %>%
  select(X1, phase) %>% rename(label = X1)
​
# Get bad HMP1-I samples
# 745 samples
HMP1_I <- HMP_cdata %>%
  inner_join(HMP1_I_assm)
​
# 690 HQ
HMP_bad <- HMP1_I %>%
  filter(phase == "HMP1-I", !(label %in% HMP_qc$label))
​
#
data_orig <- data %>%
  filter(!(label %in% HMP_bad$label))
​
data %>%
  group_by(study) %>%
  count()
​
data_orig %>%
  group_by(study) %>%
  count()
​
nsamples <- data_orig %>%
  group_by(study) %>%
  count()
​
data_orig_summary <- summary(data_orig$norfs)
​
ggthemr::ggthemr(palette = "fresh", layout = "scientific")
data_orig %>%
  ggplot(aes(norfs)) +
  geom_histogram(binwidth = calc_bin_width(log10(data_orig$norfs)), color = "black", alpha = 0.7) +
  stat_percentile_x(probs=c(0.25, 0.5, 0.75), linetype=2, color = "#B7144B") +
  stat_percentile_xlab(probs=c(0.25, 0.5, 0.75), hjust=1, vjust=1.5, angle=90) +
  scale_x_log10(labels = scales::comma) +
  xlab("Number of ORFs") +
  ylab("Counts")
​
p25 <- quantile(data_orig$norfs, probs=0.25)
​
orfXsample <- data_orig %>%
  filter(norfs >= p25) %>%
  group_by(study) %>%
  count(sort = TRUE)
​
# Get final set of samples
data_final <- data_orig %>%
  filter(norfs >= p25)
## Write as "listSamplesPaper.tsv": lebel - norfs - study
write.table(data_final,"DATA/contextual/listSamplesPaper.tsv", col.names=T,row.names=F,sep="\t",quote=F)
​
#Plot
data_final %>%
  ggplot(aes(norfs)) +
  geom_histogram(binwidth = calc_bin_width(log10(data_orig$norfs)), color = "black", alpha = 0.7) +
  stat_percentile_x(probs=c(0.25, 0.5, 0.75), linetype=2, color = "#B7144B") +
  stat_percentile_xlab(probs=c(0.25, 0.5, 0.75), hjust=1, vjust=1.5, angle=90) +
  scale_x_log10(labels = scales::comma) +
  xlab("Number of ORFs") +
  ylab("Counts")


###
