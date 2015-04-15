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


def get_next_state(wealth, pfolio):
    # at the end of each player trial check the total amount of money
    for s in pfolio:
        # add total value of remaining stocks to money
        # (- because sign of total in portfolio is negative for assets)
        wealth -= float(pfolio[s][2])

    nextState = - 1

    if wealth < 60000:
        nextState = 0  # poor
        # print "poor"
    elif wealth <= 100000:
        nextState = 1  # mid
        # print "mid"
    elif wealth > 100000:
        nextState = 2  # rich
        # print "rich"

    return nextState


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


def select_action(temporaryMLE):
    random_dice = random.random()

    if random_dice < terms[0]:
        MLE_act = 0
    elif terms[0] <= random_dice < (terms[0] + terms[1]):
        MLE_act = 1
    else:
        MLE_act = 2

    if terms[MLE_act] > 0:
        temporaryMLE += log(terms[MLE_act])
    else:
        temporaryMLE = 0

    return temporaryMLE, MLE_act


def saveMLEs(fileName):
    comma = ' , '
    outFile = open(fileName, 'w')
    for n in sorted(MLEs):
        outFile.write(str(players.index(n)) + comma + comma + comma + comma + str(randomMLEs[n]) + comma +
                      str(1 / nActions) + comma + str(MLEs[n][min(Alpha)][min(Betas)][min(Gamma)][2]) + '\n')
        for a in sorted(MLEs[n]):
            for b in sorted(MLEs[n][a]):
                for g in sorted(MLEs[n][a][b]):

                    # print 'MLE[' + str(players.index(n)) + '-' + str(n) + '][' + str(a) + '][' + str(b) + '] = ' + \
                    #       str(MLEs[n][a][b][0]) + ',' + str(MLEs[n][a][b][0]) + ',' + str(MLEs[n][a][b][2])

                    outFile.write(str(players.index(n)) + comma + str(a) + comma + str(b) + comma + str(g) +
                                  comma + str(MLEs[n][a][b][g][0]) +
                                  comma + str(MLEs[n][a][b][g][1]) +
                                  comma + str(MLEs[n][a][b][g][2]) + '\n')
    outFile.close()
    print 'saved in ' + str(fileName)


def printMLEs():
    for pl in sorted(MLEs):
        print '\n' + pl
        print randomMLEs[pl]
        for a in MLEs[pl]:
            for b in MLEs[pl][a]:
                for g in sorted(MLEs[pl][a][b]):
                    print '\t alpha: ' + str(a) + ' beta: ' + str(b) + ' gamma: ' + str(g) + \
                          ' MLE: ' + str(MLEs[pl][a][b][g][0]) + ' P: ' + str(MLEs[pl][a][b][g][1])


def htan_custom(factor):
    return (1 - np.exp(- reward_base * factor)) / (1 + np.exp(- reward_base * factor))


def build_filename():
    fn = str(nActions) + 'act_'
    fn += str(nIterations) + 'rep_'
    fn += str(min(Alpha)) + '-' + str(max(Alpha)) + '_alpha'
    fn += str(min(Betas)) + '-' + str(max(Betas)) + '_beta'
    fn += str(min(Gamma)) + '-' + str(max(Gamma)) + '_gamma'
    fn += '_' + bin_type
    return fn

''' ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ MAIN ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ '''
'''~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'''

t0 = time.time()

if len(sys.argv) < 5:
    print 'Usage: python modelFitForward.py   N   C  u[r]|s[r]  B\n' \
          'N = number of iterations for averaging\n'\
          'C = number of max transactions to consider (min = 16, max = 107)\n' \
          'u = uniform risk distribution [r] random\n' \
          's = skewed  risk distribution [r] random\n' \
          'B = number of bins'

elif int(sys.argv[2]) < 16 or int(sys.argv[2]) > 107:
    print 'C = number of max transactions to consider (min = 16, max = 107)'

elif sys.argv[3] not in ['u', 'ur', 's', 'sr']:
    print 'Use one of the following risk distribution options:\n' \
          'u = uniform risk distribution [r] random\n' \
          's = skewed  risk distribution [r] random'

elif int(sys.argv[4]) != 3:
    print 'use 3 bins, other configuration to be implemented in next versions'

