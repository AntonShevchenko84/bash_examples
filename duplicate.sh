#!/bin/bash
#this script search for multiple files with same content based on sha1 or md5 hash
# Anton She3vchenko 2018
#
# duplicate [--algo] [--size] [directory]

#read command-line parameters
while (( "$#" )); do
	case "$1" in
		'-a') shift; algo="$1" ;;
		'--algo='*) algo="${1#*=}" ;;
		'-s') shift; sizelimit="$1" ;;
		'--size='*) sizelimit="${1#*=}" ;;
		'-h') echo "
		Usage is\n -a(--algo=) select algorigthm, sha1 and md5 supported\
		-s(--size=) sizelimit to exclude files smaller than this value\
		[dirname] is optional
		"
		exit
		;;
		*) dir="$1" ;;
	esac
	shift
done
#setting default values
algo="${algo:-sha1}"
sizelimit="${sizelimit:-1k}"
dir="${dir:=./}"
#if [ -z $directory ]; then
	#path="$relpath/"
#else
#	path=$(echo "$directory" | sed -e 's/\.\///' -e 's/\/$//')
	
#fi
[ ! -d "$dir" ] && exit 1
path=$(cd $dir; pwd)
cipher="${algo}sum"

if ! type "$cipher" > /dev/null 2>&1; then exit 1; fi


echo "Parameters $algo : $sizelimit : $path"

#create temp directury
tmpdir="./tmp-duplicate$(( ( RANDOM % 100 ) +1 ))"
echo "$tmpdir" > tmp.lock
if [ ! -d "$tmpdir" ]; then
	mkdir "$tmpdir" && echo "creating dir $tmpdir"
	
fi

similar_size_list() {
	
	for sizes in $(du -abh "$path/" | head -n -1 | awk '{print $1}' | sort -u); do
		echo "Executing $sizes"
		file_list="$tmpdir/sim_size_${sizes}"
		#du -abh "$path/" | head -n -1 | awk "/$sizes/ {print $2 }" | xargs -0 "$cipher" > "$tmpdir/sim_size_${sizes}"
		du -abh "$path/" | head -n -1 | grep "$sizes" | awk '{print $2}' | xargs "$cipher" > "$file_list"
		for hashes in $(cat "$file_list" | awk '{print $1}' | sort -u); do
			cat "$file_list" | grep "$hashes" | awk '{print $2}' > "${file_list}.identical"
			read -p "Show:  " answer
			if [ ! "$answer" = "n" ]; then
				echo "==========================================================================="
				cat "${file_list}.identical"
				echo "============================================================================="
			fi

		done
	done
}
cleanup_tmp() {
	if [ "$1" = $( cat './tmp.lock' ) ]; then 
		rm -rf "$1"
	fi
	rm tmp.lock
}


similar_size_list
read -p "remove?" clean
[ "$clean" = 'n' ] || cleanup_tmp "$tmpdir"
