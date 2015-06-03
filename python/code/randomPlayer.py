from __future__ import division
import sys
import random
import time
from math import log
from DatabaseHandler import DatabaseHandler

''' ---- FUNCTIONS ---- '''


def read_stock_file(b_type, b_amount):
    path = "../../data/risk_classified_stocks/"
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

    print 'total players: ' + str(len(players))

    # data structure that contains the MLEs and precisions
    randomPlayers = []

    for player in players:

        print '\n' + str(players.index(player)) + ' : ' + str(player)

        # retrieve the transactions for each player
        transactions = db.select_transactions('transactions', player)

        avg_MLE = 0
        avg_correct_actions = 0

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

                        random_action = random.randint(1, nActions)

                        # update MLE
                        tempMLE += log(1 / nActions)

                        # update precision
                        if random_action == action:
                            correctActions += 1

            avg_MLE += tempMLE
            avg_correct_actions += correctActions

        avg_MLE /= repetitions
        avg_MLE = -avg_MLE

        analytical_MLE = - actionsAmount * log(1 / nActions)

        precision = avg_correct_actions / (actionsAmount * repetitions)
        if precision > 1 / nActions:
            print "##########################################################################"

        print "nMLE: {0:.3f} \naMLE: {1:.3f}\nPrec: {2:.2f}%".format(avg_MLE, analytical_MLE, precision * 100)

        print str(actionsAmount) + ' transactions '

    db.close()

print str((time.time() - t0)) + ' seconds'
