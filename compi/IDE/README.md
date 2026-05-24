# Craft Studio

IDE prototipo en PySide6 para editar archivos `.craft` y compilar el archivo
activo usando el compilador del proyecto.

## Estado actual
- Permite abrir cualquier carpeta como workspace.
- Lista archivos `.craft` reales del workspace, incluyendo subcarpetas.
- Abre archivos `.craft` en tabs con resaltado de sintaxis.
- Valida en vivo con una tabla LL(1) auxiliar para sugerencias y, cuando la
  sintaxis base ya es válida, ejecuta también el parser y el análisis semántico
  reales para reportar errores del compilador.
- Marca la pestaña `Problemas` con un indicador rojo y el conteo de problemas
  activos; si hay errores en el editor, la salida deja de mostrar `Listo para
  compilar`.
- Guarda el archivo activo.
- Ejecuta `compi/main.py -r -b <archivo.craft>` desde el boton Compilar.
- Muestra salida, problemas y artefactos generados.

## Requisitos
- Python 3.10+
- PySide6

## Analisis LL(1) para el IDE

El archivo `ll1_syntax.py` implementa un servicio auxiliar para que el IDE pueda
dar diagnosticos y sugerencias mientras se escribe codigo `.craft`.

Importante: esta tabla LL(1) no reemplaza al parser principal del compilador.
El compilador sigue usando `compi/parser.py`. La tabla LL(1) existe para la
experiencia interactiva del editor: detectar errores temprano, explicar que se
esperaba y alimentar el popup de sugerencias. Si la LL(1) no encuentra errores,
el IDE corre `Parser` y `SemanticAnalyzer` sobre el mismo texto para marcar
errores más precisos del lenguaje.

### Estructura general

`LL1SyntaxService` construye una gramatica predictiva a partir de un diccionario:

```python
grammar = {
    "Program": [("EnterOpt", "TopItems", "EOF")],
    "FunctionDecl": [
        ("KW_CRAFT", "COLON", "Type", "IDENT", "LPAREN", "ParamsOpt", "RPAREN", "Block")
    ],
    ...
}
```

Cada llave es un no terminal y cada tupla es una produccion. Los terminales usan
los nombres reales de `TokenType`, por ejemplo `KW_CRAFT`, `IDENT`,
`SEMICOLON`, `TYPE_INT`, etc. Esto permite usar el lexer real del proyecto.

### FIRST, FOLLOW y tabla predictiva

Cuando se crea `LL1SyntaxService`, se calculan tres estructuras:

- `first`: conjunto de terminales con los que puede empezar cada no terminal.
- `follow`: conjunto de terminales que pueden aparecer despues de cada no terminal.
- `table`: tabla LL(1) predictiva.

La tabla final es un diccionario:

```python
(no_terminal, token_actual) -> produccion
```

Ejemplos conceptuales:

```python
("Statement", "KW_IF") -> ("IfStmt",)
("Statement", "KW_RETURN") -> ("ReturnStmt",)
("Type", "TYPE_INT") -> ("TYPE_INT",)
```

Con eso, el servicio puede simular un parser predictivo usando una pila. Si el
token actual no tiene entrada valida en la tabla, el servicio mira que terminales
eran esperados y construye un diagnostico.

### Diagnosticos

El metodo principal para validacion es:

```python
diagnostics, suggestions = service.analyze(source)
```

El flujo es:

1. Se tokeniza el texto con `Lexer`.
2. Se corre el parser predictivo LL(1).
3. Si encuentra un token inesperado, genera un `Diagnostic`.
4. Si la sintaxis predictiva está completa, ejecuta parser y semántica reales.
5. El IDE subraya el rango del error en el editor y escribe el detalle en el
   panel `Problemas`.

Un diagnostico contiene:

```python
Diagnostic(
    line=4,
    column=1,
    length=1,
    message="Se encontro '}'; se esperaba ;.",
    expected=(";",),
    suggestions=(Suggestion("Insertar ;", ";"),),
)
```

Ejemplo:

```craft
@EnterCraftWorld
craft:int main() {
    x:int = 0
}
```

El servicio detecta que antes de `}` se esperaba `;`, por lo que el IDE puede
mostrar:

```text
Linea 4, columna 1: Se encontro '}'; se esperaba ;.
Sugerencias:
- Insertar ;
```

También se detectan errores de fase semántica, por ejemplo:

