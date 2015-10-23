import random
import time
import sys


def population_randomiser(n):
    pop = []
    for i in xrange(n):
        birth = random.randint(1900, 2000)
        pop.append((birth, random.randint(birth, 2000)))
    return pop

people = population_randomiser(100000)

people = sorted(people)

# find the year with the most number of people alive.
first = min(min(people))
end = max(max(people, key=lambda k: max(k)))

# SOLUTION 1 (Umberto)
t0 = time.time()
pop_vector = [0] * (end - first)

for p in people:
    for y in xrange(p[0], p[1]):
        pop_vector[y - first] += 1

print max(pop_vector)
print str((time.time() - t0)) + "sec"
print str(sys.getsizeof(pop_vector) + sys.getsizeof(y) + sys.getsizeof(p)) + "bytes"

# SOLUTION 2 (Alvin)
t1 = time.time()
highest = 0
alive = 0
birth_years = [x[0] for x in people]
death_years = [x[1] for x in people]

for year_idx in xrange(first, end):
    alive += birth_years.count(year_idx)
    alive -= death_years.count(year_idx)

    if alive > highest:
        highest = alive

print highest
print str((time.time() - t1)) + "sec"
print str(sys.getsizeof(birth_years) + sys.getsizeof(death_years) + sys.getsizeof(alive) + sys.getsizeof(highest) +
          sys.getsizeof(year_idx)) + "bytes"