else:

    ''' SETUP '''
    HTAN_SIGMA = 500
    Alpha = [0.1, 0.25, 0.5, 0.75, 1]
    Betas = [10, 20, 30, 40]
    Gamma = [0.01, 0.25, 0.5, 0.75, 0.999]

    nIterations = int(sys.argv[1])
    CAP = int(sys.argv[2])
    bin_type = sys.argv[3]
    nStates  = 3
    nActions = int(sys.argv[4])  # number of bins is the same of number of actions
    total_sell_trans = dict()

    warnings.simplefilter("error", RuntimeWarning)

    # Read the stocks previously classified according to their risk
    stock_risk = read_stock_file(bin_type, nActions)

    # connect to DB
    db = DatabaseHandler('localhost', 'root', 'root', 'virtualtrader')

    # retrieve players
    db_players = db.select_players('transactions')
    players = sorted(filter_players(db_players, '../../data/players_threshold.txt'))

    print
    print 'Version history \n' \
          '1.3.0 rearranged database code in self contained class\n' \
          '1.2.5 adapt code to new bins\n' \
          '1.2.4 extend beta to 40 and raise poor threshold to 60k\n' \
          '1.2.3 capping transactions at CAP (not needed to revert to greedy?)\n' \
          '1.2.2 fixed bugs\n' \
          '1.2.0 softmax reverts to greedy in case of numerical issues\n' \
          '1.1.8 investigating numerical issues\n' \
          '1.1.7 reduce beta to 15\n' \
          '1.1.6 extend beta to 20\n' \
          '1.1.5 extend beta to 10\n' \
          '1.1.4 extend beta to 5\n' \
          '1.1.3 fixed new_total for buy bug\n' \
          '1.1.2 fixed bug of stock risk classification\n' \
          '1.1.1 timing of process\n' \
          '1.1.0 gamma is back\n' \
          '1.0.2 beta range printed on save file\n' \
          '1.0.1 testing scopes ' \
          '1.0.0 migrated to GitHub\n' \
          '0.8.2 printing player id together with name\n' \
          '0.8.1 number of iteration to be passed as parameter when running from command line \n' \
          '0.8.0 restricted the range of param alpha max=1\n' \
          '0.7.9 widened the range of parameters\n' \
          '0.7.8 pruned players with less than 15 actions \n' \
          '0.7.7 back to 3 actions, rearranged code \n' \
          '0.7.6 created a separate function for printing MLEs to console \n' \
          '0.7.5 counting the total transactions \n' \
          '0.7.4 stocks classified in 5 bins (5 actions)\n' \
          '0.7.3 pruned players with less than 8 actions \n' \
          '0.7.2 saving 1000 iterations \n' \
          '0.7.1 fixed bug in update rule (gamma = 0 not 1) \n' \
          '0.7.0 reward through custom hyperbolic tangent function \n'

    print 'nIterations', nIterations
    print 'total players: ' + str(len(players))

    # data structure that contains the MLEs
    MLEs = dict()
    for p in players:
        MLEs[p] = dict()
        for a in Alpha:
            MLEs[p][a] = dict()
            for b in Betas:
                MLEs[p][a][b] = dict()

    randomMLEs = dict()

    for player in players:
        ti = time.time()

        print '\n' + str(players.index(player)) + ' : ' + str(player)
        # RL set-up
        money = 100000
        state = 1

        # retrieve the transactions for each player
        transactions = db.select_transactions('transactions', player)
        # store the stocks purchased for future estimation of reward
        portfolio = dict()

        for alpha in Alpha:
            for beta in Betas:
                for gamma in Gamma:

                    avgMLE = 0
                    avg_correct_actions = 0

                    for iteration in xrange(nIterations):

                        Q = [[0 for x in xrange(nActions)] for x in xrange(nStates)]
                        tempMLE = 0
                        actionsAmount = 0
                        correct_actions = 0

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
                                    price       = float(transaction[6])
                                    total       = float(transaction[7])

                                    if 'Buy' in a_type and stock:
                                        # save the stocks that have been purchased
                                        if stock in portfolio:
                                            old_volume = portfolio[stock][0]
                                            old_price  = portfolio[stock][1]
                                            old_total  = portfolio[stock][2]
                                            new_volume = volume + old_volume
                                            new_price  = (total + old_total) / (volume + old_volume)
                                            new_total  = old_total + total
                                            portfolio[stock] = (new_volume, new_price, new_total)
                                        else:
                                            portfolio[stock] = (volume, price, total)

                                        # deduct money spent to purchase stock
                                        # (+ sign because the sign of the total is negative for purchases)
                                        money += total

                                        next_state = get_next_state(money, portfolio)

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

                                            # if all shares for the stock have been sold delete stock from portfolio
                                            # otherwise update the values (new_volume, old_price, new_total)
                                            new_volume = old_volume - volume
                                            if new_volume <= 0:
                                                del portfolio[stock]
                                            else:
                                                portfolio[stock] = (new_volume, old_price, new_volume * old_price)
                                                # old_price so it is possible to calculate margin for future sells

                                            # update money with gain/loss from sell
                                            money += total

                                            ''' SoftMax Action Selection '''
                                            terms = [0] * nActions
                                            for a in xrange(nActions):
                                                try:
                                                    terms[a] = np.exp(Q[state][a] * beta)
                                                except RuntimeWarning:

                                                    # print 'RuntimeWarning: ' \
                                                    #      'overflow encountered at transaction', actionsAmount
                                                    for act in xrange(nActions):
                                                        terms[a] = np.exp(beta * (Q[state][act] - max(Q[state])))
                                                    # print 'terms calculated with max normalisation', terms

                                                # the following raises except only if the previous try raises except
                                                denominator = sum(terms)
                                                terms = np.true_divide(terms, denominator)

                                            tempMLE, MLEaction = select_action(tempMLE)

                                            if tempMLE == 0:
                                                print 'Breaking because of prob(' + str(MLEaction) + ') =' \
                                                      + str(terms[MLEaction])
                                                break

                                            ''' softmax end '''

                                            # select the action really picked by player
                                            action = stock_risk[stock]

                                            # Precision calculation (counting correctly predicted actions)
                                            if MLEaction == action:
                                                correct_actions += 1

                                            next_state = get_next_state(money, portfolio)

                                            ''' Qvalues update '''
                                            TD_error = (reward + (gamma * max(Q[next_state])) - Q[state][action])
                                            Q[state][action] += alpha * TD_error

                                            state = next_state

                        total_sell_trans[player] = actionsAmount
                        avg_correct_actions += correct_actions
                        avgMLE += tempMLE

                    avg_correct_actions /= nIterations
                    avgMLE /= nIterations
                    avgMLE = -avgMLE
                    randMLE = - actionsAmount * log(1 / nActions)
                    randomMLEs[player] = randMLE

                    precision = avg_correct_actions / actionsAmount

                    MLEs[player][alpha][beta][gamma] = (avgMLE, precision, actionsAmount)

        print str(actionsAmount) + ' transactions '

        print str((time.time() - ti) / 60) + ' minutes'

    db.close()

    # printMLEs()

    save_filename = build_filename()
    # TODO  remove NEW from filename
    saveMLEs('results/results_NEW' + save_filename + '.csv')

    print 'total: ' + str((time.time() - t0) / 60) + ' minutes'

