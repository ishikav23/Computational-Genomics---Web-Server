#!/bin/bash

loc=""
out=""
qloc=""
env=""

while getopts "l:o:q:e:" flag;
do
	case "$flag" in
		l)	
			loc=$OPTARG
			;;
    o)
			out=$OPTARG
			;;
    q)
			qloc=$OPTARG
			;;
    e)
			env=$OPTARG
			;;
		*)
			;;
	esac
done

if [ ! -d $out ]; then
  mkdir $out
fi

conda activate $env

ls -d -1 $loc/*|sed '/^.*\.fai$/d'| grep .fasta > "${out}/contig_list.txt"
ls -d -1 $qloc/databases/phylogeny/*|sed '/^.*\.fai$/d'| grep .fasta >> "${out}/contig_list.txt"

sample=$(ls $loc|sed '/^.*\.fai$/d'| grep .fasta)



fastANI --ql "${out}/contig_list.txt" --rl "${out}/contig_list.txt" -o "${out}/fastani.out" -t 20

python3 $qloc/scripts/plot_tree.py -i "${out}/fastani.out" -o $out -s $sample



