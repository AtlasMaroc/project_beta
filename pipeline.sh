#!/bin/bash

#check for the presence of arguments

if [[ $# -eq 0 ]]
then
        echo "Enter the required argument"
        exit 1
fi

if [[ -z "$1" ]] ; then echo "you must provide long reads filename"; exit 1; fi
if [[ -z "$2" ]] ; then echo "you must provide short reads file name for genome size estimation"; exit 1; fi
if [[ -z "$3" ]] ; then echo "you must provide BUSCO lineage"; exit 1; fi

if [[ ! -f "$1" ]] ; then echo $1 "does not exist"; exit 1; fi 
if [[ ! -f "$2" ]] ; then echo $2 "does not exist"; exit 1; fi
if [[ ! "$3" == ?(_odb) ]] ; then echo "$3" "is not a valiable BUSCO lineage reference"; exit 1; fi 

filesdir=$1
shortread=$2 #for genome size estimation 
busco_lin=$3 #BUSCO lineage 

#check if the conda environement and assembly package are activated

pack=$( conda info | awk -F' : ' 'NR==2 {print $2, exit}')

if ! [[ $pack == assembly ]]
    then 
	    echo "Please activate the conda environement and assembly first"
            exit 1
fi
 
#creating a read-length table and N50_stats for every file, to be used as input for r-script: 

echo "platform, length" >reads.length.csv

#iterate over files in a directory provided as an argument: 


for file in $filesdir
do
	bioawk -c fastx '{print "ONT", length($seq)}' $file >>reads.length.csv #
        assembly-stats $file >>N50_stat_reads #assembly stats for different files
done 

#visualizing read length distrubition data using r script:

./N50_reads.R

#Approximation of  Genome size estimation using short reads:

kat hist -o prefix -t 10 $2 1>kat.out.put

echo "species_size" >>genome_size

grep -i "Estimated" kat.output.txt >>genome_size

#ONT long read sequence-based genome assembly and N50 stats:

outputdirectory=assembly_files #create a directory name where the assembled contigs file will be deposited:


for file in $files_dir 
	do
	shasta --config Nanopore-Oct2021 --threads 8 --input $1 --assemblyDirectory $outputdirectory_${file##*/}

        assembly-stats $(pwd)/$outputdirectory_${file##*/}/Assembly.fasta >>N50_stat_contigs
done 
#Quality assessment:

#coverage plot: 

species=ONT_species
path=$(pwd)/$outputdirectory_*/assembly.fasta #genome file path
len=$(bioawk -c fastx '{sum+=length($seq)}END{print sum}' $path) #length of the genome assembled
TYPE=contig #specifying genome assembly type 

echo "line, length, coverage" >contigs.length.csv

for file in $path
 do 
	cat $path
	bioawk -c fastx -v  line="$species" '{print line","length($seq)","length($seq)}'
	sort -k3rV -t ","
	awk -F"," -v len="$len" -v type="$TYPE" 'OFS="," {print $1,$2,type,(sum+0)/len; sum+=$3}'
done >>contigs.length.csv

#visualizing cumulative coverage
        
./N50_contigs.R

#performing Benchmarking Universal Single Copy Orthologs BUSCO:

for assembly in $path
do
	name_1=${assembly#*assembly_files} 
	name_2=${name_1%/*}
        busco -i $assembly -c 10 -o "{$name_2}_busco"  -m genome -l "$3"
done 

#parsing the BUSCO output results:

echo "Strain,Complete_single_copy,Complete_duplicated,Fragmented,Missing" >busco.csv

busco_path=$(pwd)/*_busco/short_*_busco.txt

for file in $busco_path
do
	
        name1=${file%%_busco*}
        name2=${name1##*/}
        #extract BUSCO counts for the current file:
         awk -v strain="$name2" 'NR==1 { print strain","$1 }' $file >complete_single.txt; #extract the number of complet single copy genes
         awk 'NR==2 { print $1 }' $file >complete_duplicated.txt; #extract the number of complete and duplicated genes
         awk 'NR==3 { print $1 }' $file >fragmented.txt; #extract the number of fragmented genes
         awk 'NR==4 { print $1 }' $file >missing.txt; #extractt the number of missing genes

        #Append to busco.csv
        paste -d "," complete_single.txt complete_duplicated.txt fragmented.txt missing.txt >> busco.csv;

        #Clean up temporary files:
        rm complete_single.txt complete_duplicated.txt fragmented.txt missing.txt;
done






