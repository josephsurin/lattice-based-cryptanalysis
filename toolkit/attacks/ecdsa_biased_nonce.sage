load('../problems/hidden_number_problem.sage')


def ecdsa_biased_nonce_zero_msb(Z, R, S, n, l):
    T = [ZZ(pow(s, -1, n) * r % n) for s, r in zip(S, R)]
    A = [ZZ(-pow(s, -1, n) * z % n) for s, z in zip(S, Z)]
    B = 2^(n.nbits() - l)
    d = hnp(n, T, A, B, verbose=True)
    return d


def ecdsa_biased_nonce_zero_lsb(Z, R, S, n, l):
    T = [ZZ(pow(2, -l, n) * pow(s, -1, n) * r % n) for s, r in zip(S, R)]
    A = [ZZ(-pow(2, -l, n) * pow(s, -1, n) * z % n) for s, z in zip(S, Z)]
    B = 2^(n.nbits() - l)
    d = hnp(n, T, A, B, verbose=True)
    return d


def ecdsa_biased_nonce_known_msb(Z, R, S, T, n, l):
    T_ = [ZZ(pow(s, -1, n) * r % n) for s, r in zip(S, R)]
    A = [ZZ(-pow(2, l, n) * t - pow(s, -1, n) * z % n) for s, z, t in zip(S, Z, T)]
    B = 2^(n.nbits() - l)
    d = hnp(n, T_, A, B, verbose=True)
    return d


def ecdsa_biased_nonce_shared_msb(Z, R, S, n, l):
    z1, r1, s1 = Z[0], R[0], S[0]
    T = [ZZ((pow(s, -1, n) * r - pow(s1, -1, n) * r1) % n) for s, r in zip(S[1:], R[1:])]
    A = [ZZ((pow(s1, -1, n) * z1 - pow(s, -1, n) * z) % n) for s, z in zip(S[1:], Z[1:])]
    B = 2^(n.nbits() - l)
    d = hnp(n, T, A, B, verbose=True)
    return d


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
        k = 2^l * t + randrange(1, 2^(n.nbits() - l))
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
        k = 2^l * t + randrange(1, 2^(n.nbits() - l))
        X = k * G
        r = int(X.xy()[0]) % n
        s = pow(k, -1, n) * (z + r * d_) % n
        Z.append(ZZ(z)); R.append(ZZ(r)); S.append(ZZ(s))
    d = ecdsa_biased_nonce_shared_msb(Z, R, S, n, l)
    print('  Actual solution:', d_)
    print('  Found  solution:', d)
