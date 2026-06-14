def main():
    arr = [0] * 480

    i = 0
    while i < 480:
        arr[i] = i
        i = i + 1

    i = 0
    idx = 0
    suma = 0
    while i < 480:
        suma = suma + arr[idx]
        idx = idx + 341
        if idx >= 480:
            idx = idx - 480
        i = i + 1

    return suma

print(main())
