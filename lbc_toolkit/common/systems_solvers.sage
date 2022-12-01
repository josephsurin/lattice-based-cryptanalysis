from sage.rings.polynomial.multi_polynomial_sequence import PolynomialSequence


# TODO: error handling when solution doesn't exist
def solve_system_with_resultants(H, vs):
    if len(vs) == 1:
        for h in (h for h in H if h != 0):
            roots = h.univariate_polynomial().roots()
            if roots and roots[0][0] != 0:
                return { h.variable(): roots[0][0] }
    else:
        v = min(vs, key=lambda v: sum(h.degree(v) for h in H))
        H_ = [H[i].resultant(H[i+1], v) for i in range(len(vs) - 1)]
        vs.remove(v)
        roots = solve_system_with_resultants(H_, vs)
        H_ = [h.subs(roots) for h in H]
        roots |= solve_system_with_resultants(H_, [None])
        return roots


def solve_system_with_gb(H, vs):
    H_ = PolynomialSequence([], H[0].parent().change_ring(QQ))
    for h in H:
        H_.append(h)
        I = H_.ideal()
        if I.dimension() == -1:
            H_.pop()
        elif I.dimension() == 0:
            roots = []
            for root in I.variety(ring=ZZ):
                root = tuple(H[0].parent().base_ring()(root[var]) for var in vs)
                roots.append(root)
            return roots


# From https://gist.github.com/hyunsikjeong/0c26e83bb37866f5c7c6b8918a854333
def solve_system_with_jacobian(H, f, bounds, iters=100, prec=200):
    vs = list(f.variables())
    n = f.nvariables()
    x = f.parent().objgens()[1]
    x_ = [var(str(vs[i])) for i in range(n)]
    for ii in Combinations(range(len(H)), k=n):
        f = symbolic_expression([H[i](x) for i in ii]).function(x_)
        jac = jacobian(f, x_)
        v = vector([t // 2 for t in bounds])
        for _ in range(iters):
            kwargs = {str(vs[i]): v[i] for i in range(n)}
            try:
                tmp = v - jac(**kwargs).inverse() * f(**kwargs)
            except ZeroDivisionError:
                return None
            v = vector((numerical_approx(d, prec=prec) for d in tmp))
        v = [int(_.round()) for _ in v]
        if H[0](v) == 0:
            return tuple(v)
    return None
