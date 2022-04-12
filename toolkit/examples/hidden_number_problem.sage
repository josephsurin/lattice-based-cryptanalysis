load('../problems/hidden_number_problem.sage')


def hnp_example():
    print('HNP Example')
    p, m, B = random_prime(2^512), 3, 2^180
    alpha = randrange(1, p)
    T = [randrange(1, p) for _ in range(m)]
    Beta = [randrange(0, B) for _ in range(m)]
    A = [(t * alpha - beta) % p for t, beta in zip(T, Beta)]
    sol = hnp(p, T, A, B, verbose=True)
    print('  Actual solution:', alpha)
    print('  Found  solution:', sol, end='\n\n')


def ehnp_example():
    pass


if __name__ == '__main__':
    hnp_example()
