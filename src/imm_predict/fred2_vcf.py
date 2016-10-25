#!/usr/bin/env python2
# read in the vcf file
import sys
sys.path.append("/home/avsec/Cancer_Epitopes_CSHL/src")
from Fred2.Core import Allele, Peptide, Protein, generate_peptides_from_proteins
from Fred2.IO import read_lines, read_fasta
from Fred2.EpitopePrediction import EpitopePredictorFactory
from imm_predict import fred2wrap
from subprocess import call
import sys
import os
from urllib import urlretrieve
import pandas as pd
sys.path.append(os.path.dirname(os.path.realpath(__file__)) + "/../")


save_directory = "/home/data/peptides/"
filename = "Homo_sapiens.GRCh38.pep.all.fixheader.fa"
final_file = save_directory + filename
if not os.path.isfile(final_file):
    print("downloading the protein sequences")
    urlretrieve("ftp://ftp.ensembl.org/pub/release-86/fasta/homo_sapiens/pep/" + filename + ".gz",
                final_file + ".gz")
    call(["gunzip", final_file + ".gz"])
# download the fasta file

print("read fasta")
proteins = read_fasta(final_file, id_position=0, in_type=Protein)
print("setup peptides")
peptides = generate_peptides_from_proteins(proteins[0:10], 9)
peptides_list = [peptide for peptide in peptides]

# dict(s.split(':') for s in a)
# proteins_list = [[s.split(":")[1] for s in peptide.split(" ") if "transcript:" in s][0] for peptide in peptides_list]
proteins_list = [peptide.proteins.keys()[0] for peptide in peptides_list]
peptides_str_list = [peptide.tostring() for peptide in peptides_list]
peptides_position_list = [peptide.proteinPos.items()[0][1][0] for peptide in peptides_list]

dt_peptides = pd.DataFrame({"peptide": peptides_str_list,
                            "peptide_position": peptides_position_list,
                            "transcript_id": proteins_list}
)

print("predict the effects")
res = fred2wrap.predict_peptide_effects(peptides_list)
res["peptide"] = [peptide.tostring() for peptide in res["peptide"]]

print("write to csv")
full = pd.merge(dt_peptides, res, how = 'left', on = "peptide")

full.to_csv("/tmp/fred2_result.csv", index = False)
