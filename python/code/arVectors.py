from __future__ import division
import sys
import random
import numpy as np
from datetime import datetime
import time
from math import log
import warnings
from DatabaseHandler import DatabaseHandler


__author__ = 'alvin'


""" Script description:
    Generate vectors containing the actions for each player

    Action vector A = [a_1, a_2, ..., a_i, ..., a_n] with S = {stock_riskiness}
    Reward vector R = [r_1, r_2, ..., r_i, ..., r_n]
    where
     n is the amount of transactions for the player
     a_i is the riskiness of the action a in S
     r_i is the reward (htan transformation of profit) for action a_i

 """

''' ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ FUNCTIONS ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ '''


def htan_custom(factor):
    return (1 - np.exp(- reward_base * factor)) / (1 + np.exp(- reward_base * factor))


def filter_players(all_players, threshold_file):
    t_players = [line.rstrip('\n') for line in open(threshold_file, 'r')]
    return list(set(all_players).intersection(set(t_players)))


def calculate_risk():
    print "Loading the stock riskiness dictionary..."
    risk_dict = dict()
    with open("../../data/risk_classified_stocks/uniform_3.txt", 'r') as risk_file:
        content = risk_file.readlines()
        for line in content:
            line = line.strip().split('~')
            if len(line) > 1:
                risk_dict[line[0]] = line[1]
    print "Done"
    return risk_dict

''' ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ MAIN ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ '''

t0 = time.time()

HTAN_SIGMA = 500
CAP = 25
ar_vectors = dict()
stock_risk = calculate_risk()

# connect to DB
db = DatabaseHandler('localhost', 'root', 'root', 'virtualtrader')

# retrieve players
db_players = db.select_players('transactions')
players = sorted(filter_players(db_players, '../../data/players_threshold.txt'))

for player in players:
    # retrieve the transactions for each player
    transactions = db.select_transactions('transactions', player)
    # store the stocks purchased for future estimation of reward
    portfolio = dict()
    actionsAmount = 0
    ar_vectors[player] = list()

    for transaction in transactions:

        # CAP transactions amount
        if CAP and actionsAmount < CAP:

            # get only buy/sell actions
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
                        reward = htan_custom(1 / HTAN_SIGMA)

                        # store in the action_reward vector the stock's name, riskiness and the reward obtained
                        ar_vectors[player].append((stock, stock_risk[stock], reward))

                        # if all shares for the stock have been sold delete stock from portfolio
                        # otherwise update the values (new_volume, old_price, new_total)
                        new_volume = old_volume - volume
                        if new_volume <= 0:
                            del portfolio[stock]
                        else:
                            # the asset (selling power) is still
                            # the old price is avg of all the buying prices normalised on the volumes
                            # times the new amount of stocks held
                            portfolio[stock] = (new_volume, old_price, new_volume * old_price)
                            # old_price so it is possible to calculate margin for future sells

for arv in ar_vectors:
    print str(arv) + " " + str(ar_vectors[arv])
    print

print "there are " + str(len(ar_vectors)) + " action vectors\n"
db.close()
print 'total: ' + str((time.time() - t0)) + 'seconds'