#### Compositional validation scripts usage:

Compiling of the scripts for the SSN filtering:

```bash
cd scripts/Cluster_validation/compositional/
```

```bash
gcc is_connected.c -I${HOME}.linuxbrew/Cellar/igraph/0.7.1_6/include -L${HOME}/.linuxbrew/Cellar/igraph/0.7.1_6/lib/ -ligraph -o is_connected
```

```bash
gcc -O3 filter_graph.c -I${HOME}/.linuxbrew/Cellar/igraph/0.7.1_6/include -L${HOME}/.linuxbrew/Cellar/igraph/0.7.1_6/lib/ -ligraph -o filter_graph
```

Running the evaluation script using ffindex in mpi mode ([ffindex](https://github.com/soedinglab/ffindex_soedinglab))

```bash
/bioinf/software/openmpi/openmpi-1.8.1/bin/mpirun -np 32 ~/opt/ffindex_mg_updt/bin/ffindex_apply_mpi \
 data/mmseqs_clustering/marine_hmp_db_03112017_clu_fa \
 data/mmseqs_clustering/marine_hmp_db_03112017_clu_fa.index \
 -- scripts/Cluster_validation/compositional/compos_val.sh
```
  - output: tab-separated file with 24 fields:
    - <cl_name>
    - <new_representative>
    - <cl_size>
    - <n_vertices> info about the Sequence Similarity Network
    - <n_edges> as above
    - <density> as above
    - <cut_w> as above
    - <connected> as above
    - <n_compon> as above
    - <tr_min_id> min intra-cluster identity (trimmed)
    - <tr_mean_id> mean intra-cluster identity (trimmed)
    - <tr_median_id> median intra-cluster identity (trimmed)
    - <tr_max_id> max intra-cluster identity (trimmed)
    - <raw_min_id> min intra-cluster identity (original graph)
    - <raw_mean_id> mean intra-cluster identity (original graph)
    - <raw_median_id> median intra-cluster identity (original graph)
    - <raw_max_id> max intra-cluster identity (original graph)
    - <min_len> min ORF length in the cluster
    - <mean_len> mean ORF length in the cluster
    - <median_len> median ORF length in the cluster
    - <max_len> max ORF length in the cluster
    - <rejected> number of bad aligned sequences
    - <core> number of good sequences
    - <prop_rejected> proportion of bad aligned sequences per cluster
