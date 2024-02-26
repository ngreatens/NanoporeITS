# use of NGS Species ID and scripts to get ITS seqs from Nanopore reads.


## download of NGSSpeciesID

see NGSpeciesID [github](https://github.com/ksahlin/NGSpeciesID)

e.g. 

```
module load miniconda
conda create -n NGSpeciesID python=3.6 pip 
conda activate NGSpeciesID
### need pysam==0.15.2 because of conflict with medaka. I can't get this to work anyway even with the conflict resolved, but better this way anyway
conda install --yes -c conda-forge -c bioconda pysam==0.15.2 medaka==0.11.5 openblas==0.3.3 spoa racon minimap2
pip install NGSpeciesID
```

## 

Follow test on github page. I can't get medaka to work, but with Racon as a polisher, it is working just fine.

shell script  I used: 

(You may have to provide your own path to the conda env or initialize the shell in a slightly different way)

```
#!/bin/bash


reads=$1
outfolder=${reads%.*}

eval "$(conda shell.bash hook)" #intialize shell for conda environments
conda activate ~/.conda/envs/NGSpeciesID

NGSpeciesID \
        --ont \
        --consensus \
        --racon \
        --racon_iter 3 \
        --m 750 `#target length`\
        --s 250 `#filter for target length =/250 bp`\
        --fastq $reads \
        --outfolder $outfolder

conda deactivate
```

Example usage (with above shell script in folder with fastqs):

```
./NGSpeciesID.sh sample_10062.fastq
```

To get commands for all fastqs:
```
for file in *.fastq; do echo "./NGSpeciesID.sh $file"; done >  NGS.commands
```

copy output into slurm submission script. It runs very fast on a cluster. Probably doesn't take much time on a laptop either.

Result should be something similar to this for one sample.

tree 10028
```
10028
├── 1
│   ├── cluster_origins.csv
│   └── pre_clusters.csv
├── 2
│   ├── cluster_origins.csv
│   └── pre_clusters.csv
├── 3
│   ├── cluster_origins.csv
│   └── pre_clusters.csv
├── consensus_reference_12.fasta
├── consensus_reference_23.fasta
├── final_cluster_origins.tsv
├── final_clusters.tsv
├── logfile.txt
├── racon_cl_id_12
│   ├── consensus.fasta
│   ├── mm2_stderr_it_0.txt
│   ├── mm2_stderr_it_1.txt
│   ├── mm2_stderr_it_2.txt
│   ├── racon_polished_it_0.fasta
│   ├── racon_polished_it_1.fasta
│   ├── racon_polished_it_2.fasta
│   ├── racon_stderr_it_0.txt
│   ├── racon_stderr_it_1.txt
│   ├── racon_stderr_it_2.txt
│   ├── read_alignments_it_0.paf
│   ├── read_alignments_it_1.paf
│   ├── read_alignments_it_2.paf
│   └── stdout.txt
├── racon_cl_id_23
│   ├── consensus.fasta
│   ├── mm2_stderr_it_0.txt
│   ├── mm2_stderr_it_1.txt
│   ├── mm2_stderr_it_2.txt
│   ├── racon_polished_it_0.fasta
│   ├── racon_polished_it_1.fasta
│   ├── racon_polished_it_2.fasta
│   ├── racon_stderr_it_0.txt
│   ├── racon_stderr_it_1.txt
│   ├── racon_stderr_it_2.txt
│   ├── read_alignments_it_0.paf
│   ├── read_alignments_it_1.paf
│   ├── read_alignments_it_2.paf
│   └── stdout.txt
├── reads_to_consensus_12.fastq
├── reads_to_consensus_23.fastq
└── sorted.fastq
```

## summarize data



