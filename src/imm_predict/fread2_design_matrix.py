#!/usr/bin/env python2
"""
Generate the design matrix

Usage:
       fred2_design_matrix.py [--alleles=<alleles_list>] --input=FILE_IN --output=FILE_OUT
       fred2_design_matrix.py -h | --help

Arguments:
  --input=FILE_IN       Input csv file
  --output=FILE_OUT     Output csv file

Options:
  --alleles=<alleles_list>   Comma separated list of target alleles [Default use all]:
                             --allleles="B*27:20,B*83:01,A*32:15"
"""

# read in the vcf file
import sys, os
sys.path.append("/home/avsec/Cancer_Epitopes_CSHL/src")
sys.path.append(os.path.dirname(os.path.realpath(__file__)) + "/../")
from Fred2.Core import Allele, Peptide, Protein, generate_peptides_from_proteins
from Fred2.IO import read_lines, read_fasta
from Fred2.EpitopePrediction import EpitopePredictorFactory
from imm_predict import fred2wrap
from subprocess import call
from urllib import urlretrieve
import pandas as pd
from docopt import docopt


if __name__ == "__main__":
    arguments = docopt(__doc__)

    if arguments["--alleles"]:
        alleles = arguments["--alleles"].split(",")
    else:
        alleles = None

    file_in = arguments["--input"]
    file_out = arguments["--output"]

    file_in = "/home/avsec/Cancer_Epitopes_CSHL/data/binders.txt"


    dt = pd.read_table(file_in)
    peptides = [Peptide(peptide) for peptide in dt["Sequence"]]
    res = fred2wrap.predict_peptide_effects(peptides, alleles = alleles)
    res["peptide"] = [peptide.tostring() for peptide in res["peptide"]]
    
    # peptides_str_list = [peptide.tostring() for peptide in peptides_list]

    print("writing to csv")
    full.to_csv(file_out, index = False)
    
