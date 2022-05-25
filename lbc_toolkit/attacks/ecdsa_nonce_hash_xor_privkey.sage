def ecdsa_nonce_hash_xor_privkey(Z, R, S, n):
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
