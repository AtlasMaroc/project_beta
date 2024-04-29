This pipeline is built for the assembly of long reads using a specified set of three arguments and dependecies. it 
utilize long read data for genome assembly and short read data for genome size estimation, incorporating quality 
assesement using R script.

Pipeline overview:

workflow of the pipeline is as follow:

1. Raw Reads statistics 

2. Genome size estimation using short reads

3. De novo genome assembly 

4. Quality assesement of genome assembly using N50 statistics and BUSCO 

Pipeline usage:

To run the pipeline, execute the main script with following argument:

1$ = path to Long Read folder `data/raw/*.fastq`

2$ = path to Short Read folder 

3$ = specify BUSCO lineage `lactobacillales_odb10`

Pipeline dependencies:

`N50_reads.R` for generating length read distribution 
 
`N50_contigs.R` for performing quality assesement of N50 
