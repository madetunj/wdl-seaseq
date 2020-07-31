#!/bin/bash

module load node
module load igvtools/2.3.2
module load fastqc/0.11.5
module load bowtie/1.2.2
module load macs/041014
module load ucsc/041619
module load bedtools/2.25.0
module load meme/4.11.2
module load meme/5.1.0
module load bedops/2.4.2
module load java/1.8.0_60
module load bam2gff/072320 
module load rose/072320 
module load python/3.7.0
module load samtools/1.9
module load R/3.6.1 


rm -rf SEASEQ wf-seaseq_logs call-seaseq_logs
export PATH=$PATH:$(pwd)/../bin

java -jar /home/madetunj/.software/cromwell-52.jar run ../wdl/seaseq.wdl -i seaseqinputs.json -o seaseqoptions.json

#withdocker
#java -jar ~/Downloads/cromwell-51.jar run wdl-docker/seaseq.wdl -i seaseqinputs.json -o seaseqoptions.json

