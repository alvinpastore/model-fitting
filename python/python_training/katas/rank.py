import timeit


def ranks1(b):
    a = list(b) # avoid -Input must not be mutated- test fail ???
    res = [0] * len(a)
    curr_rank = 1
    while curr_rank < len(a)+1:
        indexes = [i for i, val in enumerate(a) if val == max(a)]
        for idx in indexes:
            res[idx] = curr_rank
            a[idx] = min(a) - 1
        curr_rank += len(indexes)
    return res


def ranks2(results):
    ranks = {}
    for k, v in enumerate(sorted(results, reverse=True), start=1):
        if not v in ranks:
            ranks[v] = k
    return [ranks[i] for i in results]


def ranks3(a):
    print a
    sortA = sorted(a, reverse=True)
    print sortA
    return [sortA.index(s) + 1 for s in a]


#print ranks1([-3, -2, -5, -4, -6, 2, 1, 0, -1])
#print ranks2([-3, -2, -5, -4, -6, 2, 1, 0, -1])
print ranks3([-3, -2, -5, -4, -6, 2, 1, 0, -1])

#print(timeit.timeit('ranks1([-3, -2, -5, -4, -6, 2, 1, 0, -1])', 'from __main__ import ranks1', number=1000000))
#print(timeit.timeit('ranks2([-3, -2, -5, -4, -6, 2, 1, 0, -1])', 'from __main__ import ranks2', number=1000000))
#print(timeit.timeit('ranks3([-3, -2, -5, -4, -6, 2, 1, 0, -1])', 'from __main__ import ranks3', number=1000000))