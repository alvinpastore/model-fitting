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
    file_number = -1
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
        file_number = int(b_type.split("r")[1])
        print file_number

    path += str(b_amount) + '.txt' if file_number < 0 else str(b_amount) + '_' + str(file_number) + '.txt'

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

def select_action(temporaryMLE):
    random_dice = random.random()

    bin_idx = 0
    term_idx = 0

    while term_idx < nActions:
        bin_idx += terms[term_idx]
        term_idx += 1
        if random_dice < bin_idx:
            MLE_act = term_idx - 1
            break

    if terms[MLE_act] > 0:
        temporaryMLE += log(terms[MLE_act])
    else:
        temporaryMLE = 0

    return temporaryMLE, MLE_act


def htan_custom(xx, factor):
    return (1 - np.exp(- xx * factor)) / (1 + np.exp(- xx * factor))


''' ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ MAIN ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ '''
'''~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'''

t0 = time.time()

if len(sys.argv) < 3:
    print 'Usage: python model_fit_histograms.py  C  B\n' \
          'C = number of max transactions to consider (min = 16, max = 107)\n' \
          'B = number of bins'

elif int(sys.argv[1]) < 16 or int(sys.argv[1]) > 107:
    print 'C = number of max transactions to consider (min = 16, max = 107)'

else:

    ''' SETUP '''
    HTAN_REWARD_SIGMA = 500
    CAP = int(sys.argv[1])
    nActions = int(sys.argv[2])
    bin_type = 'u'

    # Read the stocks previously classified according to their risk
    stock_risk = read_stock_file(bin_type, nActions)
    # connect to DB
    db = DatabaseHandler('localhost', 'root', 'root', 'virtualtrader')

    # retrieve players
    db_players = db.select_players('transactions')
    players = sorted(filter_players(db_players, '../../data/players_threshold.txt'))

    print 'Version history \n' \
          '1.0.0 code rewritten, generalised actions/states number, database access, ' \
          'now recording profit along with reward and actions\n' \
          '0.0.1 first version'

    print 'total players: ' + str(len(players))

    player_statistics = {}

    for player in players:
        ti = time.time()

        playerID = players.index(player)

        # structure to store reward_base, reward and profit
        player_statistics[playerID] = []
        profit = 0
        actionsAmount = 0

        print '\n' + str(playerID) + ' : ' + str(player)

        # retrieve the transactions for each player
        transactions = db.select_transactions('transactions', player)

        # store the stocks purchased for future estimation of reward
        portfolio = dict()

        for transaction in transactions:

            # CAP transactions amount
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

                        ''' NO NEED TO CHANGE STATE SINCE IT DEPENDS ON PROFIT CHANGE
                        (only sells can modify it)
                        # deduct money spent to purchase stock
                        # (+ sign because the sign of the total is negative for purchases)
                        # money += total

                        # next_state = get_next_state(money, portfolio)
                        '''

                    elif 'Sell' in a_type and stock:

                        if stock not in portfolio:
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
                                portfolio[stock] = (new_volume, old_price, new_volume * old_price)
                                # old_price so it is possible to calculate margin for future sells

                            # update profit with reward from sell
                            profit += reward

                            # select the action really picked by player
                            action = stock_risk[stock]

                            player_statistics[playerID].append((reward_base, reward, profit))

        print str((time.time() - ti) / 60) + ' minutes'

    db.close()
    print 'total: ' + str((time.time() - t0) / 60) + ' minutes'

    with open('results/stats/players_stats_' + str(CAP) + 'cap_' + str(nActions) + 'act.csv', 'w') as out_file:
        for p in player_statistics:
            for item in player_statistics[p]:
                out_file.write(str(p) + ", " + str(item[0]) + ", " + str(item[1]) + ", " + str(item[2]) + "\n")