#!/bin/bash

# produce design matrix


# 1. create data/immunogenic_SNVs-training_sets.csv
echo "run Rscript src/imm_explore/0-read.R"
# Rscript src/imm_explore/0-read.R

export TMPDIR=/tmp/
# 2. data/immunogenic_SNVs-training_sets.csv -> data/immunogenic_SNVs-model_data.csv
echo "src/imm_explore/fred2_design_matrix.py"
PYTHON=/opt/modules/i12g/anaconda/3-4.1.1/envs/python27/bin/python 
$PYTHON src/imm_explore/fred2_design_matrix.py \
	--input=data/immunogenic_SNVs-training_sets.csv \
	--output=data/immunogenic_SNVs-model_data.csv
