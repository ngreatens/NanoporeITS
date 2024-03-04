#!/bin/bash

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
done <tophits.files >> summary/sample_blast_summary.csv
rm tophits.files


