#!/bin/bash
#SBATCH --job-name="m-mapping"
#SBATCH -D .
#SBATCH --array=1-116%10
#SBATCH --output=serial-%A_%a.out
#SBATCH --error=serial-%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48

set -e
set -x

# Requirements: java and java picard, python 2.7, dnanexus/samtools, bedtools, bbtools, bedops, bwa


SAMPLES=samples.txt #list of metagenomic sample labels
SAMPLE=$(tail -n+${SLURM_ARRAY_TASK_ID} "${SAMPLES}" | head -n1)

declare -r NAM=${SAMPLE} #sample ids
declare -r CON=${NAM}.fasta
declare -r GFF=${NAM}.gff
declare -r NSLOTS=${SLURM_JOB_CPUS_PER_NODE}
declare -r MEM=4G

#Prepare data
declare -r RES=${PWD}/results/${NAM}-mapping
declare -r TMPDIR=${RES}
#create folder
[[ -d ${RES} ]] && rm -rf ${RES}
mkdir -p ${RES}

cd ${RES}

# Get read files, combine them and QC them with bbduk
RDIR=${PWD}/non-merged_reads/

rsync -av --files-from="${RES}"/rfile.txt "${RDIR}" "${RES}"/

PE1=${RES}/${NAM}.R1.fastq
PE2=${RES}/${NAM}.R2.fastq
SE=${RES}/${NAM}.SR.fastq

