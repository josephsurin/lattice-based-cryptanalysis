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
        raise ValueError('Expected number of t_i to equal number of a_i.')

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


def ehnp():
    pass
