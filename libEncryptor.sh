#!/bin/bash
# This file is a library file to hold all the common commands
# File Version: V1.0
## Initial version
# File Version: V2.0
## Enhanched generateSeed() function: option of two ways of randomization
## Enhanced outputToFile() function to use time difference based on Unix Epoch, and to create Enc.txt if first run

export PATH=.:/usr/sbin:/usr/bin:/sbin:/bin:/

RAND_HANDLE=randfile
OutFile=Enc.txt
INT_MINS=10
KEY_SIZE=1024

function parseUsrArgs(){
    case $1 in
    '-s')

      ;;
    '-d')
      ;;
    *)
      echo "Invalid args"
      ;;
  esac
}

function generateSeed(){
    CURR_DATE=$(date +%s%N | fold -w6 | shuf | tr -d '\n') 

    # First 26 letter are small, the next 25 are capitial and the rest are special
    # Total Number = 65
    arr=({a..z} {A..Z} '!' '@' '#' '$' '%' '^' '&' '*' '(' ')' '-' '=' '_' '+')

#<< 'MULTILINE-COMMENT'
    MODIFIED=${CURR_DATE}
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
            MODIFIED=${MODIFIED/${RAND_CHAR[j]}/${REPLACE_CHAR[j]}}
        done
    done

    #sed style
    #result=echo ${MOD} | sed -i "s/${RAND_CHAR}/${REPLACE_CHAR}/g"
#MULTILINE-COMMENT

#TODO: Search limitation for srand()
<< USING-AWK
    read MODIFIED <<< $(echo $CURR_DATE | awk -v var="${arr[*]}" 'BEGIN{split(var,arr1," "); TXT=$0} \
        {srand(); \
            for(i=0;i<3;i++) {RAND_CHAR[i]=arr1[srand()%length(arr1)]; \
                REPLACE_CHAR[i]=substr($0,srand()%length($0),1);  \
                for(j=0;j<3;j++){ \
                    sub(REPLACE_CHAR[j],RAND_CHAR[j],$0); \
                } \
            } \
        print $0; }')
USING-AWK

    echo ${MODIFIED} > randfile
}

#TODO: Encrypt the random key with the public key
function encrypt(){
    # generate new random seed
    generateSeed
    
    # Swallow annoying outputs to the black hole "/dev/null"
    # genrsa to generate private keys
    openssl genrsa -rand randfile -out private.pem 1024 &>/dev/null
    # Generate the pair public key
    openssl rsa -in private.pem -pubout -out public.pem &>/dev/null

    # Use rsautl to encrypt/decrypt
    ENCRYPTED=$(echo "${PLAINTXT}" | openssl rsautl -encrypt -pubin -inkey public.pem)
    echo ${ENCRYPTED}
}

function outputToFile(){
# Check if file exists
if [ ! -f Enc.txt ]; then
    touch Enc.txt
fi

# Here We can use two ways of comparison, either to compare using direct minutes (a bug here)
# Or to use time (as seconds) since EPOCH in Unix format
# I strongly prefer using "time since Epoch" 
<< COMPATING-MINUTS
    LAST_MOD=`stat -c%y ${OutFile} | cut -d':' -f2`
    CURR_DATE=`date +%M`

    timediff=$(expr ${CURR_DATE} - ${LAST_MOD})
COMPATING-MINUTS

#<< COMPARING-SINCE-EPOCH
# Getting the number of seconds since 1970-01-01 00:00:00 UTC
    LAST_MOD=`stat -c%Y ${OutFile} | awk '{print strftime("%s", $0)}'` # We can use date to get file mod time directly!
    CURR_DATE=`date +%s`

    timediff=$(($((${CURR_DATE} - ${LAST_MOD}))/60))
#COMPARING-SINCE-EPOCH

    # Don't use () in if, compatiability issue
    if [[ ${timediff} -gt ${INT_MINS} ]]; then
        echo $1 > ${OutFile}
    else
        echo $1 >> ${OutFile}
    fi
}

# Decypt using the private key
# The reverse is hard, and we need search for encrypted text, use Enc.txt
# The problem now that we have one private key, we need to store all the private keys
function decrypt(){
    if [ -f $1 ]; then
        OUTPUT=""
        while IFS= read -r line
        do
            `echo "${line}" | openssl rsautl -decrypt -inkey private.pem -out plaintext.txt`
        done < "$1"
        echo ${OUTPUT}
    else
        echo "File not found!" 1>&2   
    fi  
}

function cleanup(){
    rm -f RAND_HANDLE
}

function readLine() {
    read -p 'Please type the plain text to encrypt: ' -e TEXT
    echo ${TEXT}
}

function readMultiline(){
    while read line
    do
        # break if the line is empty
        [ -z "$line" ] && break
        TEXT+="${line} "
    done
    echo ${TEXT}
}

function readTxtFromFile(){
    if [ -f $1 ]; then
        OUTPUT=""
        while IFS= read -r line
        do
            OUTPUT+=${line}
        done < "$1"
        echo ${OUTPUT}
    else
        echo "File not found!" 1>&2   
    fi  
}

function encryptSensitive(){
        DEL_COUNT=`echo $1 | awk -F';' '{ print NF }'`
        echo ${DEL_COUNT}

        #Starting from 1 becuase of AWK print
        LOOP_INDEX=${DEL_COUNT}+1
        for (( i=1; i<${LOOP_INDEX}; i++ ))
        do
            #TODO: try to use cut command instead
            PLAINTXT=`awk -F';' -v ai="$i" '{ print $(ai) }' <<< $1`
            #Use the envirnomental var PLAINTXT
            #TODO: Don't use PLAINTXT, otherwise send paramters to encrypt to encapsulate it
            CIPHERTXT=$(encrypt) 
            #TODO: Bug to deal with special charachters with seds, we might using awk instead
            if [ ! -z "$2" ] || [ "$2" == "NO" ]; then
                sed -i "s#${PLAINTXT}#${CIPHERTXT}#g" "${CWD}"/*.txt
            else
                find . -type f -exec sed -i "s#${PLAINTXT}#${CIPHERTXT}#g" *.txt {} \;
            fi

            echo ${PLAINTXT}
            echo ${CIPHERTXT}
        done
}

# Neither printf nor echo makes new lines, it's envirnoment dependent
function help() {
    echo -e '--------------- Welcome to GDPD_Encryptor.sh ---------------\n'
    echo -e 'You can use this script in two ways\n'
    echo -e '1. In default Mode\n'
    echo -e 'Just type ./encryptor.sh <text-to-encrypt>\n'
    echo -e 'OR 2. In Replace sensitive words mode\n'
    echo -e 'type ./encryptor.sh -s <text-sparated-by-comma[;]> [-d] [<replace-dir>]\n'
}