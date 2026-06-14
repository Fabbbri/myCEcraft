def main():
    n = 6
    i = 0
    suma = 0

    while i < n:
        suma = suma + i
        i = i + 1

    return suma

# N asignada como constante antes del loop; el unroller propaga su valor.
# Resultado esperado: 0+1+2+3+4+5 = 15.
print(main())
