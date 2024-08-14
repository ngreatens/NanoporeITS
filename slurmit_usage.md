# slurmit usage

download script. save to ~/scripts for example

add to bashrc, e.g. Change path if needed
```
echo "alias slurmit='~/scripts/makeslurms.py'" >> ~/.bashrc
source ~/.bashrc
```

put all commands in shell script with command line inputs

e.g. a script spades-paired.sh

```
#!/bin/bash

threads=16
forward_reads=$1
reverse_reads=$2
outname=$3

module load \
    spades/3.15.5 \
    python_3/3.11.1

spades.py \
    -1 $forward_reads \
    -2 $reverse_reads \
    -t $threads \
    -o $outname
```

then 
```
echo ./spades-paired.sh Col_R1.fastq col_R2.fastq Col > spades.cmds
slurmit spades.cmds 24 32
```
should output a slurm script
```
#!/bin/bash
#SBATCH --nodes 1
#SBATCH --ntasks 16
#SBATCH --time 24:00:00
#SBATCH --job-name spades_0
#SBATCH --output spades_0.o%j
#SBATCH --error spades_0.e%j
#SBATCH --mail-user=nicholas.greatens@usda.gov
#SBATCH --mail-type=end,fail
#SBATCH --partition=short
#SBATCH --mem=32G
cd $SLURM_SUBMIT_DIR
ulimit -s unlimited
./spades-paired.sh Col_R1.fastq Col_R2.fastq Col
scontrol show job $SLURM_JOB_ID
```
  
