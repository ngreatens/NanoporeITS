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
# !/bin/bash


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

## summarize data: NGSpeciesID_postprocessing.sh



Next, I've put togther a script that will 
1. map and trim primers
2. calculate coverage
3. move sequences to bins based on coverage and success of primer mapping
4. summarize data and output several files: a summary.txt, coverage.csv, and lists of seqs that passed and samples or seqs that failed

The script is quite long, so I haven't copied it here, but it is available with all scripts in the scripts folder in this repository.


> [!IMPORTANT]
> make sure all needed software is available.

This script uses minimap2, samtools, and seqkit.

Minimap2 and samtools are supported by umn. [seqkit](https://github.com/shenwei356/seqkit) must be downloaded separately

e.g. 

```
module load miniconda
conda create -n seqkit
conda activate seqkit
conda install -c bioconda seqkit
```

Either in the script or in the shell (if running in the shell), you will have to activate the seqkit conda environment
e.g.

```
eval "$(conda shell.bash hook)" #intialize shell for conda environments
conda activate ~/.conda/envs/seqkit
```

Usage (in directory where NGSpeciedID was run)
./NGSpeciesID_postprocessing.sh <coverage> <forwardprimer> <reverseprimer>



This should run quite fast, so you can just run it in the shell after allocating yourself a node with salloc

you may have to configure this on your own depending on where your conda envs are stored or if you would like to share environmments between members of the project

## blast the seqs

Short script to blastn the seqs and output the top 10 results in a tsv.

```
#!/bin/bash

query=$1
outname=${query}.blast.out

ml blast+

blastn \
		-db nt \
		-remote \
		-query $query \
		-out $outname \
		-max_target_seqs 10 \
		-outfmt "6  qseqid sseqid sgi staxids pident length mismatch gapopen qstart qend sstart send evalue bitscore"
```

Usage :
        ./blast.sh path/to/folder/example.fasta


This can be done most easily through first getting the commands

```
for folder in seqs/*; do
        for file in $folder/*.fasta;do
                echo  "./blast.sh $file";
        done;
done > blast.commands
```

and copypasting into one or more slurm submission scripts and submitting (ideally), or just running for a while on the shell

e.g.
```
while read line; do
        cat $line
done < blast.commands &
```

Note: if the module is named differently, you may have to adjust the script accordingly

## get taxids

Unfortunately for some reason blast will not output the scientific name into its tsv format and you have to manually look up the taxids  with a second database

An easy solution is to use [taxonkit](https://github.com/shenwei356/taxonkit), but it must be downloaded from github through conda, as above.

```
module load miniconda
conda create -n taxonkit
conda activate taxonkit
conda install -c bioconda taxonkit
```

You must also download the NCBI taxdump database, as explained in the github.

```
wget -c ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz 
tar -zxvf taxdump.tar.gz

mkdir -p ~/.taxonkit
cp names.dmp nodes.dmp delnodes.dmp merged.dmp ~/.taxonkit
```

note you must edit the shell script to supply it with th proper path the taxdump database.
Another script, blast_out_to_taxa.sh, will call taxonkit, and output a simplified file with top hits for each blast out file from the previous step.

```
#!/bin/bash

blastout=$1
outfile=${blastout%.out}.tophits
taxdump_dir=/project/fdwsru_fungal/Nick/databases/taxdump

eval "$(conda shell.bash hook)" #intialize shell for conda environments
conda activate taxonkit

while read line; do 
        taxid=$(echo $line | awk '{print $4}')
	taxon=`echo $taxid | taxonkit lineage --data-dir=$taxdump_dir -L -n | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'`
	seqhit=$(echo $line | awk '{print $2}' |cut -f 4 -d "|")
	match=$(echo $line | awk '{print $5}')
	echo "${taxon},${seqhit},${match}"
done < ${blastout} > $outfile

conda deactivate

```

Usage:
```
./blast_out_to_taxa.sh path/to/example.fasta.blast.out
```

call with for loop:

```
#salloc  #if needed
for folder in seqs/*; do
        for blastout in $folder/*.blast.out; do
                ./blast_out_to_taxa.sh $blastout
        done
done &
```


This will run for a while. 


## Generate summary file

after the previous step runs, you can summarize the results in a csv

```
for folder in seqs/*; do
	for file in $folder/*.tophits; do
		echo $file
	done
done | grep -v "*" > tophits.files


echo "sample,seq_name,seqbin,top_hit_species,top_hit_accession,top_hit_match" > sample_blast_summary.txt
while read line; do
	sample=$(basename $line | cut -f 1 -d "_")
	seqname=$(basename $line .blast.tophits)
	seqbin=$(echo $line |cut -f 2 -d "/")
	top_hit_species=$(head -1 $line | cut -f 1 -d ",")
	top_hit_accession=$(head -1 $line | cut -f 2 -d ",")
	top_hit_match=$(head -1 $line | cut -f 3 -d ",")
	echo "${sample},${seqname},${seqbin},${top_hit_species},${top_hit_accession},${top_hit_match}"
done <tophits.files >> sample_blast_summary.txt
rm tophits.files
```


















