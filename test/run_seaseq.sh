#!/bin/bash

modupe_imac_cromwell="/Users/madetunj/Downloads/cromwell-51.jar"
logout="wdlseaseq-out"
logerr="wdlseaseq-err"

#removing old files
rm -rf SEASEQ wf-seaseq_logs call-seaseq_logs wdlseaseq*

#hpc syntax
wdlscript="java -Dconfig.file=/home/madetunj/.commands/lsf.conf -jar /home/madetunj/.software/cromwell-52.jar run ../wdl/seaseq.wdl --inputs seaseqinputs.json --options seaseqoptions.json"

#checking if imac cromwell file exists else its hpc
if [ -f "$modupe_imac_cromwell" ]; then
    java -jar ~/Downloads/cromwell-51.jar run ../wdl/seaseq.wdl -i seaseqinputs.json -o seaseqoptions.json 1>$logout 2>$logerr
else
    bsub -P watcher -q compbio -J wdlseaseq -o $logout -e $logerr -N $wdlscript
fi

