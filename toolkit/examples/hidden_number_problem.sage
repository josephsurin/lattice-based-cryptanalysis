load('../problems/hidden_number_problem.sage')


def hnp_example():
    print('HNP Example')
    p, m, B = random_prime(2^512), 3, 2^180
    _alpha = randrange(1, p)
    T = [randrange(1, p) for _ in range(m)]
    _Beta = [randrange(0, B) for _ in range(m)]
    A = [(t * _alpha - beta) % p for t, beta in zip(T, _Beta)]
    sol = hnp(p, T, A, B, verbose=True)
    print('  Actual solution:', _alpha)
    print('  Found  solution:', sol, end='\n\n')


def ehnp_2holes_example():
    print('HNP with Two Holes Example')
    p, d = random_prime(2^512), 4
    _x = randrange(1, p)
    xbar = 0
    Pi = [0]
    Nu = [512]
    Alpha = [randrange(1, p) for _ in range(d)]
    Rho = [[randrange(1, p), randrange(1, p)] for _ in range(d)]
    Mu = [[80, 100] for _ in range(d)]
    _K = [[randrange(1, 2^Mu[i][0]), randrange(1, 2^Mu[i][1])] for i in range(d)]
    Beta = [(alpha_i * _x + Rho_i[0] * K_i[0] + Rho_i[1] * K_i[1]) % p
            for alpha_i, Rho_i, K_i in zip(Alpha, Rho, _K)]
    sol = ehnp(xbar, p, Pi, Nu, Alpha, Rho, Mu, Beta, verbose=True)
    print('  Actual solution:', _x)
    print('  Found  solution:', sol, end='\n\n')


def ehnp_example():
    print('EHNP Example')
    p, d, m = random_prime(2^512), 5, 3
    _x = randrange(1, p)
    Pi = [0, 24, 140, 230]
    Nu = [16, 72, 56, 32]
    mask = 2^512 - 1 - sum(2^pi_j * (2^nu_j - 1) for pi_j, nu_j in zip(Pi, Nu))
    xbar = _x & mask
    Alpha = [randrange(1, p) for _ in range(d)]
    Rho = [[randrange(1, p) for _ in range(m)] for _ in range(d)]
    Mu = [[36, 52, 28] for _ in range(d)]
    _K = [[randrange(1, 2^mu_i_j) for mu_i_j in Mu_i] for Mu_i in Mu]
    Beta = [(alpha_i * _x + sum(rho_i_j * k_i_j for rho_i_j, k_i_j in zip(Rho_i, K_i))) % p
            for alpha_i, Rho_i, K_i in zip(Alpha, Rho, _K)]
    sol = ehnp(xbar, p, Pi, Nu, Alpha, Rho, Mu, Beta, verbose=True)
    print('  Actual solution:', _x)
    print('  Found  solution:', sol, end='\n\n')


if __name__ == '__main__':
    hnp_example()
    ehnp_2holes_example()
    ehnp_example()
