from __future__ import division
import operator
import MySQLdb
import random
import numpy as np
from datetime import datetime
import time
from math import log
import warnings


def get_next_state(wealth, pfolio):
    # at the end of each player trial check the total amount of money
    for s in pfolio:
        # add total value of remaining stocks to money
        # (- because sign of total in portfolio is negative for assets)
        wealth -= float(pfolio[s][2])

    if wealth < 50000:
        nextState = 0  #poor
        #print "poor"
    elif wealth <= 100000:
        nextState = 1  #mid
        #print "mid"
    elif wealth > 100000:
        nextState = 2  #rich
        #print "rich"

    return nextState


def read_stock_file(path):
    stock_list_file = open(path, 'r')
    stocks = dict()
    risk_flag = 0
    separator = "risk class "
    for line in stock_list_file:
        if separator + str(0) in line:
            risk_flag = 0
        elif separator + str(1) in line:
            risk_flag = 1
        elif separator + str(2) in line:
            risk_flag = 2
        elif separator + str(3) in line:
            risk_flag = 3
        elif separator + str(4) in line:
            risk_flag = 4
        elif line.strip():
            stocks[line.split("~")[0]] = risk_flag

    stock_list_file.close()
    return stocks


def connect_DB(host, user, pw, database):
    # Open Database connection
    db = MySQLdb.connect(host=host, user=user, passwd=pw, db=database)
    cursor = db.cursor()
    return cursor, db


def close_DB():
    db.close()


def select_players(table, cursor, db):

    # Execute SQL query
    cursor.execute('SELECT DISTINCT name FROM ' + table + ' ORDER BY name')
    db.commit()
    results = cursor.fetchall()
    # get the list of names of the players
    names = []
    for r in results:
        names.append(r[0])
    return names


def filter_players(all_players,  threshold_file):
    t_players = [line.rstrip('\n') for line in open(threshold_file, 'r')]
    return list(set(all_players).intersection(set(t_players)))


def select_transactions(table, name, cursor, db):
    # retrieve all transactions for each player
    query = 'SELECT *  FROM '  + table + ' WHERE name="' + str(name) + '"' + 'ORDER BY date, type'
    try:
        cursor.execute(query)
    except MySQLdb.Error:
        print "Error in QUERY", query
        raw_input("press any key to continue")
    db.commit()
    player_transactions = cursor.fetchall()
    return player_transactions


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
    for n in sorted(analysed_players):
        outFile.write(str(players.index(n)) + comma + comma + comma + comma + str(randomMLEs[n]) + comma + str(1/nActions) + comma + str(MLEs[n][min(Alpha)][min(Betas)][min(Gamma)][2]) + '\n')
        for a in sorted(MLEs[n]):
            for b in sorted(MLEs[n][a]):
                for g in sorted(MLEs[n][a][b]):
                    #print 'MLE['+str(players.index(n)) + '-' + str(n) + '][' + str(a) + '][' + str(b) + '] = ' + str(MLEs[n][a][b][0]) + ',' + str(MLEs[n][a][b][0]) + ',' + str(MLEs[n][a][b][2])
                    outFile.write(str(players.index(n)) + comma + str(a) + comma + str(b) + comma + str(g) + comma + str(MLEs[n][a][b][g][0]) + comma + str(MLEs[n][a][b][g][1]) + comma + str(MLEs[n][a][b][g][2]) + '\n')
    outFile.close()
    print 'saved in ' + str(fileName)


def htan_custom(factor):
    return (1 - np.exp(- reward_base * factor)) / (1 + np.exp(- reward_base * factor))


def build_filename():
    fn = str(nActions) + 'act_'
    fn += str(nIterations) + 'rep_'
    fn += str(min(Alpha)) + '-' + str(max(Alpha)) + '_alpha'
    fn += str(min(Betas)) + '-' + str(max(Betas)) + '_beta'
    fn += str(min(Gamma)) + '-' + str(max(Gamma)) + '_gamma'
    fn += str()
    return fn

''' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '''
''' - - - - - - - - - - - - - -  MAIN  - - - - - - - - - - - - - -'''
''' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -'''

t0 = time.time()

resultsFile = open('results/results_3act_1000rep_0.1-1_alpha10-35_beta0.01-0.999_gamma.csv', 'r')

subset = {}

for i in xrange(0, 46):
    subset[i] = 0

for line in resultsFile:
    l = line.split(',')
    pid = int(l[0])
    if l[1].strip() is not '':
        subset[pid] += float(l[5])

for e in subset:
    subset[e] /= 150  # combinations of models (alphaAmount x gammaAmount x betaAmount)
    print subset[e]
player_subset = []
f_out = open('players_Prec_04.txt', 'w')
for p in subset:
    if subset[p] > 0.4:
        f_out.write(str(p) + '\n')
        player_subset.append(p)
f_out.close()

resultsFile.close()

print 'Players with avg prec > 0.4: ' + str(player_subset)

''' SETUP '''
Alpha = [0.1, 0.25, 0.5, 0.75, 1]
Betas = [10, 15, 20, 25, 30, 35]
Gamma = [0.01, 0.25, 0.5, 0.75, 0.999]

