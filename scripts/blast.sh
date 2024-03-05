#!/bin/bash

#database=/project/fdwsru_fungal/Nick/databases/nt/nt
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



#follow ncbi protocol for downloading nt database. It will take a long time to download. Then set search to your own nt database.
#eventually NCBI will punish your ip address for repeated searches on their servers.

#ml blast+
#
#blastn \
#                -db $database \
#                -query $query \
#                -out $outname \
#                -max_target_seqs 10 \
#                -outfmt "6  qseqid sseqid sgi staxids pident length mismatch gapopen qstart qend sstart send evalue bitscore"
#
