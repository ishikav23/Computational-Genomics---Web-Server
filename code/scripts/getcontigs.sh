#!/bin/bash

#This script is used to properly extract all of the final.contig.fa files from the genome assembly pipeline 
#into a separate folder for easier access. The files are also gunziped with pigs

#note to properly activate the conda environment you need to add this preffix to the script "bash -i"

#env store the conda environent
env=""

#loc is the main parent folder that includes all of the assemblies 
#(propgram will scan each subfolder to get the final.contigs.fa files)
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

#will store the base name of the parent folder with the assembly outputs 
base_loc=$(basename $loc)

#gets all relevant subfolders from the main assembly output folder
list=$(ls $loc|grep ^"$base_loc")

#gets the sample ID to properly rename the final.contigs.fa file into SAMPLE_ID.fasta file
list=$(echo "$list"| sed 's|\(^'"$base_loc"'_\)\(.*\)\(_$\)|\2|g')

#activate the conda environment to run pigz
conda activate $env

#create Ouput folder that will include the gunzipped fasta files
if [ ! -d $out ]; then
  mkdir $out
fi

#scan through each subfolder iterateively to find final.contgs.fa files, copy them into the output folder with the proper name
echo "$list" | awk -v "loc_v"=$loc -v "bloc_v"=$base_loc -v "out_v"=$out '{system("cp "loc_v"/"bloc_v"_"$1"_/"bloc_v"_"$1"__asm/final.contigs.fa "out_v"/"$1".fasta")}'

#leave conda environment
conda deactivate
