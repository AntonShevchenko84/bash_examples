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
#fi
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
write_to_file() {
str=$1
for ext in "${EXT[@]}"; do 
	for name in "${NAMES[@]}"; do
	 rnd_cnt=$(( ( RANDOM % 4 ) + 1 ))
	 for a in $(seq 1 $(( 3 + $rnd_cnt )) ); do 
		fname="$name$a.$ext"
	 	[ -e "$fname" ] || touch "$fname"
	 	#echo "File $fname is ${#1} length"
	 	echo "$str" > "$fname" 2>/dev/null
	 	echo "created $fname with size $(du -ch $fname 2>/dev/null | awk '{print $1'})"
	 done
	done
done
}

#populate array of words
WORDS=(`man test | awk '{print $2}' | sort -u`) 

for i in {1..10}; do
	cont_str=''
	rnd_cnt=$(( ( RANDOM % 4 ) + 1 ))
		for j in $(seq 1 $(( 5 + $rnd_cnt )) ) ; do
		t_str="${WORDS[$i]} ${WORDS[@]}"
		cont_str+="${t_str}"$cont_str
	done
	rnd_cnt=0;
	write_to_file "$cont_str"

done
	
