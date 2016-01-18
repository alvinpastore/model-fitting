from __future__ import division
import sys
import random
import numpy as np
from datetime import datetime
import time
from math import log, sqrt
import warnings
from DatabaseHandler import DatabaseHandler
''' ---- FUNCTIONS ---- '''


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


def read_stock_file(b_type, b_amount):
    file_number = -1
    path = "../../data/" + results_subfolder + "_classified_stocks/" + str(b_amount) + "/"
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


def select_action(temporaryMLE):
    random_dice = random.random()

    bin_idx = 0
    term_idx = 0

    while term_idx < nActions:
        bin_idx += terms[term_idx]

        if random_dice < bin_idx:
            MLE_act = term_idx
            break

        term_idx += 1

    if terms[MLE_act] > 0:
        temporaryMLE += log(terms[MLE_act])
    else:
        temporaryMLE = 0

    return temporaryMLE, MLE_act


def saveMLEs(fileName):
    comma = ' , '
    out_file = open(fileName, 'w')
    for nth in sorted(MLEs):
        out_file.write(str(players.index(nth)) + comma
                       + '0' + comma
                       + '0' + comma
                       + '0' + comma
                       + str(randomMLEs[nth]) + comma
                       + '0' + comma
                       + str(1 / nActions * 100) + comma
                       + '0' + comma
                       + str(MLEs[nth][min(Alpha)][min(Betas)][min(Gamma)][4]) + '\n')
        
        for a in sorted(MLEs[nth]):
            for b in sorted(MLEs[nth][a]):
                for g in sorted(MLEs[nth][a][b]):

                    # print 'MLE[' + str(players.index(n)) + '-' + str(n) + '][' + str(a) + '][' + str(b) + '] = ' + \
                    #       str(MLEs[n][a][b][0]) + ',' + str(MLEs[n][a][b][0]) + ',' + str(MLEs[n][a][b][2])

                    out_file.write(str(players.index(nth)) + comma + str(a) + comma + str(b) + comma + str(g) +
                                   comma + str(MLEs[nth][a][b][g][0]) +        # MLE
                                   comma + str(MLEs[nth][a][b][g][1]) +        # MLE stdev
                                   comma + str(MLEs[nth][a][b][g][2]) +        # Prec
                                   comma + str(MLEs[nth][a][b][g][3]) +        # Stdev
                                   comma + str(MLEs[nth][a][b][g][4]) + '\n')  # actionsAmount

    out_file.close()
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


def htan_custom(xx, factor):
    return (1 - np.exp(- xx * factor)) / (1 + np.exp(- xx * factor))


def build_filename():
    fn = str(CAP) + 'cap_'
    fn += str(nActions) + 'act_'
    fn += str(nIterations) + 'rep_'
    fn += str(min(Alpha)) + '-' + str(max(Alpha)) + '_alpha'
    fn += str(min(Betas)) + '-' + str(max(Betas)) + '_beta'
    fn += str(min(Gamma)) + '-' + str(max(Gamma)) + '_gamma'
    fn += '_' + bin_type
    return fn


def load_parameters(file_name):
    abg = []
    with open(file_name, 'r') as configuration:
        for line in configuration:
            if line[0] != '#':
                line = map(float, line.rstrip().split('=')[1].split(','))
                abg.append(line)
    return abg

''' ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ MAIN ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ '''
'''~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'''

t0 = time.time()

if len(sys.argv) < 6:
    print 'Usage: python modelFitForward.py   N   C  u[rX]|s[rX]  B  t  S\n' \
          'N = number of iterations for averaging\n'\
          'C = number of max transactions to consider (min = 16, max = 107)\n' \
          'u = uniform risk distribution [r] random\n' \
          's = skewed  risk distribution [r] random\n' \
          'X = random file number\n' \
          'B = number of bins\n' \
          't = type of risk classification [risk|beta|std]' \
          'S = number of states (2 or 3 for this version, 3 needs implementing)'

elif int(sys.argv[2]) < 16 or int(sys.argv[2]) > 107:
    print 'C = number of max transactions to consider (min = 16, max = 107)'

elif sys.argv[3].strip("0123456789") not in ['u', 'ur', 's', 'sr']:
    print 'Use one of the following risk distribution options:\n' \
          'u = uniform risk distribution [r] random\n' \
          's = skewed  risk distribution [r] random\n' \
          'X = file number (ur0, ur1, ur...)'

