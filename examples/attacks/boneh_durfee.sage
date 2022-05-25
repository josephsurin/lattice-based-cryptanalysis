import os, sys
sys.path.append(os.path.join(os.path.dirname(__file__), '../..'))

from lbc_toolkit import boneh_durfee


if __name__ == '__main__':

    print('Boneh-Durfee attack with delta = 0.264')
    p, q = random_prime(2^512), random_prime(2^512)
    N = p * q
    phi = (p - 1) * (q - 1)
    delta = 0.264
    while True:
        d_ = randint(1, floor(N^delta))
        if gcd(d_, phi) == 1:
            break
    e = pow(d_, -1, phi)
    d = boneh_durfee(N, e, delta)
    print(  'Actual d:', d_)
    print(  'Found  d:', d)
