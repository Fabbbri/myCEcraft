def main():
    par = 0
    impar = 0

    i = 0
    while i < 32:
        par = par + i
        impar = impar + i + 1
        i = i + 2

    return par + impar

# FOR con N constante grande (32), factor auto = 8.
# Resultado esperado: sum(0..31) = 496.
print(main())
