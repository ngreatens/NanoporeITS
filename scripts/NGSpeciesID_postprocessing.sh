#!/bin/bash

if [ $# -ne 3 ] ; then
   echo -e "usage: $(basename "$0") <coverage minimum> <forward primer> <reverse primer>"
   echo ""
   echo -e "\t for use in directory where you just ran NGSpeciesID with Racon for polishing"
   echo -e "\t required modules: seqkit, samtools, and minimap2."
   echo -e "\t If not available, install separately and revise this script with paths"
   echo ""
   echo -e "example: ./$(basename "$0") 20 TGAACCTGCAGAAGGATCATTA GCCTTAGATGGAATTTACCACCC"
   exit 0
fi

module load \
        seqkit \
        samtools \
        minimap2

coverage_minimum=$1
forward_primer=$2
reverse_primer=$3

###################
####Get seqs
###################


# get list of subfolders beginning with "racon" since each consensus sequence will have a folder
for folder in */; do
	for subfolder in ${folder}racon*; do
		for file in $subfolder/consensus*; do
			echo $file
		done
	done
done > raconsubfolders.txt

#get list of samples that do not have a subfolder

cat raconsubfolders.txt | grep '\*' > noseq_tmp
while read line; do echo "$(echo $line | cut -f 1 -d "/")"; done < noseq_tmp > samples_without_consensus_seqs.txt
#rm noseq_tmp

#for samples with consensus sequences
cat raconsubfolders.txt | grep -v '\*' > withseq_tmp
rm  raconsubfolders.txt

#copy and rename consensus sequences to folder seqs
mkdir seqs seqs/passed
while read line; do
	sample=$(echo $line | cut -f 1 -d "/")
	num=$(echo $line | cut -f 2 -d "/" | cut -f 4 -d "_")
	cp ${sample}/racon_cl_id_${num}/consensus.fasta seqs/passed/${sample}_racon_${num}_consensus.fasta
done < withseq_tmp
rm withseq_tmp


##### get sequence counts per sample
for file in seqs/passed/*.fasta; do 
	echo $(basename $file | cut -f 1 -d "_" ) 
	done |
sort | 
uniq -c > counts_passed

echo "sample,number_of_seqs" > seqs_per_sample.csv
while read line; do
echo $line | awk '{print $2","$1}' >> seqs_per_sample.csv
done < counts_passed

while read line; do 
	echo "$(echo $line | cut -f 1 -d "/"),0" >> seqs_per_sample.csv
done < noseq_tmp

echo -n "" > samples2ormoreseqs.txt
while read line; do 
cov=$(echo $line | cut -f 2 -d ",")
if [[ $cov -gt 1 ]]; then 
	echo $(echo $line | cut -f 1 -d ",") >> samples2ormoreseqs.txt
fi
done < seqs_per_sample.csv

rm noseq_tmp
rm counts_passed

#########################
#Trim primers#
#########################

#uses seqkit fish to assess how many times the forward and reverse primers align to sequence

echo -n "" >primer_alignment_summary
for fasta in seqs/passed/*consensus.fasta; do
	cat $fasta | seqkit fish -F $forward_primer 2> forward.alignment
	cat $fasta | seqkit fish -F $reverse_primer 2> reverse.alignment
	forward_lines=$(wc -l forward.alignment | awk '{print $1}')
	reverse_lines=$(wc -l reverse.alignment | awk '{print $1}')
	if [[ $forward_lines -eq 0 ]];
		then
			num_f_alignments=0
		else
			num_f_alignments=$(expr $forward_lines - 1)
	fi
	if [[ $reverse_lines -eq 0 ]];
                then
                        num_r_alignments=0
                else
                        num_r_alignments=$(expr $reverse_lines - 1)
        fi
	echo "$fasta $num_f_alignments $num_r_alignments" >> primer_alignment_summary
done
rm forward.alignment
rm reverse.alignment

#use primer_alignment_summary to make lists of seqs that do not have primers aligning or aligning more than once
echo -n "" > primer_mapping_failed.txt

while read line; do
	if [[ $(echo $line | awk  '{print $2}') -ne 1 ]]; then
	       echo $(echo $line | awk '{print $1}') >> primer_mapping_failed.txt
	fi
	if [[ $(echo $line | awk  '{print $3}') -ne 1 ]]; then
               echo $(echo $line | awk '{print $1}') >> primer_mapping_failed.txt
        fi
done < primer_alignment_summary
rm primer_alignment_summary

mkdir seqs/primers_mapping_error
while read line; do
	mv $line seqs/primers_mapping_error
done < primer_mapping_failed.txt
rm primer_mapping_failed.txt

for fasta in seqs/passed/*.fasta; do
	cat $fasta | seqkit amplicon -F $forward_primer -R $reverse_primer -m 2 > ${fasta%.fasta}_trimmed.fasta
	rm $fasta
done

#################################
####Calculate cov for passed seqs
#################################

echo "sequence,coverage">coverage.csv
for consensus in seqs/passed/*consensus_trimmed.fasta; do
	sample=$(echo $(basename $consensus) | cut -f 1 -d "_")
	num=$(echo $(basename $consensus) | cut -f 3 -d "_")
	reads=${sample}/reads_to_consensus_${num}.fastq
	minimap2 -a $consensus $reads | samtools view -b | samtools sort | samtools coverage - | tail -1 | awk '{print $7}' > cov_tmp
	cov=$(cat cov_tmp | awk '{print int($1+0.5)}') `#round to nearest whole number`
	echo "$(basename $consensus),${cov}">>coverage.csv
done
rm cov_tmp

for folder in seqs/*; do 
	for consensus in $folder/*.fasta; do
        	sample=$(echo $(basename $consensus) | cut -f 1 -d "_")
        	num=$(echo $(basename $consensus) | cut -f 3 -d "_")
        	reads=${sample}/reads_to_consensus_${num}.fastq
        	minimap2 -a $consensus $reads | samtools view -b | samtools sort | samtools coverage - | tail -1 | awk '{print $7}' > cov_tmp
        	cov=$(cat cov_tmp | awk '{print int($1+0.5)}') `#round to nearest whole number`
        	echo "$(basename $consensus),${cov}">>coverage.csv
	done
done
rm cov_tmp

########################
##separate seqs with low cov
##########################

mkdir seqs/low_cov
while read line; do
	seq=$(echo $line | cut -f 1  -d ",")
	cov=$(echo $line | cut -f 2  -d ",")
	if [[ $cov -lt $coverage_minimum ]]; then
		mv seqs/passed/${seq} seqs/low_cov
	fi
done < coverage.csv
		

#################################
#####Summarize results
#################################


####generate summary file######

echo "Date: `date`" > summary.txt
echo "Working directory: `pwd`" >> summary.txt
echo "Forward primer: $forward_primer" >> summary.txt
echo "Reverse primer: $reverse_primer" >> summary.txt
echo "minimap2 v.`minimap2 --version` `samtools version | head  -1` `seqkit version`" >> summary.txt
echo -e "\n" >> summary.txt
echo "number of seqs passed: $(ls seqs/passed/ | wc -l)" >> summary.txt
echo "number of seqs failed due to low coverage of consensus sequence: $(ls seqs/low_cov/ | wc -l)" >> summary.txt
echo "number of seqs failed due to failed primer mapping: $(ls seqs/primers_mapping_error/ | wc -l)" >> summary.txt
echo "number of seq failed due to no consensus sequence: $(cat samples_without_consensus_seqs.txt | wc -l | awk '{print $1}')" >> summary.txt
echo "Samples with more than one sequence generated (regardless of coverage): $(cat samples2ormoreseqs.txt | wc -l)" >>summary.txt
echo -e "\n" >> summary.txt
echo "Seqs passed:" >> summary.txt
echo "$(ls seqs/passed/)" >> summary.txt
echo -e "\n" >> summary.txt
echo "Seqs failed due to low coverage of consensus sequence:" >> summary.txt
echo "$(ls seqs/low_cov/)" >> summary.txt
echo -e "\n" >> summary.txt
echo "Seqs failed due to failed primer mapping:" >> summary.txt
echo "$(ls seqs/primers_mapping_error/)" >> summary.txt
echo -e "\n" >> summary.txt
echo "Seqs failed due to no consensus sequence:" >> summary.txt
echo "$(cat samples_without_consensus_seqs.txt)" >> summary.txt
echo -e "\n" >> summary.txt
echo "Samples with more than one sequence generated (regardless of coverage): $(cat samples2ormoreseqs.txt | wc -l)" >>summary.txt
cat samples2ormoreseqs.txt >> summary.txt

#### generate seqs_passed.txt ####
echo "$(ls seqs/passed/)" > seqs_passed.txt

#### generate seqs_failed.txt #####

echo "Seqs failed due to low coverage of consensus sequence:" > seqs_failed.txt
echo "$(ls seqs/low_cov/)" >> seqs_failed.txt
echo -e "\n" >> seqs_failed.txt
echo "Seqs failed due to failed primer mapping:" >> seqs_failed.txt
echo "$(ls seqs/primers_mapping_error/)" >> seqs_failed.txt
echo -e "\n" >> seqs_failed.txt
echo "Seqs failed due to no consensus sequence:" >> seqs_failed.txt
echo "$(cat samples_without_consensus_seqs.txt)" >> seqs_failed.txt
rm samples_without_consensus_seqs.txt

mkdir summary
mv samples2ormoreseqs.txt  seqs_per_sample.csv seqs_failed.txt seqs_passed.txt coverage.csv summary.txt summary/
