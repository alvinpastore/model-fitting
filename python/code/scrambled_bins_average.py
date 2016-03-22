from __future__ import division
import sys
from operator import add
from math import sqrt

"""  averages out the results of the model on the scrambled bins  """


def average(s):
    return sum(s) / len(s)


def variance(s, mean):
    var = map(lambda e: (e - mean) ** 2, s)
    return sum(var) / (len(var) - 1)


def std_dev(var):
    return sqrt(var)


def std_err(std_d, n):
    return std_d / sqrt(n)



def integerise(values):
    out_values = [0] * 7
    for j in xrange(len(values) - 1):
        if len(values[j].strip()) > 0:
            out_values[j] = float(values[j])
        else:
            out_values[j] = 0
    # last value is an integer (the amount of transactions) and does not need conversion or validation
    out_values[j + 1] = int(values[j + 1])
    return out_values


nActions = '3'
path = 'results/after_money_1k/scrambled_' + nActions + '/'
nRandomFiles = 99
filename = 'results_25cap_' + nActions + 'act_1000rep_0.1-1_alpha10-40_beta0.01-0.999_gamma_ur'
nLines = 4646
nColumns = 7

# save the sum of the value for each column and average out at the end
out_lines = [[0 for x in range(nColumns)] for x in range(nLines)]

# saves the values of precision to calculate the variance (can extend implementing running variance)
# last column is where the variance is stored
var_lines = [[0 for x in range(nRandomFiles)] for x in range(nLines)]


# this xrange generates the the integers to be used as scrambled result files identifier
for i in xrange(0, nRandomFiles):
    print "\nfile", i
    iFilename = filename + str(i) + ".csv"

    lines = [line.rstrip('\n') for line in open(path + iFilename, 'r')]

    for line_idx in xrange(len(lines)):
        current_line = lines[line_idx].split(",")

        # save precision (fifth column of the line)
        var_lines[line_idx][i] = float(current_line[5])

        # map applies the function (param1) to the elements in the other param)
        out_lines[line_idx] = map(add, out_lines[line_idx], integerise(current_line))

# save statistical measures (mean, std dev and std err in a list of tuples)
stats = []
for i in xrange(0, nLines):
    print
    #print var_lines[i]
    avg = average(var_lines[i])
    #raw_input(round(avg, 3))
    v = variance(var_lines[i], avg)
    #raw_input(round(v, 3))
    std = std_dev(v)
    #raw_input(round(std, 3))
    ste = std_err(std, len(var_lines[i]))
    #raw_input(round(ste, 3))
    stats.append((avg, std, ste))

i = 0
with open(path + filename + ".csv", "w") as out_file:
    for line in out_lines:
        #print line
        line[:] = [round(x / nRandomFiles, 3) for x in line]
        line.append(round(stats[i][0], 3))
        line.append(round(stats[i][1], 3))
        line.append(round(stats[i][2], 3))
        print line
        print
        i += 1
        #raw_input()
        out_file.write(str(line).replace("[", "").replace("]", "") + '\n')

out_file.close()