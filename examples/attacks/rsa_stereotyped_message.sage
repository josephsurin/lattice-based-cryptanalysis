import os, sys
sys.path.append(os.path.join(os.path.dirname(__file__), '../..'))

from lbc_toolkit import rsa_stereotyped_message, rsa_stereotyped_message_multi


if __name__ == '__main__':

    print('Simple RSA stereotyped message example')
    N = 318110533564846846327681562969806306267050757360741
    e = 3
    c = 312332738778608882264230787188876936416561274050341
    m_known = int.from_bytes(b'my secret pin is \x00\x00\x00\x00', 'big')
    x = rsa_stereotyped_message(N, e, c, m_known, 2^32)
    print(f'  Recovered secret pin:', int(x).to_bytes(4, 'big').decode())

    print()

    print('RSA stereotyped message with two holes example')
    N = random_prime(2^292) * random_prime(2^292)
    e = 3
    m = int.from_bytes(b'my four letter username is zxcv and my secret four digit pin code is 1337', 'big')
    c = pow(m, e, N)
    m_known = int.from_bytes(b'my four letter username is \x00\x00\x00\x00 and my secret four digit pin code is \x00\x00\x00\x00', 'big')
    Xs = (2^32, 2^32)
    ts = [42*8, 0]
    x = rsa_stereotyped_message_multi(N, e, c, m_known, Xs, ts)
    print(f'  Recovered username:', int(x[0]).to_bytes(4, 'big').decode())
    print(f'  Recovered secret pin:', int(x[1]).to_bytes(4, 'big').decode())
