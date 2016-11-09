#!/usr/bin/env python2
"""
Compute the predictions for reference and alternative allele

Usage:
       fred2_allele_prediction.py [--alleles=<alleles_list>] --input=FILE_IN --output=FILE_OUT
       fred2_allele_prediction.py -h | --help

Arguments:
  --input=FILE_IN       Input csv file
  --output=FILE_OUT     Output csv file

Options:
  --alleles=<alleles_list>   Comma separated list of target alleles [Default use all]:
                             --alleles="B*27:20,B*83:01,A*32:15"
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

def sliding_window(dt, peptide_length = 9):
    """
    Given a datatable:
    >>> dt.head()
                                              ID                     MT  \
    0  IGLV6-57_ENST00000390285_2.missense.63S/A  VQWYQQRPGSAPTTVIYEDNQ   
    1  FAM230A_ENST00000434783_2.missense.322E/Q  KEDAVQGIANQDAAQGIAKED   
    2  CACNA1I_ENST00000402142_1.missense.107C/Y  GMYQPCDDMDYLSDRCKILQV   
    3     NEFH_ENST00000310624_2.missense.830P/T  VKSPVKEEEKTQEVKVKEPPK   
    4     GGA1_ENST00000343632_3.missense.484P/A  SLLHTVSPEPARPPQQPVPTE   
    
                          WT  
    0  VQWYQQRPGSSPTTVIYEDNQ  
    1  KEDAVQGIANEDAAQGIAKED  
    2  GMYQPCDDMDCLSDRCKILQV  
    3  VKSPVKEEEKPQEVKVKEPPK  
    4  SLLHTVSPEPPRPPQQPVPTE  

    convert to:
    >>> sliding_window(dt).head()
           MT     WT  position                                         ID
    6   RPGSA  RPGSS         6  IGLV6-57_ENST00000390285_2.missense.63S/A
    7   PGSAP  PGSSP         7  IGLV6-57_ENST00000390285_2.missense.63S/A
    8   GSAPT  GSSPT         8  IGLV6-57_ENST00000390285_2.missense.63S/A
    9   SAPTT  SSPTT         9  IGLV6-57_ENST00000390285_2.missense.63S/A
    10  APTTV  SPTTV        10  IGLV6-57_ENST00000390285_2.missense.63S/A
    """
    dt2_list  = [window(dt.iloc[i]["MT"],
                        dt.iloc[i]["WT"] , window_size = peptide_length).\
                 assign(ID= dt.iloc[i]["ID"]).\
                        assign(variant_id= dt.iloc[i]["variant_id"]) \
                        for i in xrange(len(dt))]
                 
    dt2 = pd.concat(dt2_list)
    return dt2[dt2["MT"] != dt2["WT"]]

def window(MT_seq, WT_seq, window_size=5):
    """
    Chop two sequences with a sliding window
    """
    if len(MT_seq) != len(WT_seq):
        raise Exception("len(MT_seq) != len(WT_seq)")
    pos = []
    mt = []
    wt = []
    for i in xrange(len(MT_seq) - window_size + 1):
        pos.append(i)
        mt.append(MT_seq[i:i+window_size])
        wt.append(WT_seq[i:i+window_size])
    dt = pd.DataFrame({"position": pos,
                         "MT": mt,
                         "WT": wt})
    return dt


def append_score(dt2):
    """
    Given a choped sequence (output from sliding_window()),
    append the immunogenicity scores
    """
    peptides_to_compute = [Peptide(peptide) for peptide in set(list(dt2["MT"]) + list(dt2["WT"]))]
    res = fred2wrap.predict_peptide_effects(peptides_to_compute)
    res["peptide"] = [str(peptide) for peptide in res["peptide"]]

    full = pd.merge(dt2, res, how = 'left', left_on = "WT", right_on = "peptide")
    full = full.rename(columns={'score': 'WT_score'})
    del full["peptide"]
    full = pd.merge(full, res, how = 'left', left_on = ["MT", "method", "allele"],
                    right_on = ["peptide", "method", "allele"])
    full = full.rename(columns={'score': 'MT_score'})
    del full["peptide"]
    return full


if __name__ == "__main__":
    arguments = docopt(__doc__)

    if arguments["--alleles"]:
        alleles = arguments["--alleles"].split(",")
    else:
        alleles = None

    file_in = arguments["--input"]
    file_out = arguments["--output"]
    dt = pd.read_csv(file_in)
    print("chop the peptides around a variant")
    dt2 = sliding_window(dt, 9)

    print("append the immunogenicity score")
    full = append_score(dt2)

    print("writing to csv")
    full.to_csv(file_out, index = False)
    
