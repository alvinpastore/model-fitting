from __future__ import division
import operator
import sys
import MySQLdb
import random
import numpy as np
from datetime import datetime
import time
from math import log
import warnings
from DatabaseHandler import DatabaseHandler


def filter_players(all_players, threshold_file):
    t_players = [line.rstrip('\n') for line in open(threshold_file, 'r')]
    return list(set(all_players).intersection(set(t_players)))


def htan_custom(xx, factor):
    return (1 - np.exp(- xx * factor)) / (1 + np.exp(- xx * factor))


def save_performances(file_path, perfs):
    perf_file = open(file_path + '/profit_performances.csv', 'w')

    for pl in sorted(perfs.items(), key=operator.itemgetter(1)):
        print str(players.index(pl[0])) + '\t' + str(pl[0]) + '\t' + str(pl[1])
        perf_file.write(str(pl[0]) + ',' + str(players.index(pl[0])) + ',' + str(pl[1]) + '\n')

    perf_file.close()

''' ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ MAIN ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ '''
'''~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'''

t0 = time.time()

if len(sys.argv) < 2 or int(sys.argv[1]) < 16 or int(sys.argv[1]) > 107:
    print 'Usage: python performance_calculator.py   C  \n' \
          'C = number of max transactions to consider (min = 16, max = 107)'

CAP = int(sys.argv[1])

# connect to DB
db = DatabaseHandler('localhost', 'root', 'root', 'virtualtrader')

# retrieve players
db_players = db.select_players('transactions')
players = sorted(filter_players(db_players, '../../data/players_threshold.txt'))
profit = 0
HTAN_REWARD_SIGMA = 500
performances = dict()

print
print 'Version history \n' \
      '2.0.0 using profit(relative) instead of money (absolute wealth)\n' \
      '1.0.0 unified with DatabaseHandler module\n' \
      '0.0.2 saving performances in files (ids and names)\n' \
      '0.0.1 first draft for calculating performance \n' \

for player in players:
    print '\n' + str(players.index(player)) + ' : ' + str(player)

    # retrieve the transactions for each player
    transactions = db.select_transactions('transactions', player)

    # store the stocks purchased for future estimation of reward
    portfolio = dict()
    actionsAmount = 0
    profit = 0
    for transaction in transactions:

        # CAP transactions amount
        if actionsAmount < CAP:

            if 'Buy' in transaction[3] or 'Sell' in transaction[3]:

                name        = str(transaction[1])
                date_string = str(transaction[2]).split(' ')[0].replace('-', ' ')
                date        = datetime.strptime(date_string, '%Y %m %d')
                a_type      = str(transaction[3])
                stock       = str(transaction[4])
                volume      = int(transaction[5])
                total       = float(transaction[7])
                # price       = float(transaction[6])
                # deprecated: decimal precision incorrect for average price calculation
                price = abs(total / volume)

                ''' PRINT TRANSACTIONS DETAILS '''
                #print name + " " + a_type + " " + stock + " " + str(total)
                #for s in portfolio:
                #    print str(s) + " " + str(portfolio[s])
                #raw_input()
                if 'Buy' in a_type and stock:

                    # save the stocks that have been purchased
                    if stock in portfolio:
                        old_volume = portfolio[stock][0]
                        old_price  = portfolio[stock][1]
                        old_total  = portfolio[stock][2]
                        new_volume = volume + old_volume
                        new_price  = abs((total + old_total) / (volume + old_volume))
                        new_total  = old_total + total

                        portfolio[stock] = (new_volume, new_price, new_total)

                    else:
                        portfolio[stock] = (volume, price, total)

                    ''' NO NEED TO CHANGE STATE SINCE IT DEPENDS ON PROFIT CHANGE
                    (only sells can modify it)
                    # deduct money spent to purchase stock
                    # (+ sign because the sign of the total is negative for purchases)
                    # money += total

                    # next_state = get_next_state(money, portfolio)
                    '''

                elif 'Sell' in a_type and stock:

                    if stock not in portfolio:
                        print ':::::::::::::::::::::::::::::::::::::::::::::::'
                        print player
                        print 'stock', stock
                        print 'portfolio', portfolio
                        # messed up player
                        break
                    else:

                        actionsAmount += 1
                        old_volume = portfolio[stock][0]
                        old_price  = portfolio[stock][1]
                        old_total  = portfolio[stock][2]

                        # the reward is the gain on the price times the number of shares sold
                        reward_base = ((price - old_price) * volume)
                        reward = htan_custom(reward_base, 1 / HTAN_REWARD_SIGMA)

                        # if all shares for the stock have been sold delete stock from portfolio
                        # otherwise update the values (new_volume, old_price, new_total)
                        new_volume = old_volume - volume
                        if new_volume <= 0:
                            del portfolio[stock]
                        else:

                            new_total = - (new_volume * old_price)
                            # the asset (selling power) is still
                            # the old price (which is the avg of all the buying prices normalised on the volumes)
                            # times the new amount of stocks held

                            portfolio[stock] = (new_volume, old_price, new_total)
                            # old_price so it is possible to calculate margin for future sells

                        # update profit with reward from sell
                        profit += reward_base
    '''
    assets = 0
    for s in portfolio:
        print str(s) + " " + str(portfolio[s])
        assets += portfolio[s][2]

    # assets values are negative for holdings
    print "assets", assets
    print "profit", profit
    print "performance", profit - assets
    raw_input()

    performances[player] = (profit - assets) / 1000 OLD '''

    performances[player] = profit
    print profit

save_performances('results/stats/performances', performances)

db.close()
final_time = (time.time() - t0)
print("%.2f secs" % final_time)