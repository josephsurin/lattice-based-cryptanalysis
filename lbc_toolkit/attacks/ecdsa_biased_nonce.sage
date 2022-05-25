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
    A = [ZZ(pow(2, n.nbits() - l, n) * t - pow(s, -1, n) * z % n) for s, z, t in zip(S, Z, T)]
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
