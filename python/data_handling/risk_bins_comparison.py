from __future__ import division
import os
import sys
import numpy as np
import operator
import random
import math

rootdir = '../../data/'

bin_idx = -1
beta_stocks = {i: [] for i in xrange(3)}
with open(rootdir + "beta_classified_stocks/3/uniform_3.txt") as beta_bins_file:
    for line in beta_bins_file.readlines():
        if "~" not in line:
            bin_idx += 1
        else:
            line = line.split("~")
            beta_stocks[bin_idx].append((line[0]))

bin_idx = -1
std_stocks = {i: [] for i in xrange(3)}
with open(rootdir + "std_classified_stocks/3/uniform_3.txt") as std_bins_file:
    for line in std_bins_file.readlines():
        if "~" not in line:
            bin_idx += 1
        else:
            line = line.split("~")
            std_stocks[bin_idx].append((line[0]))

bin_idx = -1
risk_stocks = {i: [] for i in xrange(3)}
with open(rootdir + "risk_classified_stocks/3/uniform_3.txt") as risk_bins_file:
    for line in risk_bins_file.readlines():
        if "~" not in line:
            bin_idx += 1
        else:
            line = line.split("~")
            risk_stocks[bin_idx].append((line[0]))

print "risk and beta low" #17
print len(list(set(risk_stocks[0]) & set(beta_stocks[0])))
print
print "risk and beta mid" #12
print len(list(set(risk_stocks[1]) & set(beta_stocks[1])))
print
print "risk and beta high" #18
print len(list(set(risk_stocks[2]) & set(beta_stocks[2])))
print
#47

print "risk and std low" #29
print len(list(set(risk_stocks[0]) & set(std_stocks[0])))
print
print "risk and std mid" #25
print len(list(set(risk_stocks[1]) & set(std_stocks[1])))
print
print "risk and std high" #31
print len(list(set(risk_stocks[2]) & set(std_stocks[2])))
#85