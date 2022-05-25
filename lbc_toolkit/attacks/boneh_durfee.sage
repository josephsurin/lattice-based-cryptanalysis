def boneh_durfee(N, e, delta):
    P.<x, y> = PolynomialRing(ZZ)
    f = 1 + 2 * x * ((N + 1)//2 - y)
    roots = small_roots(f.change_ring(Zmod(e)), (floor(N^delta), floor(N^0.5)), algorithm='resultants', m=4, d=4)
    k, s = roots[0]
    ed = f(ZZ(k), ZZ(s))
    d = ed//e
    return d
