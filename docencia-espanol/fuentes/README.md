# Fuentes transcritas

Archivo en texto plano del contenido de los capítulos de libro que ya se han transcrito a
partir de escaneos o fotos. **El objetivo es no volver a escanear ni volver a fotografiar
lo mismo**: si mañana hace falta una ficha en Word, una presentación o un ejercicio nuevo
sobre un capítulo que ya está aquí, se parte de este texto.

Cada archivo trae la teoría, los enunciados y **las respuestas en negrita**, en Markdown.

## Capítulos preparados pero sin publicar: `pendientes/`

Los PDF que el profesor adjunta al chat **viven solo en esa sesión** (`/root/.claude/uploads/`)
y desaparecen con ella; el repositorio, en cambio, se hereda entero. Por eso, cuando un
capítulo se va a construir en otra sesión, su material de partida —texto de la página,
respuestas del solucionario, transcripción del audio y dibujos recortados— se deja en
`pendientes/`. Ver el README de esa carpeta: **no se confunde con este archivo**, que es de
capítulos ya publicados y lo genera `extraer.mjs`.

## Cómo se generan

No se escriben a mano. Se extraen del artefacto interactivo ya publicado y verificado, con:

```bash
cd docencia-espanol/fuentes
NODE_PATH=/opt/node22/lib/node_modules node extraer.mjs \
  ../materiales/<archivo>.html <CÓDIGO> > nuevo-espanol-en-marcha/<nivel>/<capítulo>.md
```

`extraer.mjs` abre el artefacto en un navegador, rellena todos los huecos con texto
imposible, pulsa «Corregir todos» y recoge del DOM cada enunciado junto con la respuesta
que el propio motor revela. Es decir: **lo archivado es exactamente lo que se verificó que
funciona**, no una segunda transcripción que podría desviarse.

Consecuencia práctica: si se corrige una respuesta en el artefacto, hay que **regenerar**
el archivo correspondiente, no editarlo a mano.

## Qué hay y de dónde salió

