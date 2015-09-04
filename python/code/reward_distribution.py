from __future__ import division
import sys
from DatabaseHandler import DatabaseHandler
from datetime import datetime
import numpy as np
import time

def filter_players(all_players, threshold_file):
    t_players = [line.rstrip('\n') for line in open(threshold_file, 'r')]
    return list(set(all_players).intersection(set(t_players)))


def htan_custom(xx, factor):
    return (1 - np.exp(- xx * factor)) / (1 + np.exp(- xx * factor))


''' ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ MAIN ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ '''
'''~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'''

t0 = time.time()
CAP = int(sys.argv[1])
HTAN_SIGMA = 500
# connect to DB
db = DatabaseHandler('localhost', 'root', 'root', 'virtualtrader')

# retrieve players
db_players = db.select_players('transactions')
players = sorted(filter_players(db_players, '../../data/players_threshold.txt'))

print 'Scan the transactions to record the rewards and store them'
print 'total players: ' + str(len(players))

reward_file = open('results/stats/rewards' + str(CAP) + '_cap.csv', 'w')
rew_counter = 0

for player in players:
    print player
    # retrieve the transactions for each player
    transactions = db.select_transactions('transactions', player)
    # store the stocks purchased for future estimation of reward
    portfolio = dict()

    actionsAmount = 0
    for transaction in transactions:

        if actionsAmount < CAP:
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

                    actionsAmount += 1
                    old_volume = portfolio[stock][0]
                    old_price  = portfolio[stock][1]
                    old_total  = portfolio[stock][2]

                    # the reward is the gain on the price times the number of shares sold
                    reward_base = ((price - old_price) * volume)
                    reward = htan_custom(reward_base, 1 / HTAN_SIGMA)

                    reward_file.write(str(reward_base) + ',' + str(reward) + '\n')
                    rew_counter += 1
                    # if all shares for the stock have been sold delete stock from portfolio
                    # otherwise update the values (new_volume, old_price, new_total)
                    new_volume = old_volume - volume
                    if new_volume <= 0:
                        del portfolio[stock]
                    else:
                        portfolio[stock] = (new_volume, old_price, new_volume * old_price)
                        # old_price so it is possible to calculate margin for future sells

    print str(actionsAmount)  + " transactions"

reward_file.close()
db.close()

print str(rew_counter) + " rewards"
print 'total: ' + str((time.time() - t0) / 60) + ' minutes'




