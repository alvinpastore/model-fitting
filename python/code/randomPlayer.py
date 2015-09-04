from __future__ import division
import sys
import random
import time
from math import log, sqrt

from DatabaseHandler import DatabaseHandler

''' ---- FUNCTIONS ---- '''


def read_stock_file(b_type, b_amount):
    path = "../../data/risk_classified_stocks/" + str(b_amount) + "/"
    if 'u' in b_type:
        path += 'uniform_'
    elif 's' in b_type:
        path += 'skewed_'
    else:
        print 'Risk distribution bin-type not valid'
        sys.exit()
    if 'r' in b_type:
        path += 'random_'

    path += str(b_amount) + '.txt'

    stocks = dict()
    risk_idx = -1
    with open(path, 'r') as stock_list_file:
        for line in stock_list_file:
            if '~' in line:
                stocks[line.split('~')[0]] = risk_idx
            else:
                risk_idx += 1

    return stocks


def filter_players(all_players, threshold_file):
    t_players = [line.rstrip('\n') for line in open(threshold_file, 'r')]
    return list(set(all_players).intersection(set(t_players)))

''' ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ MAIN ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ '''
'''~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'''

if len(sys.argv) < 4:
    print 'Usage: python randomPlayer.py   C   B   A   N \n\n' \
          'C = transactions CAP\n' \
          'B = bin type (u for uniform, s for skewed)\n'\
          'A = number of actions\n' \
          'N = number of repetition to average randomness\n'

elif int(sys.argv[1]) < 16 or int(sys.argv[1]) > 107:
    print 'C = number of max transactions to consider (min = 16, max = 107)'

else:

    t0 = time.time()

    # max transactions amount
    CAP = int(sys.argv[1])
    bin_type = sys.argv[2]
    nActions = int(sys.argv[3])
    repetitions = int(sys.argv[4])

    # Read the stocks previously classified according to their risk
    stock_risk = read_stock_file(bin_type, nActions)

    # connect to DB
    db = DatabaseHandler('localhost', 'root', 'root', 'virtualtrader')

    # retrieve players
    db_players = db.select_players('transactions')
    players = sorted(filter_players(db_players, '../../data/players_threshold.txt'))

    # print 'total players: ' + str(len(players))

    # data structure that contains the MLEs and precisions
    randomPlayers = []

    '''outfile = open('test_random' + str(nActions) + '.csv', 'w')'''
    # save data points for central limit theorem demonstration
    CLT_P_file = open('results/CLT/CLT_P_' + str(nActions) + '.csv', 'w')

    for player in players:

        print '\n' + str(players.index(player)) + ' : ' + str(player)
        '''outfile.write(str(players.index(player)) + ", ")'''

        # retrieve the transactions for each player
        transactions = db.select_transactions('transactions', player)

        avg_MLE = 0
        avg_correct_actions = 0

        # running variance setup
        # Knuth Welford
        # https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Online_algorithm
        n = 0
        mean = 0
        M2 = 0

        for rep in xrange(repetitions):

            actionsAmount = 0
            correctActions = 0
            tempMLE = 0

            for transaction in transactions:

                if actionsAmount < CAP:
                    stock = str(transaction[4])
                    if 'Sell' in transaction[3] and stock:
                        stock = str(transaction[4])

                        actionsAmount += 1

                        action = stock_risk[stock]

                        # nActions - 1 because we start counting from 0
                        random_action = random.randint(0, nActions - 1)

                        # update MLE
                        tempMLE += log(1 / nActions)

                        # update precision
                        if random_action == action:
                            correct_actions += 1

            avg_MLE += tempMLE
            avg_correct_actions += correct_actions
            local_precision = correct_actions / actionsAmount * 100

            # running variance calculations
            n += 1
            delta = local_precision - mean
            mean = mean + delta / n
            M2 = M2 + delta * (local_precision - mean)

            # store precision of each iteration
            CLT_P_file.write(str(local_precision) + ", ")

        avg_MLE /= repetitions
        avg_MLE = -avg_MLE

        analytical_MLE = - actionsAmount * log(1 / nActions)

        precision = avg_correct_actions / (actionsAmount * repetitions)

        variance = M2 / n
        std_dev = sqrt(variance)

        '''outfile.write("{0:.3f}, {1:.3f}\n".format(precision, std_dev))'''
        CLT_P_file.write(str(actionsAmount) + "\n")

        # print "nMLE: {0:.3f} \naMLE: {1:.3f}\nPrec: {2:.2f}%\nVar: {3:.2f}\nStdev: {4:.2f}".\
        #    format(avg_MLE, analytical_MLE, precision * 100, variance, std_dev)

        # print str(actionsAmount) + ' transactions '

    db.close()
    '''outfile.close()'''
    CLT_P_file.close()

    print str((time.time() - t0)) + ' seconds'
