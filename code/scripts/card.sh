
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

if [ ! -d $out ]; then
  mkdir $out
fi

conda activate $env

diamond blastx --db $src/databases/card_db/card.dmnd -q "${loc}/out.fna" -o "${out}/out.tsv" --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qframe qseq


python3 $src/scripts/gff_from_blastX.py -blastx "${out}/out.tsv" -source card -o "${out}/card_out"

awk 'BEGIN {FS=OFS="\t"} {if ($4 > $5) {temp=$4; $4=$5; $5=temp} print}' "${out}/card_out.gff" > "${out}/card_out_corrected.gff"

mv "${out}/card_out_corrected.gff" "${out}/card_out.gff"

