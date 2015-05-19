import subprocess
import sys
import os

""" CALLS modelFitForward N times with the random bins"""
""" python call_modelFitForward nIterations CAP nActions randomBinsAmount"""

nIterations = sys.argv[1]
CAP = sys.argv[2]
nActions = sys.argv[3]
randomBinsAmount = int(sys.argv[4])  # number of scrambled bins files available
path = os.path.dirname(os.path.realpath(__file__))

sp = [subprocess.Popen("python " + path + "/modelFitForward.py " + nIterations + " "
                       + CAP + " ur" + str(_) + " " + nActions, shell=True) for _ in xrange(randomBinsAmount)]

