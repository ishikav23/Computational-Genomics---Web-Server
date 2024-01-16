#!/bin/bash

#This assembly_core shell script is able to assemble the genome from a pair of 2 fastq files and run a quast report
#every relevnat command is wrapped with the time prefix and a log is generated

#env will store the conda environment
env=""

#i1 and i2 will be the fastq inputs
i1=""
i2=""

#out will be the output folder with the results
out=""

#configure variables above based on the given flag options
while getopts "e:1:2:o:" flag;
do
	case "$flag" in
		1)
			i1=$OPTARG
			;;
		2)	
			i2=$OPTARG
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

#get the name of the fastq pair (exclude the _Number.fq.gz)
name=$(echo $i1| sed 's/\(^.*\)\(\/[^\/]*_.*fq.*$\)/\2/g')
name=$(echo $name| sed 's/\(^\/\)\(.*\)\(_.*fq.*$\)/\2/g')

echo $out
out_base=$(basename "$out")
echo "${out}/${out_base}_raw_qa"
#activate the conda environment with all the dependecies installed and create an output folder
conda activate $env
mkdir "$out"
mkdir "${out}/${out_base}_raw_qa"
echo "Starting Assembly for pair ${name}" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "++++++++++++++++++++++++++++++++++++++" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "" 2>&1 | tee -a "${out}/${name}_long_log.log"

#Run falco for both fastq files from pair to get quality assesment and also record what happens to log file
echo "Running Falco" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "For read ${i1}" 2>&1 | tee -a "${out}/${name}_long_log.log"
(time falco -t 25 -o "${out}/${out_base}_raw_qa/1" $i1) 2>&1 | tee -a "${out}/${name}_long_log.log" 
echo "For read ${i2}" 2>&1 | tee -a "${out}/${name}_long_log.log"
(time falco -t 25 -o "${out}/${out_base}_raw_qa/2" $i2) 2>&1 | tee -a "${out}/${name}_long_log.log"
mkdir "${out}/${out_base}_trim"
echo "______________________________________" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "" 2>&1 | tee -a "${out}/${name}_long_log.log"

#Run trimmomatic to trim low quality regions from the fastq files and also record what happens to log file
echo "Running Trimmomatic" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "" 2>&1 | tee -a "${out}/${name}_long_log.log"
(time trimmomatic PE -phred33 -threads 25 $i1 $i2 "${out}/${out_base}_trim/r1.paired.fq.gz" "${out}/${out_base}_trim/r1_unpaired.fq.gz" "${out}/${out_base}_trim/r2.paired.fq.gz" "${out}/${out_base}_trim/r2_unpaired.fq.gz" LEADING:4 TRAILING:4 MAXINFO:97:0.7 MINLEN:100 AVGQUAL:28) 2>&1 | tee "${out}/${out_base}_trim/trim_log.txt"
cat "${out}/${out_base}_trim/trim_log.txt" >> "${out}/${name}_long_log.log"

#extract surviving read info from log into a smaller trim log file
sed -i -n '3p' "${out}/${out_base}_trim/trim_log.txt"
cat "${out}/${out_base}_trim/trim_log.txt" | sed 's/\(^.*\)\([\(][0-9]\{1,\}\.[0-9]\{1,\}%[\)]\)\(.*\)\([\(][0-9]\{1,\}\.[0-9]\{1,\}%[\)]\)\(.*\)\([\(][0-9]\{1,\}\.[0-9]\{1,\}%[\)]\)\(.*\)\([\(][0-9]\{1,\}\.[0-9]\{1,\}%[\)]\)\(.*$\)/\2\4\6\8/g'|sed 's/[\(\)]//g'|sed 's/%/,/g' >> "${out}/${out_base}_trim/trim_vals.txt"
echo "" 2>&1 | tee -a "${out}/${name}_long_log.log"

