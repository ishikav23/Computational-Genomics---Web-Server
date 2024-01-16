#!/bin/bash

#This getfastq shell script accepts a folder path as an input and prints out the fastq pairs in order from smallest file size to largest
#There is also an optional -p flag to only print the first N ammount of pairs, if ommited it prints all pairs

#num stores the number of pairs it wants to list if set to -1 it will print all pairs
num=-1

#loc sotres the folder with the fastq files
loc=""

#configure variables above based on the given flag options
while getopts "l:p:" flag;
do
	case "$flag" in
		p)	
			num=$OPTARG
			;;
		l)
			loc=$OPTARG
			;;
		*)
			;;
	esac
done

#created a tabbed string based on string length of folder path which is helpful with formating during regex substitutions and string concatenations
len=${#loc}
tabbed=""
for i in {1..$len}
do
  tabbed+="\t\t\t\t"
done

#complex pipe to list all the fastq files from smallest to largest (may not be paired next to each toher at this point yet)
list=$(ls -sh $loc|sed -e 's/\( \{1,\}\)/ /g'|sed -e 's/\t\{1,\}/\n/g'|sed 's/\(^ \)\(.*\)/\2/g'|sed 's/ /\n/2;P;D'|sort -h|tail -n +2|cut -f 2 -d ' ')


#if num is -1 set num to the total number of pairs
if [ "$num" == -1 ];then
  num=$(echo "$list"|wc -l)
  num=$(( num / 2 ))
fi

#fastq file names from list variable will be transffere to array arr_list
arr_list=()
temp=""
char=""
NL=$'\n' #variable to help use new line character

#transfer fastq files to arr_list.
for (( i=0; i<${#list}; i++ ))
do
	char="${list:$i:1}"
	if [ "$char" = "$NL" ];
	then
		arr_list+=("$temp")
		temp=""
	else
		temp="${temp}${char}"
	fi
	
done

#following code will try to order the files from the arr_list into pairs next to each other and store that to arr_filter.

#count will keep track of only storing as many pairs as num variable states
count=0 
arr_filter=()
for i in "${arr_list[@]}"
do
	:
	#if fastq name does not exist in arr_filter add it and its counterpart if it exists the skip as both pairs should be listed
	name=$(echo $i|sed 's/\(^.*_\)\(.*$\)/\1/g')
	if [[ " ${arr_filter[*]} " == *" $i "* ]]; then
		true
	else
		fname="${name}1.fq.gz"
		arr_filter+=("$fname")
		fname="${name}2.fq.gz"
		arr_filter+=("$fname")
		count=$((count+1))
	fi
	if [ "$count" -ge "$num" ]; then
		#break loop once count reaches num
		break
	fi
done

#add reordered arr_filter elements into the list_filters string separated by a new line character
list_filter=""

for i in "${arr_filter[@]}"
do
	:
	list_filter="${list_filter}${NL}${i}"
done

#print out the list filter with pairs orders (to be used for next parts of the batch assembly)
list_filter=$(echo "$list_filter"|tail -n +2)
echo "$list_filter"



