# Documentation

* [Lattice-based Problems](#lattice-based-problems)
    * [subset_sum](#subset_sum)
    * [small_roots](#small_roots)
    * [hnp](#hnp)
    * [ehnp](#ehnp)
* [Lattice-based Attacks](#lattice-based-attacks)
    * [bleichenbacher98](#bleichenbacher98)
    * [boneh_durfee](#boneh_durfee)
    * [ecdsa_biased_nonce](#ecdsa_biased_nonce)
    * [ecdsa_key_disclosure](#ecdsa_key_disclosure)
    * [ecdsa_nonce_hash_xor_privkey](#ecdsa_nonce_hash_xor_privkey)
    * [partial_key_exposure_rsa](#partial_key_exposure_rsa)
    * [rsa_stereotyped_message](#rsa_stereotyped_message)
* [References](#references)

# Lattice-based Problems

Lattice-based problems are generic problems with some linear structure that makes them a good target for lattice reduction. They form the basis of many lattice attacks.

Each function takes an optional `lattice_reduction` argument which can be specified to use a different algorithm for lattice reduction. This argument should be a function which takes the lattice basis as its only argument and returns a reduced basis.

Each function also takes an optional `verbose` boolean argument which prints extra info if set to `True`.


## subset_sum

```py
subset_sum(weights, targets, modulus=None, N=None, lattice_reduction=None, verbose=False)
```

Finds the solution of the subset sum problem with the given `weights` and `targets`. Supports multiple knapsacks as well as the modular case with the `modulus` argument. The implementation follows the algorithm as described in [PZ16].

**Arguments:**

&nbsp;&nbsp;&bull;&nbsp; `weights` - A list of integer weights $a_1, \ldots, a_n$, or a list of lists $a_{1, 1}, \ldots, a_{k, n}$ for the multiple subset sum problem with $k$ different subset sums.

&nbsp;&nbsp;&bull;&nbsp; `targets` - The integer target $s$, or a list of targets $s_1, \ldots, s_j$ for the multiple subset sum problem case.

&nbsp;&nbsp;&bull;&nbsp; `modulus` - (optional) The modulus $M$.

&nbsp;&nbsp;&bull;&nbsp; `N` - (optional) The scaling factor $N$ as described in [PZ16]. (Default: $\lceil \sqrt{(n+1)/4} \rceil$)

**Returns:**

A solution to the given subset sum problem as a list representing the $e_i$ such that

$$
    \sum_{i=1}^n e_i a_{j, i} = s_j
$$

for all $1 \leq j \leq k$.



## small_roots

```py
small_roots(f, bounds, m=1, d=None, algorithm='groebner', lattice_reduction=None, verbose=False)
```

Finds the 'small' roots of the polynomial `f` where `bounds` specifies the roots' upper bounds. The algorithm implemented is Coppersmith's algorithm, using the strategy for shift polynomials as described in [JM06]. The code is heavily inspired by [Wan20].

Note that in some cases this algorithm may be used to find small roots of polynomials over the integers by choosing `f` to be an element of a polynomial ring whose base ring has characteristic much larger than `f(*bounds)`. This algorithm may also be able to find small roots modulo a divisor of the polynomial's base ring characteristic.

**Arguments:**

&nbsp;&nbsp;&bull;&nbsp; `f` - A (multivariate) polynomial whose base ring is the integers modulo some `N`.

&nbsp;&nbsp;&bull;&nbsp; `bounds` - A tuple specifying the bounds on each small root of `f`.

&nbsp;&nbsp;&bull;&nbsp; `m` - The highest power of `N` to be used in the shift polynomials. (Default: 1)

&nbsp;&nbsp;&bull;&nbsp; `d` - The number of variables to use for extra shifts. If `None`, the degree of `f` is used. (Default: `None`)

&nbsp;&nbsp;&bull;&nbsp; `algorithm` - The technique used to solve the system of equations after the lattice reduction step. Must be one of `'groebner'` or `'resultants'` or `'jacobian'` or else a `ValueError` exception is raised. (Default: `'groebner'`)

**Returns:**

A list of tuples containing all roots that were found. If no roots were found, the empty list is returned.



## hnp

```py
hnp(p, T, A, B, lattice_reduction=None, verbose=False)
```

Finds the solution of the given hidden number problem instance. i.e. finds $\alpha \in [1, p - 1]$ satisfying

$$
\beta_i - t_i \alpha + a_i = 0 \pmod p
$$

where the $t_i$ and $a_i$ are given by `T` and `A`, and the $\beta_i$ are bounded above by `B`.

The implementation follows the algorithm as described in section 2.5 of [AH21].

**Arguments:**

&nbsp;&nbsp;&bull;&nbsp; `p` - The modulus $p$ as described above.

&nbsp;&nbsp;&bull;&nbsp; `T` - A list of integers representing the $t_i$.

&nbsp;&nbsp;&bull;&nbsp; `A` - A list of integers representing the $a_i$.

&nbsp;&nbsp;&bull;&nbsp; `B` - The upper bound on the $\beta_i$ as described above.

**Returns:**

The integer $\alpha$ which is a solution to the HNP instance. If no solution could be found, `None` is returned.



## ehnp

```py
ehnp(xbar, p, Pi, Nu, Alpha, Rho, Mu, Beta, delta=None, lattice_reduction=None, verbose=False)
```

Finds the solution of the given extended hidden problem instance. i.e. finds $x \in [1, p - 1]$ satisfying

$$
x = \bar{x} + \sum_{j=1}^m 2^{\pi_j} x_j
$$

where $0 \leq x_j < 2^{\nu_j}$, and

$$
\alpha_i \sum_{j=1}^m 2^{\pi_j} x_j + \sum_{j=1}^{l_i} \rho_{i,j} k_{i,j} = \beta_i - \alpha_i \bar{x} \pmod p
$$

for $1 \leq i \leq d$ where the $k_{i,j}$ also satisfy $0 \leq k_{i,j} < 2^{\mu_{i,j}}$.

The implementation follows the algorithm as described in [HR07].

**Arguments:**

&nbsp;&nbsp;&bull;&nbsp; `xbar` - The known parts of $x$ as described above.

&nbsp;&nbsp;&bull;&nbsp; `p` - The modulus $p$ as described above.

&nbsp;&nbsp;&bull;&nbsp; `Pi` - A list of $m$ integers representing the $\pi_j$.

&nbsp;&nbsp;&bull;&nbsp; `Nu` - A list of $m$ integers representing the $\nu_j$.

&nbsp;&nbsp;&bull;&nbsp; `Alpha` - A list of $d$ integers representing the $\alpha_i$.

&nbsp;&nbsp;&bull;&nbsp; `Rho` - A list of $d$ lists of integers (each with length $l_i$) representing the $\rho_{i,j}$.

&nbsp;&nbsp;&bull;&nbsp; `Mu` - A list of $d$ lists of integers (each with length $l_i$) representing the $\mu_{i,j}$.

&nbsp;&nbsp;&bull;&nbsp; `Beta` - A list of $d$ integers representing the $\beta_i$.

&nbsp;&nbsp;&bull;&nbsp; `delta` - (optional) The $\delta$ parameter used in lattice construction. See [HR07] for details on how to choose $\delta$. (Default: `1e-8 / kappa`)

**Returns:**

The integer $x$ which is a solution to the EHNP instance. If no solution could be found, `None` is returned.



# Lattice-based Attacks

Lattice-based attacks are attacks using lattices against cryptographic constructions. The implementations of lattice-based attacks in this toolkit are mostly for illustrative purposes; the user should check by themself that the bounds are reasonable, otherwise the attack may fail.



## bleichenbacher98

```py
bleichenbacher98(N, e, c, O_B, verbose=False)
```

Performs the Bleichenbacher padding oracle attack on PKCS#1 v1.5 using the lattice approach as described in [Ngu09].

**Arguments:**

&nbsp;&nbsp;&bull;&nbsp; `N` - The RSA modulus.

&nbsp;&nbsp;&bull;&nbsp; `e` - The RSA public exponent.

&nbsp;&nbsp;&bull;&nbsp; `c` - The RSA ciphertext to decrypt.

&nbsp;&nbsp;&bull;&nbsp; `O_B` - A function which acts as the PKCS decryption oracle. This function should take a ciphertext as its only argument and return `True` or `False` if the ciphertext is PKCS conforming.

**Returns:**

The decryption of the ciphertext `c`.



## boneh_durfee

```py
boneh_durfee(N, e, delta)
```

Performs the Boneh-Durfee attack on RSA with low private exponent [BD99]. The upper bound is $d < N^{0.292}$, however this implementation may fail to achieve this bound as it uses a generic Coppersmith algorithm to find small roots instead of an optimised lattice.

**Arguments:**

&nbsp;&nbsp;&bull;&nbsp; `N` - The RSA modulus.

&nbsp;&nbsp;&bull;&nbsp; `e` - The RSA public exponent.

&nbsp;&nbsp;&bull;&nbsp; `delta` - The parameter which bounds the size of $d$. i.e. $d < N^{\delta}$.

**Returns:**

The RSA private exponent $d$.



## ecdsa_biased_nonce

```py
ecdsa_biased_nonce_zero_msb(Z, R, S, n, l)
ecdsa_biased_nonce_zero_lsb(Z, R, S, n, l)
ecdsa_biased_nonce_known_msb(Z, R, S, T, n, l)
ecdsa_biased_nonce_shared_msb(Z, R, S, n, l)
```

Implementation of a few different variations of attacks against (EC)DSA with biased nonces as described in [HS01]. The signatures satisfy the DSA equation

$$
s_i = k_i^{-1}(z_i + r_i d) \pmod n
$$

Given many messages $z_i$ and their signatures $(r_i, s_i)$ calculated with the biased nonces $k_i$, the private signing key $d$ may be recovered.

**Arguments:**

&nbsp;&nbsp;&bull;&nbsp; `Z` - A list of the message hashes $z_i$.

&nbsp;&nbsp;&bull;&nbsp; `R` - A list of the $r_i$.

&nbsp;&nbsp;&bull;&nbsp; `S` - A list of the $s_i$.

&nbsp;&nbsp;&bull;&nbsp; `n` - The modulus $n$.

&nbsp;&nbsp;&bull;&nbsp; `l` - The number of bits of bias.

In the `ecdsa_biased_nonce_known_msb` function, the argument `T` is the list of known MSBs of each $k_i$.

**Returns:**

The (EC)DSA private signing key $d$.



## ecdsa_key_disclosure

```py
ecdsa_key_disclosure(dbar, n, Z, R, S, Kbar, Pi, Nu, Lambda, Mu)
```

Solves the (EC)DSA key disclosure problem as described in [HR07]. This is a generalisation of the biased nonce situation in which we know many chunks of each $k_i$ as well as some chunks of the private signing key $d$. That is, we have

$$
  d = \bar{d} + \sum_{j=1}^m 2^{\pi_j} d_j, \quad 0 \leq d_j < 2^{\nu_j}
$$

$$
  k_i = \bar{k_i} + \sum_{j=1}^{l_i} 2^{\lambda_{i, j}} k_{i, j}, \quad 0 \leq k_{i, j} < 2^{\mu_{i, j}}
$$

where we know all of $\bar{d}, \nu_j, \bar{k_i}, \pi_j, \lambda_{i, j}$ and $\mu_{i, j}$.

Note that $0$ is a valid value for $\bar{d}$ (i.e. none of $d$ is known).

**Arguments:**

&nbsp;&nbsp;&bull;&nbsp; `dbar` - $\bar{d}$ as described above; the known parts of $d$.

&nbsp;&nbsp;&bull;&nbsp; `n` - The modulus $n$.

&nbsp;&nbsp;&bull;&nbsp; `Z` - A list of the message hashes $z_i$.

&nbsp;&nbsp;&bull;&nbsp; `R` - A list of the $r_i$.

&nbsp;&nbsp;&bull;&nbsp; `S` - A list of the $s_i$.

&nbsp;&nbsp;&bull;&nbsp; `Kbar` - A list of the $\bar{k_i}$ as described above; the known parts of each $k_i$.

&nbsp;&nbsp;&bull;&nbsp; `Pi` - A list of the $\pi_j$ as described above; the positions of each unknown part of $d$.

&nbsp;&nbsp;&bull;&nbsp; `Nu` - A list of the $\nu_j$ as described above; the sizes of each unknown part of $d$.

&nbsp;&nbsp;&bull;&nbsp; `Lambda` - A list of lists representing the $\lambda_{i, j}$ as described above; the positions of each unknown part of the $k_i$.

&nbsp;&nbsp;&bull;&nbsp; `Mu` - A list of lists representing the $\mu_{i, j}$ as described above; the sizes of each unknown part of the $k_i$.

**Returns:**

The (EC)DSA private signing key $d$.



## ecdsa_nonce_hash_xor_privkey

```py
ecdsa_nonce_hash_xor_privkey(Z, R, S, n)
```

Recovers the (EC)DSA private signing key given at least two messages and their signatures where the nonces $k_i$ were generated as $k_i = z_i \oplus d$ (i.e. message hash XOR private key). This problem was seen in [map22].

**Arguments:**

&nbsp;&nbsp;&bull;&nbsp; `Z` - A list of the message hashes $z_i$.

&nbsp;&nbsp;&bull;&nbsp; `R` - A list of the $r_i$.

&nbsp;&nbsp;&bull;&nbsp; `S` - A list of the $s_i$.

&nbsp;&nbsp;&bull;&nbsp; `n` - The modulus $n$.

**Returns:**

The (EC)DSA private signing key $d$.



## partial_key_exposure_rsa

```py
partial_key_exposure_rsa(N, e, d0, delta, gamma)
```

Partial key exposure attacks on RSA can be thought of as extensions of the Boneh-Durfee attack in which the private exponent $d$ is small, but some of its (most significant) bits are known. In this setting, we have $d < N^{\delta}$ and we know $(\delta - \gamma) \log_2 N$ MSBs of $d$. That is, we know an integer $d_0$ such that $|d - d_0| < N^{\gamma}$.

**Arguments:**

&nbsp;&nbsp;&bull;&nbsp; `N` - The RSA modulus.

&nbsp;&nbsp;&bull;&nbsp; `e` - The RSA public exponent.

&nbsp;&nbsp;&bull;&nbsp; `d0` - The known upper bits of $d$ as described above.

&nbsp;&nbsp;&bull;&nbsp; `delta` - The parameter which bounds the size of $d$. i.e. $d < N^{\delta}$.

&nbsp;&nbsp;&bull;&nbsp; `gamma` - The parameter $\gamma$ indicating how much of $d$ is known as described above.

**Returns:**

The RSA private exponent $d$.



## rsa_stereotyped_message

```py
rsa_stereotyped_message(N, e, c, m_known, X)
rsa_stereotyped_message_multi(N, e, c, m_known, Xs, ts)
```

Performs the stereotyped message attack on RSA as described in [Cop97].

**Arguments:**

&nbsp;&nbsp;&bull;&nbsp; `N` - The RSA modulus.

&nbsp;&nbsp;&bull;&nbsp; `e` - The RSA public exponent.

&nbsp;&nbsp;&bull;&nbsp; `c` - The RSA ciphertext to decrypt.

&nbsp;&nbsp;&bull;&nbsp; `m_known` - The known part of the message (as an integer).

&nbsp;&nbsp;&bull;&nbsp; `X` - The upper bound on the unknown part of the message (which must appear at the end of the message).

The `rsa_stereotyped_message_multi` is perhaps more useful as it allows you to specify positions and sizes for multiple unknown parts of the message:

&nbsp;&nbsp;&bull;&nbsp; `Xs` - A list containing the upper bounds on each unknown part of the message.

&nbsp;&nbsp;&bull;&nbsp; `ts` - A list containing the positions (in bits) of each unknown part of the message.

**Returns:**

All recovered unknown parts of the plaintext.



# References

- [PZ16] Yanbin Pan and Feng Zhang. *Solving low-density multiple subset sum problems with SVP oracle.* In Journal of Systems Science and Complexity, p. 228-242. Springer, 2016. https://link.springer.com/article/10.1007/s11424-015-3324-9
- [JM06] Ellen Jochemsz and Alexander May. *A Strategy for Finding Roots of Multivariate Polynomials with New Applications in Attacking RSA Variants.* In Advances in Cryptology - ASIACRYPT 2006, p. 267-282. Springer, 2006. https://link.springer.com/chapter/10.1007/11935230_18
- [Wan20] William Wang. *Coppersmith implementation.* https://github.com/defund/coppersmith
- [AH21] Martin R. Albrecht and Nadia Heninger. *On Bounded Distance Decoding with Predicate: Breaking the “Lattice Barrier” for the Hidden Number Problem.* In Lecture Notes in Computer Science, p. 528-558. Springer, 2021. https://link.springer.com/chapter/10.1007/978-3-030-77870-5_19
- [HR07] Martin Hlaváč and Tomáš Rosa. *Extended Hidden Number Problem and Its Cryptanalytic Applications.* In Selected Areas in Cryptography, p. 114-133. Springer, 2007. https://link.springer.com/chapter/10.1007/978-3-540-74462-7_9
- [Ngu09] P. Q. Nguyen. *Public-Key Cryptanalysis.* In Recent Trends in Cryptography. Ed. by I. Luengo. Vol. 477. AMS-RSME, 2009. https://www.di.ens.fr/~pnguyen/PubSantanderNotes.pdf
- [BD99] Dan Boneh and Glenn Durfee. *Cryptanalysis of RSA with Private Key $d$ Less than $N^{0.292}$.* In Advances in Cryptology, p. 1-11. Springer, 1999. https://link.springer.com/chapter/10.1007/3-540-48910-X_1
- [HS01] N. A. Howgrave-Graham and N. P. Smart. *Lattice Attacks on Digital Signature Schemes.* In Designs, Codes and Cryptography 23.3, p. 283-290. Springer, 2001. https://link.springer.com/article/10.1023/A:1011214926272
- [map22] maple3142. *TSJ CTF 2022 - Signature.* 2022. https://github.com/maple3142/My-CTF-Challenges/tree/master/TSJ%20CTF%202022/Signature
- [Ern+05] Matthias Ernst et al. *Partial Key Exposure Attacks on RSA up to Full Size Exponents.* In Advances in Cryptology, p. 371-386. Springer, 2005. https://link.springer.com/chapter/10.1007/11426639_22
- [Cop97] Don Coppersmith. *Small Solutions to Polynomial Equations, and Low Exponent RSA Vulnerabilites.* In Journal of Cryptology 10.4, p. 233-260. Springer, 1997. https://link.springer.com/article/10.1007/s001459900030
