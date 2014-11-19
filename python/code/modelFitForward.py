from __future__ import division
import os
import sys
import MySQLdb
import random
import numpy as np
from datetime import datetime
from math import log
import warnings

''' ---- FUNCTIONS ---- '''

def get_next_state(wealth, pfolio):
    # at the end of each player trial check the total amount of money
    for s in pfolio:
        # add total value of remaining stocks to money
        # (- because sign of total in portfolio is negative for assets)
        wealth -= float(pfolio[s][2])

    if wealth < 50000:
        next_state = 0  #poor
        #print "poor"
    elif wealth <= 100000:
        next_state = 1  #mid
        #print "mid"
    elif wealth > 100000:
        next_state = 2  #rich
        #print "rich" 

    return next_state


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

def filter_players(all_players,threshold_file):
    t_players =  [line.rstrip('\n') for line in open(threshold_file,'r')]
    return list(set(all_players).intersection(set(t_players)))

def select_transactions(table, name, cursor, db):
    # retrieve all transactions for each player
    query = 'SELECT *  FROM '  + table + ' WHERE name="' + str(name) + '"' + 'ORDER BY date, type'
    try:
        cursor.execute(query)
    except MySQLdb.Error, e:
        print "Error in QUERY", query
        raw_input("press any key to continue")
    db.commit()
    player_transactions = cursor.fetchall()
    return player_transactions

def select_action(tempMLE):
    random_dice = random.random()

    if random_dice < prob_t[0]:
        MLEaction = 0
    elif prob_t[0] <= random_dice < (prob_t[0] + prob_t[1]):
        MLEaction = 1
    else:
        MLEaction = 2

    if prob_t[MLEaction] > 0:
        tempMLE += log(prob_t[MLEaction])
    else:
        tempMLE = 0


    return tempMLE, MLEaction


def saveMLEs(fileName):

    comma = ' , '
    outFile = open(fileName,'w')
    for n in sorted(MLEs):
        outFile.write(str(players.index(n)) + comma + comma + comma + str(randomMLEs[n]) + comma + str(1/nActions) + comma + str(MLEs[n][1][0.1][2]) + '\n')
        for a in sorted(MLEs[n]):
            for b in sorted(MLEs[n][a]):
                #print 'MLE['+str(players.index(n)) + '-' + str(n) + '][' + str(a) + '][' + str(b) + '] = ' + str(MLEs[n][a][b][0]) + ',' + str(MLEs[n][a][b][0]) + ',' + str(MLEs[n][a][b][2])
                outFile.write(str(players.index(n)) + comma + str(a) + comma + str(b) + comma + str(MLEs[n][a][b][0]) + comma + str(MLEs[n][a][b][1]) + comma + str(MLEs[n][a][b][2]) + '\n')
    outFile.close()
    print 'saved in '+str(fileName)

def printMLEs():
    for player in MLEs:
        print player
        print randomMLEs[player]
        for a in MLEs[player]:
            for b in sorted(MLEs[player][a]):
                print '\t alpha: ' + str(a) + ' beta: ' + str(b) + ' MLE: '+str(MLEs[player][a][b][0]) + ' P: ' + str(MLEs[player][a][b][1])

def htan_custom(factor):
    return ( 1 - np.exp( - reward_base * factor )) / ( 1 + np.exp( - reward_base * factor ))

''' ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ MAIN ~~~~~~~~~~~~~~~~~~~~------~~~~~~~~~~~~~~~~~~~~ '''
'''~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'''

if len(sys.argv) < 2:
    print 'Usage: python modelFitForward.py N\n' \
          'N = number of iterations for averaging'

