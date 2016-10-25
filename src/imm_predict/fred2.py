#!/usr/bin/env python2

from __future__ import print_function, division, absolute_import
import numpy as np
import argparse
import sys
from sys import exit, stdin

from Fred2.Core import Allele, Peptide, Protein, generate_peptides_from_proteins
from Fred2.IO import read_lines, read_fasta
from Fred2.EpitopePrediction import EpitopePredictorFactory
#from nose.tools import eq_

# import pepdata
import pandas as pd

# 1.
peptides = [Peptide("SYFPEITHI"), Peptide("FIASNGVKL"), Peptide("LLGATCMFV")]

proteins = [Protein("SYFPEITHI"), Protein("FIASNGVKL"), Protein("LLGATCMFV")]
peptide3 = generate_peptides_from_proteins(proteins, 9)


peptide3 = generate_peptides_from_proteins(proteins, 8)

methods = EpitopePredictorFactory.available_methods().keys()
dir(EpitopePredictorFactory(methods[0]))

method = methods[0]

def get_predictor_info(method):
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

pd.DataFrame([get_predictor_info(method) for method in methods])

