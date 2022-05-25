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
