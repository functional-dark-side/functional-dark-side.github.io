#!/bin/bash
set -e
function error_handler() {
  printf "${RED}ERROR:${NC} Error occurred in script at line: ${RED}${1}${NC}\n"
  printf "${RED}ERROR:${NC} Line exited with status: ${RED}${2}${NC}\n"
  exit
}

trap 'error_handler ${LINENO} $?' ERR

declare -r GREEN='\033[1;32m'
declare -r RED='\033[1;31m'
declare -r YELLOW='\033[1;33m'
declare -r CYAN='\033[1;36m'
declare -r PURPLE='\033[1;35m'
# declare -r BLUE='\033[1;34m'
declare -r GREY='\033[1;30m'
declare -r NC='\033[0m'

declare -r SEQKITBIN=seqkit
declare -r TAXACONBIN=/scratch/cvanni/PRs/WF/EPA-NG/taxnameconvert-2.4/taxnameconvert.pl
declare -r MODELTBIN=/scratch/cvanni/PRs/WF/EPA-NG/modeltest-ng
declare -r RAXMLBIN=~/opt/standard-RAxML/raxmlHPC-PTHREADS-AVX2
declare -r F2PBIN=/scratch/cvanni/PRs/WF/scripts/fasta2phylip.py
declare -r PAPABIN=/scratch/cvanni/PRs/WF/papara
declare -r EPABIN=epa-ng
declare -r ODSEQBIN=~/opt/OD-Seq/OD-seq
declare -r TAXITBIN=taxit
declare -r PPLACERBIN=pplacer
declare -r GAPPABIN=gappa
declare -r CDHITBIN=cdhit
declare -r ORFANNOT=/scratch/cvanni/PRs/WF/scripts/annotate_query_sequences.R
declare -r THREADS=64
declare -r GUPPYBIN=guppy
declare -r ALLUVIALBIN=/scratch/cvanni/PRs/WF/scripts/create_alluvial.R
#declare -r COMPFILE=k_components.tsv
# Files used during the analysis

#

# Basic files
model_files=(MT.ckp MT.log MT.out)
raxml_files=(RAxML_binaryModelParameters.OPT RAxML_info.OPT RAxML_log.OPT RAxML_result.OPT)
papara_files=(MICrhoDE_prot_aligned.fixed.phy query.0.fasta query.0.core.fasta query.0.outlier.fasta query.fasta papara_alignment.ALN papara_alignment.ALN0 papara_log.ALN papara_log.ALN0 papara_quality.ALN papara_quality.ALN0)
epang_files=(EPA_PR/epa_info.log EPA_PR/epa_result.jplace)
pplacer_files=(query.PR.jplace)
#gappa_files_e=(epa-ng_labelled_tree epa-ng_per_pquery_assign epa-ng_profile.csv MICrhoDE_prot_aligned.query-SC.epa-ng.tsv)
#gappa_files_p=(pplacer_labelled_tree pplacer_per_pquery_assign pplacer_profile.csv MICrhoDE_prot_aligned.query-SC.pplacer.tsv)
basic_files_download=(k_tax_stat.tsv.gz  kwp_tax_stat.tsv.gz  gu_tax_stat.tsv.gz k_cl_orfs.tsv.gz kwp_cl_orfs.tsv.gz gu_cl_orfs.tsv.gz)
basic_files=(k_tax_stat.tsv.gz  kwp_tax_stat.tsv.gz  gu_tax_stat.tsv.gz k_cl_orfs.tsv.gz kwp_cl_orfs.tsv.gz gu_cl_orfs.tsv.gz k_pr_tax.tsv kwp_pr_tax.tsv gu_pr_tax.tsv k_pr_orfs.tsv kwp_pr_orfs.tsv gu_pr_orfs.tsv)
graft_files_e=(grafted_tree.epa-ng.tre)
graft_files_p=(grafted_tree.pplacer.tre)
annot_files_e=(epa-ng_per_pquery_assign.tsv)
annot_files_p=(pplacer_per_pquery_assign.tsv)
dedup_files=(all_sequences_names_to_extract.dedup all_sequences_names_to_extract.dedup.clstr)
itol_files=(MICrhoDE_itol_strip.txt MICrhoDE_SC_colors.txt MICrhoDE_query-SC_colors.txt MICrhoDE_itol_strip_query-SC.epa-ng.txt MICrhoDE_itol_strip_query-SC.pplacer.txt)
alluvial_files=(PR_tax_orf.pplacer.tsv PR_tax_orf.pplacer.tsv PR_tax_orf.epa-ng.tsv PR_tax_orf.epa-ng.tsv alluvial_data.pplacer.tsv alluvial_data.epa-ng.tsv)

