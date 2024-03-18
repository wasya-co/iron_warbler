import scipy.stats
from numpy import sqrt, log, exp, pi


def bs_price(c_p, S, K, r, t, sigma):
    N = scipy.stats.norm.cdf
    d1 = (log(S/K) + (r+sigma**2/2)*t) / (sigma*sqrt(t))
    print( S/K, 'check 0')
    print( log(S/K), 'check 1')
    print('d1', d1)
    d2 = d1 - sigma * sqrt(t)
    print('d2', d2)

    if c_p == 'c':
        return N(d1) * S - N(d2) * K * exp(-r*t)
    elif c_p == 'p':
        return N(-d2) * K * exp(-r*t) - N(-d1) * S
    else:
        return "Please specify call or put options."

s = 884.0
k = 910.0
r = 0.08
t = 0.010951
sigma = 0.47
print( bs_price('c', s, k, r, t, sigma) )
