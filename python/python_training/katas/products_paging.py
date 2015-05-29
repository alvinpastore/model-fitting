from __future__ import division
import sys
import math

print "usage: products_paging total_prods prods_per_page"

total_products = int(sys.argv[1])
products_per_page = int(sys.argv[2])

total_pages = int(math.ceil(total_products / products_per_page))
products_last_page = total_products % products_per_page

for page_idx in xrange(total_pages):
    print "page", page_idx

    initial_value = str((products_per_page * page_idx) + 1)  # e.g. first page is (10*0) + 1

    message = "Showing products " + initial_value + " to "

    if page_idx >= total_pages - 1:  # if on last page
        last_value = str((products_per_page * page_idx) + products_last_page)
    else:
        last_value = str((products_per_page * (page_idx + 1)))

    message += last_value
    print message

    raw_input("\n")
