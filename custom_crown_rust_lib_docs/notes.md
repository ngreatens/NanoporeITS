### Get custom library.

* Got list of ITS sequences from papers on Puccinia Series Coronata that use updated taxonomy. This way blast hits will be to specific species or subspecies within the broader species complex.

```
Abbasi, M., Hambleton, S., Liu, M., Redhead, S. A., & Brar, G. S. (2024). First report of Puccinia gibberosa on blue oatgrass (Helictotrichon sempervirens) in Canada, with taxonomic revision of the rust species. Canadian Journal of Plant Pathology, 46(1), 19–26. https://doi.org/10.1080/07060661.2023.2270941
Demers, J. E., Byrne, J. M., & Castlebury, L. A. (2016). First Report of Crown Rust (Puccinia coronata var. Gibberosa) on Blue Oat Grass (Helictotrichon sempervirens) in the United States. Plant Disease, 100(5), 1009–1009. https://doi.org/10.1094/PDIS-09-15-1093-PDN
Greatens, N., Klejeski, N., Szabo, L. J., Jin, Y., & Olivera, P. D. (2023). Puccinia coronata var. Coronata, a Crown Rust Pathogen of Two Highly Invasive Species, Is Detected Across the Midwest and Northeastern United States. Plant Disease, 107(7), 2009–2016. https://doi.org/10.1094/PDIS-07-22-1711-RE
Greatens, N., Miller, K., Watkins, E., Jin, Y., & Olivera, P.D. (in press). Host specificity of Puccinia digitaticoronata, a new crown rust fungus of Kentucky bluegrass in North America. Plant Disease. 
Hambleton, S. (2019). Crown rust fungi with short lifecycles – the Puccinia mesnieriana species complex. Sydowia An International Journal of Mycology, 71, 47–63. https://doi.org/10.12905/0380.sydowia71-2019-0047
Ji, J., Li, Z., Li, Y., & Kakishima, M. (2022). Phylogenetic approach for identification and life cycles of Puccinia (Pucciniaceae) species on Poaceae from northeastern China. Phytotaxa, 533(1), Article 1. https://doi.org/10.11646/phytotaxa.533.1.1
Kenaley, S. C., Ecker, G., & Bergstrom, G. C. (2017). First Report of Puccinia coronata var. Coronata sensu stricto Infecting Alder Buckthorn in the United States. Plant Health Progress, 18(2), 84–86. https://doi.org/10.1094/PHP-01-17-0003-BR
Liu, M., & Hambleton, S. (2013). Laying the foundation for a taxonomic review of Puccinia coronata s.l. In a phylogenetic context. Mycological Progress, 12(1), 63–89. https://doi.org/10.1007/s11557-012-0814-1
```
* There are some additional fungi in here--e.g. P. graminis, etc. that were used as outroups in Liu and Hambleton 2013. This won't affect results.
*  a few remaining seqs in the library labelled as Puccinia coronata, but you are unlikely to get these as hits. They are all in unresolved taxa that are not present in the U.S. to my knowledge. Most hits of crown rust fungi should be labelled to subspecies, variety, etc. within P. Series Coronata
  

* download fastas from NCBI using list; save as Custom_Crown_rust_library.fasta

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


* In additiion, I included some sequences for some common contaminants, at least in the last runs that I did--mostly basidiomycete yeasts:
* I think no need to cite these, but useful to include in your library so you don't have a bunch of samples with no hits
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


### Example usage to make db

```
#### after downloading files in this folder to your dir ###
module load blast-plus ###### use module name used by MSI

makeblastdb -in crownrust_wcontaminants_library.fasta -parse_seqids -taxid_map crownrust_wcontaminants_taxids.txt -dbtype nucl -title crownrust_wcontaminants_library.fasta
```
* then you will have to change the name of the directory in blast.sh.
* you will direct it to the fasta file, after making the db
* e.g. database="/path/to/dir/crownrust_wcontaminants_library.fasta"

### run blast

* after the blast.sh script is changed, use command as normal

```
./blast.sh example.fasta
```

### run CUSTOMLIB_blast_out_to_taxa.sh

in place of "blast_out_to_taxa.sh", you will run CUSTOMLIB_blast_out_to_taxa.sh on blast.out files. For some reason some information is lost with custom searches, and the place of the match is different in the output. This will work, but only with the custom libary.

```
./CUSTOMLIB_blast_out_to_taxa.sh example.blast.out
```
### Continue

* Everything else should work as normal

	