function create_alluvial (){
  cat <(printf "short_name\torf\tcl_name\ttaxid\tfunc\tsize\tspecies\tgenus\tfamily\torder\tclass\tphylum\tsuperkingdom\tcategory\tsupercluster\n") > PR_tax_orf."${1}".tsv
  join -t $'\t' -1 13 -2 1 <(sort -t $'\t' -k13,13 <(cat <(awk '{print $0"\tk"}' k_pr_tax.tsv) <(awk '{print $0"\tkwp"}' kwp_pr_tax.tsv) <(awk '{print $0"\tgu"}' gu_pr_tax.tsv))) <(sort -t $'\t' -k1,1 <(cat "${1}"_per_pquery_assign.tsv | tr ';' $'\t' | cut -f1,2)) >> PR_tax_orf."${1}".tsv
  cat <(printf "orf\tcl_name\tshort_name\tcategory\n") <(awk '{print $0"\tk"}' k_pr_orfs.tsv) <(awk '{print $0"\tkwp"}' kwp_pr_orfs.tsv) <(awk '{print $0"\tgu"}' gu_pr_orfs.tsv) > PR_cl_orf."${1}".tsv
  "${ALLUVIALBIN}" -d PR_tax_orf."${1}".tsv -p 64 -c "${COMPFILE}" -o alluvial_data."${1}".tsv
}


function get_time() {
  TIME=$(date +%T)
  printf "[${GREY}${TIME}${NC}]"
}

function gappa_assign () {
  "${GAPPABIN}" analyze assign --jplace-path "${1}" --taxon-file MICrhoDE_prot_aligned.SC.tsv
  sed ':a;N;/\nseq/!s/\n/\t/;ta;P;D' per_pquery_assign | awk -vFS="\t" '{if(NF > 2){print $1"\t"$6}else{print $1"\tNO_ASSIGN"}}' > MICrhoDE_prot_aligned.query-SC."${2}".tsv
  mv labelled_tree "${2}"_labelled_tree
  mv profile.csv "${2}"_profile.csv
  mv per_pquery_assign "${2}"_per_pquery_assign
}

function graft_tree () {
  "${GUPPYBIN}" tog -o grafted_tree."${2}".tre "${1}"
}

function orf_assign (){
  "${ORFANNOT}" -t "${1}" -d "${2}" -p "${THREADS}" -o  "${3}"_per_pquery_assign.tsv
}

function check_files_missing(){
  files=("$@")
  ALL=0
  for file in "${files[@]}"; do
    if [ ! -f "${file}" ]; then
      ALL=1
    fi
  done
  echo "${ALL}"
}

function create_basic_data (){
  # Generate files for alluvial plots
  # Prepare results from HMMER
  # Get consensus taxonomy for each orf
  files=("$@")
  printf "$(get_time)    Rsyncing cluster data from ${YELLOW}temp storage location${NC}..."
  for file in "${files[@]}"; do
    #URL=http://files.metagenomics.eu/unknowns/
    #wget -qN "${URL}"/"${file}"
    rsync -Pauvx /scratch/cvanni/temp_data/"${file}" .
  done
  printf " ${GREEN}done${NC}\n"
  
  printf "$(get_time)    Filtering taxonomic information ${RED}[get a coffee]${NC}..."
  join -t $'\t' -1 2 -2 1 <(zcat k_tax_stat.tsv.gz | sort --parallel="${THREADS}" -S20%  -k2,2) <(sort -k1,1 "${NAM}".name_mapping.tsv) > k_pr_tax.tsv
  join -t $'\t' -1 2 -2 1 <(zcat kwp_tax_stat.tsv.gz | sort --parallel="${THREADS}" -S20%  -k2,2) <(sort -k1,1 "${NAM}".name_mapping.tsv) > kwp_pr_tax.tsv
  join -t $'\t' -1 2 -2 1 <(zcat gu_tax_stat.tsv.gz | sort --parallel="${THREADS}" -S20%  -k2,2) <(sort -k1,1 "${NAM}".name_mapping.tsv) > gu_pr_tax.tsv
  printf " ${GREEN}done${NC}\n"

  printf "$(get_time)    Adding cluster information to query sequences ${RED}[get a coffee]${NC}..."
  join -t $'\t' -1 2 -2 1 <(zcat k_cl_orfs.tsv.gz | tr ' ' $'\t' | sort --parallel="${THREADS}" -S20%  -k2,2) <(sort -k1,1 "${NAM}".name_mapping.tsv) > k_pr_orfs.tsv
  join -t $'\t' -1 2 -2 1 <(zcat kwp_cl_orfs.tsv.gz | tr ' ' $'\t' | sort --parallel="${THREADS}" -S20%  -k2,2) <(sort -k1,1 "${NAM}".name_mapping.tsv) > kwp_pr_orfs.tsv
  join -t $'\t' -1 2 -2 1 <(zcat gu_cl_orfs.tsv.gz | tr ' ' $'\t' | sort --parallel="${THREADS}" -S20%  -k2,2) <(sort -k1,1 "${NAM}".name_mapping.tsv) > gu_pr_orfs.tsv
  printf " ${GREEN}done${NC}\n"
}

