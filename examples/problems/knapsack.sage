import os, sys
sys.path.append(os.path.join(os.path.dirname(__file__), '../..'))

from sage.modules.free_module_integer import IntegerLattice

from lbc_toolkit import subset_sum


def subset_sum_example():
    print('Subset Sum Example')
    U, n = 2^64, 40
    weights = [randint(0, U) for _ in range(n)]
    e = [randint(0, 1) for _ in range(n)]
    target = sum([e * a for e, a in zip(e, weights)])
    sol = subset_sum(weights, target, verbose=True)
    assert sol
    assert target == sum([e * a for e, a in zip(sol, weights)])
    print('  Actual solution:', e)
    print('  Found  solution:', sol, end='\n\n')


def modular_subset_sum_example():
    print('Modular Subset Sum Example')
    U, M, n = 2^80, 2^80, 64
    weights = [randint(0, U) for _ in range(n)]
    e = [randint(0, 1) for _ in range(n)]
    target = sum([e * a for e, a in zip(e, weights)]) % M
    sol = subset_sum(weights, target, modulus=M, lattice_reduction=lambda B: IntegerLattice(B).BKZ(block_size=30), verbose=True)
    assert sol
    assert target == sum([e * a for e, a in zip(sol, weights)]) % M
    print('  Actual solution:', e)
    print('  Found  solution:', sol, end='\n\n')


def multiple_subset_sum_example():
    print('Multiple Subset Sum Example')
    U, k, n = 2^64, 4, 80
    weights = [[randint(0, U) for _ in range(n)] for _ in range(k)]
    e = [randint(0, 1) for _ in range(n)]
    targets = [sum([e * a for e, a in zip(e, W)]) for W in weights]
    sol = subset_sum(weights, targets, verbose=True)
    assert sol
    assert all(targets[j] == sum([e * a for e, a in zip(sol, weights[j])]) for j in range(k))
    print('  Actual solution:', e)
    print('  Found  solution:', sol, end='\n\n')


def multiple_modular_subset_sum_example():
    print('Multiple Modular Subset Sum Example')
    U, M, k, n = 2^80, 2^80, 6, 100
    weights = [[randint(0, U) for _ in range(n)] for _ in range(k)]
    e = [randint(0, 1) for _ in range(n)]
    targets = [sum([e * a for e, a in zip(e, W)]) % M for W in weights]
    sol = subset_sum(weights, targets, modulus=M, verbose=True)
    assert sol
    assert all(targets[j] == sum([e * a for e, a in zip(sol, weights[j])]) % M for j in range(k))
    print('  Actual solution:', e)
    print('  Found  solution:', sol, end='\n\n')


if __name__ == '__main__':
    subset_sum_example()
    modular_subset_sum_example()
    multiple_subset_sum_example()
    multiple_modular_subset_sum_example()
