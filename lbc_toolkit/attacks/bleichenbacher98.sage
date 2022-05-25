def bleichenbacher98(N, e, c, O_B, verbose=False):
    _verbose = (lambda *a: print('[bb98]', *a)) if verbose else lambda *_: None

    NUM_QUERIES = 0
    l = N.nbits()

    ell = int(1.3 * l / 16)
    _verbose(f'Using ell = {ell} for N = {l} bits')

    R = []
    while len(R) < ell:
        r = randrange(1, N)

        NUM_QUERIES += 1
        if O_B(pow(r, e, N) * c % N, N):
            R.append(r)

            _verbose(f'Used {NUM_QUERIES} queries, have {len(R)} points')

    T = R
    B = 2^(l - 16)
    A = [2 * B] * ell
    m = hnp(N, T, A, B, verbose=verbose)

    return m
