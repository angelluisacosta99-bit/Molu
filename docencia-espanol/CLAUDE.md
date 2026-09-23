<!--
  Movido aquí desde CLAUDE.md (raíz) el 2026-09-18 — este contenido solo
  aplica a docencia-espanol/, así que se carga solo cuando Claude Code
  trabaja en esta carpeta, en vez de ocupar espacio en el CLAUDE.md raíz
  en cada sesión de cualquier otra parte del repo. Movido verbatim, sin
  resumir nada (ver la regla "podar CLAUDE.md, no solo hacerlo crecer" y
  la lección de las 6-7 rondas de revisión que costó una poda anterior
  demasiado agresiva — un traslado 1:1 no corre ese riesgo, un resumen sí).
-->

# Materiales de referencia para clases de español

Al crear tareas, ejercicios, presentaciones o cualquier material nuevo
para las clases de español, basarse en el contenido real que el usuario
ya usa con sus alumnos, disponible en esta carpeta de Google Drive:

<https://drive.google.com/drive/folders/1YM1M17tG5C4kxEWIK6Dh-BoSdqR0CcZv>

Contiene tres subcarpetas. Orden de prioridad de uso (de más a menos
frecuente):

1. **Nuevo Español en Marcha** — libro de texto principal, el que más
   se usa.
2. **ПК Гонсалес** ("полный курс" González, es decir, el curso completo
   de González) — segundo material más usado.
3. **Temas** — recursos adicionales organizados por tema.

Antes de generar un ejercicio, tarea o presentación nueva, consultar el
contenido de estas carpetas (vía el conector de Google Drive) para
mantener consistencia con la progresión, el vocabulario y la
metodología que el alumno ya conoce, en vez de crear contenido genérico
desde cero.

**Pero mirar antes `docencia-espanol/fuentes/`.** Varios de esos PDF son
escaneados sin texto extraíble, así que hubo que transcribirlos a partir
de fotos que el profesor envió por el chat. Todo lo transcrito queda
archivado en esa carpeta en texto plano, con sus respuestas y con la
nota de si estas vienen del solucionario del libro o están deducidas. Si
el capítulo que hace falta ya está ahí, se parte de ese archivo: **no se
le vuelven a pedir fotos de algo ya transcrito.** Y todo lo que se
transcriba de nuevo se archiva ahí (ver el paso 8 de la skill
`ejercicio-interactivo`).

Si el profesor comparte un enlace externo (un artículo, un vídeo, un PDF)
como referencia para una clase, usar `/graphify add <url>` para meterlo
directo en el corpus del grafo de conocimiento en vez de copiar el
contenido a mano — ver la sección `## graphify` del `CLAUDE.md` raíz
del repo.

## Procesar PDFs escaneados: OCR local antes que visión

Cuando el profesor envíe un PDF/foto para transcribir, seguir este orden
— ahorra tokens porque evita transcribir la imagen desde cero.

**Si es un capítulo de `docencia-espanol/fuentes/`** (libro de texto con
páginas numeradas): usar directamente
`./docencia-espanol/fuentes/paginas.sh <archivo.pdf> <primera> [última]`
— ya resuelve todo lo de abajo (texto con `-layout`, render a `/tmp`
leído por glob en vez de un nombre fijo, aviso de fuente
Custom/Identity-H, imágenes incrustadas) y es la referencia hardened
para este caso. Ver su cabecera para el porqué de cada detalle.

**Para cualquier otro PDF escaneado** (cartas del consulado, documentos
sueltos sin script dedicado), el mismo procedimiento a mano:

1. **`pdftotext -layout -f N -l N "archivo.pdf" -`** primero, siempre — con
   `-layout`, nunca sin él: sin esa opción, una página con una tabla o
   un gráfico incrustado mezcla las etiquetas con el cuerpo del texto
   (pasó con un plano de metro en un capítulo real). Correr también
   `pdffonts "archivo.pdf"`: si muestra encoding `Custom`/`Identity-H`, el
   texto puede salir con caracteres cambiados aunque parezca correcto
   (incidente real, documentado en el diagnóstico `pdffonts` de
   `paginas.sh`) — tratarlo como si no hubiera texto y seguir al paso 2.
   Este paso da un borrador rápido, pero **no decide por sí solo si hace
   falta ver la imagen** — eso lo decide el paso 3, siempre, sin
   excepción: incluso con texto perfecto, solo la imagen muestra líneas
   dibujadas, ítems ya resueltos o marcas a mano (ver paso 3).
