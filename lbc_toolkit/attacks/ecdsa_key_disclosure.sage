def ecdsa_key_disclosure(dbar, n, Z, R, S, Kbar, Pi, Nu, Lambda, Mu):
    Alpha = [ZZ(r) for r in R]
    Rho = [[ZZ(-pow(2, Lambda[i][j], n) * S[i] % n) for j in range(len(Lambda[0]))] for i in range(len(Lambda))]
    Beta = [ZZ((S[i] * Kbar[i] - Z[i]) % n) for i in range(len(Z))]
    d = ehnp(dbar, n, Pi, Nu, Alpha, Rho, Mu, Beta, delta=1/10^12, verbose=True)
    return d
