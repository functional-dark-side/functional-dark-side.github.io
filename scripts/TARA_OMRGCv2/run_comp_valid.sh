#!/bin/bash
#SBATCH --nodes=9
#SBATCH --ntasks-per-node=4
#SBATCH --ntasks=36
#SBATCH --partition=nomaster
#SBATCH --job-name=update_val

set -e
set -x

export OMPI_MCA_btl=^openib
export OMP_NUM_THREADS=7
export OMP_PROC_BIND=FALSE

export LD_LIBRARY_PATH=/vol/cloud/test_wkfl/bin/igraph/lib:$LD_LIBRARY_PATH

#Run compositional validation in mpi-mode
# (using ffindex to iterate through the clusters)

srun --mpi=pmi2 /vol/cloud/test_wkfl/bin/mmseqs apply /vol/cloud/omrgc2/mg_g_omrgc2_update/mg_g_omrgc2_20200203_clu_fa /vol/cloud/omrgc2/mg_g_omrgc2_update/compositional_validation/res_valDB -- \
  /vol/cloud/test_wkfl/scripts/compositional_validation.sh --derep /vol/cloud/test_wkfl/bin/mmseqs \
  --msa /vol/cloud/test_wkfl/bin/famsa \
  --msaeval /vol/cloud/test_wkfl/bin/OD-seq \
  --ssn /vol/cloud/test_wkfl/bin/parasail_aligner \
  --gfilter /vol/cloud/test_wkfl/scripts/filter_graph \
  --gconnect /vol/cloud/test_wkfl/scripts/is_connected \
  --seqp seqtk \
  --datap datamash \
  --stats /vol/cloud/test_wkfl/scripts/get_stats.r \
  --index /vol/cloud/omrgc2/mg_g_omrgc2_update/omrgc2_cluster_name_index.tsv \
  --out /vol/cloud/omrgc2/mg_g_omrgc2_update/compositional_validation/stats \
  --threads 7 &> omrgc2_val.log
