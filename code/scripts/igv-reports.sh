#!/bin/bash

# using igv-reports

# made minimal.tsv of contig info. basically just need sequence, begin, and end

env=""
seq=""
out=""
t1=""
t2=""
tloc=""
while getopts "e:i:o:t:" flag;
do
	case "$flag" in

		i)
			seq=$OPTARG
			;;
		t)
			tloc=$OPTARG
			;;
		o)
			out=$OPTARG
			;;
 		e)
			env=$OPTARG
			;;
		*)
			;;
	esac

done

conda activate $env
if [ ! -d $out ]; then
  mkdir $out
fi
t1=$(ls $tloc | sed -nE '/^.*\.gff$/p'|sed -n '1p')
t2=$(ls $tloc | sed -nE '/^.*\.gff$/p'|sed -n '2p')
t1="${tloc}/${t1}"
t2="${tloc}/${t2}"
# maybe a better solution would be to awk the contig index file (.fai)

seq_file=$(ls $seq | sed -nE '/^.*\.fasta$/p'| sed 's/^\(.*\)\(\.fasta\)$/\1/g')

samtools faidx "${seq}/${seq_file}.fasta"

awk 'BEGIN {FS="\t"; print "contig" FS "start" FS "end"}; {print $1 FS "0" FS $2}' "${seq}/${seq_file}.fasta.fai" > "${seq}/${seq_file}.tsv"
# the prodigal output .gff works without any issues. 


create_report "${seq}/${seq_file}.tsv" "${seq}/${seq_file}.fasta" --sequence 1 --begin 2 --end 3 --output "${out}/igv_out.html" --tracks "${t1}" "${t2}"

