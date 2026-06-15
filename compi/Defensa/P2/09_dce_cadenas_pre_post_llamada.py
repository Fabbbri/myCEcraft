contador = 0

def registrar(v):
    global contador
    contador = contador + v
    return v + 1

def main():
    global contador
    local = 4
    p1 = local + 7
    p2 = p1 + p1
    p3 = p2 + p1
    p4 = p3 + p2
    p5 = p4 + p3

    ret = registrar(6)
    q1 = ret + p5
    q2 = q1 + q1
    q3 = q2 + q1

    r1 = local + q3
    r2 = r1 + r1
    r3 = r2 + r1

    return contador

# DCE elimina bloques muertos antes y despues de la llamada con efecto.
# La llamada registrar(6) y su retorno alimentan cadena muerta pero la
# llamada se conserva por su efecto observable.
# Resultado esperado: 6.
print(main())
