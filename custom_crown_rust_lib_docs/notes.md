* download fastas from NCBI using list

* get rid of wrapping and eliminate metadata

```
cat Custom_Crown_rust_library.fasta | bioawk -c fastx '{print ">"$1"\n"$2}' > library.fasta
```

* get seqlist with updated versions

```
cat library.fasta | grep '>' | tr -d ">" > seqlist.txt
```

* look up taxid for each accession using nucl_gb.accession2taxid database from NCBI

```
while read line; do grep $line nucl_gb.accession2taxid | awk '{print $2" "$3}'; done < seqlist.txt > taxids.txt
```


In additiion, I included some sequences for some common contaminants, at least in the last runs that I did--mostly basidiomycete yeasts:
```
Filobasidium stepposum                     | MN128835.1
Aspergillus cibarius                       | OL711856.1
Filobasidium magnum                        | JX188126.1
Aspergillus caperatus                      | OL711858.1
Symmetrospora coprosmae                    | AM160645.1
Naganishia globosa                         | JX188127.1
Erythrobasidium hasegawianum               | FN824494.1
Cryptococcus sp. HB 1222                   | AM160648.1
```

* And similarly downloaded and formatted files. concatenated contaminant files with crown rust library files.

crown rust library files:
* library.fasta
* taxids.txt
* seqlist.txt

crown rust with contaminants library files (recommended):
* crownrust_wcontaminants_library.fasta
* crownrust_wcontaminants_taxids.txt
* crownrust_wcontaminants_seqlist.txt


module load blast+ ###### use module name used by MSI

makeblastdb -in crownrust_wcontaminants_library.fasta -parse_seqids -taxid_map crownrust_wcontaminants_taxids.txt -dbtype nucl -title crownrust_wcontaminants_library.fasta


	
