
player_stock_distribution = dict()

with open('../../data/player_9_transactions_risks_test.txt', 'r') as stock_distributions:

    current_ranking = ''

    for line in stock_distributions:
        line = line.strip()  # remove trailing newline

        # if the line is not a stock but a title instantiate a key,value pair in the dict using the string as a key
        if not line[0].isdigit():
            current_ranking = line
            player_stock_distribution[current_ranking] = dict()
        else:
            line = line.split(' ')
            player_stock_distribution[current_ranking][line[1]] = line[0]

    for rank, item in player_stock_distribution.items():
        counts = [0, 0, 0]
        print '--->', str(rank)
        for k, value in item.iteritems():
            print value + ' ' + k
            value = int(value)
            if value == 0:
                counts[0] += 1
            elif value == 1:
                counts[1] += 1
            elif value == 2:
                counts[2] += 1

        print counts
        print
