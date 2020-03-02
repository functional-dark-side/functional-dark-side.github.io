#!/bin/bash

set -o nounset
#set -e
set -x

usage() { echo -e "Usage: $(basename $0) [OPTIONS...]
Options:
--derep    tool to dereplicate cluster sequences (mmseqs)
--msa      tool for MSAs (famsa)
--msaeval  tool to evaluate the MSAs (odseq)
--ssn      sequence similarity network tool (parasail)
--gfilter  graph filtering script
--gconnect is_connected graph script
--seqp     sequence processing tool (seqkt)
--datap    data processing tool (datamash)
--stats    script to get the SSN stats
--index    cluster name-index file
--out      output directory
--threads  number of threads to use" 1>&2; exit 1; }

OPT_LIST="derep:,msa:,msaeval:,ssn:,gfilter:,gconnect:,seqp:,datap:,stats:,index:,out:,threads:"

eval set -- `getopt -o '' --long "${OPT_LIST}" -- "$@"`
while true; do
  case "$1" in
    --derep)
      MMSEQS_BIN=$2; shift 2 ;;
    --msa)
      FAMSA_BIN=$2; shift 2 ;;
    --msaeval)
      ODSEQ_BIN=$2; shift 2 ;;
    --ssn)
      PARASAIL_BIN=$2; shift 2 ;;
    --gfilter)
      FILTER_BIN=$2; shift 2 ;;
    --gconnect)
      ISCON_BIN=$2; shift 2 ;;
    --seqp)
      SEQTK_BIN=$2; shift 2 ;;
    --datap)
      DATAMASH_BIN=$2; shift 2 ;;
    --stats)
      STATS=$2; shift 2 ;;
    --index)
      INDEX=$2; shift 2 ;;
    --out)
      OUT=$2; shift 2 ;;
    --threads)
      NSLOTS=$2; shift 2 ;;
    --)
      shift; break ;;
    *)
      usage ;;
  esac
done

if [ -z "${MMSEQS_BIN}" ] || [ -z "${FAMSA_BIN}" ] || [ -z "${ODSEQ_BIN}" ] || \
  [ -z "${PARASAIL_BIN}" ] || [ -z "${FILTER_BIN}" ] || [ -z "${ISCON_BIN}" ] || \
  [ -z "${SEQTK_BIN}" ] || [ -z "${DATAMASH_BIN}" ] || [ -z "${STATS}" ] || \
  [ -z "${OUT}" ] || [ -z "${NSLOTS}" ]; then
  usage
fi

function f2i() {
  awk 'BEGIN{for (i=1; i<ARGC;i++)
  printf "%.0f\n", ARGV[i]}' "$@"
}

function create_outdir() {
  OUTDIR="${RES}"/temp/"${N}"
  # Create output folder
  if [[ -d "${OUTDIR}" ]]; then
    find "${OUTDIR}" -delete -print
    mkdir -p "${OUTDIR}"
  else
    mkdir -p "${OUTDIR}"
  fi
  # Change to output folder
  cd "${OUTDIR}" || exit "${OUTDIR} folder not found"
}

function cleanup() {
  if [[ -n "${OUTDIR}" ]]; then
    rm -rf "${OUTDIR}"
  fi
  echo "Cleaned up" && exit 0
}

function  create_destdirs() {
  ALNDIR="${PWD}"/"${RES}"/alignments
  if [[ ! -d "${ALNDIR}" ]]; then
    mkdir -p "${ALNDIR}"
  fi
  REJDIR="${PWD}"/"${RES}"/rejected
  if [[ ! -d "${REJDIR}" ]]; then
    mkdir -p "${REJDIR}"
  fi
  CORDIR="${PWD}"/"${RES}"/core
  if [[ ! -d "${CORDIR}" ]]; then
    mkdir -p "${CORDIR}"
  fi
  STATSDIR="${PWD}"/"${RES}"/stats
  if [[ ! -d "${STATSDIR}" ]]; then
    mkdir -p "${STATSDIR}"
  fi
}

function get_length() {
  "${SEQTK_BIN}" comp "${FA}" | awk '{print $1"\t"$2}' > "${N}"_length.txt
  LEN_STATS=$("${DATAMASH_BIN}" min 2 mean 2 median 2 max 2 < "${N}"_length.txt)
}