function create_itol_data () {
  paste <(cut -f2 MICrhoDE_prot_aligned.SC.0.tsv | sort -u)  <(printf "#72d9d3\n#e7abd3\n#bfd89b\n#9fbeed\n#e6bb8f\n#b2d6c8\n#dac4c8") > MICrhoDE_SC_colors.txt
  cat <(printf "DATASET_COLORSTRIP\nSEPARATOR TAB\nDATASET_LABEL\tSuperCluster\nCOLOR\t#ff0000\nCOLOR_BRANCHES\t0\nDATA\n\n") <(join -t $'\t' -1 2 -2 1 <(sort -t $'\t' -k2,2 MICrhoDE_prot_aligned.SC.0.tsv) <(sort -k1,1 MICrhoDE_SC_colors.txt) | awk -vFS="\t" '{print $2"\t"$5"\t"$1}') > MICrhoDE_itol_strip.txt

  # Create data file for iTOL using the grappa assignments
  paste <(cut -f2 MICrhoDE_prot_aligned.SC.0.tsv | sort -u)  <(printf "#72d9d3\n#e7abd3\n#bfd89b\n#9fbeed\n#e6bb8f\n#b2d6c8\n#dac4c8") > MICrhoDE_qurey-SC_colors.txt
  cat MICrhoDE_SC_colors.txt <(printf "NO_ASSIGN\t#000000") >>  MICrhoDE_query-SC_colors.txt
  cat MICrhoDE_itol_strip.txt <(join -t $'\t' -1 2 -2 1 <(sort -t $'\t' -k2,2 <(cat pplacer_per_pquery_assign.tsv | tr ';' $'\t' | cut -f1,2)) <(sort -k1,1 MICrhoDE_query-SC_colors.txt) | awk -vFS="\t" '{print $2"\t"$3"\t"$1}') > MICrhoDE_itol_strip_query-SC.pplacer.txt
  cat MICrhoDE_itol_strip.txt <(join -t $'\t' -1 2 -2 1 <(sort -t $'\t' -k2,2 <(cat epa-ng_per_pquery_assign.tsv | tr ';' $'\t' | cut -f1,2)) <(sort -k1,1 MICrhoDE_query-SC_colors.txt) | awk -vFS="\t" '{print $2"\t"$3"\t"$1}') > MICrhoDE_itol_strip_query-SC.epa-ng.txt
}

