import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../..'))

from functools import partial
from lbc_toolkit import bleichenbacher98


def oracle(d, c, N):
    m = pow(c, d, N)
    return int(m).to_bytes(N.nbits()//8, 'big').startswith(b'\x00\x02')


if __name__ == '__main__':

    print('Bleichenbacher98 attack (lattice version)')
    p, q = random_prime(2^192, lbound=2^191), random_prime(2^192, lbound=2^191)
    N = p * q
    e = 0x10001
    d = pow(e, -1, (p - 1) * (q - 1))
    m_ = randrange(1, N)
    c = ZZ(pow(m_, e, N))
    m = bleichenbacher98(N, e, c, partial(oracle, d), verbose=True)
    print('  Actual solution:', m_)
    print('  Found  solution:', m)
