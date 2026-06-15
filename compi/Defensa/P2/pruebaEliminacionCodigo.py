def multiplicacion_matrices(A, B):

    filas = len(A)
    columnas = len(B[0])
    comun = len(B)

    C = [[0 for _ in range(columnas)]
         for _ in range(filas)]

    total_operaciones = 0

    for i in range(filas):

        temporal_externo = i * 100

        for j in range(columnas):

            basura1 = i + j

            suma = 0

            for k in range(comun):

                basura2 = k * 50

                suma += A[i][k] * B[k][j]

                total_operaciones += 1

            C[i][j] = suma

            basura3 = suma * 999

    estadistica = total_operaciones
    desperdicio = estadistica * 2

    return C


# Misma prueba que pruebaEliminacionCodigo.craft:
#   [[1, 2], [3, 4]] * [[5, 6], [7, 8]] = [[19, 22], [43, 50]]
# Se imprime la suma de todos los elementos de C para comparar con el valor
# que el .craft deja en x11. Resultado esperado: 134.
A = [[1, 2], [3, 4]]
B = [[5, 6], [7, 8]]
C = multiplicacion_matrices(A, B)
print(sum(valor for fila in C for valor in fila))
