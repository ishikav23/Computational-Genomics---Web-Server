#!/bin/bash

#This script is used to properly extract all of the quast report from the genome assembly pipeline 
#into a separate folder for easier access.

#note to properly activate the conda environment you need to add this preffix to the script "bash -i"

#env store the conda environent
env=""

#loc is the main parent folder that includes the quast report
loc=""

#out is the output folder that will include all the fasta files gunzziped
out=""

#configure variables above based on the given flag options
while getopts "e:l:o:" flag;
do
	case "$flag" in
		e)	
			env=$OPTARG
			;;
		l)
			loc=$OPTARG
			;;
    o)
			out=$OPTARG
			;;
		*)
			;;
	esac
done

#will store the base name of the parent folder with the quast outputs 
base_loc=$(basename $loc)

#activate the conda environment to run pigz
conda activate $env

#create Ouput folder that will include the gunzipped fasta files
if [ ! -d $out ]; then
  mkdir $out
fi

#scan through each subfolder iterateively to find the quast report files, copy them into the output folder with the proper name
cp -r "${loc}/quast_batch_report" "${out}/quast_report"

#leave conda environment
conda deactivate