#Remove unpaired reads as they are not needed
echo "Removing unpaired Reads" 2>&1 | tee -a "${out}/${name}_long_log.log"
(time rm -v "${out}/${out_base}_trim"/*unpaired*) 2>&1 | tee -a "${out}/${name}_long_log.log"
mkdir "${out}/${out_base}_raw_qa_trimmed"
echo "______________________________________" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "" 2>&1 | tee -a "${out}/${name}_long_log.log"

#Run falco for both trimmed fastq files from pair to get quality assesment after trimming and also record what happens to log file
echo "Running Falco after trimming" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "For 1st trimmed paired read"2>&1 | tee -a "${out}/${name}_long_log.log"
(time falco -t 25 -o "${out}/${out_base}_raw_qa_trimmed/1" "${out}/${out_base}_trim/r1.paired.fq.gz") 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "For 2nd trimmed paired read" 2>&1 | tee -a "${out}/${name}_long_log.log"
(time falco -t 25 -o "${out}/${out_base}_raw_qa_trimmed/2" "${out}/${out_base}_trim/r2.paired.fq.gz") 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "______________________________________" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "" 2>&1 | tee -a "${out}/${name}_long_log.log"

#Decompress trimmed fastq files to prepare them for genome assembly with megahit also records to log file
echo "Decompressing trimmed paired reads for megahit assembly" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "Decompressing 1st paired trimmed read" 2>&1 | tee -a "${out}/${name}_long_log.log"
(time pigz -d "${out}/${out_base}_trim/r1.paired.fq.gz") 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "Decompressing 2nst paired trimmed read" 2>&1 | tee -a "${out}/${name}_long_log.log"
(time pigz -d "${out}/${out_base}_trim/r2.paired.fq.gz") 2>&1 | tee -a "${out}/${name}_long_log.log"
rm -rf "${out}/${out_base}_asm"
echo "______________________________________" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "" 2>&1 | tee -a "${out}/${name}_long_log.log"

#Run the megahit genome assembly and record to log file
echo "Running megahit" 2>&1 | tee -a "${out}/${name}_long_log.log"
(time megahit -t 25 -1 "${out}/${out_base}_trim/r1.paired.fq" -2 "${out}/${out_base}_trim/r2.paired.fq" -o "${out}/${out_base}_asm" --min-count 4) 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "______________________________________" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "" 2>&1 | tee -a "${out}/${name}_long_log.log"

#Recompress trimmed fastq files into gz format
echo "Recompressing trimmed paired reads" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "Recompressing 1st paired trimmed read" 2>&1 | tee -a "${out}/${name}_long_log.log"
(time pigz "${out}/${out_base}_trim/r1.paired.fq") 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "Recompressing 2nd paired trimmed read" 2>&1 | tee -a "${out}/${name}_long_log.log"
(time pigz "${out}/${out_base}_trim/r2.paired.fq") 2>&1 | tee -a "${out}/${name}_long_log.log"
mkdir "${out}/${out_base}_quast_out"
echo "______________________________________" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "" 2>&1 | tee -a "${out}/${name}_long_log.log"

#Run QUAST for quality assesment of the assembled genome
echo "Running QUAST" 2>&1 | tee -a "${out}/${name}_long_log.log"
(time quast.py "${out}/${out_base}_asm/final.contigs.fa" -o "${out}/${out_base}_quast_out" -t 25) 2>&1 | tee "${out}/${out_base}_quast_out/asm_log.txt"
qvar=$(cat "${out}/${out_base}_quast_out/asm_log.txt")
echo "$qvar" >> "${out}/${name}_long_log.log"

#also extract quast results to a smaller quast log file
echo $qvar|sed 's/\(^.* \)\(final\.contigs, \)\(N50 = .*\)\(, # N.*$\)/\3/g' > "${out}/${out_base}_quast_out/asm_log.txt"
echo "++++++++++++++++++++++++++++++++++++++" 2>&1 | tee -a "${out}/${name}_long_log.log"
echo "" >> "${out}/${name}_long_log.log"

#Genome assembly is complete
echo "Assembly Processes for ${name} is complete" 2>&1 | tee -a "${out}/${name}_long_log.log"
