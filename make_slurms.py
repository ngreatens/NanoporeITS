#!/usr/bin/python

Usage = """
creates a job file for desired number of commands per job

Usage:

  makeSLURMs.py <commands file> <hours (optional)> <GB ram (optional)> <commands per sub (optional)>

by Arun Seetharam arnstrm@iastate.edu 11/08/2016

modified 15/02/2024 by Nick Greatens for ease of use and to allow customization of runtime/partition and memory allocation

"""
import sys
import os

def determine_partition(hours):
        if hours<=96:
                return 'msismall'
        else:
                raise Exception("Job must be shorter than 4 days")

if len(sys.argv)<2:
    print(Usage)
else:
   if len(sys.argv)>2:
         hours=int(sys.argv[2])
         partition=determine_partition(hours)
         hours=str(hours)
   else:
        hours=str(48)
        partition="short"
   if len(sys.argv)>3:
       mem=str(sys.argv[3])
   else:
       mem=str(32)

   cmdargs = str(sys.argv)
   cmds = open(sys.argv[1],'r')
   jobname = str(os.path.splitext(sys.argv[1])[0])
   filecount = 0
   if len(sys.argv)>4:
       numcmds = int(sys.argv[4])
   else:
       numcmds = 1
   line = cmds.readline()
   while line:
        cmd = []
        while len(cmd) != int(numcmds):
                cmd.append(line)
                line = cmds.readline()
        w = open(jobname+'_'+str(filecount)+'.sub','w')
        w.write("#!/bin/bash\n")
        w.write("#SBATCH --nodes 1\n")
        w.write("#SBATCH --ntasks 16\n")
        w.write("#SBATCH --time "+hours+":00:00\n")
        w.write("#SBATCH --job-name "+jobname+"_"+str(filecount)+"\n")
        w.write("#SBATCH --output "+jobname+"_"+str(filecount)+".o%j\n")
        w.write("#SBATCH --error "+jobname+"_"+str(filecount)+".e%j\n")
        w.write("#SBATCH --mail-user=nicholas.greatens@usda.gov\n")
        w.write("#SBATCH --mail-type=end,fail\n")
        w.write("#SBATCH --partition="+partition+"\n")
        w.write("#SBATCH --mem="+mem+"G\n")
        w.write("cd $SLURM_SUBMIT_DIR\n")
        w.write("ulimit -s unlimited\n")
        #w.write("module purge\n")
        #w.write("module use /opt/rit/spack-modules/lmod/linux-rhel7-x86_64/Core\n")
        #w.write("module use /opt/rit/spack-modules/lmod/linux-rhel7-x86_64/gcc/7.3.0\n")
        #w.write("#module use /work/GIF/software/modules\n")
        count = 0
        while (count < numcmds):
           w.write(cmd[count])
           count = count + 1
        w.write("scontrol show job $SLURM_JOB_ID\n")
        w.close()
   
