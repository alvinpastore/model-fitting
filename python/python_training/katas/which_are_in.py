from collections import OrderedDict

def in_array1(array1, array2):
    res = []
    for w1 in array1:
        for w2 in array2:
            if w1 in w2:
                res.append(w1)
    return res


def in_array(array1, array2):
    return list(OrderedDict.fromkeys([w1 for w2 in array2 for w1 in array1 if w1 in w2]))

#[[w1 if w1 in w2 for w2 in a2] for w1 in a1]


a1 = ["live", "arp", "strong"]
a2 = ["lively", "alive", "harp", "sharp", "armstrong"]

a3 = ['cod', 'code', 'wars', 'ewar']
a4 = ['lively', 'alive', 'harp', 'sharp', 'armstrong', 'codewars']

r1 = ['arp', 'live', 'strong']
r2 = ['cod', 'code', 'ewar', 'wars']

print in_array(a3, a4)
print in_array(a3, a4) == r2
