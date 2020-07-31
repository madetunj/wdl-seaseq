#!/bin/bash

rm -rf SEASEQ wf-seaseq_logs call-seaseq_logs

export PATH=$PATH:$(pwd)/../bin

#on iMAC + docker
#java -jar ~/Downloads/cromwell-51.jar run ../wdl/seaseq.wdl -i seaseqinputs.json -o seaseqoptions.json

