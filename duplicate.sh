#!/bin/bash
#this script search for multiple files with same content based on sha1 or md5 hash
#
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
		*) directory="$1" ;;
	esac
	shift
done
#setting default values
algo="${algo:-sha1}"
sizelimit="${sizelimit:-1k}"
directory="${directory:-./}"

echo "Parameters $algo : $sizelimit : $directory"

#create temp directury
tmpdir="/tmp/duplicate$(( ( RANDOM % 100 ) +1 ))"
[ ! -d tmpdir ] && mkdir "$tmpdir"
