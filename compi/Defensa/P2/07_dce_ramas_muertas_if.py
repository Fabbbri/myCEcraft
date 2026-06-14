estado = 0

def marcar(v):
    global estado
    estado = estado + v
    return estado

def main():
    global estado
    base = 7

    if base > 0:
        m1 = base + 3
        m2 = m1 + m1
        m3 = m2 + m1
        m4 = m3 + m2
    else:
        n1 = base + 9
        n2 = n1 + n1
        n3 = n2 + n1
        n4 = n3 + n2

    marcar(5)
    return estado

# DCE elimina cadenas muertas dentro de IF/ELSE: ninguno de esos valores
# llega al return ni a una llamada con efecto.
# Resultado esperado: 5.
print(main())