else:

    ''' SETUP '''
    Alpha = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1]
    #Betas = [0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.1]
    Betas = [0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]
    nIterations = int(sys.argv[1])
    nStates  = 3
    nActions = 3
    total_sell_trans = dict()


    warnings.simplefilter("error", RuntimeWarning)

    # Read the stocks previously classified according to their risk (3 bins)
    stock_risk = read_stock_file("../../data/risk_classified_stocks_"+str(nActions)+".txt")

    # connect to DB and get the cursor and the db
    cursor_and_db = connect_DB('localhost', 'root', 'root', 'virtualtrader')
    cursor = cursor_and_db[0]
    db     = cursor_and_db[1]

    # retrieve players
    players = sorted(filter_players(select_players('transactions', cursor, db),'players_threshold.txt'))

    print
    print 'Version history \n' \
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

    print 'nIterations',nIterations
    print 'total players: ' + str(len(players))

    # data structure that contains the MLEs
    MLEs = dict()
    for p in players:
        MLEs[p] = dict()
        for a in Alpha:
            MLEs[p][a] = dict()

    randomMLEs = dict()

    for player in players:

        print '\n' + str(players.index(player)) +' : '+ str(player)
        # RL set-up
        money = 100000
        state = 1


        # retrieve the transactions for each player
        transactions = select_transactions('transactions', player, cursor, db)

        # store the stocks purchased for future estimation of reward
        portfolio = dict()

        for alpha in Alpha:
            for beta in Betas:
                avgMLE = 0
                avg_correct_actions = 0

                for iteration in xrange(nIterations):

                    Q = [[0 for x in xrange(nActions)] for x in xrange(nStates)]
                    tempMLE = 0
                    randMLE = 0
                    actionsAmount = 0
                    correct_actions = 0
                    for transaction in transactions:


                        # get only buy/sell actions
                        if 'Buy' in transaction[3] or 'Sell' in transaction[3]:

                            name        = str(transaction[1])
                            date_string = str(transaction[2]).split(' ')[0].replace('-',' ')
                            date        = datetime.strptime(date_string,'%Y %m %d')
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
                                    new_price  = ((price * volume) + (old_volume * old_price)) / (volume + old_volume)
                                    new_total  = old_total + (price * volume)
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
                                    actionsAmount += 1
                                    old_volume = portfolio[stock][0]
                                    old_price  = portfolio[stock][1]
                                    old_total  = portfolio[stock][2]

                                    # the reward is the gain on the price times the number of shares sold
                                    reward_base = ((price - old_price) * volume)
                                    reward = htan_custom(1/500)

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
                                    prob_t = [0] * nActions

                                    for a in xrange(nActions):
                                        prob_t[a] = np.exp(Q[state][a] * beta)

                                    try:
                                        prob_t = np.true_divide(prob_t, sum(prob_t))
                                    except RuntimeWarning:
                                        print '----------------------------'
                                        print 'iteration',iteration
                                        print 'Q['+str(Q[state][action])+'] + '+str(alpha)+ ' * ('+str(reward) + ' - ' + 'Q['+str(state)+']['+str(action)+']'

                                        print 'player',player
                                        print 'state: ',state
                                        print 'action: ',action
                                        print 'Q[state][action]: ',Q[state][action]
                                        print 'exp(Q[s][a]): ',np.exp(Q[state][action])
                                        print 'prob_t: ',prob_t
                                        print 'sum(prob_t): ',sum(prob_t)
                                        raw_input('Value error:  alpha=' + str(alpha) + ' beta=' + str(beta))


                                    tempMLE,MLEaction = select_action(tempMLE)

                                    if tempMLE == 0:
                                        print 'Breaking because of prob('+str(MLEaction)+') =' + str(prob_t[MLEaction])
                                        break

                                    ''' softmax end '''

                                    # select the action really picked by player
                                    action = stock_risk[stock];

                                    # Precision calculation (counting correctly predicted actions)
                                    if MLEaction == action:
                                        correct_actions += 1

                                    next_state = get_next_state(money,portfolio);

                                    ''' Qvalues update '''
                                    #Q[state][action] = Q[state][action] + alpha * (reward + (gamma * max(Q[next_state]))  - Q[state][action])
                                    #print 'Q[state:'+str(state)+'][action:'+str(action)+']: ' + str(Q[state][action])
                                    Q[state][action] = Q[state][action] + alpha * (reward - Q[state][action])

                                    #print 'Q['+str(state)+','+str(action)+'] = Q['+str(state)+','+str(action)+'] + '+str(alpha)+'*('+str(reward)+'-Q['+str(state)+','+str(action)+'])'
                                    #print 'Q[state:'+str(state)+'][action:'+str(action)+']: ' + str(Q[state][action])
                                    #raw_input("iteration: "+str(iteration)+"  transaction: "+str(actionsAmount)+'\n')

                                    state = next_state

                    total_sell_trans[player] = actionsAmount
                    avg_correct_actions += correct_actions
                    avgMLE += tempMLE

                avg_correct_actions /= nIterations
                avgMLE /= nIterations
                avgMLE = -avgMLE
                randMLE = - actionsAmount * log(1/nActions)
                randomMLEs[player] = randMLE

                precision = avg_correct_actions/actionsAmount

                MLEs[player][alpha][beta] = (avgMLE,precision,actionsAmount)
        print str(actionsAmount) + ' transactions '

    close_DB()

    printMLEs()

    saveMLEs('results/results_'+str(nActions)+'act_'+str(nIterations)+'rep.csv')


    # counting transactions
    #temp = 0
    #for p in total_sell_trans:
    #    temp += total_sell_trans[p]
    #print temp