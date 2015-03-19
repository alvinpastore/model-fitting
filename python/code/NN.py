__author__ = 'alvin'
import matplotlib.pyplot as plt
import gzip
import cPickle
import numpy as np

with gzip.open('mnist.pkl.gz', 'rb') as f:
    train_set, valid_set, test_set = cPickle.load(f)

for item in train_set:
    for vec in item:
        vec = np.reshape(vec, (28, 28))
        print vec
        print 'shape' + str(np.shape(vec))
        raw_input()
        plt.imshow(vec)
        raw_input()