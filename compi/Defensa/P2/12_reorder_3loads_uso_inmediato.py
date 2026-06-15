da = 4
db = 8
dc = 12

def main():
    a = da
    parta = a + 1

    w1 = 2 + 3

    b = db
    partb = b + 1

    w2 = 4 + 5

    c = dc
    partc = c + 1

    total = parta + partb + partc
    return total

# Tres loads globales con trabajo independiente intercalado entre cada load y su uso.
# Resultado esperado: parta=5, partb=9, partc=13 -> total=27.
print(main())
