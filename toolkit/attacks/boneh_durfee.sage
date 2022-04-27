load('../problems/small_roots.sage')


def boneh_durfee(N, e, delta):
    P.<x, y> = PolynomialRing(ZZ)
    f = 1 + 2 * x * ((N + 1)//2 - y)
    roots = small_roots(f.change_ring(Zmod(e)), (floor(N^delta), floor(N^0.5)), algorithm='resultants', m=4, d=4)
    k, s = roots[0]
    ed = f(ZZ(k), ZZ(s))
    d = ed//e
    return d


if __name__ == '__main__':

    print('Boneh-Durfee attack with delta = 0.264')
    p, q = random_prime(2^512), random_prime(2^512)
    N = p * q
    phi = (p - 1) * (q - 1)
    delta = 0.264
    while True:
        d_ = randint(1, floor(N^delta))
        if gcd(d_, phi) == 1:
            break
    e = pow(d_, -1, phi)
    d = boneh_durfee(N, e, delta)
    print(  'Actual d:', d_)
    print(  'Found  d:', d)
