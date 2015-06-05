import timeit


# my solution
def min_dot1(a, b):
    dot = 0
    while len(a) > 0:
        dot += a.pop(a.index(min(a))) * b.pop(b.index(max(b)))
    return dot


def min_dot2(a, b):
    return sum(x * y for (x, y) in zip(sorted(a), sorted(b, reverse = True)))


def min_dot3(a, b):
    return sum(map(int.__mul__, sorted(a), sorted(b)[::-1]))


def min_dot4(a, b):
    if a and b:
        return sum(map(lambda x, y: x * y, sorted(a, reverse=True), sorted(b)))
    return 0

print(timeit.timeit('min_dot1([1,3,5,4,7,3], [4,-2,1,7,3,9])', 'from __main__ import min_dot1', number=1000000))
print(timeit.timeit('min_dot2([1,3,5,4,7,3], [4,-2,1,7,3,9])', 'from __main__ import min_dot2', number=1000000))
print(timeit.timeit('min_dot3([1,3,5,4,7,3], [4,-2,1,7,3,9])', 'from __main__ import min_dot3', number=1000000))
print(timeit.timeit('min_dot4([1,3,5,4,7,3], [4,-2,1,7,3,9])', 'from __main__ import min_dot4', number=1000000))

