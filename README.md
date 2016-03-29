# model-fitting model-based

Python main routine

Usage: python model_fit_model_based.py   N   C  u[rX]|s[rX]  B  t  S

          N = number of iterations for averaging
          C = number of max transactions to consider (min = 16, max = 107)
          u = uniform risk distribution [r] random
          s = skewed  risk distribution [r] random
          X = random file number
          B = number of bins
          t = type of risk classification [risk|beta|std]
          S = number of states (2 or 3 for this version, 3 needs implementing)
          
