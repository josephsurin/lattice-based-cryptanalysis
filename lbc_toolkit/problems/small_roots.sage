import itertools
from sage.rings.polynomial.multi_polynomial_sequence import PolynomialSequence


def small_roots(f, bounds, m=1, d=None, algorithm='groebner', lattice_reduction=None, verbose=False):
    r"""
    Returns the 'small' roots of the polynomial ``f`` where ``bounds`` specifies the
    roots' upper bounds. The algorithm implemented is Coppersmith's algorithm, using the
    strategy for shift polynomials as described in [1]. The code is heavily inspired
    by [2].

    Note that in some cases this algorithm may be used to find small roots of
    polynomials over the integers by choosing ``f`` to be an element of a polynomial ring
    whose base ring has characteristic much larger than ``f(*bounds)``. This algorithm
    may also be able to find small roots modulo a divisor of the polynomial's base ring
    characteristic.

    INPUT:

    - ``f`` -- A (multivariate) polynomial whose base ring is the integers modulo some ``N``.

    - ``bounds`` -- A tuple specifying the bounds on each small root of ``f``.

    - ``m`` -- The highest power of ``N`` to be used in the shift polynomials. (Default: 1)

    - ``d`` -- The number of variables to use for extra shifts. If ``None``, the degree of
    ``f`` is used. (Default: ``None``)

    - ``algorithm`` -- The technique used to solve the system of equations after the
    lattice reduction step. Must be one of 'groebner' or 'resultants' or else a ``ValueError``
    exception is raised.

    OUTPUT:

    A list of tuples containing all roots that were found. If no roots were found, the
    empty list is returned.

    REFERENCES:

    [1] Ellen Jochemsz and Alexander May. *A Strategy for Finding Roots of Multivariate Polynomials with New Applications in Attacking RSA Variants.*
    In Advances in Cryptology - ASIACRYPT 2006, p. 267--282. Springer, 2006.
    https://link.springer.com/chapter/10.1007/11935230_18

    [2] William Wang. *Coppersmith implementation.*
    https://github.com/defund/coppersmith
    """

    verbose = (lambda *a: print('[small_roots]', *a)) if verbose else lambda *_: None

    if algorithm not in ['groebner', 'resultants']:
        raise ValueError(f'"{algorithm}" is not a valid algorithm. Specify one of "groebner" or "resultants".')

    if d is None:
        d = f.degree()

    R = f.base_ring()
    N = R.cardinality()
    f_ = (f // f.lc()).change_ring(ZZ)
    f = f.change_ring(ZZ)
    l = f.lm()

    M = []
    for k in range(m+1):
        M_k = set()
        T = set((f^(m-k)).monomials())
        for mon in (f^m).monomials():
            if mon//l^k in T: 
                for extra in itertools.product(range(d), repeat=f.nvariables()):
                    g = mon * prod(map(power, f.variables(), extra))
                    M_k.add(g)
        M.append(M_k)
    M.append(set())

    shifts = PolynomialSequence([], f.parent())
    for k in range(m+1):
        for mon in M[k] - M[k+1]:
            g = mon//l^k * f_^k * N^(m-k)
            shifts.append(g)

    B, monomials = shifts.coefficient_matrix()
    monomials = vector(monomials)

    factors = [monomial(*bounds) for monomial in monomials]
    for i, factor in enumerate(factors):
        B.rescale_col(i, factor)

    verbose('Lattice dimensions:', B.dimensions())
    lattice_reduction_timer = cputime()
    if lattice_reduction:
        B = lattice_reduction(B.dense_matrix())
    else:
        B = B.dense_matrix().LLL()
    verbose(f'Lattice reduction took {cputime(lattice_reduction_timer):.3f}s')

    B = B.change_ring(QQ)
    for i, factor in enumerate(factors):
        B.rescale_col(i, 1/factor)
    B = B.change_ring(ZZ)

    H = PolynomialSequence([h for h in B*monomials if not h.is_zero()])

    if algorithm == 'groebner':
        groebner_timer = cputime()
        roots = solve_system_with_gb(H, list(f.variables()))
        verbose(f'Solving system with Groebner bases took {cputime(groebner_timer):.3f}s')
        return roots

    elif algorithm == 'resultants':
        resultants_timer = cputime()
        roots = solve_system_with_resultants(H, list(f.variables()))
        verbose(f'Solving system with resultants took {cputime(resultants_timer):.3f}s')
        if not roots:
            return []

        return [tuple(map(R, map(roots.__getitem__, f.variables())))]