```craft
@EnterCraftWorld
craft:int main() {
    x:manzana = 1;
    return 0;
}
```

El IDE reporta `Tipo desconocido 'manzana'` y muestra los tipos reconocidos por
Craft. Otros casos cubiertos incluyen símbolos no declarados, funciones llamadas
con cantidad incorrecta de argumentos, `ender` usado fuera de `chest[ender, N]`,
retornos faltantes en funciones no `void` y tamaños inválidos de `chest`.

Además de detenerse en el primer error sintáctico fuerte, el IDE ejecuta una
pasada estructural independiente para marcar delimitadores seguros que falten o
sobren. Así puede mostrar, por ejemplo, un tipo inválido y una llave `}` faltante
en el mismo archivo.

### Sugerencias con Ctrl+Space

El autocompletado usa:

```python
suggestions = service.complete(source, cursor_position)
```

Este metodo no analiza siempre el archivo completo. Primero detecta si hay una
palabra parcial antes del cursor. Luego analiza el contexto anterior a esa
palabra con la tabla LL(1), obtiene los tokens validos en ese punto y filtra las
sugerencias segun el prefijo escrito.

La LL(1) decide la categoria valida. Cuando esa categoria permite un
identificador, el IDE agrega sugerencias semanticas a partir del codigo visible:
variables locales, parametros, funciones declaradas para `summon:` y aliases de
modulos importados. Por ejemplo, si LL(1) indica que puede venir una expresion,
el popup no muestra solo `identificador`; muestra nombres reales como
`contador    int`.

Ejemplos:

```text
Texto antes del cursor        Sugerencias
-------------------------------------------------
""                            @EnterCraftWorld, invoke, craft function
"@"                           @EnterCraftWorld
"cra"                         craft function
"craft:"                      int, uint32, uint16, char, void, pointer, chest
dentro de un bloque           for, if, return, summon, while, Cerrar }
"ret" dentro de un bloque     return
"return 0"                    Insertar ;
"return con"                  contador
"summon:s"                    suma(a:int, b:int) -> int
```

La tabla LL(1) decide que tokens son validos en el contexto actual. Luego
`TERMINAL_SUGGESTIONS` traduce esos tokens a texto insertable:

```python
"KW_RETURN": Suggestion("return", "return ;")
"SEMICOLON": Suggestion("Insertar ;", ";")
"RPAREN": Suggestion("Cerrar )", ")"
```

Esta separacion es importante:

- La gramatica decide que puede venir.
- El diccionario de sugerencias decide como se muestra e inserta.

### Integracion con la UI

En `main.py`, `CodeEditor` detecta `Ctrl+Space` y emite una senal:

```python
completion_requested = Signal()
```

`MainWindow` recibe esa senal, llama a `LL1SyntaxService.complete(...)` y muestra
un `QListWidget` flotante cerca del cursor. Al seleccionar una sugerencia, se
inserta el `insert_text` correspondiente.

Para los errores, cada vez que cambia el texto del editor se llama a
`LL1SyntaxService.analyze(...)`. Los errores se dibujan con
`QTextEdit.ExtraSelection` usando subrayado rojo ondulado.

### Autocorrecciones con Enter

Cuando se presiona `Enter`, el editor consulta `LL1SyntaxService.complete(...)`.
Si la primera sugerencia estructural esperada es clara, el IDE puede insertar
automaticamente:

- `;`
- `)`
- `]`
- `:`
- `}`

Para `}` la regla es conservadora: solo se inserta si el cursor esta en una
linea vacia o con espacios, existe una llave `{` abierta pendiente y la linea
anterior significativa no termina ya en `}`. Esto evita cerrar bloques de mas,
por ejemplo despues de un `while` que ya fue cerrado.

## Ejecutar

```bash
python3 compi/IDE/main.py
```

## Demo automatica de diagnosticos

El boton `Demo errores` crea o abre `ide_error_demo.craft` dentro del workspace
actual y rota casos cada pocos segundos para revisar visualmente el IDE:

- numero invalido como `5awd`
- falta de `;` y `}`
- tipo desconocido
- `return` incompleto
- parentesis faltante
- variable no declarada
- aridad incorrecta en llamadas
- programa valido para confirmar que se limpian los errores

El boton cambia a `Detener demo` mientras la reproduccion esta activa.

Si no tenes PySide6:

```bash
pip install PySide6
```
