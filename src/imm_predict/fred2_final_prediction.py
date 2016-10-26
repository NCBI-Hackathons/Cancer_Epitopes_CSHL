#!/usr/bin/env python2
"""
Compute the predictions for reference and alternative allele

Usage:
       fred2_final_prediction.py --input=FILE_IN --output=FILE_OUT
       fred2_final_prediction.py -h | --help

Arguments:
  --input=FILE_IN       Input csv file
  --output=FILE_OUT     Output csv file
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
import pickle

if __name__ == "__main__":
    # get the methods
        
    arguments = docopt(__doc__)
    file_in = arguments["--input"]
    # file_in = "/home/data/peptides/allele_prediction.csv"
    file_out = arguments["--output"]
    dt = pd.read_csv(file_in)

    # TODO - get the absolute path
    this_file = os.path.dirname(os.path.realpath(__file__))
    output_model = this_file + "/../../" + "/data/log_reg_model.pickle"

    print("load the model")
    fit = pickle.load(open(output_model, 'rb'))
    print("loaded")
    model = fit["model"]
    methods = fit["features"]
    colnames = dt.columns.values.tolist()
    idx = [col for col in colnames if col not in ["method", "WT_score", "MT_score"]]
    # pivot the table:
    dt_wide = dt.pivot_table(index = idx, columns = "method",
                             values = ["WT_score", "MT_score"]).reset_index(None)

    print("generate the prediction score")
    # generate the prediction score
    wt = dt_wide["WT_score"][methods]
    mt = dt_wide["MT_score"][methods]
    wt_none = wt.notnull().all(axis = 1)
    mt_none = mt.notnull().all(axis = 1)
    not_none = wt_none & mt_none
    WT_predict = wt[not_none]
    MT_predict = mt[not_none]
    WT_score = model.predict_proba(WT_predict)[:, 1]
    MT_score = model.predict_proba(MT_predict)[:, 1]
    final_score_notnone = MT_score - WT_score

    final_score = np.empty(not_none.shape)
    final_score[:] = np.NAN
    final_score[np.where(not_none)] = final_score_notnone
    print("final score done")

    # append to the final table
    del dt_wide["WT_score"]
    del dt_wide["MT_score"]
    dt_wide.columns = dt_wide.columns.droplevel(level = 1)
    dt_wide["immscore"] = final_score
    
    # for each ID, take the max one
    dt_wide.reset_index(inplace=True)

    dt_final = dt_wide.sort('immscore', ascending=False).\
               groupby(by = ['ID', 'variant_id']).first().\
               reset_index().sort('immscore', ascending=False)
    del dt_final["index"]
    del dt_final["position"]

    print("writing to csv")
    dt_final.to_csv(file_out, index = False)
    
