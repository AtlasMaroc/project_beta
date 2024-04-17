#!/bin/bash

#check if the conda environement and assembly package are activated

pack=$( conda info | awk -F' : ' 'NR==2 {print $2}')

if ! [[ $pack == assembly ]]
    then 
	    echo "Please activate the conda environement and assembly first"
     
fi

#check for the presence of arguments 

if [[ #? -eq 0 ]]
then 
	echo "Parameters as an absolute path is required"
	exit 1
fi 

#creating a read-length table: 

echo "platform, length" >length.csv

#iterate of files in path provided as an argument 

for file in $1
do
	bioawk -c fastx '{print $name, length($seq)}' $file >>length.csv 
done 

	
