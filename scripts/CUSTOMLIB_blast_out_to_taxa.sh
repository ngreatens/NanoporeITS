#!/bin/bash
ml miniconda

blastout=$1
outfile=${blastout%.out}.tophits
taxdump_dir=/project/fdwsru_fungal/Nick/databases/taxdump

eval "$(conda shell.bash hook)" #intialize shell for conda environments
conda activate taxonkit

while read line; do 
        taxid=$(echo $line | awk '{print $4}')
	taxon=`echo $taxid | taxonkit lineage --data-dir=$taxdump_dir -L -n | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'`
	seqhit=$(echo $line | awk '{print $2}' |cut -f 2 -d "|")
	match=$(echo $line | awk '{print $5}')
	echo "${taxon},${seqhit},${match}"
done < ${blastout} > $outfile


conda deactivate

