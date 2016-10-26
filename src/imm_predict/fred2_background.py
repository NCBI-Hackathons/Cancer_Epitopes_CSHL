#!/usr/bin/env python2
"""
Given a protein FASTA file, compute immunogenicity for all posible 9-mer peptides.

Usage:
       fred2_background.py [--alleles=<alleles_list> --top_N=N] --input=FILE_IN --output=FILE_OUT
       fred2_background.py -h | --help

Arguments:
  --input=FILE_IN      Input fasta file, can be retrieved from:
               ftp://ftp.ensembl.org/pub/release-86/fasta/homo_sapiens/pep/Homo_sapiens.GRCh38.pep.all.fa.gz

  --output=FILE_OUT    Output csv file

Options:
  --top_N=N                  Number of top N proteins to compute the background for. [Default all].
  --alleles=<alleles_list>   Comma separated list of target alleles [Default use all]:
                             --allleles="B*27:20,B*83:01,A*32:15"
"""
# read in the vcf file
import sys, os
# sys.path.append("/home/avsec/Cancer_Epitopes_CSHL/src")
sys.path.append(os.path.dirname(os.path.realpath(__file__)) + "/../")
from Fred2.Core import Allele, Peptide, Protein, generate_peptides_from_proteins
from Fred2.IO import read_lines, read_fasta
from Fred2.EpitopePrediction import EpitopePredictorFactory
from imm_predict import fred2wrap
from subprocess import call
from urllib import urlretrieve
import pandas as pd
from docopt import docopt
# download and extract from ensemble
# save_directory = "/home/data/peptides/"
# filename = "Homo_sapiens.GRCh38.pep.all.fixheader.fa"
# final_file = save_directory + filename
# if not os.path.isfile(final_file):
#     print("downloading the protein sequences")
#     urlretrieve("ftp://ftp.ensembl.org/pub/release-86/fasta/homo_sapiens/pep/" + filename + ".gz",
#                 final_file + ".gz")
#     call(["gunzip", final_file + ".gz"])
# download the fasta file

if __name__ == "__main__":
    arguments = docopt(__doc__)
    PEPTIDE_LENGTH = 9
    
    # get arguments
    if arguments["--alleles"]:
        alleles = arguments["--alleles"].split(",")
    else:
        alleles = None
    file_in = arguments["--input"]
    file_out = arguments["--output"]
    
    print("read fasta")
    proteins = read_fasta(file_in, id_position=0, in_type=Protein)
    
    # restrict to only top N proteins if provided
    if arguments["--top_N"]:
        Nargs = int(arguments["--top_N"])
        N = min(Nargs, len(proteins))
        proteins = proteins[0:N]

    # parse peptide/protein information from Peptide list and Protein list
    print("setup peptide/protein information table")
    peptides = generate_peptides_from_proteins(proteins, PEPTIDE_LENGTH)
    peptides_list = [peptide for peptide in peptides]
    proteins_list = [peptide.proteins.keys()[0] for peptide in peptides_list]
    peptides_str_list = [peptide.tostring() for peptide in peptides_list]
    peptides_position_list = [peptide.proteinPos.items()[0][1][0] for peptide in peptides_list]
    dt_peptides = pd.DataFrame({"peptide": peptides_str_list,
                                "peptide_position": peptides_position_list,
                                "transcript_id": proteins_list}
    )

    # predict the effect for each unique peptide
    print("predict the effects")
    res = fred2wrap.predict_peptide_effects(peptides_list, alleles = alleles)
    res["peptide"] = [peptide.tostring() for peptide in res["peptide"]]

    # map peptides back to proteins
    full = pd.merge(dt_peptides, res, how = 'left', on = "peptide")

    print("write to csv")
    full.to_csv(file_out, index = False)
