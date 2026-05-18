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

## TEA con imagen cargada por loader

Desde la raiz del repo, prepare todo con una sola orden:

```powershell
python arqui/scripts/prepare_teaimg.py --input TU_IMAGEN.png

Ejemplo:
 python arqui/scripts/prepare_teaimg.py --input arqui/scripts/examples/testimg.jpg
```

Ese comando ajusta `compi/ejemplos/teaimg.craft`, regenera
`arqui/tb/teaimg_config.svh`, compila el programa y crea:

- `arqui/programs/teaimg_loader.hex`
- `arqui/programs/teaimg_input.hex`

Luego ejecute:

```powershell
./run.sh run tb_teaimg_loader
```

El script imprime el comando exacto para recuperar la imagen descifrada. La
forma general es:

```powershell
python arqui/scripts/extract_data.py --memory arqui/outputs/teaimg_salida.hex --address DIRECCION_DESCIFRADA --size BYTES_REALES --output arqui/outputs/teaimg_recuperada.png
```

La direccion descifrada y `BYTES_REALES` dependen del tamano de la imagen. Si
la imagen no cabe en la RAM con buffers original+cifrado+descifrado, el script
se detiene antes de modificar los loaders y muestra el maximo permitido.

## Imagenes grandes

El flujo actual de TEA guarda tres copias del archivo en RAM: original, cifrada
y descifrada. Por eso, con la RAM actual, la entrada debe pesar alrededor de
10 KB o menos.

Si una imagen pesa mas, `prepare_teaimg.py` intenta reducirla automaticamente
antes de generar los loaders:

```powershell
python arqui/scripts/prepare_teaimg.py --input arqui/scripts/examples/foto.jpg
./run.sh run tb_teaimg_loader
```

La imagen reducida queda guardada en:

```text
arqui/outputs/prepared_inputs/
```

Si quiere reducir una imagen manualmente, tambien puede usar:

```powershell
python arqui/scripts/compress_image.py --input arqui/scripts/examples/foto.jpg --output arqui/scripts/examples/foto_small.jpg --max-bytes 10240
```

La utilidad reduce resolucion y calidad hasta que el archivo de salida quede
por debajo del limite indicado. Para imagenes JPG suele funcionar mejor que
comprimir con ZIP/GZIP, porque JPG ya es un formato comprimido.

## TEA con archivos .txt o .bin

Aunque el flujo se llama `teaimg`, los scripts trabajan con bytes crudos. Por
eso tambien se puede usar un archivo de texto o un binario como entrada para el
algoritmo TEA.

Hay que distinguir dos partes:

- `load_file.py` no cifra ni descifra; solo convierte cualquier archivo a bytes
  en formato `$readmemh`.
- `prepare_teaimg.py` prepara el programa y los datos para que `tb_teaimg_loader`
  ejecute el algoritmo TEA sobre esos bytes.

Ejemplo con un archivo de texto:

```powershell
python arqui/scripts/prepare_teaimg.py --input arqui/scripts/examples/mensaje.txt
./run.sh run tb_teaimg_loader
```

El comando anterior carga los bytes de `mensaje.txt`, ejecuta TEA sobre ellos y
genera el dump de salida. Para recuperar el texto descifrado, use el comando que
imprime `prepare_teaimg.py`, cambiando la extension del archivo de salida:

```powershell
python arqui/scripts/extract_data.py --memory arqui/outputs/teaimg_salida.hex --address DIRECCION_DESCIFRADA --size BYTES_REALES --output arqui/outputs/mensaje_recuperado.txt
```

Ejemplo con un binario:

```powershell
python arqui/scripts/prepare_teaimg.py --input arqui/scripts/examples/manual.bin
./run.sh run tb_teaimg_loader
```

Y para extraerlo:

```powershell
python arqui/scripts/extract_data.py --memory arqui/outputs/teaimg_salida.hex --address DIRECCION_DESCIFRADA --size BYTES_REALES --output arqui/outputs/manual_recuperado.bin
```

La extension de salida no cambia los datos extraidos; solo ayuda al sistema
operativo a abrirlos con el programa correcto.

## Solo descifrar archivos .enc

Si el archivo ya esta cifrado con TEA, use el modo `decrypt`. En ese modo
`prepare_teaimg.py` no cifra primero: carga el `.enc` en RAM, lo descifra en el
mismo buffer y deja el resultado listo para extraer desde `0x8010`.

Ejemplo:

```powershell
python arqui/scripts/prepare_teaimg.py --decrypt --input arqui/scripts/examples/warfoxes_1k.txt.enc
./run.sh run tb_teaimg_loader
```

El script imprime el comando exacto de extraccion. Para el ejemplo anterior se
vera con esta forma:

```powershell
python arqui/scripts/extract_data.py --memory arqui/outputs/teaimg_salida.hex --address 0x8010 --size 1024 --output arqui/outputs/warfoxes_1k_descifrado.txt
```

Tambien sirve con imagenes cifradas que quepan en la RAM:

```powershell
python arqui/scripts/prepare_teaimg.py --decrypt --input arqui/scripts/examples/priv.png.enc
./run.sh run tb_teaimg_loader
```

Si el archivo original no tenia un tamano multiplo de 8, el `.enc` puede incluir
padding al final. Como el `.enc` no guarda metadatos del tamano original, puede
indicar manualmente cuantos bytes reales quiere extraer:

```powershell
python arqui/scripts/prepare_teaimg.py --decrypt --input arqui/scripts/examples/priv.png.enc --output-size BYTES_ORIGINALES
```

Con la RAM actual, el modo `decrypt` acepta aproximadamente 32 KB de entrada
cifrada. Archivos `.enc` mas grandes necesitan aumentar la RAM o partirse en
bloques.

## Descifrar .enc grandes por bloques

Para archivos que no caben completos en RAM, use `decrypt_teaimg_chunks.py`.
Ese script parte el `.enc` en bloques que si caben, prepara cada bloque con
`prepare_teaimg.py --decrypt`, corre `tb_teaimg_loader`, extrae el bloque
descifrado y concatena todo en un archivo final.

Ejemplo:

```powershell
python arqui/scripts/decrypt_teaimg_chunks.py --input arqui/scripts/examples/M2.jpg.enc --output arqui/outputs/M2_descifrado.jpg
```

Y para el video:

```powershell
python arqui/scripts/decrypt_teaimg_chunks.py --input arqui/scripts/examples/cattttz.mp4.enc --output arqui/outputs/cattttz_descifrado.mp4
```

Si el archivo original tenia padding al final, indique el tamano real del
archivo original para que el resultado quede recortado correctamente:

```powershell
python arqui/scripts/decrypt_teaimg_chunks.py --input arqui/scripts/examples/M2.jpg.enc --output arqui/outputs/M2_descifrado.jpg --output-size BYTES_ORIGINALES
```

El tamano de bloque por defecto usa el maximo actual del modo decrypt. Si quiere
usar bloques mas pequenos:

```powershell
python arqui/scripts/decrypt_teaimg_chunks.py --input arqui/scripts/examples/M2.jpg.enc --chunk-size 16384
```

Si su entorno no puede ejecutar `./run.sh run tb_teaimg_loader` automaticamente,
puede dar un comando explicito. El comando se ejecuta desde la raiz del repo:

```powershell
python arqui/scripts/decrypt_teaimg_chunks.py --input arqui/scripts/examples/M2.jpg.enc --sim-command "bash run.sh run tb_teaimg_loader"
```
