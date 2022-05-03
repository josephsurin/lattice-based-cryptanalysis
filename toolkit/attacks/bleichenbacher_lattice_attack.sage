from functools import partial
load('../problems/hidden_number_problem.sage')


def oracle(d, c, N):
    m = pow(c, d, N)
    return int(m).to_bytes(N.nbits()//8, 'big').startswith(b'\x00\x02')


def bleichenbacher_lattice_attack(N, e, c, O_B):
    NUM_QUERIES = 0
    l = N.nbits()

    ell = int(1.3 * l / 16)
    print(f'  Using ell = {ell}')

    R = []
    while len(R) < ell:
        r = randrange(1, N)

        NUM_QUERIES += 1
        if O_B(pow(r, e, N) * c % N, N):
            R.append(r)

            print(f'  Used {NUM_QUERIES} queries, have {len(R)} points')

    T = R
    B = 2^(l - 16)
    A = [2 * B] * ell
    m = hnp(N, T, A, B, verbose=True)

    return m


if __name__ == '__main__':

    print('Bleichenbacher attack (lattice version)')
    p, q = random_prime(2^512, lbound=2^511), random_prime(2^512, lbound=2^511)
    N = p * q
    e = 0x10001
    d = pow(e, -1, (p - 1) * (q - 1))
    m_ = randrange(1, N)
    c = ZZ(pow(m_, e, N))
    m = bleichenbacher_lattice_attack(N, e, c, partial(oracle, d))
    print('  Actual solution:', m_)
    print('  Found  solution:', m)
