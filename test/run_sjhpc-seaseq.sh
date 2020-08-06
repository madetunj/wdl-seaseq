#!/bin/bash

rm -rf sjwdlseaseq*

bsub -P watcher -q compbio -J sjwdlseaseq -o sjwdlseaseq-out -e sjwdlseaseq-err -N bash sjhpc-seaseq.sh

