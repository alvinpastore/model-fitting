import subprocess
import sys
import os

""" CALLS modelFitForward N times with the random bins"""
""" python call_modelFitForward nIterations CAP nActions nStates randomBins_begin randomBins_end"""

nIterations = sys.argv[1]
CAP = sys.argv[2]
nActions = sys.argv[3]
nStates = sys.argv[4]
randomBins_begin = int(sys.argv[5])
randomBins_end = int(sys.argv[6]) + 1  # number of scrambled bins files available
path = os.path.dirname(os.path.realpath(__file__))

sp = [subprocess.Popen("python " + path + "/model_fit.py " + nIterations + " " + CAP + " ur" + str(_) +
                       " " + nActions + " " + nStates, shell=True) for _ in xrange(randomBins_begin, randomBins_end)]

