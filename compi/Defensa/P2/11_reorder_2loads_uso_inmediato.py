ga = 10
gb = 30

def main():
    a = ga
    parta = a + 1

    w1 = 2 + 3
    w2 = 4 + 5

    b = gb
    partb = b + 1

    w3 = w1 + w2
    w4 = w3 + w2

    total = parta + partb + w4
    return total

# Dos loads con uso inmediato; scheduler mueve trabajo independiente
# para cubrir la latencia de cada load.
# Resultado esperado: parta=11, partb=31, w4=23 -> total=65.
print(main())
