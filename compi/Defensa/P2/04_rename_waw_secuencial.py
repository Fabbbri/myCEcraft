def main():
    a = 1
    primero = a + 10
    a = 2
    segundo = a + 20
    a = 3
    tercero = a + 30
    return primero + segundo + tercero

# WAW en secuencia densa: 'a' se reescribe 3 veces antes de usarse.
# Resultado esperado: (1+10) + (2+20) + (3+30) = 11 + 22 + 33 = 66.
print(main())
