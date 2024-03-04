#!/bin/bash


cd summary
cat sample_blast_summary.csv | tail -n+2 | sort -t, -k 2 > sample_blast_summary_sorted.csv
cat coverage.csv | sort -t, -k 1 > coverage_sorted.csv
head -1 sample_blast_summary.csv|  tr -d '\n' > sample_blast_summary_withcov.csv
echo ",coverage" >> sample_blast_summary_withcov.csv
join -t , -1 2 -2 1 -o 1.1,1.2,1.3,1.4,1.5,1.6,2.2 sample_blast_summary_sorted.csv coverage_sorted.csv | sort  -t, -k 1 -V >> sample_blast_summary_withcov.csv

rm sample_blast_summary_sorted.csv
rm coverage_sorted.csv

cd ..
