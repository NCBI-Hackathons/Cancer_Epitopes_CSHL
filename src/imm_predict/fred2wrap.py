#!/usr/bin/env python2

from __future__ import print_function, division, absolute_import
# import numpy as np
# import argparse
# import sys
# from sys import exit, stdin
import warnings
from Fred2.Core import Allele, Peptide, Protein, generate_peptides_from_proteins
from Fred2.IO import read_lines, read_fasta
from Fred2.EpitopePrediction import EpitopePredictorFactory
import sys
import time

# import pepdata
import pandas as pd

# # 1.
# peptides = [Peptide("SYFPEITHI"), Peptide("FIASNGVKL"), Peptide("LLGATCMFV")]
# proteins = [Protein("SYFPEITHI"), Protein("FIASNGVKL"), Protein("LLGATCMFV")]
# alleles = ['A*02:16', 'B*45:01']
# peptide3 = generate_peptides_from_proteins(proteins, 9)

def predictor_info(method):
    """
    Get the information about different predictors
    """

    predictor = EpitopePredictorFactory(method)
    try:
        is_in_path = predictor.is_in_path()
    except:
        is_in_path = None
    try:
        command = predictor.command
    except:
        command = None

    method_hash = {"syfpeithi": "T-cell epitope",
                   "bimas": "MHC-I binding",
                   "svmhc": "MHC-I binding",
                   "arb": "MHC-I binding",
                   "smm": "MHC-I binding",
                   "smmpmbec": "MHC-I binding",
                   "epidemix": "MHC-I binding",
                   "comblib": "MHC-I binding",
                   "comblibsidney": "MHC-I binding",
                   "pickpocket": "MHC-I binding",
                   "netmhc": "MHC-I binding",
                   "netmhcpan": "MHC-I binding",
                   "hammer": "MHC-II binding",
                   "tepitopepan": "MHC-II binding",
                   "netmhcii": "MHC-II binding",
                   "netmhciipan": "MHC-II binding",
                   "unitope": "T-cell epitope",
                   "netctlpan": "T-cell epitope",
                   }

    retdict = {
        "is_in_path": is_in_path,
        "name": method,
        "supportedAlleles": predictor.supportedAlleles,
        "supportedLength": predictor.supportedLength,
        "command": command,
        "version": predictor.version,
        "type": method_hash.get(method)
    }
    return retdict


def valid_predictors():
    methods = EpitopePredictorFactory.available_methods().keys()
    dt = pd.DataFrame([predictor_info(method) for method in methods])

    dt = dt[[9 in elems for elems in dt["supportedLength"]]]
    dt = dt[dt["type"].notnull()]
    dt = dt[dt["is_in_path"].isnull()]
    dt = dt[dt["name"] != "epidemix"]
    dt = dt[dt["name"] != "unitope"] # too long runtime

    return dt


def predict_peptide_effects(peptides, alleles=None):
    """
    Predict the peptide effect for all the available methods on the machine
    args:
    -----
        peptides (list of Peptides): Usually an output from read_fasta
        alleles (list of chars): Alleles for which to run the predictors

    results:
    --------
        pd.DataFrame: Tidy pd.DataFrame. If the method is unable to predict
                      for a particular value the rows are not present.

    examples:
    >>> peptides = [Peptide("SYFPEITHI"), Peptide("FIASNGVKL"), Peptide("LLGATCMFV")]
    >>> alleles = ['A*02:16', 'B*45:01']
    >>> predict_peptide_effects(peptides, alleles = alleles).head()
                               Seq    Method   allele       score
    0  (F, I, A, S, N, G, V, K, L)       arb  A*02:16  594.691144
    1  (F, I, A, S, N, G, V, K, L)       smm  A*02:16  159.768074
    2  (F, I, A, S, N, G, V, K, L)  smmpmbec  A*02:16  211.977614
    4  (F, I, A, S, N, G, V, K, L)   unitope  A*02:16    0.527849
    5  (L, L, G, A, T, C, M, F, V)       arb  A*02:16    6.784222
    """
    dt = valid_predictors()
    results = []
    for i in range(len(dt)):
        # subset to valid alleles
        if alleles is not None:
            valid_alleles = dt.iloc[i]["supportedAlleles"].intersection(alleles)

            if len(valid_alleles) == 0:
                continue
            valid_alleles = [Allele(al) for al in valid_alleles]
        else:
            valid_alleles = None
        method = dt.iloc[i]["name"]
        print("running for method: ", method)
        # TODO - use try, except
        t0 = time.time()

        try:
            results.append(EpitopePredictorFactory(method).predict(peptides, alleles=valid_alleles))
        except:
            print("Error! Unable to run ", method, ": ", sys.exc_info()[0])
        t1 = time.time()
        print("  - runtime: ", str(t1 - t0))

    df = results[0].merge_results(results[1:]).reset_index()
    dfm = pd.melt(df, id_vars=["Seq", "Method"], var_name="allele", value_name="score")
    dfm = dfm[dfm["score"].notnull()]
    dfm.rename(columns={'Seq': 'peptide', 'Method': 'method'}, inplace=True)
    return dfm

