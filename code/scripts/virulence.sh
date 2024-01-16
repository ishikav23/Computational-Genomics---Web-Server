#!/bin/bash

env=""
loc=""
out=""
src=""

while getopts "e:l:o:q:" flag;
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
		q)
			src=$OPTARG
			;;
		*)
			;;
	esac

done
#initialization
if [ ! -d $out ]; then
  mkdir $out
fi

conda activate $env

#run out.fna against VFDB using mmseqs
echo "----------------mmseqs start--------------"
mmseqs easy-search "${loc}/out.fna" $src/databases/vf_db/VFDB_setA_pro.fas "${out}/out.m8" tmp --format-output query,target,pident,alnlen,mismatch,gapopen,qstart,qend,tstart,tend,evalue,bits,qframe,qseq -s 7.5 -v 0
echo "mmseqs successeed"
	
	
#generate the gff file
echo "----------convert blastx fmt to gff--------"
python3 $src/scripts/mmseqs_gff_from_blastX.py -blastx "${out}/out.m8" -source VFDB -o "${out}/vf_out.gff" #linsey's original script for gff generation
echo "----------trimming gff-----------"
#trim the seq id in gff
cut -f1 "${out}/vf_out.gff" | sed 's/:.*//' | paste -d '\t' - <(cut -f2- "${out}/vf_out.gff") > "${out}/vf_mod.txt"
mv "${out}/vf_mod.txt" "${out}/vf_out.gff"

awk 'BEGIN {FS=OFS="\t"} {if ($4 > $5) {temp=$4; $4=$5; $5=temp} print}' "${out}/vf_out.gff" > "${out}/vf_out_corrected.gff"

mv "${out}/vf_out_corrected.gff" "${out}/vf_out.gff"

