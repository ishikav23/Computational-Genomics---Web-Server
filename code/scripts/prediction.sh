
env=""
loc=""
out=""

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

conda activate $env

inp=$(ls $loc | sed -nE '/^.*\.fasta$/p')

if [ ! -d $out ]; then
  mkdir $out
fi

prodigal -i "${loc}/${inp}" -c -m -f gff -o "${out}/out.gff"
bedtools getfasta -fi "${loc}/${inp}" -bed "${out}/out.gff" -fo "${out}/out.fna"

