def combinar(a, b):
    acc = a + b

    if a > b:
        prev_if = acc
        acc = acc + prev_if
        return acc
    else:
        prev_el = acc
        acc = acc + a
        return acc + prev_el

def main():
    total = 0

    i = 1
    while i <= 5:
        total = total + combinar(i, 6 - i)
        i = i + 1

    return total

# WAW + WAR en funcion con if/else anidado.
# 'acc' sufre WAW (escrita en ambas ramas) y 'prev' sufre WAR.
print(main())
