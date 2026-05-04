# Herramienta 4.3: carga y extraccion de archivos

Esta carpeta implementa la herramienta solicitada en la seccion 4.3 del enunciado.
Los scripts trabajan con bytes crudos, por lo que aceptan texto, imagenes, binarios
o cualquier otro formato sin conversion especial.

## Cargar un archivo a RAM

Desde la raiz del repositorio, coloque los archivos de prueba dentro de
`.\arqui\scripts\examples\`. Por ejemplo, si la imagen se llama `foto.jpg`:

```powershell
python .\arqui\scripts\load_file.py --input .\arqui\scripts\examples\foto.jpg --output .\arqui\scripts\examples\foto.mem --address 0x2000
```

El archivo generado usa formato `$readmemh` de Verilog:

```text
@2000
48
6F
6C
61
```

Cada linea es un byte. La directiva `@2000` indica la direccion inicial dentro
de la RAM de 64 KB usada por `rtl/data_ram.sv`.

## Extraer datos desde un dump

Use como `--size` el valor que imprimio `load_file.py` en `Bytes cargados`.
Ese numero depende del archivo cargado: si cambia la imagen, el texto o el
binario de entrada, tambien debe cambiar el `--size` del comando de extraccion.

Por ejemplo, si `load_file.py` imprime:

```text
Bytes cargados: 4096
Rango RAM: 0x2000..0x2FFF
```

extraiga usando `--size 4096` y la misma direccion base `--address 0x2000`:

```powershell
python .\arqui\scripts\extract_data.py --memory .\arqui\scripts\examples\foto.mem --address 0x2000 --size 4096 --output .\arqui\scripts\examples\foto_resultado.jpg
```

La extension del archivo de salida depende de como quiera usar el resultado.
Si quiere un binario generico, use `.bin`:

```powershell
python .\arqui\scripts\extract_data.py --memory .\arqui\scripts\examples\foto.mem --address 0x2000 --size 4096 --output .\arqui\scripts\examples\foto_resultado.bin
```

Si quiere abrirlo nuevamente como imagen, use la misma extension del archivo
original, por ejemplo `.jpg` o `.png`:

```powershell
python .\arqui\scripts\extract_data.py --memory .\arqui\scripts\examples\foto.mem --address 0x2000 --size 4096 --output .\arqui\scripts\examples\foto_resultado.jpg
```

El contenido extraido es el mismo en ambos casos; la extension solo ayuda al
sistema operativo o al visor a saber con que programa abrirlo.

El dump puede contener directivas `@direccion` y bytes en hexadecimal, como los
archivos generados por `$writememh` o por `load_file.py`.
