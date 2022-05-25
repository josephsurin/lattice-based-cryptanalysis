import os, sys
sys.path.append(os.path.join(os.path.dirname(__file__), '../..'))

from lbc_toolkit import partial_key_exposure_rsa


if __name__ == '__main__':

    print('Toy partial key exposure attack on RSA with delta = 0.51 and gamma = 0.12')
    delta, gamma = 0.51, 0.12
    p, q = 176625123334760631807715191322442026027, 295300086877458905325818370978330175487
    N = p * q
    phi = (p - 1) * (q - 1)
    d_ = 524984144780305290164299581053414094497
    e = int(pow(d_, -1, phi))
    g = int(gamma * log(N, 2))
    d0 = (d_ >> g) << g
    print(f'  Given {d_.nbits() - g}/{d_.nbits()} MSB of d:', d0)
    d = partial_key_exposure_rsa(N, e, d0, delta, gamma)
    print('  Actual d:', d_)
    print('  Found  d:', d)

    print()

    print('Partial key exposure attack on RSA with delta = 0.62 and gamma = 0.1')
    delta, gamma = 0.62, 0.1
    p, q = random_prime(2^512), random_prime(2^512)
    N = p * q
    phi = (p - 1) * (q - 1)
    while True:
        d_ = randint(1, floor(N^delta))
        if gcd(d_, phi) == 1:
            break
    e = int(pow(d_, -1, phi))
    g = int(gamma * log(N, 2))
    print(f'  Given {d_.bit_length() - g}/{d_.bit_length()} MSB of d')
    d0 = (d_ >> g) << g
    d = partial_key_exposure_rsa(N, e, d0, delta, gamma)
    print('  Actual d:', d_)
    print('  Found  d:', d)
