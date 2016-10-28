#!/usr/bin/env python2
# build a predictive model in numpy
from __future__ import print_function, division, absolute_import
import pandas as pd
from sklearn.cross_validation import train_test_split
from sklearn import metrics
from sklearn.cross_validation import cross_val_score
import numpy as np
import pickle

output_model = "./data/log_reg_model.pickle"
print("read design matrix")
dt = pd.read_csv("data/binders_design_matrix.csv")

with open('data/use_methods.txt', 'r') as f:
    methods = f.read().splitlines()

print("prepare model")
dtX = dt[methods + ["binder"]].dropna()
X = dtX[methods]
y = dtX["binder"]
y = np.where(y=='yes', True, False)

from sklearn.linear_model import LogisticRegression

model = LogisticRegression()
model = model.fit(X, y)
print("model fitted")
print(model.score(X,y))

result = {"model":model,
          "features": methods}
print("save model to ", output_file)
pickle.dump(result, open(output_model, 'wb'))
print("saved")
# loaded_model = pickle.load(open(output_model, 'rb'))

# scores = cross_val_score(LogisticRegression(), X, y, scoring='accuracy', cv=10)
