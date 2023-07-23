def hnp(p, T, A, B, lattice_reduction=None, verbose=False):
    r"""
    Returns the solution of the given hidden number problem instance. i.e. finds
    `\alpha \in [1, p - 1]` satisfying

    .. MATH::

        \beta_i - t_i \alpha + a_i \equiv 0 \pmod p

    where the `t_i` and `a_i` are given by ``T`` and ``A``, and the `\beta_i`
    are bounded above by ``B``.

    The implementation follows the algorithm as described in section 2.5 of [1].

    INPUT:

    - ``p`` -- The modulus `p` as described above.

    - ``T`` -- A list of integers representing the `t_i`.

    - ``A`` -- A list of integers representing the `a_i`.

    - ``B`` -- The upper bound on the `\beta_i` as described above.

    OUTPUT:

    The integer `\alpha` which is a solution to the HNP instance. If no solution
    could be found, None is returned.

    REFERENCES:

    [1] Martin R. Albrecht and Nadia Heninger. *On Bounded Distance Decoding with Predicate:
    Breaking the “Lattice Barrier” for the Hidden Number Problem.*
    In Lecture Notes in Computer Science, p. 528--558. Springer, 2021.
    https://link.springer.com/chapter/10.1007/978-3-030-77870-5_19
    """

    verbose = (lambda *a: print('[hnp]', *a)) if verbose else lambda *_: None

    if len(T) != len(A):
        raise ValueError(f'Expected number of t_i to equal number of a_i, but got {len(T)} and {len(A)}.')

    m = len(T)
    M = p * Matrix.identity(QQ, m)
    M = M.stack(vector(T))
    M = M.stack(vector(A))
    M = M.augment(vector([0] * m + [B / p] + [0]))
    M = M.augment(vector([0] * (m + 1) + [B]))
    M = M.dense_matrix()

    verbose('Lattice dimensions:', M.dimensions())
    lattice_reduction_timer = cputime()
    if lattice_reduction:
        M = lattice_reduction(M)
    else:
        M = M.LLL()
    verbose(f'Lattice reduction took {cputime(lattice_reduction_timer):.3f}s')

    for row in M:
        if row[-1] == -B:
            alpha = (row[-2] * p / B) % p
            if all((beta - t * alpha + a) % p == 0 for beta, t, a in zip(row[:m], T, A)):
                return alpha
        if row[-1] == B:
            alpha = (-row[-2] * p / B) % p
            if all((beta - t * alpha + a) % p == 0 for beta, t, a in zip(-row[:m], T, A)):
                return alpha

    return None