| Archivo | Origen | Páginas | Respuestas |
| --- | --- | --- | --- |
| `nuevo-espanol-en-marcha/a1/unidades-1-8_presente-gerundio-indefinido.md` | Nuevo Español en Marcha 1 (A1), unidades 1-8 | — | **elaboradas** para el ejercicio |
| `nuevo-espanol-en-marcha/a1/cuaderno-unidad6a_como-se-va-a-goya.md` | Nuevo Español en Marcha 1 (A1), **cuaderno de ejercicios**, unidad 6A | 28 | **solucionario oficial** (ejercicios 1-3); el ejercicio 4 es de marcar un plano, sin respuesta de texto |
| `nuevo-espanol-en-marcha/a1/cuaderno-unidad6b_cierra-la-ventana.md` | Nuevo Español en Marcha 1 (A1), **cuaderno de ejercicios**, unidad 6B | 29 | **solucionario oficial** (los cinco ejercicios). Dos respuestas del ej. 1 salían ilegibles en la foto y se dedujeron por descarte; después se comprobaron contra el solucionario del PDF (pág. 59) y coinciden |
| `nuevo-espanol-en-marcha/a1/cuaderno-unidad6c_mi-barrio-es-tranquilo.md` | Nuevo Español en Marcha 1 (A1), **cuaderno de ejercicios**, unidad 6C | 30-31 | **solucionario oficial** (los nueve ejercicios; el 6 es actividad libre) |
| `nuevo-espanol-en-marcha/a1/practica-mas-3_unidades-5-6.md` | Nuevo Español en Marcha 1 (A1), **cuaderno de ejercicios**, «Practica más 3» (repaso de las unidades 5 y 6) | 32-33 | **solucionario oficial** (los ocho ejercicios) |
| `nuevo-espanol-en-marcha/a1/cuaderno-unidad7a_donde-quedamos.md` | Nuevo Español en Marcha 1 (A1), **cuaderno de ejercicios**, unidad 7A | 34-35 | **solucionario oficial** (páginas 59-60 del propio cuaderno). El ej. 2 es actividad libre; los ej. 1 y 3 son de audio (pistas 9 y 10) y llevan su transcripción, tomada de las páginas 54-55 |
| `nuevo-espanol-en-marcha/b1/cuaderno-unidad1a_vida-cotidiana.md` | Nuevo Español en Marcha 3 (B1), **cuaderno de ejercicios**, unidad 1A | 4 | **solucionario oficial** (página 69 del propio cuaderno). El ej. 1 (comprensión lectora) enseña el artículo completo en un recuadro de referencia; el ej. 3 es actividad libre, así que no puntúa — su caja de texto se envía al profesor sin corregir |
| `nuevo-espanol-en-marcha/b1/cuaderno-unidad1b_que-hiciste-que-has-hecho.md` | Nuevo Español en Marcha 3 (B1), **cuaderno de ejercicios**, unidad 1B | 5 | **solucionario oficial** (página 69). El ej. 1 (relaciona) usa type "match" (tocar para conectar), el primer uso real de este tipo en un capítulo publicado. El ej. 3 (declaraba/declaró) acepta las dos formas que da el propio solucionario |
| `nuevo-espanol-en-marcha/b1/cuaderno-unidad1c_el-futuro-que-nos-espera.md` | Nuevo Español en Marcha 3 (B1), **cuaderno de ejercicios**, unidad 1C | 6-7 | **solucionario oficial** (página 69). El ej. 3 (relaciona sujeto con predicción) es una relación de varios-a-uno (el viento admite tres finales válidos) — se resuelve escribiendo las letras separadas por comas, aceptando cualquier orden. El ej. 4 (tildes) pide reescribir la frase completa; el ej. 5 del libro (solo escuchar y comprobar, pista 1) no aporta contenido nuevo que archivar |
| `nuevo-espanol-en-marcha/b1/repaso-b1_secciones-1-12.md` | Nuevo Español en Marcha 3 (B1), repaso final | 140-163 | **deducidas**, sin solucionario |
| `nuevo-espanol-en-marcha/b1/cuaderno-unidad5a_por-que-soy-vegetariano.md` | Nuevo Español en Marcha 3 (B1), **cuaderno de ejercicios**, unidad 5A | 20 | **solucionario oficial** (página 71 del propio cuaderno). El ej. 3 lo da el libro como «posibles respuestas», así que en el artefacto no puntúa y las del libro van en un plegable |
| `nuevo-espanol-en-marcha/b1/cuaderno-unidad5b_las-otras-medicinas.md` | Nuevo Español en Marcha 3 (B1), **cuaderno de ejercicios**, unidad 5B | 21 | **solucionario oficial** (página 71 del propio cuaderno). El ej. 1 es de audio (pista 6) y lleva su transcripción, tomada de la página 65; el ej. 2 es actividad libre, así que no puntúa. Los ej. 1 y 3 se adaptaron a lista (en el libro se escribe sobre dos figuras y en una rejilla de crucigrama), avisando de ello en el enunciado |
| `nuevo-espanol-en-marcha/b1/cuaderno-unidad5c_el-sueno.md` | Nuevo Español en Marcha 3 (B1), **cuaderno de ejercicios**, unidad 5C | 22-23 | **solucionario oficial** (página 71), **con una excepción**: la clave se salta la fila de «oír» del cuadro del ejercicio 2, así que sus dos huecos (*oye*, *oiga*) están **deducidos** — las otras dos formas de esa fila vienen impresas en el libro. Los ej. 8 y 9 son de audio (pistas 7 y 8) y llevan su transcripción, de la página 65; los ej. 7 y 8 son de escribir y escuchar, así que no puntúan |
| `nuevo-espanol-en-marcha/b1/cuaderno-unidad6a_ecologicamente-correcto.md` | Nuevo Español en Marcha 3 (B1), **cuaderno de ejercicios**, unidad 6A | 24-25 | **solucionario oficial** (página 72 del propio cuaderno). El ej. 5 es de audio (pista 9) y lleva su transcripción, tomada de la página 65 (no hay grabación real); el ej. 6 es actividad libre, así que no puntúa — su caja de texto se envía al profesor sin corregir |
| `nuevo-espanol-en-marcha/b1/cuaderno-unidad6b_menos-humos-por-favor.md` | Nuevo Español en Marcha 3 (B1), **cuaderno de ejercicios**, unidad 6B | 25 | **solucionario oficial** (página 72). El ej. 2 es actividad libre (redacción con plantilla), así que no puntúa. El ej. 3 combina una pieza intermedia (a-h) y un final (1-8) por frase — se pide como «letra, número», igual que lo da el propio solucionario |
| `nuevo-espanol-en-marcha/b1/cuaderno-unidad6c_la-ecologista-del-himalaya.md` | Nuevo Español en Marcha 3 (B1), **cuaderno de ejercicios**, unidad 6C | 26-27 | **solucionario oficial** (página 72). El ej. 1 (comprensión del texto «Volver al campo») se corrige por palabra clave, no por frase exacta; el texto de lectura va en un recuadro de referencia dentro del propio ejercicio. El ej. 2 (vocales que faltan) se adaptó a «palabra enmascarada → palabra completa» en vez de recrear huecos letra a letra |
| `nuevo-espanol-en-marcha/b2/12b_turismo-cultural.md` | Nuevo Español en Marcha 4 (B2), unidad 12B | 12B | **solucionario oficial** del libro |
| `nuevo-espanol-en-marcha/b2/12c_perifrasis-verbales.md` | Nuevo Español en Marcha 4 (B2), unidad 12C | 12C | **solucionario oficial** del libro |

