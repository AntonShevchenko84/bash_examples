#!/bin/bash
#mdate - Normalizes month field in date specification
#    to three letters, first letter capitalized. A helper
#    function for hack #7, validdate.  Exits w/ zero if no error.
#Addendum
OUTPUT=""
monthToName()
{

  # sets the variable 'month' to the appropriate value
  case $1 in
    1 ) month="Jan"    ;;  2 ) month="Feb"    ;;
    3 ) month="Mar"    ;;  4 ) month="Apr"    ;;
    5 ) month="May"    ;;  6 ) month="Jun"    ;;
    7 ) month="Jul"    ;;  8 ) month="Aug"    ;;
    9 ) month="Sep"    ;;  10) month="Oct"    ;;
    11) month="Nov"    ;;  12) month="Dec"    ;;
    * ) echo "ERR: Unknown numeric month value $1" >&2; exit 1
   esac
   OUTPUT="Fulldate is $month"
   return 0
}
weektoName() {
  if (( "$1" >=0 && "$1" <=5 )); then
  OUTPUT+=" week $1"
  return 0
  else
    echo "Week is out of range" >&2; exit 1
  fi
}
daytoName()
{
  
  OUTPUT+=" day $1"
  return 0
}

## Begin main script

[ -z $1 ] && echo "Provide arguments" >&2; exit 1
strip_garbage() {
for var in "$@"
do
 # echo "$var"
#
#  let "n = n+1"
  #set -- $(echo $1 | sed 's/[\-\\\/]//g')
   var=$(echo $var | sed 's/[-\\\/]//g')
   [ -z "$var" ]  || args=(${args[@]} "$var") 
done
}
strip_garbage $@


if [ "${#args[@]}" = 0 ];then  echo "Parameters should be nubmers" >&2 ;exit 1;fi 

#printf "\nArray dump %s\n"   ${args[@]}

case "${#args[@]}" in
  1) monthToName "${args[0]}" ;;
  2) monthToName "${args[0]}"; weektoName "${args[1]}" ;;
  3) monthToName "${args[0]}"; weektoName "${args[1]}"; daytoName "${args[2]}" ;;
  * ) echo "Too many parameters passed" >&2; exit 1
esac
echo $OUTPUT
