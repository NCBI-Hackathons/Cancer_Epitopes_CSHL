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
sys.path.append(os.path.dirname(os.path.realpath(__file__)) + "/../")


save_directory = "/tmp/"
filename = "Homo_sapiens.GRCh38.pep.all.fa"
final_file = save_directory + filename

if not os.path.isfile(final_file):
    urlretrieve("ftp://ftp.ensembl.org/pub/release-86/fasta/homo_sapiens/pep/" + filename + ".gz",
                final_file + ".gz")
    call(["gunzip", final_file + ".gz"])
# download the fasta file

proteins = read_fasta("/tmp/Homo_sapiens.GRCh38.pep.all.fa", id_position=0, in_type=Protein)

peptides = generate_peptides_from_proteins(proteins[0:2], 9)
peptides_list = [peptide for peptide in peptides]
[peptide for peptide in peptides]
predictor = EpitopePredictorFactory("smmpmbec")
method = "syfpeithi"
predictor = EpitopePredictorFactory("syfpeithi")
predictor = EpitopePredictorFactory("hammer")
results = predictor.predict(peptides)

res = fred2wrap.predict_peptide_effects(peptide3)


