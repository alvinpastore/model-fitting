import subprocess
import sys
import os

""" CALLS grad_desc_model_fit with the random bins"""
""" python call_grad_desc_model_fit.py CAP na ns rc ral at randomBins_begin randomBins_end"""

CAP = sys.argv[1]
nActions = sys.argv[2]
nStates = sys.argv[3]
risk_type = sys.argv[4]
RESTRICTED_ACTION_LIMIT = sys.argv[5]
ALGORITHM_TYPE = sys.argv[6]

randomBins_begin = int(sys.argv[7])
randomBins_end = int(sys.argv[8]) + 1  # number of scrambled bins files available
path = os.path.dirname(os.path.realpath(__file__))

sp = [subprocess.Popen("python " + path + "/grad_desc_model_fit.py " + CAP + " ur" + str(_) +
                       " " + nActions + " " + nStates + " " + risk_type + " " + RESTRICTED_ACTION_LIMIT +
                       " " + ALGORITHM_TYPE, shell=True) for _ in xrange(randomBins_begin, randomBins_end)]

