import timeit


# my solution
def presses1(phrase):
    layout = [['1'],['a','b','c','2'],['d','e','f','3'],
              ['g','h','i','4'],['j','k','l','5'],['m','n','o','6'],
              ['p','q','r','s','7'],['t','u','v','8'],['w','x','y','z','9'],
              ['*'],[' ','0'],['#']]
    return sum(sum((key.index(c)+1) for key in layout if c in key) for c in phrase.lower())


def presses2(phrase):
    BUTTONS = [ '1',   'abc2',  'def3',
          'ghi4',  'jkl5',  'mno6',
          'pqrs7', 'tuv8', 'wxyz9',
            '*',   ' 0',    '#'   ]

    return sum(1 + button.find(c) for c in phrase.lower() for button in BUTTONS if c in button)


# my solution improved (learn nested loops inline)
def presses3(phrase):
    layout = [ '1',   'abc2',  'def3',
          'ghi4',  'jkl5',  'mno6',
          'pqrs7', 'tuv8', 'wxyz9',
            '*',   ' 0',    '#'   ]
    return sum((key.index(c)+1) for c in phrase.lower() for key in layout if c in key)


print(timeit.timeit("presses1('Alv1n P4store soluti0n hop3fully the be5t ever')","from __main__ import presses1", number=100000))
print(timeit.timeit("presses2('Alv1n P4store soluti0n hop3fully the be5t ever')","from __main__ import presses2", number=100000))
print(timeit.timeit("presses3('Alv1n P4store soluti0n hop3fully the be5t ever')","from __main__ import presses3", number=100000))