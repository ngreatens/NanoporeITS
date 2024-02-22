#
USAGE

command.py \
	-file \
	-reference (optional) \
	-forward primer \
	-reverse primer \
	-length \
	-quality


1. Clean reads and filter for length (bbduk)
2. Map to reference (minimap)
3. Align reads that map to reference (mafft)
4. Align primers (Primer3)
5. Orient seq (custom script)
6. Trim primers (custom script)
7. Generate consensus
8. BLASTn result
9. output text file with coverage

