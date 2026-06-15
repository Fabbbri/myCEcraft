def main():
    a = [0] * 64
    b = [0] * 64
    c = [0] * 64

    i = 0
    while i < 64:
        a[i] = i
        b[i] = 1
        i = i + 1

    i = 0
    ia = 0
    while i < 8:
        j = 0
        while j < 8:
            acc = 0
            k = 0
            kb = 0
            while k < 8:
                acc = acc + a[ia + k] * b[kb + j]
                k = k + 1
                kb = kb + 8
            c[ia + j] = acc
            j = j + 1
        i = i + 1
        ia = ia + 8

    suma = 0
    i = 0
    while i < 64:
        suma = suma + c[i]
        i = i + 1

    return suma

print(main())
