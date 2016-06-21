from __future__ import division
from scipy.optimize import minimize
from DatabaseHandler import DatabaseHandler
import time
from datetime import datetime
import numpy as np
from math import log
import sys


def get_next_state(wealth):
    # wealth is the profit up to this moment (calculated as sum of rewards)
    if nStates == 2:
        if wealth < 0:
            return 0  # poor
        else:
            return 1  # rich
    elif nStates == 3:
        # TODO implement 3 states
        print
        print wealth
        w = htan_custom(wealth, 1 / 10)
        print w

        if w < - 1 / 3:
            print 'poor'
            return 0  # poor
        elif w < 1 / 3:
            print 'mid'
            return 1  # mid
        else:  # w > 1/3
            print 'rich'
            return 2  # rich


def read_stock_file(b_type, b_amount, res_subfolder):
    file_number = -1
    path = "../../data/" + res_subfolder + "_classified_stocks/" + str(b_amount) + "/"
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
    print 'stock file: ', path

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


def htan_custom(xx, factor):
    return (1 - np.exp(- xx * factor)) / (1 + np.exp(- xx * factor))


def model_fit(parameters, *args):
    alpha, beta, gamma = parameters

    Q = [[0 for x in xrange(nActions)] for x in xrange(nStates)]
    profit = 0
    state = 1

    # store the stocks purchased for future estimation of reward
    portfolio = dict()

    # Measures set-up
    MLE = 0
    actionsAmount = 0

    for transaction in transactions:

        # CAP transactions amount
        if actionsAmount < CAP:

            # get only buy/sell actions
            if 'Buy' in transaction[3] or 'Sell' in transaction[3]:

                name = str(transaction[1])
                date_string = str(transaction[2]).split(' ')[0].replace('-', ' ')
                date = datetime.strptime(date_string, '%Y %m %d')
                a_type = str(transaction[3])
                stock = str(transaction[4])
                volume = int(transaction[5])
                total = float(transaction[7])
                # price       = float(transaction[6]) DEPRECATED...
                # ... decimal precision incorrect for average price calculation
                price = abs(total / volume)

                if 'Buy' in a_type and stock:

                    # save the stocks that have been purchased
                    if stock in portfolio:
                        old_volume = portfolio[stock][0]
                        old_price = portfolio[stock][1]
                        old_total = portfolio[stock][2]
                        new_volume = volume + old_volume
                        new_price = abs((total + old_total) / (volume + old_volume))
                        new_total = old_total + total
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
                        old_price = portfolio[stock][1]
                        old_total = portfolio[stock][2]

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
                            # the asset (selling power) is still the old price
                            # (which is the avg of all the buying prices normalised on the volumes)
                            # times the new amount of stocks held

                            portfolio[stock] = (new_volume, old_price, new_total)
                            # old_price so it is possible to calculate margin for future sells

                        # update profit with reward from sell
                        profit += reward

                        ''' SoftMax Action Selection NEW - - - - - - - - - - - - - - - - - -'''
                        # select the action really picked by player
                        action = stock_risk[stock]

                        denominator = 0
                        for a in xrange(nActions):
                            denominator += np.exp(beta * Q[state][a])

                        # for the calculation of MLE consider only from the n-th action
                        # (does not need -1 because increment is in the loop)
                        if actionsAmount > RESTRICTED_ACTION_LIMIT:
                            MLE += beta * Q[state][action] - log(denominator)

                        ''' softmax end ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~'''
                        next_state = get_next_state(profit)

                        ''' Qvalues update '''
                        TD_error = (reward + (gamma * max(Q[next_state])) - Q[state][action])
                        Q[state][action] += alpha * TD_error

                        state = next_state

    return -MLE


def test_f(params):
    x1, x2 = params
    return x1**2 + x2**2

if __name__ == '__main__':

    CAP = 25
    results_subfolder = 'risk'
    bin_type = 'u'
    nActions = 5
    nStates = 2
    HTAN_REWARD_SIGMA = 500
    RESTRICTED_ACTION_LIMIT = 10

    # Read the stocks previously classified according to their risk
    stock_risk = read_stock_file(bin_type, nActions, results_subfolder)

    # connect to DB
    db = DatabaseHandler('localhost', 'root', 'root', 'virtualtrader')

    # retrieve players
    db_players = db.select_players('transactions')
    players = sorted(filter_players(db_players, '../../data/players_threshold.txt'))

    # guess points (start of search space)
    gps = [(0, 0, 0), (0, 0, 0.5), (0, 0, 1), (0, 25, 0), (0, 25, 0.5), (0, 25, 1), (0, 50, 0), (0, 50, 0.5), (0, 50, 1),
          (0.5, 0, 0), (0.5, 0, 0.5), (0.5, 0, 1), (0.5, 25, 0), (0.5, 25, 0.5), (0.5, 25, 1), (0.5, 50, 0), (0.5, 50, 0.5), (0.5, 50, 1),
          (1, 0, 0), (1, 0, 0.5), (1, 0, 1), (1, 25, 0), (1, 25, 0.5), (1, 25, 1), (1, 50, 0), (1, 50, 0.5), (1, 50, 1)]

    # bounds
    bounds = ((0.0001, 1), (0, 50), (0, 0.9999))
    #bounds = ((0.0001, 1), (0, 50), (0, 0)) add nogamma to the filename

    MLEs = []
    params = []
    restricted_type = 'un' if RESTRICTED_ACTION_LIMIT <= 0 else str(RESTRICTED_ACTION_LIMIT) + 'act'
    results_path = '../../results/gradient_descent/' + restricted_type  + '_restricted/'
    filename = results_path + 'grad_desc_' + str(CAP) + 'CAP_'  + str(nActions) + 'act.csv'
    MLE_file = open(filename, 'w')

    print 'testing with: '
    print 'CAP:', CAP
    print 'act:', nActions
    print 'restricted:', RESTRICTED_ACTION_LIMIT
    print 'saving in ', filename

    for player in players:
        ti = time.time()

        MLEs.append(1000)  # placeholders
        params.append([])

        print '\n' + str(players.index(player)) + ' : ' + str(player)

        # retrieve the transactions for each player
        transactions = db.select_transactions('transactions', player)

        for gp in gps:

            result = minimize(model_fit, gp, bounds=bounds, tol=1e-18)

            if result['success'] and result['fun'] < MLEs[players.index(player)]:
                MLEs[players.index(player)] = result['fun']
                params[players.index(player)] = list(result['x'])

        print MLEs[players.index(player)]
        print params[players.index(player)]
        print
        MLE_file.write(str(players.index(player)) + ',' +
                       str(params[players.index(player)][0]) + ',' +
                       str(params[players.index(player)][1]) + ',' +
                       str(params[players.index(player)][2]) + ',' +
                       str(MLEs[players.index(player)]) + '\n')

        print str(time.time() - ti) + ' seconds'

    MLE_file.close()
