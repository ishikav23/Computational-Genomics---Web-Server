#!/bin/bash

env=""
genv=""
loc=""
aloc=""
out=""

while getopts "e:g:a:l:o:q:" flag;
do
	case "$flag" in

		e)
			env=$OPTARG
			;;
 		g)
			genv=$OPTARG
			;;
		l)
			loc=$OPTARG
			;;
 		a)
			aloc=$OPTARG
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
bash -i $src/scripts/card.sh -e $env -l $loc -o $out -q $src
bash -i $src/scripts/virulence.sh -e $env -l $loc -o $out -q $src
bash -i $src/scripts/igv-reports.sh -e $genv -i $aloc -t $out -o $out