#we need to combine them
cat "${RES}"/*_1.fastq.gz > R1.fastq.gz &
cat "${RES}"/*_2.fastq.gz > R2.fastq.gz &
wait

rm "${RES}"/*_1.fastq.gz &
rm "${RES}"/*_2.fastq.gz &
rm "${RES}"/rfile.txt
wait

bbduk.sh in=R1.fastq.gz in2=R2.fastq.gz out1="${PE1}" out2="${PE2}" outs="${SE}" qin=33 minlen=45 qtrim=rl trimq=20 ktrim=r k=25 mink=11 ref=/apps/BBTOOLS/37.36/resources/truseq.fa.gz hdist=1 tbo tpe t=${NSLOTS}

rm R1.fastq.gz &
rm R2.fastq.gz &
wait

# Metagenomic assemblies (contigs)
ln -s data/*${NAM}*.fasta ${RES}/${CON}
# Predicted ORFs gff file
ln -s gene_prediction/*${NAM}*.gff ${RES}/${GFF}

cd ${RES}

# Burrows-Wheeler Aligner -> mapping low-divergent sequences against a large reference genome
# Construct the FM-index for the contigs and use bwa's mem algorithm for our quality trimmed paired-end -and single reads
# BWA-MEM: is generally recommended for high-quality queries as it is faster and more accurate, and has also better performance for 70-100bp Illumina reads.
bwa index ${RES}/${CON}
bwa mem -M -t ${NSLOTS} ${RES}/${CON} ${SE} > ${RES}/${NAM}.se.sam
bwa mem -M -t ${NSLOTS} ${RES}/${CON} ${PE1} ${PE2} > ${RES}/${NAM}.pe.sam

rm ${PE1} ${PE2} ${SE}

# Index mapping results
# merge both mappings into one SAM file
samtools faidx ${RES}/${CON}

# We convert paired and single end SAM files to BAM
# We filter out unmapped reads and one with mapping-quality (mapq) < 10
samtools view -@ ${NSLOTS} -q 10 -F 4 -u -bt ${RES}/${CON}.fai ${RES}/${NAM}.se.sam | samtools rocksort -@ ${NSLOTS} -m ${MEM}  ${RES}/${NAM}.se.bam
samtools view -@ ${NSLOTS} -q 10 -F 4 -u -bt ${RES}/${CON}.fai ${RES}/${NAM}.pe.sam | samtools rocksort -@ ${NSLOTS} -m ${MEM}  ${RES}/${NAM}.pe.bam

# Merge the BAM files
samtools merge -@ ${NSLOTS} ${RES}/${NAM}.bam ${RES}/${NAM}.pe.bam ${RES}/${NAM}.se.bam

rm ${RES}/${NAM}.pe.sam ${RES}/${NAM}.se.sam
rm ${RES}/${NAM}.pe.bam ${RES}/${NAM}.se.bam

# Once the merging is done, we will sort the files again
# rocksort for fast sorting of very large bam files
samtools rocksort -@ ${NSLOTS} -m ${MEM} ${RES}/${NAM}.bam ${RES}/${NAM}.sorted.bam

samtools index ${RES}/${NAM}.sorted.bam

JAVA_OPT="-Xms2g -Xmx32g -XX:ParallelGCThreads=4 -XX:MaxPermSize=2g -XX:+CMSClassUnloadingEnabled"

# Mark and remove duplicates and sort
java $JAVA_OPT \
  -jar $PICARD MarkDuplicates \
  INPUT=${RES}/${NAM}.sorted.bam \
  OUTPUT=${RES}/${NAM}.sorted.markdup.bam \
  METRICS_FILE=${RES}/${NAM}.sorted.markdup.metrics \
  AS=TRUE \
  VALIDATION_STRINGENCY=LENIENT \
  MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
  REMOVE_DUPLICATES=TRUE

# Sort and index the BAM file without the duplicates and we will get some statistics:
samtools rocksort -@ ${NSLOTS} -m ${MEM} ${RES}/${NAM}.sorted.markdup.bam ${RES}/${NAM}.sorted.markdup.sorted.bam
samtools index ${RES}/${NAM}.sorted.markdup.sorted.bam
samtools flagstat ${RES}/${NAM}.sorted.markdup.sorted.bam > ${RES}/${NAM}.sorted.markdup.sorted.flagstat

rm ${RES}/${NAM}.sorted.markdup.bam
rm ${RES}/*.fasta.*

# Determine genome coverage and mean coverage per contig
genomeCoverageBed -ibam ${RES}/${NAM}.sorted.markdup.sorted.bam > ${RES}/${NAM}.sorted.markdup.sorted.coverage
# Generate table with length and coverage stats per contig (From http://github.com/BinPro/CONCOCT)
python ~/opt/scripts/gen_contig_cov_per_bam_table.py --isbedfiles ${RES}/${CON} ${RES}/${NAM}.sorted.markdup.sorted.coverage > ${RES}/${NAM}.sorted.markdup.sorted.coverage.percontig

#COUNT FEATURES
bedtools multicov -q 10 -bams ${RES}/${NAM}.sorted.markdup.sorted.bam -bed ${RES}/${NAM}.gff > ${RES}/${NAM}.bam.bedtools.d.cnt

bamToBed -i ${RES}/${NAM}.sorted.markdup.sorted.bam | LC_ALL=C sort --parallel=${NSLOTS} -k1,1 -k2,2n > ${RES}/${NAM}.sorted.markdup.sorted.bed

~/opt/bedops/bin/gff2bed < ${RES}/${GFF} | LC_ALL=C sort --parallel=${NSLOTS} -k1,1 -k2,2n > ${RES}/${NAM}.bed

bedtools coverage -hist -sorted -b ${RES}/${NAM}.sorted.markdup.sorted.bed -a ${RES}/${NAM}.bed > ${RES}/${NAM}.bam.bedtools.d.hist

# Then we calculate the mean coverage per contig and the fraction covered:
LC_ALL=C awk -f ~/opt/scripts/get_gene_coverage_from_bam-coAssembly.awk ${RES}/${NAM}.bam.bedtools.d.hist | LC_ALL=C sort -V --parallel=${NSLOTS} > ${RES}/${NAM}.orf-coverage.txt

rm ${RES}/${NAM}.bam ${RES}/${NAM}.sorted.bam

find ${RES} -name "*.bed" -print -exec gzip {} \;
find ${RES} -name "*.hist" -print -exec gzip {} \;
find ${RES} -name "*.coverage" -print -exec gzip {} \;

echo "DONE"
