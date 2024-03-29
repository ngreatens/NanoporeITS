#!/bin/bash

reads=$1
quality=$2
outfolder=${reads%.*}


eval "$(conda shell.bash hook)" #intialize shell for conda environments
conda activate ~/.conda/envs/NGSpeciesID

NGSpeciesID \
	--ont \
	--consensus \
	--q $quality \
	--racon \
	--racon_iter 3 \
	--m 750 \
	--s 250 \
	--fastq $reads \
	--outfolder $outfolder

conda deactivate
