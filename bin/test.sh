#!/bin/bash

# Usage: ./test.sh  Cancer_Epitopes_CSHL/test_input/input.vcf

INPUT_VCF=$1

source /opt/conda/bin/activate python3 

python /home/linuxbrew/Cancer_Epitopes_CSHL/src/generate_fasta.py   --input=$INPUT_VCF  --output=outXXX   --peptide_sequence_length=21

