def procesar_bloques(bloques):

    total = 0

    for bloque in bloques:

        i = 0

        while i < len(bloque):

            total += bloque[i] * 2

            i += 1

    return total

print(procesar_bloques([
    [1, 2, 3, 4, 5, 6, 7, 8],
    [9, 10, 11, 12, 13, 14, 15, 16],
    [17, 18, 19, 20, 21, 22, 23, 24],
    [25, 26, 27, 28, 29, 30, 31, 32],
]))
