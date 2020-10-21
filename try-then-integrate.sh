#!/bin/bash
#Samples
OutFile=Enc.txt
START=1
END=5
TXT="Hello;hello;Two;One;Three"
#array=($(echo $TXT | cut -d";"))

<< Try-MuliEncMultiWord
DEL_COUNT=`echo ${TXT} | awk -F';' '{ print NF }'`
CWD=.
for (( i=1; i<${DEL_COUNT}+1; i++ ))
do
	ENCRYPTED="XX&X"
    PLAINTXT=`awk -F';' -v ai="$i" '{ print $(ai) }' <<< ${TXT}`
	echo $PLAINTXT
	#TODO: Bug to deal with special charachters with seds, we might using awk instead
	sed -i "s#${PLAINTXT}#${ENCRYPTED}#g" "${CWD}"/*.txt
done

Try-MuliEncMultiWord

<< Gen-Random-Using-BASH
	CURR_DATE=$(date +%s%N | fold -w6 | shuf | tr -d '\n')

# First 26 letter are small, the next 25 are capitial and the rest are special
# Total Number = 65
arr=({a..z} {A..Z} '!' '@' '#' '$' '%' '^' '&' '*' '(' ')' '-' '=' '_' '+')
MOD=${CURR_DATE}
RAND_CHAR=()
REPLACE_CHAR=()
for i in {1..3}; do
    #Array of random charachters
    RAND_CHAR=(${CURR_DATE:RANDOM%${#CURR_DATE}:1} ${CURR_DATE:RANDOM%${#CURR_DATE}:1} ${CURR_DATE:RANDOM%${#CURR_DATE}:1})
    #Array of random replacments
    REPLACE_CHAR=(${arr[RANDOM % 25]} ${arr[RANDOM % 51]} ${arr[RANDOM % 65]})

    #Replace them
    for j in {0..2}
    do
        MOD=${MOD/${RAND_CHAR[j]}/${REPLACE_CHAR[j]}}
    done
done

    #sed style
    #result=echo ${MOD} | sed -i "s/${RAND_CHAR}/${REPLACE_CHAR}/g"

echo ${MOD}
Gen-Random-Using-BASH

# ERROR !!: RSA operation error
<< DECRYPT-TRIAL
function decrypt(){
    if [ -f $1 ]; then
        OUTPUT=""
        while IFS= read -r line
        do
            `echo ${line} | openssl rsautl -decrypt -inkey private.pem -out plaintext.txt`
        done < "$1"
        echo ${OUTPUT}
    else
        echo "File not found!" 1>&2   
    fi  
}

decrypt ${OutFile}
DECRYPT-TRIAL

#<< USING-Epoch-Time-Diff
# Getting the number of seconds since 1970-01-01 00:00:00 UTC
LAST_MOD=`stat -c%Y ${OutFile} | awk '{print strftime("%s", $0)}'` # We can use date to get file mod time directly!
CURR_DATE=`date +%s`

echo ${LAST_MOD}
echo ${CURR_DATE}

timediff=$(($((${CURR_DATE} - ${LAST_MOD}))/60))
echo $timediff
#USING-Epoch-Time-Diff
