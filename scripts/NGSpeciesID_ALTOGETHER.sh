#!/bin/bash

if [ $# -ne 4 ] ; then
   echo -e "usage: $(basename "$0") <coverage minimum> <forward primer> <reverse primer> <quality>"
   echo ""
   echo -e "\t for use in directory where you just ran NGSpeciesID with Racon for polishing"
   echo -e "\t required modules: blast+, seqkit, samtools, and minimap2."
   echo -e "\t If not available, install as needed and revise this script or other called scripts with paths"
   echo ""
   echo -e "example: ./$(basename "$0") 20 TGAACCTGCAGAAGGATCATTA GCCTTAGATGGAATTTACCACCC 10"
   exit 0
fi


coverage_minimum=$1
forward_primer=$2
reverse_primer=$3
quality=$4

######CHANGE PATH#########
export PATH=$PATH:/project/fdwsru_fungal/Nick/nanopore/seqs_for_ng/NanoporeITS/scripts

module load parallel

# run NGSpeciesID

declare -a samples=() 
for file in *.fastq; do samples+=($file); done
parallel -j 16 NGSpeciesID.sh {} $4 ::: "${samples[@]}"

## run post processing script to trim primers, summarize data, and move everything to bins
NGSpeciesID_postprocessing.sh $coverage_minimum $forward_primer $reverse_primer

## run blast on everything. ideally parallelize this step or run batches in separate slurm submissions. by far the longest step in the process. e.g.

for folder in seqs/*; do
        for file in $folder/*.fasta;do
                echo $file
        done;
done | grep -v '*' > blast.files

declare -a blast_files=()
while read line; do 
	blast_files+=($line)
done<blast.files

parallel -j 16 blast.sh {} ::: ${blast_files[@]}

# get taxa for blast output and reformat

declare -a blastouts=()
for folder in seqs/*; do
        for blastout in $folder/*.blast.out; do
		blastouts+=($blastout)
        done
done

parallel -j 16 blast_out_to_taxa.sh {} ::: "${blastouts[@]}"


## summarise blast results

summarize_blast.sh

## merge coverage and blast resul summary

merge_cov_blastout.sh

## move seqs/ and summary/ folders to computer for analysis
