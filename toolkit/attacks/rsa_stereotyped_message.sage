load('../problems/small_roots.sage')


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


if __name__ == '__main__':

    print('Simple RSA stereotyped message example')
    N = 318110533564846846327681562969806306267050757360741
    e = 3
    c = 312332738778608882264230787188876936416561274050341
    m_known = int.from_bytes(b'my secret pin is \x00\x00\x00\x00', 'big')
    x = rsa_stereotyped_message(N, e, c, m_known, 2^32)
    print(f'  Recovered secret pin:', int(x).to_bytes(4, 'big').decode())

    print()

    print('RSA stereotyped message with two holes example')
    N = random_prime(2^292) * random_prime(2^292)
    e = 3
    m = int.from_bytes(b'my four letter username is zxcv and my secret four digit pin code is 1337', 'big')
    c = pow(m, e, N)
    m_known = int.from_bytes(b'my four letter username is \x00\x00\x00\x00 and my secret four digit pin code is \x00\x00\x00\x00', 'big')
    Xs = (2^32, 2^32)
    ts = [42*8, 0]
    x = rsa_stereotyped_message_multi(N, e, c, m_known, Xs, ts)
    print(f'  Recovered username:', int(x[0]).to_bytes(4, 'big').decode())
    print(f'  Recovered secret pin:', int(x[1]).to_bytes(4, 'big').decode())
