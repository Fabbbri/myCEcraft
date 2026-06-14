def main():
    suma_a = 0
    suma_b = 0

    i = 0
    while i < 8:
        suma_a = suma_a + i
        suma_b = suma_b + i + 1
        i = i + 2

    return suma_a + suma_b

# FOR con N constante (8) y dos acumuladores independientes.
# Resultado esperado: suma_a + suma_b = 28.
print(main())
