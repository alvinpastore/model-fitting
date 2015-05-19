from __future__ import division
import sys
from operator import add


"""  averages out the results of the model on the scrambled bins  """


def integerise(values):
    out_values = [0] * 7
    for j in xrange(len(values)):
        if len(values[j].strip()) > 0:
            out_values[j] = float(values[j])
        else:
            out_values[j] = 0
    return out_values


path = 'results/'

filename = 'results_RANDOM5act_1000rep_0.1-1_alpha10-40_beta0.01-0.999_gamma_ur'
out_lines = [[0] * 7] * 4646

for i in xrange(10):
    print "\nfile", i
    iFilename = filename + str(i) + ".csv"

    lines = [line.rstrip('\n') for line in open(path + iFilename, 'r')]
    for line_idx in xrange(len(lines)):
        print "\nline", line_idx

        # print out_lines[line_idx]
        # print lines[line_idx]
        out_lines[line_idx] = map(add, out_lines[line_idx], integerise(lines[line_idx].split(",")))


with open(path + filename + ".csv", "w") as out_file:
    for line in out_lines:
        line[:] = [round(x / 10, 3) for x in line]
        out_file.write(str(line).replace("[", "").replace("]", "") + '\n')

out_file.close()