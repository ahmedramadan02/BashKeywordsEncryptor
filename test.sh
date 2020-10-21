#!/bin/bash
#This file is used to test the encryptor
SUBTST=subdirtest

rm ./*.txt
rm ./${SUBTST}/*.txt

mkdir ${SUBTST}

echo -e "hello\n Two" > testfile01.txt
echo -e "One\n Three \nHello" > testfile02.txt

echo -e "hello\n Two" > ./${SUBTST}/testfile03.txt
echo -e "One\n Three" > ./${SUBTST}/testfile04.txt

./encryptor.sh --help

# Default Modem You need to give him plain text after the prompt
./encryptor.sh

# Working in Replace Sensitive Words mode"
./encryptor.sh -s "Hello;One;Two"

./encryptor.sh -s "Hello;One;Two" -d "./${SUBTST}"
