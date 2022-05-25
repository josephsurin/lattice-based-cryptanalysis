import os, sys
sys.path.append(os.path.join(os.path.dirname(__file__), '../..'))

from lbc_toolkit import ecdsa_nonce_hash_xor_privkey


if __name__ == '__main__':

    p = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f 
    a, b = 0, 7
    n = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141
    E = EllipticCurve(GF(p), [a, b])
    G = E(0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, 0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8)

    ell = 3
    print(f'ECDSA k = z ⊕ d attack with ell = {ell}')
    Z, R, S = [], [], []
    d_ = randrange(1, n)
    for i in range(ell):
        z = randrange(1, n)
        k = d_ ^^ z
        X = k * G
        r = int(X.xy()[0]) % n
        s = pow(k, -1, n) * (z + r * d_) % n
        Z.append(ZZ(z)); R.append(ZZ(r)); S.append(ZZ(s))
    d = ecdsa_nonce_hash_xor_privkey(Z, R, S, n)
    print('  Actual solution:', d_)
    print('  Found  solution:', d)
