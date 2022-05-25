def rsa_stereotyped_message(N, e, c, m_known, X):
    P.<x> = PolynomialRing(Zmod(N), 1)
    f = (m_known + x)^e - c
    roots = small_roots(f, (X, ))
    x0 = roots[0][0]
    return x0


def rsa_stereotyped_message_multi(N, e, c, m_known, Xs, ts):
    assert len(Xs) == len(ts)
    P = PolynomialRing(Zmod(N), [f'x{i}' for i in range(len(Xs))])
    x_vars = P.gens()
    f = (m_known + sum(2^t * x_vars[i] for i, t in enumerate(ts)))^e - c
    roots = small_roots(f, Xs, algorithm='resultants')
    return roots[0]
