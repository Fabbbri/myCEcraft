# Craft Studio

IDE prototipo en PySide6 para editar archivos `.craft` y compilar el archivo
activo usando el compilador del proyecto.

## Estado actual
- Permite abrir cualquier carpeta como workspace.
- Lista archivos `.craft` reales del workspace, incluyendo subcarpetas.
- Abre archivos `.craft` en tabs con resaltado de sintaxis.
- Guarda el archivo activo.
- Ejecuta `compi/main.py -r -b <archivo.craft>` desde el boton Compilar.
- Muestra salida, problemas y artefactos generados.

## Requisitos
- Python 3.10+
- PySide6

## Ejecutar

```bash
python3 compi/IDE/main.py
```

Si no tenes PySide6:

```bash
pip install PySide6
```
