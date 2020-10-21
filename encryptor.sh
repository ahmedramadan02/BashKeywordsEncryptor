#!/bin/bash
# This file is the main control logic for the encryptor
# File Version: V1.0
# File Version: V2.0
## Refactored Sensitive Words mode
## Added "-t" option for recursive

echo Running $0

. ./libEncryptor.sh || exit 1

#check if argument 3 is present
if [ "$1" == "-s" ] && [ ! -z "$3" ] && [ "$3" == "-d" ] && [ ! -z "$4" ]; then
    CWD="$4"
else
   CWD=`pwd`
   if [ "$3" == "-t" ] && [ ! -z "$3" ]; then
    RECURSIVE="YES"
   else
    RECURSIVE="NO"
   fi         
fi


RECURSIVE="NO"

#Globals

# MAIN
if [ -z "$1" ];then
        # No supplied arguments
        # Default Mode
        echo "Working in the default mode"
        PLAINTXT=$(readLine)
        CIPHERTXT=$(encrypt)
        outputToFile ${CIPHERTXT}
elif [ "$1" == '--help' ]; then
    echo $(help)
else
    if [ "$#" -lt 2 ] || [ "$1" != "-s" ]; then
        echo "Wrong Argument list" >&2 # To std error, TODO: Integarte in one function logger()
        exit 1
    else
        echo "Working in Replace Sensitive Words mode"
        # TODO: Refactor these steps later, DONE!
        # And we need to append the pub and private keys for future use
        SECRET_WORDS="$2"
        encryptSensitive ${SECRET_WORDS} ${RECURSIVE}
        echo 'DONE'
        #decrypt ${OutFile}
    fi
fi