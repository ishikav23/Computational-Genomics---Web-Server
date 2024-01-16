#!/bin/bash

avar=""
bvar=""
cvar=""
dvar=""
out=""

while getopts "a:b:c:d:o:" flag;
do
	case "$flag" in
		a)	
			avar=$OPTARG
			;;
		b)
			bvar=$OPTARG
			;;
    c)
			cvar=$OPTARG
      ;;
    d)
			dvar=$OPTARG
      ;;
    o)
			out=$OPTARG
			;;
		*)
			;;
	esac
done

if [ ! -d $out ]; then
  mkdir $out
fi
cp -r "${avar}/"* "${out}/"
cp -r "${bvar}/"* "${out}/"
cp -r "${cvar}/"* "${out}/"
cp -r "${dvar}/"* "${out}/"
rm -rf $avar
rm -rf $bvar
rm -rf $cvar
rm -rf $dvar