def ehnp(xbar, p, Pi, Nu, Alpha, Rho, Mu, Beta, delta=None, lattice_reduction=None, verbose=False):
    r"""
    Returns the solution of the given extended hidden problem instance. i.e. finds
    `x \in [1, p - 1]` satisfying

    .. MATH::
        
        x = \bar{x} + \sum_{j=1}^m 2^{\pi_j} x_j

    where `0 \leq x_j < 2^{\nu_j}`, and

    .. MATH::

        \alpha_i \sum_{j=1}^m 2^{\pi_j} x_j + \sum_{j=1}^{l_i} \rho_{i,j} k_{i,j} \equiv \beta_i - \alpha_i \bar{x} \pmod p

    for `1 \leq i \leq d` where the `k_{i,j}` also satisfy `0 \leq k_{i,j} < 2^{\mu_{i,j}}`.

    The implementation follows the algorithm as described in [1].

    INPUT:

    - ``xbar`` -- The known parts of `x` as described above.

    - ``p`` -- The modulus `p` as described above.

    - ``Pi`` -- A list of `m` integers representing the `\pi_j`.

    - ``Nu`` -- A list of `m` integers representing the `\nu_j`.

    - ``Alpha`` -- A list of `d` integers representing the `\alpha_i`.

    - ``Rho`` -- A list of `d` lists of integers (each with length `l_i`) representing
    the `\rho_{i,j}`.

    - ``Mu`` -- A list of `d` lists of integers (each with length `l_i`) representing
    the `\mu_{i,j}`.

    - ``Beta`` -- A list of `d` integers representing the `\beta_i`.

    - ``delta`` -- (optional) The `\delta` parameter used in lattice construction. See
    [1] for details on how to choose `\delta`. (Default: 1/10^8)

    OUTPUT:

    The integer `x` which is a solution to the EHNP instance. If no solution could
    be found, None is returned.

    REFERENCES:

    [1] Martin Hlaváč and Tomáš Rosa. *Extended Hidden Number Problem and Its Cryptanalytic Applications.*
    In Selected Areas in Cryptography, p. 114--133. Springer, 2007.
    https://link.springer.com/chapter/10.1007/978-3-540-74462-7_9
    """

    verbose = (lambda *a: print('[ehnp]', *a)) if verbose else lambda *_: None

    if len(Pi) != len(Nu):
        raise ValueError(f'Expected number of pi_j to equal number of nu_j, but got {len(Pi)} and {len(Nu)}.')

    if not (len(Alpha) == len(Rho) == len(Mu) == len(Beta)):
        raise ValueError('Expected number of alpha_i, rho lists, mu lists, beta_i to be the same, ' + \
                         f'but got {len(Alpha)}, {len(Rho)}, {len(Mu)}, {len(Beta)}.')

    for i, (Rho_i, Mu_i) in enumerate(zip(Rho, Mu)):
        if len(Rho_i) != len(Mu_i):
            raise ValueError(f'Expected number of rho_{i},j to equal number of mu_{i},j, ' + \
                             f'but got {len(Rho_i)} and {len(Mu_i)}')

    m = len(Pi)
    d = len(Alpha)
    L = sum(len(Rho_i) for Rho_i in Rho)
    D = d + m + L
    kappa = (2^(D / 4) * (m + L)^(1 / 2) + 1) / 2
    if not delta:
        delta = RR(1e-8 / kappa)

    verbose(f'kappa * delta = {(kappa * delta).n()}')
    if not 0 < kappa * delta < 1:
        raise ValueError(f'Expected kappa * delta to be between 0 and 1, but got {(kappa * delta).n()}.')

    A = Matrix([[alpha_i * 2^pi_j for alpha_i in Alpha] for pi_j in Pi])
    X = diagonal_matrix([delta / 2^nu_j for nu_j in Nu])
    R = block_diagonal_matrix([column_matrix(Rho_i) for Rho_i in Rho])
    K = diagonal_matrix(flatten([[delta / 2^mu_ij for mu_ij in Mu_i] for Mu_i in Mu]))

    B = block_matrix(QQ, [
        [p * identity_matrix(d), zero_matrix(d, m), zero_matrix(d, L)],
        [A,                      X,                 zero_matrix(m, L)],
        [R,                      zero_matrix(L, m), K],
    ])

    verbose('Lattice dimensions:', B.dimensions())
    lattice_reduction_timer = cputime()
    if lattice_reduction:
        B = lattice_reduction(B)
    else:
        B = B.LLL()
    verbose(f'Lattice reduction took {cputime(lattice_reduction_timer):.3f}s')

    w = [beta_i - alpha_i * xbar for alpha_i, beta_i in zip(Alpha, Beta)]
    w += [delta / 2] * (m + L)
    babai_cvp_timer = cputime()
    u = babai_cvp(B, vector(QQ, w), perform_reduction=False)
    verbose(f'Babai CVP solver took {cputime(babai_cvp_timer):.3f}s')

    x = xbar
    for j in range(m):
        x_j = u[d + j] * 2^Nu[j] / delta
        x += int(x_j) * 2^Pi[j]

    # TODO: Check if valid solution. -x might be returned instead.
    return x % p
