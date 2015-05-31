import random
import timeit
import operator

# my -sub sub optimal- solution
# def sort_dict(d):
#     res = []
#     keys = d.keys()
#     values = d.values()
#     while len(keys) > 0:
#         max_kv = values.index(max(values))
#         res.append((keys.pop(max_kv), values.pop(max_kv)))
#     return res


def sort_sorted(d):
    return sorted(d.items(), key=lambda x: x[1], reverse=True)


def sort_dict(d):
    return sorted(d.items(), key=(lambda x: x[1]))[::-1]


def sort_itemgetter(d):
    return sorted(d.items(), key=operator.itemgetter(1), reverse=True)

diz = {i: random.randint(1, 100) for i in xrange(100)}

print diz

print(timeit.timeit('sort_dict(diz)', 'from __main__ import sort_dict, diz', number=200000))
print(timeit.timeit('sort_sorted(diz)', 'from __main__ import sort_sorted, diz', number=200000))
print(timeit.timeit('sort_itemgetter(diz)', 'from __main__ import sort_itemgetter, diz', number=200000))