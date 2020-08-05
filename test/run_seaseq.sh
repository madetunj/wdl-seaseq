#!/bin/bash

rm -rf SEASEQ wf-seaseq_logs call-seaseq_logs

wdlscript="java -Dconfig.file=/home/madetunj/.commands/lsf.conf -jar /home/madetunj/.software/cromwell-52.jar run ../wdl/seaseq.wdl --inputs seaseqinputs.json --options seaseqoptions.json"
bsub -P watcher -q compbio -J wdlseaseq -o wdlseaseq-out -e wdlseaseq-err -N $wdlscript

#java -jar ~/Downloads/cromwell-51.jar run ../wdl/seaseq.wdl -i seaseqinputs.json -o seaseqoptions.json

