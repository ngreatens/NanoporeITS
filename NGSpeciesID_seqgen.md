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

copy output into slurm script or pass. It runs very fast on a cluster. Probably doesn't take much time on a laptop either.


