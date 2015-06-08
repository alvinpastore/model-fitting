import timeit
import sys


# my solution (fastest)
def in_array1(array1, array2):
    return sorted({w1 for w2 in array2 for w1 in array1 if w1 in w2})


def in_array2(array1, array2):
    return sorted(list(set([s1 for s1 in array1 for s2 in array2 if s1 in s2])))


def in_array3(array1, array2):
    # your code
    res = []
    for a1 in array1:
        for a2 in array2:
            if a1 in a2 and not a1 in res:
                res.append(a1)
    res.sort()
    return res


def in_array4(a1, a2):
    return sorted({sub for sub in a1 if any(sub in s for s in a2)})


n = int(sys.argv[1])

print timeit.timeit('in_array1(["cod", "code", "wars", "ewar", "ar"],["lively", "alive", "harp", "sharp", "armstrong", "codewars"])',
                    'from __main__ import in_array1',number=n)
print timeit.timeit('in_array2(["cod", "code", "wars", "ewar", "ar"],["lively", "alive", "harp", "sharp", "armstrong", "codewars"])',
                    'from __main__ import in_array2',number=n)
print timeit.timeit('in_array3(["cod", "code", "wars", "ewar", "ar"],["lively", "alive", "harp", "sharp", "armstrong", "codewars"])',
                    'from __main__ import in_array3',number=n)
print timeit.timeit('in_array4(["cod", "code", "wars", "ewar", "ar"],["lively", "alive", "harp", "sharp", "armstrong", "codewars"])',
                    'from __main__ import in_array4',number=n)