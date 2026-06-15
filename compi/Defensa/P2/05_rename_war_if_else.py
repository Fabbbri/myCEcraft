def clasificar(x, lim):
    if x < lim:
        return x + lim
    else:
        lim = lim + x
        return lim

def main():
    total = 0

    i = 1
    while i <= 6:
        total = total + clasificar(i, i + 2)
        i = i + 1

    return total

# WAR sobre 'lim': leida en la condicion del if, sobreescrita en else.
# Resultado esperado: 4+6+8+10+12+14 = 54.
print(main())
