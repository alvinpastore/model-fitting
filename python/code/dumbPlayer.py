from __future__ import division
import sys
import random
import numpy as np
from datetime import datetime
import time
from math import log
import warnings
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

t0 = time.time()

# max transactions amount
CAP = 25
bin_type = sys.argv[1]
nActions = 3

# Read the stocks previously classified according to their risk
stock_risk = read_stock_file(bin_type, nActions)


# connect to DB
db = DatabaseHandler('localhost', 'root', 'root', 'virtualtrader')

# retrieve players
db_players = db.select_players('transactions')
players = sorted(filter_players(db_players, '../../data/players_threshold.txt'))


print 'total players: ' + str(len(players))

print players


# data structure that contains the MLEs
dumbPlayers = []
dpActions = []
dumbAction = [0, 1, 2]
for player in players:

    print '\n' + str(players.index(player)) + ' : ' + str(player)

    # retrieve the transactions for each player
    transactions = db.select_transactions('transactions', player)

    actionsAmount = 0
    correct_actions = [0, 0, 0]

    for transaction in transactions:
        if actionsAmount < CAP:
            stock = str(transaction[4])
            if 'Sell' in transaction[3] and stock:
                stock = str(transaction[4])

                actionsAmount += 1

                action = stock_risk[stock]

                for dA in dumbAction:
                    if dA == action:
                        correct_actions[dA] += 1

    player_summary = list(np.true_divide(correct_actions, actionsAmount))
    player_summary.append(actionsAmount)
    dumbPlayers.append(player_summary)

    print str(actionsAmount) + ' transactions '

db.close()

filename = 'results/dumb_players_25CAP_' + bin_type + '.csv'
outfile = open(filename, 'w')

print 'pid \t dp1 \t dp2 \t dp3 \t amount'
for dpi in xrange(len(dumbPlayers)):
    outfile.write('%d , %0.3f , %0.3f , %0.3f , %d\n' % (dpi, dumbPlayers[dpi][0],
                                                         dumbPlayers[dpi][1],
                                                         dumbPlayers[dpi][2],
                                                         dumbPlayers[dpi][3]))

    print '%d \t %0.3f \t %0.3f \t %0.3f \t %d' % (dpi, dumbPlayers[dpi][0],
                                                   dumbPlayers[dpi][1],
                                                   dumbPlayers[dpi][2],
                                                   dumbPlayers[dpi][3])

outfile.close()
print 'written to ', filename
print str((time.time() - t0)) + ' seconds'
