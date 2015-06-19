from __future__ import division
import os
import sys
import numpy as np
import operator
import random
import math

''' FUNCTIONS '''
# generator of chunks for the bins


def chunks(l, n):
    # generator of chunks for the bins
    """ Yield successive n-sized chunks from l.
    """
    for i in xrange(0, len(l), n):
        yield l[i: i + n]


def write_bins(file_path, sbins):
    outFile = open(file_path, "w")
    for sbin in sbins:
        outFile.write(str(len(sbin)) + '\n')
        for s in sbin:
            outFile.write(str(s[0]) + '~' + str(s[1]) + '\n')
    outFile.close()


def read_betas(file_path):
    bs = {}
    with open(file_path, 'r') as betas_file:
        for file_line in betas_file:
            if '~' in file_line:
                stock_beta = file_line.split('~')
                bs[stock_beta[0]] = float(stock_beta[1].strip())
    return bs


def replaceName(cn, rNames):

    # print "\nCompany name before:", cn

    for name in rNames:
        cn = cn.replace(name, rNames[name])

    # print "Company name after:", cn
    return cn


def random_bins(stocks, b_amount, b_size, bs, n):
    rand_bins = [[] for _ in xrange(b_amount)]
    bin_idx = 0
    larger_bins = len(bs) % b_amount
    # print "larger_bins", larger_bins


    # keep adding to the i-th bin till its full (bin size < stock amount / bins amount)
    while len(bs) > 0:
        # print "\nlarger bins", larger_bins
        random_bin_size = b_size + 1 if larger_bins > 0 else b_size

        # print "r bin size", random_bin_size

        while len(rand_bins[bin_idx]) < random_bin_size and len(bs) > 0:
            random_stock = random.choice(bs.keys())
            bs.pop(random_stock)
            rand_bins[bin_idx].append((random_stock, stocks[random_stock]))

        bin_idx += 1
        larger_bins -= 1

    # for b in rand_bins:
    #    print len(b)
    #    print b
    #    print

    write_bins(rootdir + "risk_classified_stocks/" + "uniform_random_"
               + str(bins_amount) + "_" + str(n) + ".txt", rand_bins)

''' MAIN '''
# date of last transactions 27 May 2014

if len(sys.argv) < 2:
    print 'Usage: python stockClassifier.py bins_amount [n] (generate n random bins)\n'
else:
    print 'The ordered bins are buggy: 107/4: 4bins of 26 and 1 of 3'
    print 'Random bins are fine 3 bins of 27 and one of 26'
    
    all_stock = {}
    highest_std = 8582946964.77
    bins_amount = int(sys.argv[1])
    RANDOM = int(sys.argv[2]) if len(sys.argv) > 2 else False

    rootdir = '../../data/'
    betas = read_betas(rootdir + 'betas.txt')
    bin_size = int(math.floor(len(betas) / bins_amount))

    bins = {i: [] for i in xrange(bins_amount)}

    """
    International Consolidated Airlines Group Plc
    International Consolidated Air

    Marks&Spencer Group
    Marks&amp;Spencer Group

    Tate & Lyle
    Tate &amp; Lyle

    Legal & General
    Legal &amp; General

    Smith & Nephew
    Smith &amp; Nephew

    Sports Direct International Plc
    Sports Direct International Pl

    Whitbread A
    Whitbread 'A'
    """
    repNames = {"International Consolidated Airlines Group Plc": "International Consolidated Air",
                "&": "&amp;",
                "Sports Direct International Plc": "Sports Direct International Pl",
                "Whitbread A": "Whitbread 'A'"
                }

    for folder, subs, files in os.walk(rootdir):

        for fileName in files:
            if "csv" in fileName:
                companyName = fileName[:-4]
                companyName = replaceName(companyName, repNames)

                # print "file:", companyName

                with open(os.path.join(folder, fileName), 'r') as dataFile:

                    # create a list of points (close value)
                    content = dataFile.readlines()
                    closePoints = (companyName, [])

                    # 1:   remove first line (description of columns)
                    # 250: get the close prices of the past year (sometimes history might not be enough to get to 250)
                    for line in content[1:250]:
                        line = line.split(",")

                        # multiply closing price by volume so splits do not affect directly the statistics
                        closePrice = float(line[4])
                        volume = int(line[5])
                        capitalization = closePrice * volume
                        # create a list of tuples (date, capitalization)
                        closePoints[1].append((line[0], capitalization))

                    # this is the list of cap values
                    # zip creates two lists according to the tuples: date list and cap list (TODO  remove the dates? )
                    cap = np.asarray(zip(*closePoints[1])[1])
                    stddev = np.std(cap, ddof=1)

                    # code was run the first time to estimate the highest std dev (8582946964.77)
                    # highest_std = max([stddev,highest_std]) estimate highest stdev (to normalise)

                    # TODO improve the measure including a moving window of the return average
                    # ## oneYearPrice = float(content[250].split(",")[4])    #date corresponds to 30-May-2013
                    # ## lastPrice = float(content[1].split(",")[4])

                    # the rate of gain (positive or negative) is defined as the difference of the
                    # current price with the price one year ago divided by the old price
                    # (alternatively the rate of gain can be defined as current / year -1)
                    # ##gainRate = (lastPrice - oneYearPrice) / (oneYearPrice)
                    # print "gain rate:",gainRate

                    # riskiness is the absolute value of the combination of beta of the company
                    # and std dev of the price in the last three years
                    print companyName
                    riskiness = abs(betas[companyName] * stddev / highest_std)

                    # pool of all stocks riskiness to plot distribution
                    all_stock[companyName] = riskiness

                    ''' This unbalances the bins size
                    # extends to all number of bins
                    # riskiness into j-th bin if in range [j/N, j+1/N]
                    for j in xrange(binsAmount + 1):
                        if j / binsAmount < riskiness  < (j + 1) / binsAmount:
                                    bins[j].append((companyName, riskiness))

                    '''

    # sort all the stocks according to their riskiness
    sorted_stocks = sorted(all_stock.items(), key=operator.itemgetter(1))
    stock_bins = list(chunks(sorted_stocks, bin_size))

    # for b in stock_bins:
    #     print len(b)
    #     print b
    #     print

    # Save bins to file
    write_bins(rootdir + "risk_classified_stocks/" + "uniform_" + str(bins_amount) + ".txt", stock_bins)

    if RANDOM:
        for i in range(0, RANDOM):
            b_copy = betas.copy()
            random_bins(all_stock, bins_amount, bin_size, b_copy, i)