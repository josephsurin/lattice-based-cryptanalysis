import os, sys
sys.path.append(os.path.join(os.path.dirname(__file__), '../..'))

from lbc_toolkit import ecdsa_biased_nonce_zero_msb, ecdsa_biased_nonce_zero_lsb, ecdsa_biased_nonce_known_msb, ecdsa_biased_nonce_shared_msb


if __name__ == '__main__':

    p = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f 
    a, b = 0, 7
    n = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141
    E = EllipticCurve(GF(p), [a, b])
    G = E(0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, 0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8)

    l, ell = 30, 10
    print(f'ECDSA biased nonce zero MSB attack with l = {l}, ell = {ell}')
    Z, R, S = [], [], []
    d_ = randrange(1, n)
    for i in range(ell):
        z = randrange(1, n)
        k = randrange(1, 2^(n.nbits() - l))
        X = k * G
        r = int(X.xy()[0]) % n
        s = pow(k, -1, n) * (z + r * d_) % n
        Z.append(ZZ(z)); R.append(ZZ(r)); S.append(ZZ(s))
    d = ecdsa_biased_nonce_zero_msb(Z, R, S, n, l)
    print('  Actual solution:', d_)
    print('  Found  solution:', d)

    print()

    l, ell = 15, 25
    print(f'ECDSA biased nonce zero LSB attack with l = {l}, ell = {ell}')
    Z, R, S = [], [], []
    d_ = randrange(1, n)
    for i in range(ell):
        z = randrange(1, n)
        k = randrange(1, 2^(n.nbits() - l)) << l
        X = k * G
        r = int(X.xy()[0]) % n
        s = pow(k, -1, n) * (z + r * d_) % n
        Z.append(ZZ(z)); R.append(ZZ(r)); S.append(ZZ(s))
    d = ecdsa_biased_nonce_zero_lsb(Z, R, S, n, l)
    print('  Actual solution:', d_)
    print('  Found  solution:', d)

    print()

    l, ell = 17, 17
    print(f'ECDSA biased nonce known MSB attack with l = {l}, ell = {ell}')
    Z, R, S, T = [], [], [], []
    d_ = randrange(1, n)
    for i in range(ell):
        z = randrange(1, n)
        t = randrange(1, 2^l)
        k = 2^(n.nbits() - l) * t + randrange(1, 2^(n.nbits() - l))
        X = k * G
        r = int(X.xy()[0]) % n
        s = pow(k, -1, n) * (z + r * d_) % n
        Z.append(ZZ(z)); R.append(ZZ(r)); S.append(ZZ(s)); T.append(ZZ(t))
    d = ecdsa_biased_nonce_known_msb(Z, R, S, T, n, l)
    print('  Actual solution:', d_)
    print('  Found  solution:', d)

    print()

    l, ell = 18, 18
    print(f'ECDSA biased nonce shared MSB attack with l = {l}, ell = {ell}')
    Z, R, S = [], [], []
    d_ = randrange(1, n)
    t = randrange(1, 2^l)
    for i in range(ell):
        z = randrange(1, n)
        k = 2^(n.nbits() - l) * t + randrange(1, 2^(n.nbits() - l))
        X = k * G
        r = int(X.xy()[0]) % n
        s = pow(k, -1, n) * (z + r * d_) % n
        Z.append(ZZ(z)); R.append(ZZ(r)); S.append(ZZ(s))
    d = ecdsa_biased_nonce_shared_msb(Z, R, S, n, l)
    print('  Actual solution:', d_)
    print('  Found  solution:', d)