function dereplicate() {
  DB="${N}".db
  REPLIC="${N}".replic
  DEDUP="${N}"_dedup.fasta

  "${MMSEQS_BIN}" createdb "${FA}" "${DB}"
  "${MMSEQS_BIN}" clusthash "${DB}" "${REPLIC}" --min-seq-id 0.999 --threads 1 &>/dev/null
  "${MMSEQS_BIN}" clust "${DB}" "${REPLIC}" "${REPLIC}"_clust --threads 1 &>/dev/null
  "${MMSEQS_BIN}" createtsv "${DB}" "${DB}" "${REPLIC}"_clust "${N}"_replicates.tsv --threads 1 &>/dev/null
  "${MMSEQS_BIN}" result2repseq "${DB}" "${REPLIC}"_clust dedup_"${N}"_rep --threads 1 &>/dev/null
  "${MMSEQS_BIN}" result2flat "${DB}" "${DB}" dedup_"${N}"_rep "${DEDUP}" --use-fasta-header &>/dev/null
  rm -r "${DB}"* "${REPLIC}"*  dedup_"${N}"_rep*
  sed -i 's/ //g' "${DEDUP}"
}

function res_replic() {
  # Filter SSN in case of filtering failure due to the low number of seqs after the dereplication step
  RMINW=1
  RMEAW=1
  RMEDW=1
  RMAXW=1
  SSN_FILT_STATS="${N}"_SSN_filt_stats.tsv

  REP=$(head -n 1 "${DEDUP}" | sed -e 's/^>//')
  DEN="NULL"
  NED=0
  NVX=1
  CW="NA"

  echo "NA" | awk -vN="${N}" -vV="${NVX}" -vR="${REP}" -vD="${DEN}" -vE="${NED}" -vC="${CW}" \
    -vRMIN="${RMINW}" -vRMEA="${RMEAW}" -vRMED="${RMEDW}" -vRMAX="${RMAXW}" \
    -vREJ=0 -vCOR="${NSEQS}" \
    -vL="${LEN_STATS}" -vNS="${NSEQS}"\
    'BEGIN{OFS="\t"}{print N,R,NS,V,E,D,C,"TRUE",1,$1,$1,$1,$1,RMIN,RMEA,RMED,RMAX,L,REJ,COR,REJ/NS}' > "${SSN_FILT_STATS}"
}

function align_sequences() {
  # MSA with FAMSA
  ALN="${N}".aln
  "${FAMSA_BIN}" -t "${NSLOTS}" "${DEDUP}" "${ALN}" 2> /dev/null
}

function get_outliers() {
  "${ODSEQ_BIN}" -t "${NSLOTS}" -s 2.5 -i "${ALN}" -o "${N}".out -c "${N}".cor
  # Get Rejected Ids
  LC_ALL=C grep -w -F -f <(grep '>' "${N}".cor | tr -d '>') "${N}"_replicates.tsv | cut -f2 | sort -u --parallel=4 > "${N}"_core.txt
  LC_ALL=C grep -w -F -f <(grep '>' "${N}".out | tr -d '>') "${N}"_replicates.tsv | cut -f2 | sort -u --parallel=4 > "${N}"_rejected.txt

  NREJ=$(awk "END{print NR}" "${N}"_rejected.txt)
  NCOR=$(awk "END{print NR}" "${N}"_core.txt)
  rm "${N}".out "${N}".cor
}

function get_SSN_para() {
  # Identity scores from the MSA
  ID="${N}"_id
  # the 5th column has the identity score
  "${PARASAIL_BIN}" -a sg_stats_scan_sse2_128_16 -f "${DEDUP}" -g ssn.out -c 1
  awk 'BEGIN{FS=","}{print $1" "$2" "$9/$10}' ssn.out > "${ID}"
  # Get statistics from the raw SSN
  SSN_RAW_STATS="${N}"_SSN_raw_stats.tsv
  RSTATS=$("${STATS}" "${ID}")
  echo "${RSTATS}" | awk -vN="${N}" -vS="${NSEQS}" 'BEGIN{OFS="\t"}{print N,S,$1,$3,$4,$6}' > "${SSN_RAW_STATS}"
  rm ssn.out
}

