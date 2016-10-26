#!/usr/bin/env python2
"""
Generate the design matrix

Usage:
       fred2_design_matrix.py --input=FILE_IN --output=FILE_OUT
       fred2_design_matrix.py -h | --help

Arguments:
  --input=FILE_IN       Input csv file
  --output=FILE_OUT     Output csv file
"""
# Options:
#   --alleles=<alleles_list>   Comma separated list of target alleles [Default use all]:
#                              --allleles="B*27:20,B*83:01,A*32:15"
# """

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

    file_in = arguments["--input"]
    if not file_in:
        file_in = os.path.expanduser("~/Cancer_Epitopes_CSHL/data/binders.csv")
    file_out = arguments["--output"]

    dt = pd.read_csv(file_in)
    dt = dt[dt["Sequence"].notnull()]
    dt = dt[dt["Sequence"].str.len() == 9]

    peptides = [Peptide(peptide) for peptide in dt["Sequence"]]
    
    dt["allele"] = dt["allele"].str.replace("\*","").\
                   str.replace("(-[a-zA-Z]+)([0-9]{2})([0-9]{2})","\\1*\\2:\\3").\
                   str.replace("w","").\
                   str.replace("HLA-","")
    dt.rename(columns = {"Sequence": "peptide"}, inplace = True)

    alleles = [Allele(allele) for allele in dt["allele"].unique().tolist()]
    res = fred2wrap.predict_peptide_effects(peptides, alleles = dt["allele"].unique().tolist())
    res["peptide"] = [peptide.tostring() for peptide in res["peptide"]]
    res["allele"] = [str(allele) for allele in res["allele"]]

    res = res.pivot_table(index=["peptide", "allele"],
                          columns='method',
                          values='score').reset_index(None)
    
    dt_merge = pd.merge(dt, res, on =["peptide", "allele"], how = "left")

    dt_merge.to_csv(file_out, index = False)