# counting transactions
# temp = 0
# for p in total_sell_trans:
#    temp += total_sell_trans[p]
# print temp

''' OLD SOFTMAX

#TODO divide all terms by highest (normalise only in case of numerical issues)
terms = [0] * nActions

overflow = False
for a in xrange(nActions):
    try:
        terms[a] = np.exp(Q[state][a] * beta)
    except RuntimeWarning:
        print 'action n:', actionsAmount
        print '\nRuntimeWarning'
        terms[a] = np.exp(709)
        overflow = True

if not overflow:
    try:
        terms = np.true_divide(terms, sum(terms))
    except RuntimeWarning:
        print
        print 'terms', terms
        print 'Q[state]', Q[state]

    tempMLE, MLEaction = select_action(tempMLE)

else:
    MLEaction = int(Q[state].index(max(Q[state])))
    # print 'iteration', iteration
    # print 'transaction', actionsAmount
    # print 'Q[state]', Q[state]
    # print 'MLEaction', MLEaction
    # print 'terms', terms
    if terms[MLEaction] > 0:
        tempMLE += log(terms[MLEaction])
    else:
        tempMLE = 0
#if tempMLE < 0:
    # print 'MLE minore di 0         <<<<<<<<<<<<<'
    # print 'iteration', iteration
    # print 'transaction', actionsAmount
    # print 'Q[state]', Q[state]
    # print 'MLEaction', MLEaction
    # print 'terms', terms

if tempMLE == 0:
    print 'MLE maggiore di 0       >>>>>>>>>>>>>>'
    raw_input('Breaking because of terms(' + str(MLEaction) + ') =' + str(terms[MLEaction]))
    break
'''
