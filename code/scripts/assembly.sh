#!/bin/bash

#This is the assembly shell script that wraps the getfastq.sh to fetch the fastq files in a paired format, the assembly_core.sh
#to assemblt genome for each pair (it loops through all the pairs), and the batch_quast.sh to run a quast report in all the contigs.fasta files

#env will be the conda environment
env=""
#out will be the output folder name
out=""
#loc will be the folder path with the fastq files
loc=""
#sum will be the location of the summarized report for assembly
sum=""
#num stores the number of pairs it wants to list if set to -1 it will print all pairs. It is called by the optional -p flag
num=-1

src=""

#configure variables above based on the given flag options
while getopts "e:l:p:o:s:q:" flag;
do
	case "$flag" in

		e)
			env=$OPTARG
			;;

		l)
			loc=$OPTARG
			;;
 		s)
			sum=$OPTARG
			;;
		p)
			num=$OPTARG
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


#get all the fastq files in pairs with getfastq.sh
list=$($src/scripts/getfastq.sh -p "$num" -l "$loc")
list=$(echo "$list"|sed 's/\(^.*_\)\(.*$\)/\1/g'|sed -n '1~2!p')

#generate the Output folder withe the proper log files
mkdir "$out"
touch "${out}/log.log"
echo "Both,Forward,Reversed,Dropped," > "${out}/trim_data.csv"

#awk will be used to run the assembly for each fastq pair in a loop as well as generate the proper log files
echo "$list"|awk -v out_v=$out -v env_v=$env -v loc_v=$loc -v src_v=$src '{out_l=out_v"_"$1; out_r=out_v; start=systime(); system("bash -i "src_v"/scripts/assembly_core.sh -e "env_v" -1 "loc_v"/"$1"1.fq.gz -2 "loc_v"/"$1"2.fq.gz -o "out_l); system("mv "out_l" "out_r); end=systime(); elapsed=end-start; print "Time elapsed "elapsed" seconds"; system("echo For pair "$1" >> "out_v"/log.log"); system("echo Trim Info for pair "$1" $(cat "out_v"/"out_l"/"out_l"_trim/trim_log.txt) >> "out_v"/log.log"); system("echo Assembly Info for pair "$1" $(cat "out_v"/"out_l"/"out_l"_quast_out/asm_log.txt) >> "out_v"/log.log"); system("echo Time elapsed for pair "$1": "elapsed" seconds >> "out_v"/log.log"); system("echo >> "out_v"/log.log"); system("echo Total time elapsed for pair "$1": "elapsed" seconds >> "out_v"/"out_l"/"$1"long_log.log"); system("cat "out_v"/"out_l"/"$1"long_log.log >> "out_v"/long_log.log"); system("echo ====================================== >> "out_v"/long_log.log"); system("cat "out_v"/"out_l"/"out_l"_trim/trim_vals.txt >> "out_v"/trim_data.csv");}'

#run the batch quast after assembly is complete for all fastq pairs
bash -i $src/scripts/batch_quast.sh -e $env -o $out
bash -i $src/scripts/getcontigs.sh -e $env -l $out -o $sum
bash -i $src/scripts/getquast.sh -e $env -l $out -o $sum
bash -i $src/scripts/getfalco.sh -e $env -l $out -o $sum