function filter_SSN() {
  # Filter SSN
  RMINW=$(cut -f3 "${SSN_RAW_STATS}")
  RMEAW=$(cut -f4 "${SSN_RAW_STATS}")
  RMEDW=$(cut -f5 "${SSN_RAW_STATS}")
  RMAXW=$(cut -f6 "${SSN_RAW_STATS}")
  SSN_FILT_STATS="${N}"_SSN_filt_stats.tsv

  if [ "${RMINW}" == 1 ] \
    && [ "${RMEAW}" == 1 ] \
    && [ "${RMEDW}" == 1 ] \
    && [ "${RMAXW}" == 1 ]; then

    REP=$(head -n 1 "${ALN}" | sed -e 's/^>//')
    DEN=1
    NED=$(awk 'END{print NR}' "${ID}")
    NVX=$(grep -c '^>' "${ALN}")
    CW="NA"

    echo 1 | awk -vN="${N}" -vV="${NVX}" -vR="${REP}" -vD="${DEN}" -vE="${NED}" -vC="${CW}" \
      -vRMIN="${RMINW}" -vRMEA="${RMEAW}" -vRMED="${RMEDW}" -vRMAX="${RMAXW}" \
      -vREJ="${NREJ}" -vCOR="$NCOR" \
      -vL="${LEN_STATS}" -vNS="${NSEQS}"\
      'BEGIN{OFS="\t"}{print N,R,NS,V,E,D,C,"TRUE",1,$1,$1,$1,$1,RMIN,RMEA,RMED,RMAX,L,REJ,COR,REJ/NS}' > "${SSN_FILT_STATS}"
  else
    SSN="${N}"_SSN_info.tsv
    "${FILTER_BIN}" "${ID}" | grep -v '#' | sed '/^\s*$/d' > "${SSN}"
    # Get representative
    REP0=$(grep Representative "${SSN}" |  cut -f2)
    REP=$(grep '>' "${DEDUP}" | awk -vR="${REP0}" 'NR==R+1' | tr -d '>')
    DEN=$(grep Density "${SSN}" | cut -f2)
    NED=$(grep Num_edges "${SSN}" | cut -f2)
    NVX=$(grep Num_vrtx "${SSN}" | cut -f2)
    CW=$(grep Cut_weight "${SSN}" | cut -f2)
    COM=$(grep Num_components "${SSN}" | cut -f2)
    CON=$(grep Connected "${SSN}" | cut -f2)

    "${STATS}" trimmed_graph.ncol \
      | awk -vN="${N}" -vV="${NVX}" -vR="${REP}" -vD="${DEN}" -vE="${NED}" -vC="${CW}" \
      -vRMIN="${RMINW}" -vRMEA="${RMEAW}" -vRMED="${RMEDW}" -vRMAX="${RMAXW}" \
      -vCON="${CON}" -vCOM="${COM}" \
      -vREJ="${NREJ}" -vCOR="$NCOR" \
      -vL="${LEN_STATS}" -vNS="${NSEQS}"\
      'BEGIN{OFS="\t"}{print N,R,NS,V,E,D,C,CON,COM,$1,$3,$4,$6,RMIN,RMEA,RMED,RMAX,L,REJ,COR,REJ/NS}' > "${SSN_FILT_STATS}"
    #gzip "${ALN}"
    #gzip trimmed_graph.ncol "${ID}" "${SSN}"
  fi
}

function filter_SSN_2() {
  # Filter SSN in case of filtering failure due to the low number of seqs after the dereplication step
  RMINW=$(cut -f3 "${SSN_RAW_STATS}")
  RMEAW=$(cut -f4 "${SSN_RAW_STATS}")
  RMEDW=$(cut -f5 "${SSN_RAW_STATS}")
  RMAXW=$(cut -f6 "${SSN_RAW_STATS}")
  SSN_FILT_STATS="${N}"_SSN_filt_stats.tsv

  REP=$(grep '^>' "${ALN}" | shuf -n 1 | sed -e 's/^>//')
  DEN="NULL"
  NED=$(awk 'END{print NR}' "${ID}")
  NVX=$(grep -c '^>' "${ALN}")
  CW="NA"

  echo "NA" | awk -vN="${N}" -vV="${NVX}" -vR="${REP}" -vD="${DEN}" -vE="${NED}" -vC="${CW}" \
    -vRMIN="${RMINW}" -vRMEA="${RMEAW}" -vRMED="${RMEDW}" -vRMAX="${RMAXW}" \
    -vREJ="${NREJ}" -vCOR="$NCOR" \
    -vL="${LEN_STATS}" -vNS="${NSEQS}"\
    'BEGIN{OFS="\t"}{print N,R,NS,V,E,D,C,"TRUE",1,$1,$1,$1,$1,RMIN,RMEA,RMED,RMAX,L,REJ,COR,REJ/NS}' > "${SSN_FILT_STATS}"
}

