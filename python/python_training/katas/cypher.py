import random
import timeit
import operator


def encode1(string):
    return "".join([map2[map1.index(c)] if c in map1 else c for c in string])


def decode1(string):
    return "".join([map1[map2.index(c)] if c in map1 else c for c in string])


def encode2(string):
    return "".join(map(lambda x:map2[map1.index(x)] if x in map1 else x, string))


def decode2(string):
    return "".join(map(lambda x:map1[map2.index(x)] if x in map1 else x, string))

map1 = "abcdefghijklmnopqrstuvwxyz"
map2 = "etaoinshrdlucmfwypvbgkjqxz"

print(timeit.timeit('encode1("dfliuskhfbaohafuhavofdhasvfs")', 'from __main__ import encode1, map1, map2', number=1000000))
print(timeit.timeit('encode2("dfliuskhfbaohafuhavofdhasvfs")', 'from __main__ import encode2, map1, map2', number=1000000))

print(timeit.timeit('decode1("dfliuskhfbaohafuhavofdhasvfs")', 'from __main__ import decode1, map1, map2', number=1000000))
print(timeit.timeit('decode2("dfliuskhfbaohafuhavofdhasvfs")', 'from __main__ import decode2, map1, map2', number=1000000))