**La columna de respuestas importa.** Las de 12B y 12C vienen del solucionario impreso del
libro, que el profesor envió aparte: son autoridad.

Las de **Repaso B1** las dedujo Claude aplicando la gramática, porque las fotos no incluían
solucionario. El profesor ya corrigió varias sobre la marcha, pero conviene tratarlas como
revisables y no como autoridad. Donde había margen de duda, el artefacto lo explica en una
nota que aparece al corregir, y esa nota también está aquí.

Las de **A1 (unidades 1-8)** fueron **elaboradas** para el ejercicio, no vienen de un
solucionario del libro. El profesor lo confirmó. Distinto es el caso de **A1, cuaderno de
ejercicios, unidad 6A**: esas sí vienen del solucionario oficial que el profesor envió
aparte (foto), y cubren los ejercicios 1, 2 y 3 — incluidas las tres respuestas V/F del 3,
que es de audio (**pista 7** del CD del cuaderno) pero tiene respuesta cerrada y se corrige
como cualquier otro. Solo el ejercicio 4 se archiva sin respuesta: pide marcar un recorrido
sobre un plano, así que no hay texto que corregir.

El mapeo ejercicio→pista de ese cuaderno no está en ningún índice suelto del Drive: sale de
la sección **«Transcripciones»** del propio PDF del cuaderno, que sí es legible por
herramientas. Si hace falta la pista de otra unidad, se busca ahí antes que pedírsela al
profesor. Esa misma sección trae el **texto completo de cada audio**, y el PDF incluye
además su **solucionario**: en la 6A, ambos confirmaron por sí solos lo que el profesor
había enviado por foto (respuestas `1 va, toma, baja, cambia…` y `3 1 V 2 F, 3 V`). O sea
que de ese cuaderno, respuestas y transcripciones **no hace falta fotografiarlas**.

Por eso el archivo de la 6A incluye la transcripción de la pista 7 completa, y el propio
artefacto la muestra plegada dentro del ejercicio 3. Los nombres de las dos interlocutoras
(MARTA / BEATRIZ) no están en el original —allí cada réplica lleva solo un símbolo— y se
dedujeron del contenido; queda anotado también en el artefacto.

La **6B** se hizo entera desde ese mismo PDF, sin una sola foto: su página (la 29) no lleva
el plano incrustado que desordenaba la 28, así que el texto se extrae en orden. Solo dos
respuestas del ejercicio 1 salen ilegibles en el solucionario (los ítems 8 y 9), y se
deducen por descarte sin ambigüedad: quedaban libres «i la mesa» y «j a la derecha», que
solo encajan con «Recoge» y «Tuerce». La **ilustración** de esa página (la habitación
desordenada de Jaime, del ejercicio 5, dibujo de Maravillas Delgado según los créditos del
cuaderno) sí llegó por foto: el conector de Drive devuelve el texto del PDF pero no permite
descargar el archivo para extraer las imágenes, así que ese es el único trozo de 6B que no
salió del PDF. Está incrustada en el artefacto, sin el folio de la esquina.

La foto de la página completa sirvió además para corregir algo que el texto extraído no
dejaba ver: **en el ejercicio 1 el libro trae resuelto el ítem 1**, con la línea ya trazada
de «Pon» a «g la televisión». Los cinco ejercicios de 6B traen su primer ítem hecho como
modelo, y en el artefacto van marcados como tales, sin hueco.

