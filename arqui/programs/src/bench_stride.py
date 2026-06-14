def main():
    arr = [0] * 256

    i = 0
    while i < 256:
        arr[i] = i
        i = i + 8

    i = 0
    suma = 0
    while i < 256:
        suma = suma + arr[i]
        i = i + 8

    return suma

print(main())
