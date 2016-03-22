import subprocess
import sys
import os

""" CALLS randomPlayer N times with the random bins"""
""" python call_modelFitForward CAP bin_type nActions (eg 2,3,4,5,7,10) random_repetitions"""

nIterations = sys.argv[4]
CAP = sys.argv[1]
bin_type = sys.argv[2]
nActions = sys.argv[3].split(',')

path = os.path.dirname(os.path.realpath(__file__))
sp = [subprocess.Popen("python " + path + "/random_model_fit.py " + CAP + " " + bin_type + " " + nAct + " "
                       + nIterations, shell=True) for nAct in nActions]
