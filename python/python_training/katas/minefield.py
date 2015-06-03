import timeit
from numpy import where, array


# my solution
def mineLocation1(field):
    return [field.index(max(field)), field[field.index(max(field))].index(max(max(field)))]


def mineLocation2(field):
    return [[field.index(row), row.index(1)] for row in field if row.count(1) == 1][0]


def mineLocation3(field):
    x, y = where(array(field) == 1)
    return [int(x), int(y)]


def mineLocation4(field):
    for (y, row) in enumerate(field):
        for (x, cell) in enumerate(row):
            if cell:
                return [y, x]


def mineLocation5(field):
    for subfield in field:
        if 1 in subfield: return [field.index(subfield), subfield.index(1)]


print (timeit.timeit('mineLocation1([[0,0],[0,0],[1,0]])', 'from __main__ import mineLocation1', number=1000000))
print (timeit.timeit('mineLocation2([[0,0],[0,0],[1,0]])', 'from __main__ import mineLocation2', number=1000000))
print (timeit.timeit('mineLocation3([[0,0],[0,0],[1,0]])', 'from __main__ import mineLocation3', number=1000000))
print (timeit.timeit('mineLocation4([[0,0],[0,0],[1,0]])', 'from __main__ import mineLocation4', number=1000000))
print (timeit.timeit('mineLocation5([[0,0],[0,0],[1,0]])', 'from __main__ import mineLocation5', number=1000000))