function mv_results() {
  rsync -Pauvx --append "${N}".aln "${ALNDIR}"/
  rsync -Pauvx --append "${N}"_rejected.txt "${REJDIR}"/
  rsync -Pauvx --append "${N}"_core.txt "${CORDIR}"/
  rsync -Pauvx --append "${SSN_FILT_STATS}" "${STATSDIR}"/
  rsync -Pauvx --append "${SSN_RAW_STATS}" "${STATSDIR}"/
}

main (){
  # Create destination directory
  create_destdirs
  # Count sequences
  NSEQS=$(grep -c '>' <(echo "${SEQS}"))
  # Get cluster num
  I="${MMSEQS_ENTRY_NAME}"
  # Need to join with the cluster name-index file
  N=$(awk -v Indx=$I '$1==Indx{print $2}' "${INDEX}")

  LOG="${RES}"/log_vals
  mkdir -p "${LOG}"
  export log="${LOG}"/"${N}".log
  touch "${log}"

  exec > >(tee -i -a "$log") 2> >(tee -i -a "$log" >&2)

  # Filter clusters
  if [[ "${NSEQS}" -ge 2 ]]; then
    if [ -s "${STATSDIR}"/"${N}"_SSN_filt_stats.tsv ]; then
      echo "File exists and is not empty" && exit 0
    fi

    echo "${N}"
    #Create outdir
    echo "[${N}] Creating output folder ${OUTDIR}"
    create_outdir

    FA="${N}".fasta
    echo "${SEQS}" | awk '/^>/{split($1,a,"- OS"); print a[1]; next}1' > "${FA}"
    echo "File ${FA} created"
    [ ! -f "${FA}" ] || [ ! -s "${FA}" ] && exit "File ${FA} doesn't exist"

    echo "[${N}] Calculate length"
    get_length
    # Cluster sequences dereplication
    echo "[${N}] Dereplicate sequences"
    dereplicate
    # Count deduplicated sequences, if only one --> produce results
    NDEDUP=$(grep '^>' "${DEDUP}" | wc -l)
    if [[ "${NDEDUP}" -le 2 ]]; then
      res_replic
      rsync -Pauvx --append "${SSN_FILT_STATS}" "${STATSDIR}"/
      #mv_results
    else
      # Align sequences
      echo "[${N}] Aligning dereplicated sequences"
      align_sequences
      # Identify outlier sequences
      echo "[${N}] Identifying dereplicated outliers"
      get_outliers
      # calculate SSN
      echo "[${N}] Calculating dereplicated SSN"
      get_SSN_para
      # Simplify graph
      echo "[${N}] Simplify dereplicated SSN"
      #QTL1=$(f2i "$(echo "${RSTATS}" | cut -d ' ' -f 2)")
      #MED=$(f2i "$(echo "${RSTATS}" | cut -d ' ' -f 3)")
      #MEA=$(f2i "$(echo "${RSTATS}" | cut -d ' ' -f 4)")
      QTL1=$(echo "${RSTATS}" | cut -d ' ' -f 2)
      MED=$(echo "${RSTATS}" | cut -d ' ' -f 3)
      MEA=$(echo "${RSTATS}" | cut -d ' ' -f 4)

      CMIN=0.1
      if (( $(bc -l <<< "${QTL1}" > "${CMIN}") )); then
        CMIN=0.3
      else
        CMIN=0.1
      fi

      for i in "${MED}" "${MEA}" "${QTL1}" "${CMIN}"; do
        awk -v I="${i}" '$3 >= I{print $0}' "${ID}" > "${ID}${i}"
        ISCON=$( "${ISCON_BIN}" "${ID}${i}")
        if [  "${ISCON}" = true ]; then
          mv "${ID}${i}" "${ID}"
          break
        else
          rm "${ID}${i}"
          continue
        fi
      done
      # Filter SSN
      echo "[${N}] Filtering dereplicated SSN"
      filter_SSN
      if [ -s "${STATSDIR}"/"${N}"_SSN_filt_stats.tsv ]; then
        echo "[${N}] Moving results to dest_directories/"
        mv_results
      else
        filter_SSN_2
        echo "[${N}] Moving results to dest_directories/"
        mv_results
      fi
    fi
  fi
  cleanup
  exit 0
}

trap "cleanup; exit 0" EXIT SIGHUP SIGINT SIGQUIT SIGPIPE SIGTERM

RES=$(dirname "${OUT}")
OUTDIR=""
DESTDIR=""
# Get sequences from cluster
SEQS=$(perl -ne 'print $_')

main "$@"
