# Fuentes transcritas

Archivo en texto plano del contenido de los capítulos de libro que ya se han transcrito a
partir de escaneos o fotos. **El objetivo es no volver a escanear ni volver a fotografiar
lo mismo**: si mañana hace falta una ficha en Word, una presentación o un ejercicio nuevo
sobre un capítulo que ya está aquí, se parte de este texto.

Cada archivo trae la teoría, los enunciados y **las respuestas en negrita**, en Markdown.

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
| `nuevo-espanol-en-marcha/a1/cuaderno-unidad6b_cierra-la-ventana.md` | Nuevo Español en Marcha 1 (A1), **cuaderno de ejercicios**, unidad 6B | 29 | **solucionario oficial** (los cinco ejercicios); dos respuestas del ej. 1 salen ilegibles y se deducen por descarte |
| `nuevo-espanol-en-marcha/b1/repaso-b1_secciones-1-12.md` | Nuevo Español en Marcha 3 (B1), repaso final | 140-163 | **deducidas**, sin solucionario |
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

## Origen de los escaneos

El PDF de Repaso B1 (`RepasoB1.pdf`, en el Drive del profesor) es un escaneado **sin texto
extraíble** y pesa más de lo que admite el conector de Drive, así que no se puede leer por
herramientas: llegó como fotos de las páginas enviadas en el chat. Lo mismo con 12B y 12C.
Por eso existe esta carpeta.

El cuaderno de ejercicios de A1 (`Nuevo_espan_ol_en_marcha_1_A1_Cuaderno_d.pdf`) es distinto:
**sí tiene texto extraíble** y está en el Drive del profesor, pero el texto sale desordenado
al extraerlo — se mezcla con las etiquetas del plano de metro incrustado en la página, y el
orden de lectura del PDF no coincide con el orden visual. Por eso la unidad 6A también se
transcribió a partir de una foto de la página, en vez de confiar en el texto del PDF.
