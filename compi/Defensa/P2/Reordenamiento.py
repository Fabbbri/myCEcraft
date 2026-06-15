def analizar_sensor_reordenado(datos):

    i = 0
    total = 0

    while i < len(datos):

        lectura = datos[i]

        log = i * 100

        promedio = lectura * 2
        ajuste = promedio + 10
        resultado = ajuste * 3

        if lectura > 50:
            total += resultado

        i += 1

    return total

print(analizar_sensor_reordenado([10, 20, 30, 40, 50, 60, 70]))