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


def read_stock_file(b_type, b_amount, risk_measure):
    file_number = -1
    path = "../../data/" + risk_measure + "_classified_stocks/" + str(b_amount) + "/"
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
    actions_amount = 0

    for transaction in transactions:

        # CAP transactions amount
        if actions_amount < CAP:

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

                        actions_amount += 1
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
                        if actions_amount > RESTRICTED_ACTION_LIMIT:
                            MLE += beta * Q[state][action] - log(denominator)

                        ''' softmax end ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~'''
                        next_state = get_next_state(profit)

                        if ALGORITHM_TYPE == 'qlearning':
                            ''' QLearning update '''
                            TD_error = (reward + (gamma * max(Q[next_state])) - Q[state][action])
                            Q[state][action] += alpha * TD_error

                        elif ALGORITHM_TYPE == 'sarsa':
                            ''' Sarsa update'''
                            if actions_amount < len(transactions_list[str(players.index(player))]):
                                # actions_amount is the index of the next action (incremented already within the loop)
                                next_action = stock_risk[transactions_list[str(players.index(player))][actions_amount]]
                                future_term = gamma * Q[next_state][next_action]
                            else:
                                future_term = 0

                            TD_error = (reward + future_term - Q[state][action])
                            Q[state][action] += alpha * TD_error

                        state = next_state

    return -MLE


def read_transactions_file(trans_filename):
    trans_list = dict()
    with open(trans_filename, 'r') as trans_file:
        temp_list = trans_file.readlines()
        for line in temp_list:
            t_line = [elem.strip() for elem in line.split(',')]
            if len(t_line) > 1:
                trans_list[t_line[0]] = t_line[1:]

    return trans_list

if __name__ == '__main__':

    if len(sys.argv) != 8:
        print 'Usage: python grad_desc_model_fit.py CAP u[rX]|s[rX] na ns rc ral at\n' \
              'CAP = number of max transactions to consider (min = 16, max = 107)\n' \
              'u   = uniform risk distribution [r] random\n' \
              's   = skewed  risk distribution [r] random\n' \
              'X   = random file number\n' \
              'na  = number of actions\n' \
              'ns  = number of states\n' \
              'rc  = type of risk classification [risk|beta|std]\n' \
              'ral = number of transactions to skip for MLE calculation\n' \
              'at  = algorithm type [qlearning|sarsa]\n'
    else:
        # 25 u 3 2 risk 0 qlearning


        HTAN_REWARD_SIGMA = 500

        CAP = int(sys.argv[1])
        bin_type = sys.argv[2]
        nActions = int(sys.argv[3])
        nStates  = int(sys.argv[4])
        risk_measure = sys.argv[5]
        RESTRICTED_ACTION_LIMIT = int(sys.argv[6])
        ALGORITHM_TYPE = sys.argv[7]

        # Read the stocks previously classified according to their risk
        stock_risk = read_stock_file(bin_type, nActions, risk_measure)

        transactions_list = read_transactions_file('../../data/players_transactions.csv')
        # connect to DB
        db = DatabaseHandler('localhost', 'root', 'root', 'virtualtrader')

        # retrieve players
        db_players = db.select_players('transactions')
        players = sorted(filter_players(db_players, '../../data/players_threshold.txt'))

        # guess points (start of search space)
        gps = [(0.0001, 0, 0), (0.0001, 0, 0.5), (0.0001, 0, 1), (0.0001, 25, 0), (0.0001, 25, 0.5), (0.0001, 25, 1), (0.0001, 50, 0), (0.0001, 50, 0.5), (0.0001, 50, 1),
              (0.5, 0, 0), (0.5, 0, 0.5), (0.5, 0, 1), (0.5, 25, 0), (0.5, 25, 0.5), (0.5, 25, 1), (0.5, 50, 0), (0.5, 50, 0.5), (0.5, 50, 1),
              (1, 0, 0), (1, 0, 0.5), (1, 0, 1), (1, 25, 0), (1, 25, 0.5), (1, 25, 1), (1, 50, 0), (1, 50, 0.5), (1, 50, 1)]

        # bounds
        #bounds = ((0.0001, 2), (0, 50), (0, 0.9999))
        bounds = ((0.0001, 2), (0, 50), (0, 0)) #add nogamma to the filename

        MLEs = []
        params = []
        restricted_type = 'un' if RESTRICTED_ACTION_LIMIT <= 0 else str(RESTRICTED_ACTION_LIMIT) + 'act'
        results_path = '../../results/gradient_descent/' + restricted_type  + '_restricted/' + ALGORITHM_TYPE + '/' + risk_measure + '/'
        # specify the type of bin (uniform, uniform random or skewed) only if it is not uniform
        btype = '_' + bin_type if bin_type != 'u' else ''
        filename = results_path + 'grad_desc_' + str(CAP) + 'CAP_'  + str(nActions) + 'act' + btype + '_nogamma.csv'
        MLE_file = open(filename, 'w')

        print 'Fitting with: '
        print 'CAP:', CAP
        print 'act:', nActions
        print 'restricted:', RESTRICTED_ACTION_LIMIT
        print 'saving in ', filename
        t1 = time.time()
        for player in players:

            for times in xrange(36):
                MLEs.append(9999)
                params.append([-1, -1, -1])

            if players.index(player) >= 0:
                ti = time.time()

                MLEs.append(9999)  # placeholders
                params.append([-1, -1, -1])

                print '\n' + str(players.index(player)) + ' : ' + str(player)

                # retrieve the transactions for each player
                transactions = db.select_transactions('transactions', player)

                for gp in gps:

                    result = minimize(model_fit, gp, bounds=bounds, tol=1e-18)

                    if result['success'] and result['fun'] < MLEs[players.index(player)]:
                        MLEs[players.index(player)] = result['fun']
                        params[players.index(player)] = list(result['x'])
                    else:
                        pass

                print MLEs[players.index(player)]
                print params[players.index(player)]

                MLE_file.write(str(players.index(player)) + ',' +
                               str(params[players.index(player)][0]) + ',' +
                               str(params[players.index(player)][1]) + ',' +
                               str(params[players.index(player)][2]) + ',' +
                               str(MLEs[players.index(player)]) + '\n')

                print str(time.time() - ti) + ' seconds'
        print 'total ' + str(time.time() - t1) + ' seconds'
        MLE_file.close()
