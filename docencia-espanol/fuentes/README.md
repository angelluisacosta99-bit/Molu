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
| `nuevo-espanol-en-marcha/b1/repaso-b1_secciones-1-12.md` | Nuevo Español en Marcha 3 (B1), repaso final | 140-163 | **deducidas**, sin solucionario |
| `nuevo-espanol-en-marcha/b2/12b_turismo-cultural.md` | Nuevo Español en Marcha 4 (B2), unidad 12B | 12B | **solucionario oficial** del libro |
| `nuevo-espanol-en-marcha/b2/12c_perifrasis-verbales.md` | Nuevo Español en Marcha 4 (B2), unidad 12C | 12C | **solucionario oficial** del libro |

**La columna de respuestas importa.** Las de 12B y 12C vienen del solucionario impreso del
libro, que el profesor envió aparte: son autoridad.

Las de **Repaso B1** las dedujo Claude aplicando la gramática, porque las fotos no incluían
solucionario. El profesor ya corrigió varias sobre la marcha, pero conviene tratarlas como
revisables y no como autoridad. Donde había margen de duda, el artefacto lo explica en una
nota que aparece al corregir, y esa nota también está aquí.

Las de **A1** fueron **elaboradas** para el ejercicio, no vienen de un solucionario del
libro. El profesor lo confirmó.

## Origen de los escaneos

El PDF de Repaso B1 (`RepasoB1.pdf`, en el Drive del profesor) es un escaneado **sin texto
extraíble** y pesa más de lo que admite el conector de Drive, así que no se puede leer por
herramientas: llegó como fotos de las páginas enviadas en el chat. Lo mismo con 12B y 12C.
Por eso existe esta carpeta.
