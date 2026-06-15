base = 9

def main():
    a = base
    part = a + 1

    w1 = 5 + 6
    w2 = 7 + 8
    w3 = w1 + w2

    total = part + w3
    return total

# Un load desde memoria global con uso inmediato.
# Con reorder: scheduler mueve w1, w2, w3 entre el lw y el primer uso de 'a'.
# Resultado esperado: a=9, part=10, w1=11, w2=15, w3=26 -> total=36.
print(main())
