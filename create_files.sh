#!/bin/bash

#This script is intended to create duplicate random files with different sizes and names

DIRNAME='rand_files'
EXT=('log' 'txt' 'conf')
NAMES=('apache' 'nginx' 'couchdb' 'docker')

echo "Init"

#checks
#if [ ! $(pwd) = "$HOME" ]; then
#	echo "Please run from your HOME dir"
#	exit 1
fi
echo "pwd"
if [ ! -d "$DIRNAME" ]; then
	if mkdir "$DIRNAME"; then 
	echo " Created a $DIRNAME directory"
	else 
		echo "Cannot create $DIRNAME directory"
		exit 1
	fi
fi
echo 
cd "$DIRNAME"
#create similar data

#populate array of words
WORDS=(`man test | awk '{print $2}' | sort -u`) 

for i in {1..10}; do
	cont_str=''
	for j in {1..10}; do
		t_str="${WORDS[$i]} ${WORDS[@]}"
		#echo "t_str ${#t_str}"
		cont_str+="${t_str}"$cont_str
		done
	#echo "cont_str ${#cont_str}"
	content[$i]="$cont_str"
	
done

for ext in "${EXT[@]}"; do 
	for name in "${NAMES[@]}"; do
	 for a in {1..10}; do 
	 rnd_cnt=$(( ( RANDOM % 10 ) + 1 ))
	 	fname="$name$a.$ext"
	 	[ -e "$fname" ] || touch "$fname"
	 	#echo "File $fname is already exists"
	 	echo "${content[$rnd_cnt]}" > "$fname"
	 	echo "created $fname with size $(ls -hs $fname | awk '{print $1'}) and content number $rnd_cnt"
	 done
	done
done