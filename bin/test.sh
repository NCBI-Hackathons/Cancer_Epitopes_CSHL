#!/bin/bash

# This script takes an annotated VCF file and runs fred2 on it.
#
# Usage: 
#        cd $HOME; 
#         ./Cancer_Epitopes_CSHL/bin/test.sh Cancer_Epitopes_CSHL/test_data/input.vcf
# 


INPUT_VCF=$1

FASTA_OUTPUT=file_$RANDOM
FRED_PREDICTION=fred_${RANDOM}_variant_immunogenicity.csv 

# Definitions for the Docker image  
SRC_FOLDER=/home/linuxbrew/Cancer_Epitopes_CSHL/src


# Use python3 env managed by conda  

source /opt/conda/bin/activate python3 
python /home/linuxbrew/Cancer_Epitopes_CSHL/src/generate_fasta.py   --input=$INPUT_VCF  --output=$FASTA_OUTPUT --peptide_sequence_length=21

echo "file $FASTA_OUTPUT generated"  

/home/linuxbrew/Cancer_Epitopes_CSHL/src/imm_predict/fred2_allele_prediction.py --input=$FASTA_OUTPUT  --output=${FRED_PREDICTION}

echo "file $FRED_PREDICTION has been written" 