2. **Renderizar la página**, siempre, incluso si el paso 1 dio texto
   limpio (el render hace falta para el paso 3, no es opcional): a un
   directorio fuera del repo — por ejemplo (sustituyendo `archivo.pdf`
   por la ruta real):
   `ARCHIVO="archivo.pdf"; OUT="${TMPDIR:-/tmp}/paginas-$(basename "${ARCHIVO%.*}")"; mkdir -p "$OUT"`
   (nunca escribir páginas escaneadas de material con copyright dentro
   del repositorio) — con
   `pdftoppm -jpeg -r 150 -f N -l N "$ARCHIVO" "$OUT/pagina"`. 150 DPI
   basta para OCR en la mayoría de páginas; para letra muy menuda en una
   página de tamaño normal sí conviene subir a 200-300 DPI, como
   recomienda `paginas.sh`. La excepción es una página físicamente
   grande (un póster, un plano doblado): ahí, en vez de subir el DPI de
   toda la página (`tesseract`, vía Leptonica, no Poppler, puede dar
   "imagen demasiado grande" — medido: `Error in pixCreateHeader:
   requested bytes >= 2^31`), bajar el DPI general (100 o menos) y, si
   hace falta leer letra pequeña en una zona concreta, recortar esa zona
   a mayor resolución en vez de rasterizar la página entera — con
   `pymupdf`, `get_pixmap(dpi=300, clip=pymupdf.Rect(x0, y0, x1, y1))`
   (ver el plan B de `pymupdf` más abajo). Si el paso 1 no dio texto
   fiable (escaneado, o encoding sospechoso), pasar además **todos** los
   `pagina-*.jpg` resultantes (glob, no un nombre fijo tipo
   `pagina-N.jpg`: con 10+ páginas el nombre real lleva ceros a la
   izquierda y un nombre fijo no encuentra el archivo) por
   `tesseract "$f" stdout -l spa` (o `-l rus` para las cartas del
   consulado) para tener un borrador gratis y local antes de leer la
   imagen.
3. **Leer siempre la imagen renderizada antes de dar la página por
   cerrada** — no es un paso opcional de corregir errores puntuales del
   texto/OCR, es una lectura completa obligatoria, incluso cuando el
   paso 1 dio texto limpio: hay contenido que el texto (ni el OCR) puede
   representar y que cambia las respuestas — líneas de relacionar,
   ítems que el documento ya trae resueltos (aunque no sea con un dibujo
   evidente, a veces solo una línea a mano marcando un hueco como ya
   resuelto), respuestas rodeadas, flechas, manuscrito. Usar el texto o
   el borrador de OCR como plantilla para no transcribir de cero, pero
   la fuente de verdad final es siempre la imagen, vista entera.
4. **Para dibujos, crucigramas o manuscrito puro** (donde el OCR no
   aporta ni un borrador): en el paso 2, seguir renderizando la página
   igual, pero saltar el paso de OCR con tesseract — no hace falta
   borrador, se lee la imagen directamente en el paso 3. En cualquier
   caso, renderizar solo esas páginas específicas, no el PDF completo.

**Para extraer imágenes ya incrustadas** en un PDF (ilustraciones dentro
de un documento digital, no una página entera escaneada): usar
`pdfimages -f N -l N -png "archivo.pdf" prefijo` — las saca a archivos
directamente, sin IA de por medio, cero tokens. Si no aparece ninguna y
la página sí tiene dibujos, son vectoriales (parte del contenido de la
página, no una imagen embebida) — recortarlos del render con PIL en vez
de buscarlos con `pdfimages`.

**Auto-instalación (el contenedor es efímero, esto no persiste solo):**
si `tesseract`/`pdftotext`/`pdftoppm`/`pdfimages`/`pdffonts` no existen
al empezar, instalarlos con
`apt-get install -y poppler-utils tesseract-ocr tesseract-ocr-spa tesseract-ocr-rus`
antes de usarlos — igual que `graphify` se auto-instala solo si falta.
No asumir que ya están ahí solo porque lo estuvieron en una sesión
anterior: `.claude/skills/ejercicio-interactivo/SKILL.md` tiene medido
que ni `poppler-utils` ni `tesseract` están garantizados en todos los
contenedores, y que `apt-get install poppler-utils` puede fallar con
404 (índice de paquetes caducado, sin arreglo con `apt-get update`). Si
eso pasa, `poppler` entero (no solo `pdftoppm`) falta, así que hace
falta un plan B para los tres pasos, no solo para el render: el medido
que sí funciona es `python3 -m pip install pymupdf`, con
`doc = pymupdf.open(pdf); pagina = doc[n-1]` sustituyendo a `pdftoppm`
(`pagina.get_pixmap(...)`) y `pdftotext` (`pagina.get_text()`) — ver esa
skill para el detalle de cada llamada. Para `pdfimages`, que no
documenta: `for xref, *_ in pagina.get_images(): datos =
doc.extract_image(xref)` (`get_images()` solo lista referencias; hace
falta `extract_image()` para sacar los bytes reales). Sin tesseract
tampoco pasa nada: leer el render con `Read` es la fuente de verdad de
todos modos (paso 3), tesseract solo ahorra el borrador previo, nunca es
imprescindible.
