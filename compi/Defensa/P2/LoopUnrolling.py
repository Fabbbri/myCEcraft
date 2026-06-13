def procesar_bloques(bloques):

    total = 0

    for bloque in bloques:

        i = 0

        while i < len(bloque):

            total += bloque[i] * 2

            i += 1

    return total

print(procesar_bloques([
    [ 10,  20,  30,  40,  50,  60,  70,  80],
    [ 15,  25,  35,  45,  55,  65,  75,  85],
    [ 11,  22,  33,  44,  55,  66,  77,  88],
    [ 12,  24,  36,  48,  60,  72,  84,  96],
    [100, 200, 150, 250, 120, 180, 140, 160],
    [ 90, 110, 130, 170, 190, 210, 230,  70],
    [  5,  15,  25,  35,  45,  55,  65,  75],
    [  8,  16,  24,  32,  40,  48,  56,  64],
]))