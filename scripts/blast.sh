#!/bin/bash

#database=$1 #/project/fdwsru_fungal/Nick/databases/nt/nt
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