else:

    ''' SETUP '''
    HTAN_REWARD_SIGMA = 500
    Alpha, Betas, Gamma = load_parameters('fitting.cfg')

    nIterations = int(sys.argv[1])
    CAP = int(sys.argv[2])
    bin_type = sys.argv[3]
    nActions = int(sys.argv[4])
    nStates  = int(sys.argv[6])

    results_subfolder = sys.argv[5]

    warnings.simplefilter("error", RuntimeWarning)

    # Read the stocks previously classified according to their risk
    stock_risk = read_stock_file(bin_type, nActions)
    # connect to DB
    db = DatabaseHandler('localhost', 'root', 'root', 'virtualtrader')

    # retrieve players
    db_players = db.select_players('transactions')
    players = sorted(filter_players(db_players, '../../data/players_threshold.txt'))

    print
    '''
    print 'Version history \n' \
          '4.0.0 fixed bug (new_volume * old_price changes the sign of the total). added negative sign\n' \
          '3.4.0 parameters are loaded from fitting.cfg configuration file\n' \
          '3.3.1 saving precision in % directly (to keep consistency with stdev)\n' \
          '3.3.0 calculating variance on the go and storing it in the csv\n' \
          'current columns: id, alpha, beta, gamma, MLE, Precision mean, Precision std, transactions amount\n' \
          '3.2.0 number of states can be passed as parameter of the script, 3 states still needs developing\n' \
          '3.1.0 changed states to 3 as uniform discretisation of htan bound profit ]-1,+1[\n' \
          '3.0.0 changed states to 2 because money cannot be used as a proxy for states,\n' \
          'using accumulated reward as proxy for state discretisation (above 0 rich, below 0 poor)\n' \
          '2.0.0 fixed bug where money was not reset after iteration\n' \
          '1.6.0 fixed bug on actions selection (extended to nActions)\n' \
          '1.5.1 adapting code for 5 bins\n' \
          '1.5.0 adapting code for 4 bins\n' \
          '1.4.0 fixed bug of price (used to have only 2 decimal digits from crawling, now is calculated)\n' \
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
    '''
    print 'nIterations', nIterations
    print 'total players: ' + str(len(players))

    print "alphas " + str(Alpha) + "\nbetas " + str(Betas) + "\ngammas " + str(Gamma)

    # data structure that contains the MLEs
    MLEs = dict()
    for p in players:
        MLEs[p] = dict()
        for a in Alpha:
            MLEs[p][a] = dict()
            for b in Betas:
                MLEs[p][a][b] = dict()

    randomMLEs = dict()

    MLE_dist = open('results/' + results_subfolder + '_classified/MLE_' +
                    str(Gamma) + '_' + str(nIterations) + '_' + str(bin_type) + '.csv', 'w')

    for player in players:
        ti = time.time()

        print '\n' + str(players.index(player)) + ' : ' + str(player)

        # retrieve the transactions for each player
        transactions = db.select_transactions('transactions', player)

        # store the stocks purchased for future estimation of reward
        portfolio = dict()

        for alpha in Alpha:
            for beta in Betas:
                for gamma in Gamma:

                    avgMLE = 0
                    avg_correct_actions = 0

                    # running variance setup
                    # Knuth Welford
                    # https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Online_algorithm
                    n = 0
                    mean, MLE_mean = 0, 0
                    M2, MLE_M2 = 0, 0

                    MLE_dist.write('\n' + str(players.index(player)) + ', '
                                   + str(alpha) + ', '
                                   + str(beta)  + ', '
                                   + str(gamma) + ', ')

                    for iteration in xrange(nIterations):

                        # RL set-up
                        Q = [[0 for x in xrange(nActions)] for x in xrange(nStates)]
                        profit = 0
                        state = 1

                        # Measures set-up
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
                                                new_total = - (new_volume * old_price)
                                                # the asset (selling power) is still the old price
                                                # (which is the avg of all the buying prices normalised on the volumes)
                                                # times the new amount of stocks held

                                                portfolio[stock] = (new_volume, old_price, new_total)
                                                # old_price so it is possible to calculate margin for future sells

                                            # update profit with reward from sell
                                            profit += reward

                                            ''' SoftMax Action Selection  - - - - - - - - - - - - - - - - - -'''
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
                                                print 'Breaking because of prob(' + str(MLEaction) + ') = ' \
                                                      + str(terms[MLEaction])
                                                raw_input(terms)
                                                break

                                            ''' softmax end ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~'''

                                            # select the action really picked by player
                                            action = stock_risk[stock]

                                            # Precision calculation (counting correctly predicted actions)
                                            if MLEaction == action:
                                                correct_actions += 1

                                            next_state = get_next_state(profit)

                                            ''' Qvalues update '''
                                            TD_error = (reward + (gamma * max(Q[next_state])) - Q[state][action])
                                            Q[state][action] += alpha * TD_error

                                            state = next_state

                        avg_correct_actions += correct_actions
                        avgMLE += tempMLE

                        local_precision = correct_actions / actionsAmount * 100

                        # running variance calculations (for precision)
                        n += 1
                        delta = local_precision - mean
                        MLE_delta = tempMLE - MLE_mean

                        mean = mean + delta / n
                        MLE_mean = MLE_mean + MLE_delta / n

                        M2 = M2 + delta * (local_precision - mean)
                        MLE_M2 = MLE_M2 + MLE_delta * (tempMLE - MLE_mean)

                        MLE_dist.write(str(-tempMLE) + ', ')

                    MLE_dist.write('\n')

                    avgMLE /= nIterations
                    avgMLE = -avgMLE
                    randMLE = - actionsAmount * log(1 / nActions)
                    randomMLEs[player] = randMLE

                    precision = avg_correct_actions / (actionsAmount * nIterations) * 100
                    variance = M2 / n
                    std_dev = sqrt(variance)

                    MLE_variance = MLE_M2 / n
                    MLE_std_dev = sqrt(MLE_variance)

                    MLEs[player][alpha][beta][gamma] = (avgMLE, MLE_std_dev, precision, std_dev, actionsAmount)

        print str(actionsAmount) + ' transactions '

        print str((time.time() - ti) / 60) + ' minutes'

    db.close()
    MLE_dist.close()
    # printMLEs()

    save_filename = build_filename()
    saveMLEs('results/' + results_subfolder + '_classified/Negative_' + save_filename + '.csv')

    print 'total: ' + str((time.time() - t0) / 60) + ' minutes'