if [ $# -eq 0 ]; then
    printf "$(get_time) ${RED}ERROR:${NC} No arguments supplied. Provide a ${CYAN}FASTA${NC} file with sequences to be placed\n"
    exit 1
fi

QUERY=${1}
COMPFILE=${2}

if [ ${QUERY: -6} != ".fasta" ]; then
  printf "$(get_time) ${RED}ERROR:${NC} Provide a ${CYAN}FASTA${NC} file with sequences to be placed with ${CYAN}.fasta${NC} extension\n"
  exit 1
fi

NAM=$(basename "${QUERY}" .fasta)

# Remove everything after STOP (*) codon on MICrhoDE_prot_aligned.fasta
printf "$(get_time) Getting data from ${YELLOW}MICrhoDE${NC}..."
#wget -N -q http://application.sb-roscoff.fr/micrhode/MICrhoDE_prot_aligned.fasta
#wget -N -q http://application.sb-roscoff.fr/micrhode/MicRhoDE_051214.txt
#wget -N -q http://application.sb-roscoff.fr/micrhode/tree_MicRhoDE_complete.nwk
printf " ${GREEN}done${NC}\n"

printf "$(get_time) Fixing ${YELLOW}MICrhoDE${NC} alignments..."
sed -i -e 's/*p/--/' MICrhoDE_prot_aligned.fasta
# Convert lowercase sequences to uppercase
"${SEQKITBIN}" replace -p .+ -r "ref-{nr}" MICrhoDE_prot_aligned.fasta | seqkit seq -u > MICrhoDE_prot_aligned.fixed.fasta
paste <(grep '>' MICrhoDE_prot_aligned.fasta | tr -d '>') <(grep '>' MICrhoDE_prot_aligned.fixed.fasta | tr -d '>') > MICrhoDE_prot_aligned.name_mapping.tsv
printf " ${GREEN}done${NC}\n"

printf "$(get_time) Fixing ${YELLOW}MICrhoDE${NC} tree..."
# Rename tree (http://www.cibiv.at/software/taxnameconvert/)
"${TAXACONBIN}" -f 1 -t 2 MICrhoDE_prot_aligned.name_mapping.tsv tree_MicRhoDE_complete.nwk tree_MicRhoDE_complete.renamed.nwk > /dev/null 2>&1
printf " ${GREEN}done${NC}\n"


printf "$(get_time) Dereplicating query sequences...\n"
PRES=$(check_files_missing "${dedup_files[@]}")
if [ "${PRES}" -eq 0  ]; then
  printf "$(get_time) Dereplicating query sequences... ${RED}skipped${NC}: File exists.\n"
else
  rm -f "${dedup_files[@]}"
  "${CDHITBIN}" -i "${QUERY}" -c 1 -d 0 -o "${NAM}".dedup
  printf "$(get_time) Dereplicating query sequences... ${GREEN}done${NC}\n"
fi


printf "$(get_time) Fixing query sequences..."
# Remove sequences with an X from our PRs
# Convert lowercase sequences to uppercase
"${SEQKITBIN}" replace -p .+ -r "seq-{nr}" "${NAM}".dedup | seqkit seq -u > "${NAM}".fixed.fasta
paste <(grep '>' "${NAM}".dedup | tr -d '>') <(grep '>' "${NAM}".fixed.fasta | tr -d '>') > "${NAM}".name_mapping.tsv
"${SEQKITBIN}" grep -v -s -p X -r  "${NAM}".fixed.fasta > "${NAM}".noX.fasta
printf " ${GREEN}done${NC}\n"

printf "$(get_time) Filtering sequences smaller than 100aa..."
# Keep sequences longer than 100aa
"${SEQKITBIN}" seq --quiet -m 100 "${NAM}".noX.fasta > "${NAM}".noX.100.fasta 2> /dev/null
printf " ${GREEN}done${NC}\n"

printf "$(get_time) Identifying best substitution model...\n"
PRES=$(check_files_missing "${model_files[@]}")
if [ "${PRES}" -eq 0  ]; then
  printf "$(get_time) Identifying best substitution model... ${RED}skipped${NC}: File exists.\n"
  BESTM=$(grep Model: MT.out | awk '{print $2}' | sort | uniq -c | sort -k1,1nr | awk NR==1'{print $2}')
  BESTMR=$(grep raxmlHPC MT.out | awk '{print $6}' | uniq -c | sort -k1,1nr | awk NR==1'{print $2}')
  printf "$(get_time) Best model: ${GREEN}${BESTM}${NC}\n"
else
  rm -f "${model_files[@]}"
  # Use modeltest to find the best model
  "${MODELTBIN}" -i MICrhoDE_prot_aligned.fixed.fasta -o MT -p "${THREADS}" -d aa -T raxml --force -t user -u tree_MicRhoDE_complete.renamed.nwk
  BESTM=$(grep Model: MT.out | awk '{print $2}' | sort | uniq -c | sort -k1,1nr | awk NR==1'{print $2}')
  BESTMR=$(grep raxmlHPC MT.out | awk '{print $6}' | uniq -c | sort -k1,1nr | awk NR==1'{print $2}')
  printf "$(get_time) Identifying best substitution model... ${GREEN}done${NC}\n"
  printf "$(get_time) Best model: ${GREEN}${BESTM}${NC}\n"
fi

printf "$(get_time) Optimizing initial tree parameters and branch lengths...\n"
PRES=$(check_files_missing "${raxml_files[@]}")
if [ "${PRES}" -eq 0  ]; then
  printf "$(get_time) Optimizing initial tree parameters and branch lengths... ${RED}skipped${NC}: File exists.\n"
else
  rm -f "${raxml_files[@]}"
  # Optimize tree parameters and branch lengths
  [ -f RAxML_log.OPT ] && rm -rf *.OPT
  "${RAXMLBIN}" -s MICrhoDE_prot_aligned.fixed.fasta -T "${THREADS}" -f e -n OPT -t tree_MicRhoDE_complete.renamed.nwk -m "${BESTMR}"
  printf "$(get_time) Optimizing initial tree parameters and branch lengths... ${GREEN}done${NC}\n"
fi

# Add our PRs seqs to the REF alignment with PaPaRA (https://github.com/sim82/papara_nt)
# First we need to patch the PaPaRA pvec.h. Get patch from: https://gist.github.com/genomewalker/a3f03846cf7e5ad63be63a9c8c153301
# Patch the file
# git clone --recursive https://github.com/sim82/papara_nt
# cd papara_nt || exit "Cannot create folder"
# wget https://gist.githubusercontent.com/genomewalker/a3f03846cf7e5ad63be63a9c8c153301/raw/4cee4913ea576806f504d47f6e5702e228f9307c/pvec.h.patch
# patch < pvec.h.patch

printf "$(get_time) ${PURPLE}[Iter 1]:${NC} Aligning query sequences to reference alignment with PaPaRA...\n"
PRES=$(check_files_missing "${papara_files[@]}")
if [ "${PRES}" -eq 0  ]; then
  printf "$(get_time) Aligning query sequences to reference alignment with PaPaRA... ${RED}skipped${NC}: File exists.\n"
else
  rm -f "${papara_files[@]}"
  # Convert FASTA ref alignment to relaxed phylip
  "${F2PBIN}" -i  MICrhoDE_prot_aligned.fixed.fasta -o MICrhoDE_prot_aligned.fixed.phy -r > /dev/null 2>&1
  # Align query sequences to reference alignment

  [ -f papara_log.ALN0 ] && rm -rf *ALN0
  "${PAPABIN}" -t RAxML_result.OPT -s MICrhoDE_prot_aligned.fixed.phy -q "${NAM}".noX.100.fasta -a -j "${THREADS}" -n ALN0 -r
  # We will use epa-ng to place the query sequences into the reference tree
  # First we split the alignment in reference and query
  "${EPABIN}" --split MICrhoDE_prot_aligned.fixed.phy papara_alignment.ALN0
  printf "$(get_time) ${PURPLE}[Iter 1]:${NC} Aligning query sequences to reference alignment with PaPaRA... ${GREEN} done${NC}\n"

  printf "$(get_time) Identifying outliers (OD-Seq) in query alignment..."
  [ -f query.fasta ] && mv query.fasta query.0.fasta
  "${ODSEQBIN}" -t 24 -i query.0.fasta -c query.0.core.fasta -o query.0.outlier.fasta
  printf "$(get_time) Identifying outliers (OD-Seq) in query alignment... ${GREEN}done${NC}\n"

  printf "$(get_time) ${PURPLE}[Iter 2]:${NC} Aligning core query sequences to reference alignment with PaPaRA...\n"
  # Align query sequences to reference alignment
  [ -f papara_alignment.ALN ] && rm -rf *ALN
  "${PAPABIN}"  -t RAxML_result.OPT -s MICrhoDE_prot_aligned.fixed.phy -q query.0.core.fasta -a -j "${THREADS}" -n ALN -r
  # We will use epa-ng to place the query sequences into the reference tree
  # First we split the alignment in reference and query
  [ -f query.fasta ] && rm -rf query.fasta
  "${EPABIN}" --split MICrhoDE_prot_aligned.fixed.phy papara_alignment.ALN
  printf "$(get_time) ${PURPLE}[Iter 2]:${NC} Aligning core query sequences to reference alignment with PaPaRA... ${GREEN}done${NC}\n"
fi

printf "$(get_time) Placing query sequences to reference tree using ${CYAN}epa-ng${NC}...\n"
PRES=$(check_files_missing "${epang_files[@]}")
if [ "${PRES}" -eq 0  ]; then
  printf "$(get_time) Placing query sequences to reference tree using ${CYAN}epa-ng${NC}... ${RED}skipped${NC}: File exists.\n"
else
# And place the sequences
rm -f "${epang_files[@]}"
mkdir -p EPA_PR
"${EPABIN}" --tree RAxML_result.OPT --ref-msa MICrhoDE_prot_aligned.fixed.fasta --query query.fasta --outdir EPA_PR --model "${BESTM}" -T "${THREADS}"
printf "$(get_time) Placing query sequences to reference tree using ${CYAN}epa-ng${NC}... ${GREEN}done${NC}\n"
fi

printf "$(get_time) Placing query sequences to reference tree using ${CYAN}pplacer${NC}...\n"
PRES=$(check_files_missing "${pplacer_files[@]}")
if [ "${PRES}" -eq 0  ]; then
  printf "$(get_time) Placing query sequences to reference tree using ${CYAN}epa-ng${NC}... ${RED}skipped${NC}: File exists.\n"
else
  rm -f "${pplacer_files[@]}"
  # Place sequences with pplacer
  "${TAXITBIN}" create -l PR -P PR.refpkg --aln-fasta MICrhoDE_prot_aligned.fixed.fasta --tree-stats RAxML_info.OPT --tree-file RAxML_result.OPT
  "${PPLACERBIN}" -o query.PR.jplace -p --keep-at-most 20 -c PR.refpkg query.fasta -j "${THREADS}"
  printf "$(get_time) Placing query sequences to reference tree using ${CYAN}pplacer${NC}... ${GREEN}done${NC}\n"
fi

# 2. Assign taxonomy

# PRES=$(check_files_missing "${gappa_files_e[@]}")
# if [ "${PRES}" -eq 0  ]; then
#   printf "$(get_time) Assigning SuperCluster affiliation with ${CYAN}gappa${NC} using the ${CYAN}epa-ng${NC} results... ${RED}skipped${NC}: File exists.\n"
# else
#   rm -f "${gappa_files_e[@]}"
#   gappa_assign EPA_PR/epa_result.jplace epa-ng
#   printf "$(get_time) Assigning SuperCluster affiliation with ${CYAN}gappa${NC} using the ${CYAN}epa-ng${NC} results... ${GREEN}done${NC}\n"
# fi
#
# printf "$(get_time) Assigning SuperCluster affiliation with ${CYAN}gappa${NC} using the ${CYAN}pplacer${NC} results...\n"
# PRES=$(check_files_missing "${gappa_files_p[@]}")
# if [ "${PRES}" -eq 0  ]; then
#   printf "$(get_time) Assigning SuperCluster affiliation with ${CYAN}gappa${NC} using the ${CYAN}pplacer${NC} results... ${RED}skipped${NC}: File exists.\n"
# else
#   rm -f "${gappa_files_p[@]}"
#   gappa_assign query.PR.jplace pplacer
#   printf "$(get_time) Assigning SuperCluster affiliation with ${CYAN}gappa${NC} using the ${CYAN}pplacer${NC} results... ${GREEN}done${NC}\n"
# fi

printf "$(get_time) Grafting ${CYAN}epa-ng${NC} tree with ${CYAN}guppy${NC}...\n"
PRES=$(check_files_missing "${graft_files_e[@]}")
if [ "${PRES}" -eq 0  ]; then
  printf "$(get_time) Grafting ${CYAN}epa-ng${NC} tree with ${CYAN}guppy${NC}... ${RED}skipped${NC}: File exists.\n"
else
  rm -f "${graft_files_e[@]}"
  graft_tree EPA_PR/epa_result.jplace epa-ng
  printf "$(get_time) Grafting ${CYAN}epa-ng${NC} tree with ${CYAN}guppy${NC}... ${GREEN}done${NC}\n"
fi

printf "$(get_time) Grafting ${CYAN}pplacer${NC} tree with ${CYAN}guppy${NC}...\n"
PRES=$(check_files_missing "${graft_files_p[@]}")
if [ "${PRES}" -eq 0  ]; then
  printf "$(get_time) Grafting ${CYAN}pplacer${NC} tree with ${CYAN}guppy${NC}... ${RED}skipped${NC}: File exists.\n"
else
  rm -f "${graft_files_p[@]}"
  graft_tree query.PR.jplace pplacer
  printf "$(get_time) Grafting ${CYAN}pplacer${NC} tree with ${CYAN}guppy${NC}... ${GREEN}done${NC}\n"
fi

join -t $'\t' -1 1 -2 1 <(tail -n+2 MicRhoDE_051214.txt | cut -f3,8,9,10 | sort -k1,1) <(sort -k1,1 MICrhoDE_prot_aligned.name_mapping.tsv) | awk -vFS="\t" '{print $5"\t"$2"\t"$3"\t"$4}' > MICrhoDE_prot_aligned.SC.0.tsv
paste <(cut -f1 MICrhoDE_prot_aligned.SC.0.tsv) <(cut -f2- MICrhoDE_prot_aligned.SC.0.tsv | tr $'\t' ';') > MICrhoDE_prot_aligned.SC.tsv

printf "$(get_time) Assigning SuperCluster affiliation with using the ${CYAN}epa-ng${NC} results...\n"
PRES=$(check_files_missing "${annot_files_e[@]}")
if [ "${PRES}" -eq 0  ]; then
  printf "$(get_time) Assigning SuperCluster affiliation with using the ${CYAN}epa-ng${NC} results... ${RED}skipped${NC}: File exists.\n"
else
  rm -f "${annot_files_e[@]}"
  orf_assign grafted_tree.epa-ng.tre MICrhoDE_prot_aligned.SC.tsv epa-ng
  printf "$(get_time) Assigning SuperCluster affiliation with using the ${CYAN}epa-ng${NC} results... ${GREEN}done${NC}\n"
fi

printf "$(get_time) Assigning SuperCluster affiliation with using the ${CYAN}pplacer${NC} results...\n"
PRES=$(check_files_missing "${annot_files_p[@]}")
if [ "${PRES}" -eq 0  ]; then
  printf "$(get_time) Assigning SuperCluster affiliation with using the ${CYAN}pplacer${NC} results... ${RED}skipped${NC}: File exists.\n"
else
  rm -f "${annot_files_p[@]}"
  orf_assign grafted_tree.pplacer.tre MICrhoDE_prot_aligned.SC.tsv pplacer
  printf "$(get_time) Assigning SuperCluster affiliation with using the ${CYAN}pplacer${NC} results... ${GREEN}done${NC}\n"
fi
# Create data file for iTOL/alluvial using the grafted tree assignments

printf "$(get_time) Getting basic data for ${CYAN}iTOL${NC} and ${CYAN}alluvial${NC} plots...\n"
PRES=$(check_files_missing "${basic_files[@]}")
if [ "${PRES}" -eq 0  ]; then
  printf "$(get_time) Getting basic data for ${CYAN}iTOL${NC} and ${CYAN}alluvial${NC} plots... ${RED}skipped${NC}: File exists.\n"
else
  rm -f "${basic_files[@]}"
  create_basic_data "${basic_files_download[@]}"
  printf "$(get_time) Getting basic data for ${CYAN}iTOL${NC} and ${CYAN}alluvial${NC} plots... ${GREEN}done${NC}\n"
fi

# Generate files for iTOL
# https://itol.embl.de/help/dataset_color_strip_template.txt
# 1. Assign colors to clusters and create strip file

printf "$(get_time) Creating data for ${CYAN}iTOL${NC}...\n"
PRES=$(check_files_missing "${itol_files[@]}")
if [ "${PRES}" -eq 0  ]; then
  printf "$(get_time) Creating data for ${CYAN}iTOL${NC}... ${RED}skipped${NC}: File exists.\n"
else
  rm -f "${itol_files[@]}"
  create_itol_data
  printf "$(get_time) Creating data for ${CYAN}iTOL${NC}... ${GREEN}done${NC}\n"
fi


printf "$(get_time) Creating data for ${CYAN}alluvial${NC} plots...\n"
PRES=$(check_files_missing "${alluvial_files[@]}")
if [ "${PRES}" -eq 0  ]; then
  printf "$(get_time) Creating data for ${CYAN}alluvial${NC} plots... ${RED}skipped${NC}: File exists.\n"
else
  rm -f "${itol_files[@]}"
  create_alluvial pplacer
  create_alluvial epa-ng
  printf "$(get_time) Creating data for ${CYAN}alluvial${NC} plots... ${GREEN}done${NC}\n"
fi

printf "\n\n$(get_time) ${RED}ANALYSIS FINISHED${NC}\n"
