import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../..'))

from lbc_toolkit import ecdsa_key_disclosure

if __name__ == '__main__':

    p = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f 
    a, b = 0, 7
    n = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141
    E = EllipticCurve(GF(p), [a, b])
    G = E(0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, 0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8)

    ell = 4
    print(f'ECDSA key disclosure')
    Z, R, S, Kbar = [], [], [], []
    Lambda = [[0, 48, 96, 140] for _ in range(ell)]
    Mu = [[40, 40, 32, 96] for _ in range(ell)]

    d_ = randrange(1, n)
    for i in range(ell):
        z = randrange(1, n)
        k = randrange(1, n)
        X = k * G
        r = int(X.xy()[0]) % n
        s = pow(k, -1, n) * (z + r * d_) % n
        Z.append(ZZ(z)); R.append(ZZ(r)); S.append(ZZ(s))

        mask = 2^256 - 1 - sum(2^lambda_j * (2^mu_j - 1) for lambda_j, mu_j in zip(Lambda[i], Mu[i]))
        kbar = k & mask
        Kbar.append(kbar)

    Pi = [0, 12, 30, 74]
    Nu = [10, 16, 24, 108]
    mask = 2^256 - 1 - sum(2^pi_j * (2^nu_j - 1) for pi_j, nu_j in zip(Pi, Nu))
    dbar = d_ & mask

    d = ecdsa_key_disclosure(dbar, n, Z, R, S, Kbar, Pi, Nu, Lambda, Mu)
    print('  Actual solution:', d_)
    print('  Found  solution:', d)
