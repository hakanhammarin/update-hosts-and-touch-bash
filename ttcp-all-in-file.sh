#!/bin/bash
INPUT=data.csv
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read IP NAME 
do
	echo "IP : $IP"
	echo "NAME : $NAME"
	ping -c 1 -t 1 "$IP" 
	echo "Exit code = $?"
	touch "$NAME"
	if grep -e $NAME hosts.txt > /dev/null; then
   echo "Found"
   sed -i .bak '/'"$NAME"'/ s/.*/'"$IP $NAME #Updated $(date)"'/g' hosts.txt 
else
		echo "$IP $NAME # New $(date)" >> hosts.txt
fi
	
	# echo "sed Exit code = $?"
	# if not [ $? == 0 ]
	# 	then 
	
	# fi


	#! /bin/bash

# IP=$(dig +short myIP.opendns.com @resolver1.opendns.com)

# HOST="peep.strudel.com"
done < $INPUT
IFS=$OLDIFS