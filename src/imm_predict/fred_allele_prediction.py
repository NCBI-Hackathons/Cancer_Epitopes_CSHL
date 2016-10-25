#!/usr/bin/env python2
# read in the vcf file
import sys
# sys.path.append("/home/avsec/Cancer_Epitopes_CSHL/src")
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


def sliding_window(dt, window_size = 9):
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
                        dt.iloc[i]["WT"] , window_size = window_size).assign(ID= dt.iloc[i]["ID"]) for i in xrange(len(dt))]
    dt2 = pd.concat(dt2_list)
    return dt2[dt2["MT"] != dt2["WT"]]

def window(MT_seq, WT_seq, window_size=5):
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
    peptides_to_compute = [Peptide(peptide) for peptide in set(list(dt2["MT"]) + list(dt2["WT"]))]
    res = fred2wrap.predict_peptide_effects(peptides_to_compute)
    res["peptide"] = [peptide.tostring() for peptide in res["peptide"]]

    print("write to csv")
    full = pd.merge(dt2, res, how = 'left', left_on = "WT", right_on = "peptide")
    full = full.rename(columns={'score': 'WT_score'})
    del full["peptide"]
    full = pd.merge(full, res, how = 'left', left_on = ["MT", "method", "allele"],
                    right_on = ["peptide", "method", "allele"])
    full = full.rename(columns={'score': 'MT_score'})
    del full["peptide"]
    return full

if __name__ == "__main__":
    save_directory = "/home/data/peptides/"
    filename = "test.tsv"
    fullfilename = save_directory + filename
    dt = pd.read_csv(fullfilename)
    dt2 = sliding_window(dt, 9)
    full = append_score(dt2)

    full.to_csv("/tmp/fred2_result_ase.csv", index = False)