nIterations = 10000
CAP = 20
nStates  = 3
nActions = 3
total_sell_trans = dict()

warnings.simplefilter("error", RuntimeWarning)

# Read the stocks previously classified according to their risk (3 bins)
stock_risk = read_stock_file("../../data/risk_classified_stocks_" + str(nActions) + ".txt")

#for s in sorted(stock_risk):
#    print str(s) + ' ' + str(stock_risk[s])
#raw_input()

# connect to DB and get the cursor and the db
c_db = connect_DB('localhost', 'root', 'root', 'virtualtrader')
cursor = c_db[0]
db     = c_db[1]

# retrieve players
db_players = select_players('transactions', cursor, db)
players = sorted(filter_players(db_players, 'players_threshold.txt'))


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
analysed_players = []
for player in players:
    if players.index(player) in player_subset:
        analysed_players.append(player)
        print '\n' + str(players.index(player)) + ' : ' + str(player)
        # RL set-up
        money = 100000
        state = 1

        # retrieve the transactions for each player
        transactions = select_transactions('transactions', player, cursor, db)

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
                        #tindex = 0
                        for transaction in transactions:

                            # CAP transactions amount
                            if actionsAmount < CAP:

                                # get only buy/sell actions
                                if 'Buy' in transaction[3] or 'Sell' in transaction[3]:

                                    name        = str(transaction[1])
                                    date_string = str(transaction[2]).split(' ')[0].replace('-',' ')
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

                                        next_state = get_next_state(money,portfolio)

                                    elif 'Sell' in a_type and stock:

                                        if stock not in portfolio:
                                            print ':::::::::::::::::::::::::::::::::::::::::::::::'
                                            print player
                                            print 'stock', stock
                                            print 'portfolio', portfolio
                                            # messed up player
                                            break
                                        else:
                                            #print 'transaction',tindex
                                            #tindex+=1
                                            actionsAmount += 1
                                            old_volume = portfolio[stock][0]
                                            old_price  = portfolio[stock][1]
                                            old_total  = portfolio[stock][2]

                                            # the reward is the gain on the price times the number of shares sold
                                            reward_base = ((price - old_price) * volume)
                                            reward = htan_custom(1 / 500)

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
                                            '''
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

                                            ''' softmax end '''

                                            ''' SoftMax Action Selection '''
                                            terms = [0] * nActions

                                            for a in xrange(nActions):
                                                try:
                                                    terms[a] = np.exp(Q[state][a] * beta)
                                                except RuntimeWarning:
                                                    print 'action n:', actionsAmount
                                                    print '\nRuntimeWarning'
                                                    terms[a] = np.exp(709)

                                            try:
                                                terms = np.true_divide(terms, sum(terms))
                                            except RuntimeWarning:
                                                raw_input('Value error:  alpha=' + str(alpha) + ' beta=' + str(beta))

                                            tempMLE, MLEaction = select_action(tempMLE)

                                            if tempMLE == 0:
                                                print 'Breaking because of prob(' + str(MLEaction) + ') =' + str(terms[MLEaction])
                                                break

                                            ''' softmax end '''

                                            # select the action really picked by player
                                            action = stock_risk[stock]

                                            #print 'state',state
                                            #print 'real  a: ' + str(action)
                                            #print 'model a: ' + str(MLEaction)
                                            #raw_input()

                                            # Precision calculation (counting correctly predicted actions)
                                            if MLEaction == action:
                                                correct_actions += 1

                                            #if 'IJB01' in player:
                                                #print 'action',action
                                                #print 'MLEaction',MLEaction
                                                #raw_input()

                                            next_state = get_next_state(money, portfolio);

                                            ''' Qvalues update '''
                                            #print 'Q[state:'+str(state)+'][action:'+str(action)+']: ' + str(Q[state][action])

                                            Q[state][action] += alpha * (reward + (gamma * max(Q[next_state])) - Q[state][action])
                                            #Q[state][action] += alpha * (reward - Q[state][action])

                                            #print 'Q['+str(state)+','+str(action)+'] = Q['+str(state)+','+str(action)+'] + '+str(alpha)+'*('+str(reward)+'-Q['+str(state)+','+str(action)+'])'
                                            #print 'Q[state:'+str(state)+'][action:'+str(action)+']: ' + str(Q[state][action])
                                            #raw_input("iteration: "+str(iteration)+"  transaction: "+str(actionsAmount)+'\n')
                                            #print Q

                                            state = next_state

                        total_sell_trans[player] = actionsAmount
                        avg_correct_actions += correct_actions
                        avgMLE += tempMLE

                    avg_correct_actions /= nIterations
                    avgMLE /= nIterations
                    avgMLE = -avgMLE
                    #print avgMLE
                    randMLE = - actionsAmount * log(1 / nActions)
                    randomMLEs[player] = randMLE

                    precision = avg_correct_actions / actionsAmount

                    MLEs[player][alpha][beta][gamma] = (avgMLE, precision, actionsAmount)

        print str(actionsAmount) + ' transactions '
    print 'Player time: ' + str((time.time() - t0) / 60)
close_DB()

save_filename = build_filename()
saveMLEs('results/results_' + save_filename + '.csv')


print str((time.time() - t0)/ 60) + 'minutes'