## Cómo obtener el material de un capítulo nuevo

**Lo que hace falta es el PDF en disco**, no su texto. Dos vías: bajarlo del Drive del
profesor con `download_file_content` (devuelve base64; se decodifica a archivo) o pedirle
que lo adjunte al chat, que es lo que hay que hacer con los PDF grandes — por encima de unos
pocos MB la descarga falla con un engañoso «session expired» que **no** significa que el
conector esté caído (comprobado: 74 KB, 844 KB y 2,74 MB bajan bien; 8,4 MB y 8,8 MB no).

Con el archivo en la mano, `paginas.sh` da todo lo necesario:

```bash
cd docencia-espanol/fuentes
./paginas.sh /root/.claude/uploads/<sesión>/<archivo>.pdf <primera> [última]
```

Deja el texto en orden de lectura (`pdftotext -layout`, que respeta columnas y tablas), cada
página renderizada a JPEG, y las imágenes incrustadas a resolución original. Escribe fuera
del repo: las páginas del libro son material intermedio con copyright, aquí solo se archiva
la transcripción.

La única excepción es `pendientes/`: ahí sí se guardan la página y sus recortes, porque
son lo único que le quedará a la sesión que construya el capítulo cuando el PDF ya no
esté. Se borran en cuanto el capítulo se publica.

**Mira siempre el render antes de cerrar un capítulo**, aunque el texto haya salido
perfecto. Hay cosas que el texto no puede representar y que cambian las respuestas: las
líneas de un «relaciona», los ítems ya resueltos, lo rodeado a mano. La 6B se transcribió
con un hueco de más porque el ítem resuelto del ejercicio 1 era una línea dibujada,
invisible en el texto.

`read_file_content` no sustituye a la descarga: aplana el texto y lo desordena si la página
lleva un gráfico (como el plano de metro de la 6A). Sirve para localizar y para leer texto
corrido, no para transcribir. Las fotos de páginas son el último recurso, no el segundo.

## Origen de los escaneos

Repaso B1 (`RepasoB1.pdf`), 12B y 12C se transcribieron a partir de **fotos** enviadas por
el chat, antes de saber que se podía adjuntar el PDF: son escaneados sin texto extraíble y
el archivo excede lo que admite el conector de Drive. Por eso existe esta carpeta. Hoy no
haría falta fotografiarlos: con el PDF adjunto, `paginas.sh` renderiza cada página y se
transcribe mirándola. Si alguna vez hay que revisarlos, ese es el camino.

**El cuaderno de A1 trae su propio solucionario oficial al final** (páginas 56-61 del PDF; las
54-55 son las transcripciones de los audios y las 62-64 el glosario). Ahí están las respuestas de todas las unidades y de todos los
«Practica más». Eso significa que ningún capítulo de este cuaderno hace falta deducirlo:
antes de transcribir, renderiza esas páginas y ten el solucionario delante. Se descubrió
al preparar la unidad 7A —hasta entonces las respuestas se habían ido sacando de fotos
sueltas del solucionario— y sirvió además para confirmar las dos respuestas de la 6B que
estaban deducidas por descarte: coinciden.

El cuaderno de ejercicios de A1 (`Nuevo_espan_ol_en_marcha_1_A1_Cuaderno_d.pdf`) **tampoco
tiene capa de texto**: `pdffonts` no devuelve ninguna fuente, es un escaneado igual que los
anteriores. Durante un tiempo aquí puso lo contrario, porque el conector de Drive sí
devolvía texto de ese PDF y se dio por hecho que lo estaba extrayendo. En realidad lo que
devuelve es **su propio OCR**, y eso explica de golpe las dos rarezas que se le achacaban:
que el orden de lectura no coincidiera con el visual (se mezclaba con las etiquetas del
plano de metro de la 6A) y que aparecieran caracteres cambiados.

Consecuencia práctica: de este cuaderno **nunca hay que fiarse del texto del conector para
transcribir**. Se baja el PDF, se renderizan las páginas con `paginas.sh` y se leen. Así se
hizo la 6C, y mirar la página descubrió tres cosas que el OCR no mostraba: que el ejercicio
4 trae resuelto su primer ítem, que el 7 pide escribir el número del fragmento junto a cada
ritmo (y no al revés) y que en el recuadro del 8 la palabra «cultura» va tachada.
