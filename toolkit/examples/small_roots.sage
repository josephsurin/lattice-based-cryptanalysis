from sage.modules.free_module_integer import IntegerLattice
load('../problems/small_roots.sage')


def univariate_example():
    print('Univariate Example')
    N = random_prime(2^512) * random_prime(2^512)
    bounds = (floor(N^0.31), )
    roots = tuple(randrange(bound) for bound in bounds)
    P.<x> = PolynomialRing(Zmod(N), 1)
    monomials = [x, x^2, x^3]
    f = sum(randrange(N) * monomial for monomial in monomials)
    f -= f(*roots)
    sol = small_roots(f, bounds, m=9, verbose=True)
    print('  Actual solution:', roots)
    print('  Found  solution:', sol, end='\n\n')


def bivariate_example():
    print('Bivariate Example')
    N = random_prime(2^512) * random_prime(2^512)
    bounds = (floor(N^0.16), floor(N^0.16))
    roots = tuple(randrange(bound) for bound in bounds)
    P.<x, y> = PolynomialRing(Zmod(N))
    monomials = [x, y, x*y, x^2, y^2]
    f = sum(randrange(N) * monomial for monomial in monomials)
    f -= f(*roots)
    sol = small_roots(f, bounds, m=2, algorithm='resultants', verbose=True)
    print('  Actual solution:', roots)
    print('  Found  solution:', sol, end='\n\n')


def integers_example():
    print('Integers Example')
    N = random_prime(2^512)
    bounds = (floor(N^0.32), floor(N^0.32))
    roots = tuple(randrange(bound) for bound in bounds)
    P.<x, y> = PolynomialRing(ZZ)
    monomials = [x, y, x*y, x^2]
    f = sum(randrange(N) * monomial for monomial in monomials)
    f -= f(*roots)
    assert f(*bounds) < N^2
    P.<x, y> = PolynomialRing(Zmod(N^2))
    sol = small_roots(P(f), bounds, verbose=True)
    print('  Actual solution:', roots)
    print('  Found  solution:', sol, end='\n\n')


def divisor_modulus_example():
    print('Divisor Modulus Example')
    p, q = random_prime(2^512), random_prime(2^512)
    N = p * q
    bounds = (floor(N^0.06), floor(N^0.06))
    roots = tuple(randrange(bound) for bound in bounds)
    P.<x, y> = PolynomialRing(Zmod(N))
    monomials = [x, y]
    f = sum(randrange(N) * monomial for monomial in monomials)
    f += p - f(*roots)
    sol = small_roots(f, bounds, m=2, d=4, algorithm='resultants', verbose=True)
    print('  Actual solution:', roots)
    print('  Found  solution:', sol, end='\n\n')


if __name__ == '__main__':
    univariate_example()
    bivariate_example()
    integers_example()
    divisor_modulus_example()
