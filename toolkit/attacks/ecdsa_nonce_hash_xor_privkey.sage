load('../problems/knapsack.sage')


def ecdsa_nonce_hash_xor_privkey(Z, R, S, n):
    if not (len(Z) == len(R) == len(S)):
        raise ValueError(f'Expected number of z_i, r_i and s_i to be equal, but got {len(Z)}, {len(R)} and {len(S)}.')

    jth_bit = lambda x, j: (x >> j) & 1

    ell = len(Z)
    m = n.nbits()
    P = PolynomialRing(GF(n), [f'd{j}' for j in range(m)])
    d_bits = list(P.gens())
    d = sum(2^j * d_bits[j] for j in range(m))

    weights = []
    targets = []
    for i in range(ell):
        k_i = Z[i] + d - 2 * sum(2^j * jth_bit(Z[i], j) * d_bits[j] for j in range(m))
        eq = S[i] * k_i - (Z[i] + R[i] * d)
        coeffs = [c for c, _ in eq]
        weights.append([ZZ(x) for x in coeffs[:-1]])
        targets.append(-ZZ(coeffs[-1]))

    sol = subset_sum(weights, targets, n, verbose=True)
    d = int(''.join(map(str, sol))[::-1], 2)
    return d


if __name__ == '__main__':

    ell = 3
    print(f'ECDSA k = z ⊕ d attack with ell = {ell}')
    Z, R, S = [], [], []
    p = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f 
    a, b = 0, 7
    n = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141
    E = EllipticCurve(GF(p), [a, b])
    G = E(0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, 0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8)
    d_ = randrange(1, n)
    for i in range(ell):
        z = randrange(1, n)
        k = d_ ^^ z
        X = k * G
        r = int(X.xy()[0]) % n
        s = pow(k, -1, n) * (z + r * d_) % n
        Z.append(ZZ(z))
        R.append(ZZ(r))
        S.append(ZZ(s))
    d = ecdsa_nonce_hash_xor_privkey(Z, R, S, n)
    print('  Actual solution:', d_)
    print('  Found  solution:', d)
