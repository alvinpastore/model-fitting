from DatabaseHandler import DatabaseHandler
from datetime import datetime


def filter_players(all_players, threshold_file):
    t_players = [line.rstrip('\n') for line in open(threshold_file, 'r')]
    return list(set(all_players).intersection(set(t_players)))

# connect to DB
db = DatabaseHandler('localhost', 'root', 'root', 'virtualtrader')

# retrieve players
db_players = db.select_players('transactions')
players = sorted(filter_players(db_players, '../../data/players_threshold.txt'))

filename = '../../data/player_transaction_outcomes.csv'
transaction_outcomes = open(filename, 'w')

CAP = 25

for player in players:


    # retrieve the transactions for each player
    transactions = db.select_transactions('transactions', player)

    transaction_outcomes.write(str(players.index(player)))

    # store the stocks purchased for future estimation of reward
    portfolio = dict()
    actionsAmount = 0
    profit = 0

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

                        transaction_outcomes.write(',' + str(reward_base))

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

    print str(players.index(player)) + ' : ' + str(player) + ' ' + str(profit)

    transaction_outcomes.write('\n')

transaction_outcomes.close()
