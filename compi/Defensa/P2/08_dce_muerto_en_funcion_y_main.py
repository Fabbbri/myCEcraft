acumulado = 1

def acumular(v):
    global acumulado
    d1 = v + 10
    d2 = d1 + d1
    d3 = d2 + d1
    d4 = d3 + d2
    acumulado = acumulado + v
    return acumulado

def main():
    global acumulado
    semilla = 3

    acumular(2)

    e1 = semilla + 11
    e2 = e1 + e1
    e3 = e2 + e1
    e4 = e3 + e2
    e5 = e4 + e3

    acumular(4)
    return acumulado

# DCE elimina cadena muerta en funcion auxiliar y bloque muerto en main.
# Resultado esperado: 1 + 2 + 4 = 7.
print(main())
