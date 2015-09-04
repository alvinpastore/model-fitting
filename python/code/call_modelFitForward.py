import subprocess
import sys
import os

""" CALLS modelFitForward N times with the random bins"""
""" python call_modelFitForward nIterations CAP nActions nStates randomBinsAmount"""

nIterations = sys.argv[1]
CAP = sys.argv[2]
nActions = sys.argv[3]
nStates = sys.argv[4]
randomBinsAmount = int(sys.argv[5])  # number of scrambled bins files available
path = os.path.dirname(os.path.realpath(__file__))

sp = [subprocess.Popen("python " + path + "/modelFitForward.py " + nIterations + " " + CAP + " ur" + str(_) +
                       " " + nActions + " " + nStates, shell=True) for _ in xrange(randomBinsAmount)]

