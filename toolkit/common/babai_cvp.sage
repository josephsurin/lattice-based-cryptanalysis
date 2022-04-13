def babai_cvp(B, t, perform_reduction=True):
    if perform_reduction:
        B = B.LLL(delta=0.75)

    G = B.gram_schmidt()[0]
    b = t
    for i in reversed(range(B.nrows())):
        c = ((b * G[i]) / (G[i] * G[i])).round()
        b -= c * B[i]

    return t - b
