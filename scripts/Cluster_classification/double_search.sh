#!/bin/bash

#[ -z "$MMDIR" ] && echo "Please set the environment variable \$MMDIR to your MMSEQS installation directory." && exit 1;
[ "$#" -lt 3  ] && echo "Please provide <query.fasta> <target.fasta> <OutDir>"  && exit 1;
[ ! -d "$1"   ] && echo  "Output directory $1 not found!"       && exit 1;
[ ! -f "$2"   ] && echo "Query fasta file $2 not found!"       && exit 1;
[ ! -f "$3"   ] && echo "Target fasta file $3 not found!"   && exit 1;


OUTDIR="${1}"
UNKN="${2}"
BIODB="${3}"
NSLOTS="${4}"
NAME_DB=$(basename "${BIODB}")
TMPDIR="${OUTDIR}"/tmp
MMSEQS=~/opt/MMseqs2/bin/mmseqs

"${MMSEQS}" createdb "${UNKN}" "${OUTDIR}/cons_db"

queryDB=${OUTDIR}/cons_db

targetDB=${BIODB}

results1=${OUTDIR}/round1_res

top1=${OUTDIR}/top1

aligned=${OUTDIR}/aligned

aligned_db=${OUTDIR}/aligned_db

round2=${OUTDIR}/round2_res

merged=${OUTDIR}/merged

aln_2b=${OUTDIR}/aln_2b


mkdir -p $TMPDIR/tmp_hsp1

"${MMSEQS}" search "$queryDB" "$targetDB" "$results1" ${TMPDIR}/tmp_hsp1 --max-seqs 300 --threads "${NSLOTS}" -a -e 1e-5 --max-seq-len 32768 --cov-mode 2 -c 0.6

"${MMSEQS}" filterdb "$results1" "$top1" --extract-lines 1

"${MMSEQS}" createsubdb "$top1".index "$queryDB"_h "$top1"_h

"${MMSEQS}" extractalignedregion "$top1" "$targetDB" "$top1" "$aligned" --extract-mode 2 --threads "${NSLOTS}"

mkdir -p  $TMPDIR/tmp_hsp2

"${MMSEQS}" createsubdb "$aligned" "$queryDB" "$aligned_db"

"${MMSEQS}" search "$aligned_db" "$targetDB" "$round2"  $TMPDIR/tmp_hsp2 --max-seqs 300 --threads "${NSLOTS}" -a -e 1e-5 --max-seq-len 32768 --cov-mode 2 -c 0.6

# Concat top hit from first search with all the results from second search
# We can use filterdb --beats-first to filter out all entries from second search that
# do not reach the evalue of the top 1 hit
"${MMSEQS}" mergedbs "$top1" "$merged" "$top1" "$round2"

"${MMSEQS}" filterdb "$merged" "$aln_2b" --beats-first --filter-column 4 --comparison-operator le

#The results can be converted into flat format both with createtsv or convertalis
RES="${5}"
#es: mmseqs convertalis "$queryDB" "$targetDB" "$aln_2b" "$aln_2b".m8
"${MMSEQS}" convertalis --format-mode 2 --threads "${NSLOTS}" "$queryDB" "$targetDB" "$aln_2b" "${RES}"
