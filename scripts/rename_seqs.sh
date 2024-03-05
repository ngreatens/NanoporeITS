#!/bin/bash

for folder in seqs/*; do
	for fasta in $folder/*.fasta; do
		echo $fasta
	done
done | grep -v "*" > fasta.list


mkdir seqs_renamed
mkdir seqs_renamed/passed seqs_renamed/low_cov seqs_renamed/primers_mapping_error

while read fasta; do 
	name=`awk -v fasta="$(basename $fasta)" -F',' '{ if ($2 == fasta) { print $2","$3","$4","$5","$6","$7 } }' summary/sample_blast_summary_withcov.csv | sed 's/ /_/g'`
	bin=`echo $fasta | cut -f 2 -d "/"`
	seq=`cat $fasta | bioawk -c fastx '{print $seq}'`
	outname=$(basename $fasta .fasta)_renamed.fasta
	echo ">${name}" > seqs_renamed/${bin}/${outname}
	echo $seq >> seqs_renamed/${bin}/${outname}
done < fasta.list
rm fasta.list


