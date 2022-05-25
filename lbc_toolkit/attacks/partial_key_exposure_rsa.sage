def partial_key_exposure_rsa(N, e, d0, delta, gamma):
    P.<x, y> = PolynomialRing(ZZ)
    k0 = (e * d0) // N
    f = 1 + 2 * (x + k0) * ((N + 1)//2 - y)
    bounds = (floor(N^max(gamma, delta - 0.5)), floor(N^0.5))
    roots = small_roots(f.change_ring(Zmod(e)), bounds, algorithm='resultants', m=3, d=3)
    k, s = roots[0]
    ed = f(ZZ(k), ZZ(s))
    d = ed//e
    return d
