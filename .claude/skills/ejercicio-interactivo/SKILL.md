---
name: ejercicio-interactivo
description: "Use when Angel asks to build a new interactive Spanish grammar/vocabulary exercise page with instant grading — a self-contained HTML artifact where a student fills in blanks, gets corrected instantly, and can send their results to the teacher via WhatsApp/Telegram/Teams/Correo. Also use when asked to add a new chapter/unit to this format, or to fix/extend an existing one (e.g. the A1 \"Presente, gerundio, indefinido\" or B2 12C \"¿Sigues pintando?\" exercises already in docencia-espanol/materiales/). Triggers: \"ejercicio interactivo\", \"como el de A1/12C\", \"corrección instantánea\", \"página interactiva para practicar\", \"haz lo mismo con otro capítulo\"."
version: 1.14.0
user-invocable: true
license: Apache 2.0
---

# Ejercicio interactivo con corrección instantánea

Construye páginas HTML autocontenidas (sin backend) donde un alumno completa huecos, los
corrige al instante y puede enviar su resumen de resultados al profesor. Este formato ya
existe en dos ejercicios reales — A1 (`docencia-espanol/materiales/a1/...interactivo.html`) y
B2 12C (`docencia-espanol/materiales/b2/...interactivo.html`) — y pasó por más de una docena
de correcciones de bugs reales en producción, sobre todo en los botones de "enviar al
profesor". Parte siempre de `reference/template.html`, que ya trae esas correcciones; no lo
escribas desde cero.

Si te piden tocar los botones de envío (WhatsApp/Telegram/Correo/Teams) de un ejercicio ya
publicado, lee primero entera la sección "Canal por canal". Ese código salió de mucho
ensayo-error en dispositivos reales: una idea que "debería funcionar" (otro `window.open()`,
otro esquema de URL de app) ya se intentó y falló. Antes de proponer un cambio, mira qué PRs
tocaron esas líneas (`git log -p --follow <archivo>`) en vez de fiarte de la memoria.

## Reglas vigentes (resumen de una pantalla)

Este documento es largo: en una lectura rápida, o si el archivo se trunca, es fácil
quedarse con el principio y perderse una decisión posterior. Estas son las reglas que más
veces hubo que repetir. Si algo de aquí choca con una lección de "Lecciones aprendidas",
esta sección gana.

- **Cualquier elemento visual del cuaderno (no solo sopas de letras) se incrusta como foto
  real, siempre.** Foto, dibujo, cómic, cartel, tabla con ilustraciones, plano: si el libro
  lo imprime junto a un ejercicio, se recorta de la página renderizada (300 dpi) y se
  incrusta en `ex.refHTML`/`item.img`. Nunca se sustituye por una pista de texto inventada
  ("dos primeras letras", descripción del dibujo). Si la imagen ES la pista (el alumno debe
  reconocer o recordar mirándola), el nombre o la respuesta no aparece visible hasta que se
  acierta. Detalle en el punto del checklist "TODO lo visual que el libro imprime...".
- **Antes de dar un recorte por bueno, enderézalo si el libro lo imprime inclinado y ánclalo
  a un borde real, no a un margen a ojo.** Tres herramientas ya resueltas
  (`pip3 install opencv-python-headless numpy`): (1) medir la inclinación contra el
  silueteado de la propia foto, nunca a ojo ni con Hough directo sobre el contenido (ver el
  procedimiento de 4 pasos en el checklist); (2) para contenido con borde de caja limpio
  (sopa de letras, tabla), `cv2.adaptiveThreshold` + `MORPH_CLOSE` + `findContours` para el
  rectángulo de tinta exacto (ver "Recortes: anclar a bordes reales"); (3) para una forma
  circular, curva o irregular (retrato ovalado, viñeta, globo), `cv2.floodFill` con
  tolerancia de tono (ver "Recortar formas circulares/curvas"). Tras recortar, reléelo con el
  propósito explícito de buscarle un defecto, no de confirmar que "parece que está bien".
- **Sé muy minucioso con las fotos.** Revisa el borde entero a resolución real antes de
  incrustar, no solo el centro de una miniatura. Un recorte ya publicado y verificado con
  Playwright (imagen cargada, dimensiones correctas, cero errores) seguía arrastrando restos
  de texto del ejercicio vecino por la izquierda y la franja negra de diseño del margen por
  la derecha. Playwright confirma que el `<img>` funciona, no que el CONTENIDO del recorte
  esté limpio: la segunda comprobación se hace a ojo sobre el recorte final antes de
  publicar.
- **Sopa de letras siempre `type: "wordsearch"` interactiva** (rejilla real, tocar dos
  letras para marcar la palabra), nunca una lista de pistas de texto inventadas ni la foto de
  la rejilla como único soporte. Formato de datos y motor en la lección homónima y en
  `reference/template.html`.
- **Audio: búscalo activamente en Drive antes de conformarte con la transcripción.** Se
  busca primero; la transcripción es apoyo o último recurso. Ver el paso del checklist y la
  sección "Transcripciones y audio".
- **Nunca inventes una formulación distinta del ejercicio.** El ejercicio va tal cual está
  en el libro: mismo enunciado, misma tarea, mismas partes. Si el motor actual no puede
  reproducirlo exactamente (una interacción que no existe todavía, un formato que no encaja
  en ningún `type`), no lo rediseñes ni lo aproximes: pregunta al profesor. La respuesta
  puede ser añadir un tipo nuevo al motor (así nacieron `wordsearch` y `crossword`) o
  construirlo de otra forma con su visto bueno. Error real: la 8A de B1 imprime un solo
  ejercicio ("busca en la sopa de letras... ¿con qué deporte está relacionado cada uno?") y
  se decidió, sin consultar, partirlo en dos ejercicios separados.

## Flujo de trabajo

1. **Fundamenta el contenido en material real.** Por este orden:

   1. **Mira primero `docencia-espanol/fuentes/`** (ver su README). Ahí están en texto plano,
      con sus respuestas, los capítulos ya transcritos. Si el que necesitas está, parte de
      ese archivo: no pidas fotos ni vuelvas a transcribir. Mira también
      **`fuentes/pendientes/`**: ahí se deja el material de partida de un capítulo preparado
      en una sesión y construido en otra (el PDF adjunto no sobrevive al cambio de sesión;
      el repositorio sí). Si el capítulo está ahí, ya tienes texto, respuestas,
      transcripción del audio y dibujos recortados, y no hace falta el PDF. Al publicarlo,
      genera su archivo con `extraer.mjs` y **borra su carpeta de `pendientes/`**, o
      quedarán dos versiones del mismo capítulo.
   2. **Si no está, baja el PDF entero a disco.** Lo que hace falta es el archivo, no su
      texto: con él funciona todo `poppler`, y `docencia-espanol/fuentes/paginas.sh` saca de
      un tirón el diagnóstico, el texto en orden de lectura, la página renderizada como
      imagen y las imágenes incrustadas a resolución original. Dos vías:

      - **`download_file_content` del conector de Drive** (ver `docencia-espanol/CLAUDE.md`
        para el enlace y el orden de prioridad: Nuevo Español en Marcha > ПК Гонсалес >
        Temas). Devuelve el archivo en base64; se decodifica con
        `python3 -c "import json,base64; d=json.load(open(RUTA)); open(SALIDA,'wb').write(base64.b64decode(d['content']))"`.
        La respuesta será demasiado grande para el contexto y se volcará a un archivo: eso
        **no es un error**, es lo que interesa; se decodifica desde ahí.
      - **Que el profesor lo adjunte al chat.** Los adjuntos llegan a
        `/root/.claude/uploads/<sesión>/`. Es la vía para los PDF grandes.

   3. **El límite de tamaño de `download_file_content` miente al fallar.** Por encima de unos
      pocos MB devuelve **«MCP server "Google_Drive" session expired»**, que suena a sesión
      caducada y no lo es: el resto del conector sigue respondiendo en la llamada siguiente
      (medido: 74 KB, 844 KB y 2,74 MB bajan enteros; 8,42 MB y 8,83 MB fallan siempre). Si
      ves ese error, no concluyas que el conector está roto ni pidas fotos: es un PDF
      grande, y la salida es pedir que lo adjunte al chat.

      `read_file_content` no sustituye a la descarga: devuelve el texto aplanado y
      desordenado en cuanto la página lleva un gráfico incrustado (el plano de metro de la
      6A). Sirve para localizar y leer texto corrido, no para transcribir. La descarga
      directa por HTTP no es opción: el proxy la bloquea y el archivo es privado.
   4. **Fotos de las páginas: último recurso.** Solo si el profesor no puede adjuntar el PDF.
      Con el PDF en disco no hacen falta ni para las ilustraciones (`pdfimages` las saca
      mejor que una foto) ni para los escaneos sin texto (se renderiza cada página con
      `pdftoppm` y se transcribe mirándola).

   Todo lo que llegue por fotos hay que archivarlo después en `fuentes/` (paso 8), para que no
   se fotografíe dos veces el mismo capítulo.

   **Y mires lo que mires, mira la página.** Antes de dar por buena una transcripción,
   renderiza la página y ábrela con `Read`, aunque el texto se haya extraído perfectamente.
   Hay contenido que el texto no puede representar y que cambia las respuestas: las líneas de
   un ejercicio de relacionar, los ítems que el libro ya trae resueltos, las respuestas
   rodeadas, las flechas. En la 6B el ejercicio 1 se transcribió con diez huecos cuando el
   libro trae el primero resuelto (con una línea dibujada de «Pon» a «g la televisión»). El
   texto extraído tampoco es fiable al pie de la letra: en un PDF de ПК Гонсалес `pdftotext`
   devuelve `tъ` y `йl` donde la página pone **tú** y **él**.

2. **Copia la plantilla, no la reescribas.**
   `cp .claude/skills/ejercicio-interactivo/reference/template.html <destino>`. Sustituye
   **todos** los marcadores `{{...}}` (haz `grep` por `{{` para confirmar que no queda
   ninguno) y rellena `blocks` con los ejercicios reales, usando los tipos que soporta el
   motor (`items`, `text`, `table2`, `conjTable`, `open`, `crossword`, `agenda`, `match`,
   `wordsearch`; ejemplos dentro de la plantilla y en las lecciones de más abajo). Si
   necesitas un tipo nuevo, extiende también el renderizador (busca `ex.type ===`). Dentro
   de `items`, para un hueco de verdadero/falso pon `vf: true` en el item: cambia el input de
   texto por dos botones "V"/"F" sin tocar el motor de corrección (la respuesta sigue siendo
   `["V"]`/`["F"]`).

   **Un ejercicio de "relaciona" (el libro pide unir una columna con otra) usa SIEMPRE
   `type: "match"`:** columnas de verdad, tocar para conectar; nunca un hueco de texto donde
   el alumno escribe la letra o el número de la pareja. Vale igual si se llama "Relaciona",
   "Une cada X con Y" o pide emparejar dos listas de cualquier forma. El patrón antiguo
   (escribir la letra en un `input` de `items`) quedó obsoleto tras la unidad 6 de B1; el
   motivo y el formato de `columns`/`rows` están en la lección `"Relaciona" con columnas de
   verdad`. Antes de dar un capítulo por terminado, busca en su archivo cada exercise cuyo
   `title` contenga "Relaciona"/"relaciona" y confirma que su `type` es `"match"`.
   `reference/template.html` trae el motor de `match`, pero varios capítulos ya construidos en
   `docencia-espanol/materiales/` no (se copiaron de una base más antigua). Antes de copiar un
   capítulo existente como base, `grep -c '"match"' <archivo-base>`: si da 0 y el capítulo
   nuevo tiene algún "relaciona", porta el motor completo (CSS + rama de renderizado +
   `pendingMatchDraws`) desde la plantilla antes de escribir el primer ejercicio.

3. **Tildes: decide, no asumas.** La corrección del camino principal (`isCorrect`/`norm`)
   exige tilde exacta por diseño: en la mayoría de ejercicios de gramática la tilde
   distingue tiempos verbales o palabras ("trabaja"/"trabajó", "esta"/"está"). Si el
   ejercicio es de respuesta abierta donde la tilde no es lo evaluado, usa el spec
   `{flex:[...]}` (insensible a tildes) solo en esos huecos. Si dudas qué quiere el profesor,
   pregúntale; no aflojes `norm()`/`isCorrect()` globalmente.

4. **Verifica antes de publicar.** Usa Playwright (Chromium en `/opt/pw-browsers/chromium`,
   módulo en `NODE_PATH=/opt/node22/lib/node_modules`) para: desbloquear la puerta con el
   código, rellenar cada hueco con la respuesta correcta y confirmar que puntúa 100 %, probar
   una respuesta deliberadamente mala y confirmar que se marca como error, y comprobar los
   cuatro botones de envío. Toma capturas en viewport móvil para revisar el layout.

   **Probar con `file://` local no reproduce el iframe con sandbox** que usa el artefacto
   cuando se comparte públicamente. Varios bugs reales solo aparecían en el artefacto
   publicado. No declares "funciona" solo por pasar las pruebas locales: publica y, si es
   posible, pide al profesor que lo pruebe en un dispositivo real antes de cerrarlo.

5. **Publica con el tool `Artifact`.** En la primera publicación pasa `icon` (una palabra
   genérica, distinta por nivel si quieres distinguirlos en la lista, p. ej. `exercise`; el parámetro `favicon` está obsoleto) y `description`. Al
   actualizar un artefacto ya publicado, pasa siempre el mismo `url` para no crear uno nuevo.
   Título: `Nuevo Español en Marcha · <Nivel> · <Capítulo> — <Tema>` (ver los ya publicados),
   para que se lea claro en la lista plana de Artefactos y en el índice del paso siguiente.

   **Publicar NO es terminar.** Los pasos 6 y 7 forman parte de publicar un capítulo.

6. **Añade el capítulo al índice.** `docencia-espanol/materiales/indice-clases-de-espanol.html`
   es el artefacto "Clases de Español", la página de entrada que organiza todo por manual →
   nivel → capítulo (sistema de diseño compartido en `PRODUCT.md`/`DESIGN.md`, en la raíz).
   Al publicar un capítulo nuevo: dentro de la tarjeta `.level-card` del nivel
   correspondiente, sustituye la fila `.chapter-row.empty` de "Próximo capítulo, pronto" por
   una fila real (`<a class="chapter-row" href="<url del artefacto>" target="_blank"
   rel="noopener">` con `.chapter-num`/`.chapter-title`/flecha, copiando el patrón de las
   existentes) y añade una nueva fila `.empty` al final si quieres dejar sitio para el
   siguiente. Vuelve a publicar el índice con el mismo `url`. Si algún día se añade un manual
   nuevo (ПК Гонсалес, Temas; ver la nota "Próximos manuales" del índice), duplica el bloque
   `.manual-section` completo en vez de mezclar niveles de manuales distintos.

7. **Añade el código a `docencia-espanol/materiales/codigos-acceso.html`.** Es la referencia
   privada del profesor (nivel, capítulo, código, enlace) para cuando un alumno pide el
   código en clase: añade una fila a la tabla y vuelve a publicar con el mismo `url`.
   **Nunca enlaces esta página desde el índice público ni desde ningún material que puedan
   ver los alumnos.** No es seguridad real (el código es solo un disuasivo, visible en el
   código fuente de cada ejercicio), pero no tiene sentido poner todos los códigos juntos a
   la vista de quien reciba el enlace.

8. **Archiva la transcripción en `docencia-espanol/fuentes/`. Siempre.** Instrucción
   explícita del profesor: no quiere volver a escanear ni fotografiar un capítulo ya
   transcrito. En cuanto el artefacto esté publicado y verificado, genera su archivo de
   texto:

   ```bash
   cd docencia-espanol/fuentes
   NODE_PATH=/opt/node22/lib/node_modules node extraer.mjs \
     ../materiales/<archivo>.html <CÓDIGO> > nuevo-espanol-en-marcha/<nivel>/<capítulo>.md
   ```

   `extraer.mjs` abre el artefacto en un navegador, rellena los huecos con texto imposible,
   corrige y recoge del DOM cada enunciado con la respuesta que revela el propio motor. **No
   transcribas ese archivo a mano**: lo que se archiva así es exactamente lo que se
   verificó. Si más adelante se corrige una respuesta en el artefacto, **regenera** el
   archivo en vez de editarlo.

   Añade también su fila a la tabla de `fuentes/README.md`, anotando de dónde salieron las
   respuestas: del solucionario del libro, o deducidas. Esa distinción evita que dentro de
   unos meses se tomen por buenas unas respuestas sin confirmar.

9. **Sigue el flujo de PR de `CLAUDE.md` (raíz).** Abrir el PR no dispara nada más; solo
   cuando el profesor pida fusionarlo se lanza la revisión con un agente independiente
   sobre el estado actual del PR (con contexto completo, y pidiéndole que verifique en vivo
   con Playwright en vez de fiarse de la descripción; p. ej. skill `code-review` o `Agent` en
   segundo plano), y se fusiona solo sin hallazgos
   bloqueantes.

   Los PRs anteriores de esta rama se fusionaron con `squash`, así que sus commits dejan de
   ser ancestros literales de `main`. Si antes de abrir un PR nuevo
   `git merge-base --is-ancestor <último-commit> origin/main` falla, ese commit ya no es
   ancestro de `main`: avisa al profesor, rehaz la rama
   (`git fetch origin main && git checkout -B <rama> origin/main`) re-aplicando
   (`git stash`/cherry-pick) solo los commits todavía no fusionados, y no fuerces un push sin
   confirmar qué commits se perderían.

### Checklist antes de dar por publicado un capítulo

Repásala **cada vez**, aunque el capítulo haya costado mucho y parezca acabado. Con Repaso B1
se publicó, se verificó y se fusionó, y aun así los pasos 6 y 7 se quedaron sin hacer
(la tarjeta del índice seguía diciendo "todavía sin capítulos publicados" y el código no
estaba en la lista del profesor): el fallo no fue no saber los pasos, sino no volver a
mirarlos al final.

- [ ] Artefacto publicado, y **con el mismo `url`** si ya existía.
- [ ] Fila añadida en `indice-clases-de-espanol.html`, en la tarjeta del nivel correcto, y el
      índice republicado (paso 6).
- [ ] Fila añadida en `codigos-acceso.html` con su código, y republicado (paso 7).
- [ ] Transcripción archivada en `docencia-espanol/fuentes/` con `extraer.mjs`, y su fila en
      el README de esa carpeta indicando el origen de las respuestas (paso 8).
- [ ] No queda ningún marcador `{{...}}` ni la cabecera de la plantilla sin adaptar (esa
      cabecera se publica en el código fuente que ve el alumno).
- [ ] **Si algún ejercicio es de audio ("Pista N", "Escucha y..."), se buscó el mp3 real en
      Drive ANTES de conformarse con la transcripción.** Obligatorio, no "si hay tiempo": ya
      se saltó dos veces (A1, y A2 Unidad 1). Ver la sección "Transcripciones y audio".
- [ ] **TODO lo visual que el libro imprime junto a un ejercicio** (foto, retrato, cartel,
      cómic, tabla con dibujos, plano, cuadro, ilustración de cualquier tipo) **se recorta de
      la página renderizada y se incrusta como `ex.refHTML`/`item.img`.** Nunca solo texto
      cuando el libro trae una imagen real. Es un requisito permanente: por defecto se
      asume que SÍ hay que incrustarlo, y la excepción (texto puro, sin nada gráfico en esa
      página) es la que hay que justificar. Mirar la página para no perder texto no es lo
      mismo que decidir incrustar sus fotos: A2 U1/U2 se publicaron sin ninguna foto real, y
      luego faltaron otras en las unidades 1B, 1C y 3.
      Recórtalas con PIL sobre el render a 300 dpi (con `pymupdf` si falta poppler, ver
      "PDF y herramientas"), en blanco y negro y JPEG moderado (`quality=75-80`), e
      incrústalas como `data:` URI: un artefacto no puede enlazar un archivo externo.
      `ex.refHTML` ya soporta HTML arbitrario (`<img>`, `<figure>`); si el bloque ya tiene otro
      `refHTML` (un banco de palabras), añade las fotos AL PRINCIPIO de esa misma cadena (el
      campo es uno solo).
      **Tamaño:** dale siempre a la imagen `style="max-width:min(XXXpx, 100%)"`, nunca un
      `max-width:XXXpx` a secas. Sin límite, la imagen hereda el ancho completo de
      `.exercise-ref` y sale desproporcionada; y un `px` fijo inline GANA a la regla global
      `.exercise-ref img { max-width: 100% }` (mismo peso de especificidad, el inline
      pesa más), así que la imagen fuerza su ancho aunque no quepa: una ilustración de 420 px
      desbordaba 89 px a 390 px de viewport hasta cambiar a `min()`.
      **Antes de dar una foto por buena, comprueba si el propio libro la imprime inclinada**
      (frecuente en fotos de collage o revista: boda, ciudades tipo postal, foto de
      escritorio): si una referencia real (un horizonte, un edificio, una persona de pie, el
      borde recto de la foto impresa) no queda vertical u horizontal, es la inclinación de
      impresión, no un defecto de tu recorte, y hay que enderezarla antes de incrustarla. No
      confíes en el ojo ni en Hough sobre el contenido: **mide el ángulo del rectángulo de la
      foto contra el fondo de la página**:
      1. Umbraliza una región amplia de la página (`cv2.threshold(gray, 200, 255,
         THRESH_BINARY_INV)`; ajusta el 200 si el fondo no es blanco puro) y cierra huecos
         (`cv2.morphologyEx(..., MORPH_CLOSE, np.ones((9,9)))`) para obtener la silueta de la
         foto como un blob sólido contra el fondo claro.
      2. Recorta con MUCHO margen alrededor: si el contorno toca el borde del recorte,
         `cv2.boundingRect`/`minAreaRect` da lecturas degeneradas (exactamente 0° o -90°, o
         un rectángulo del ancho completo). Si dos fotos están pegadas (Sevilla/Córdoba en
         collage), aísla la región de UNA sola, o sus siluetas se fusionan en un blob mal
         formado.
      3. Con el contorno más grande aislado (`max(contours, key=cv2.contourArea)`), no te
         fíes del ángulo de `cv2.minAreaRect` (su convención de signo y qué lado es "ancho"
         es ambigua): mide tú la pendiente. Recorre columnas (`for x in range(...)`), anota
         la primera fila `True` de la máscara en cada una (el borde superior de la foto) y
         ajusta `np.polyfit(xs, ys, 1)`; el ángulo es `np.degrees(np.arctan(pendiente))`. Si
         el escaneo sale ruidoso o no monótono (el borde pasa cerca de texto u otro
         elemento), aísla antes el contorno con `cv2.drawContours(mask, [c], -1, 255, -1)` y
         repite sobre esa máscara limpia.
      4. Rota con el ángulo medido (`PIL.Image.rotate(-ángulo, expand=True, fillcolor=...)`;
         comprueba el signo visualmente la primera vez de cada sesión, después es el mismo
         para toda la tanda) y vuelve a recortar ajustado (`cv2.boundingRect` sobre la imagen
         ya rotada, que ahora da un rectángulo limpio).
      Ejemplos reales: Sevilla +1,4°, Córdoba -4,3° y la postal de Barcelona +1,9°, todas
      en sentidos distintos porque el libro las imprime como recortes de collage sueltos.
      **La tira cómica "Leo Verdura" es la lección inversa:** a ojo (y con Hough sobre un
      recorte estrecho) parecía inclinada 1-2°, y la rotación aplicada la torció más; medido
      sobre el marco superior del cómic (un borde limpio y largo) el ángulo real era -0,5°.
      Ni la foto ni el ojo son fiables por sí solos: mide siempre contra un borde recto real.
      La excepción real fue la foto de la boda de la unidad 3A (fondo de personas y árboles,
      sin silueta limpia): ni el silueteado ni Hough dieron una lectura fiable y se resolvió a
      ojo contra la verticalidad del novio. Documéntalo explícitamente cuando tengas que
      recurrir a esto: es el último recurso.
- [ ] Si el material no viene claramente de un manual concreto, **pregunta al profesor** en
      vez de archivarlo por deducción (`RepasoB1.pdf` era un PDF suelto y se colocó bajo
      "Nuevo Español en Marcha 3" por parecido de formato; resultó correcto, pero la deducción
      se dio por buena sin preguntar). Preguntar cuesta una frase; moverlo después implica
      rehacer índice y códigos.
- [ ] Si índice/códigos/README se sincronizaron copiando el estado ya publicado de una rama
      hermana todavía sin fusionar (para no revertir sus filas en vivo), **revisa fila por
      fila que cada una tenga su archivo real en ESTA rama** antes de commitear. Copiar el
      `README.md` de otra rama trae también SUS filas de archivo (`.md` de unidades que esa
      rama construyó y la tuya no). Índice y códigos solo enlazan a artefactos ya publicados
      (válido aunque el `.html` fuente no esté en tu rama), pero una fila de README que dice
      "archivado, ver este .md" para un archivo que no existe en tu checkout es una
      afirmación falsa.

## Lecciones aprendidas (no las repitas)

Cada una causó una corrección real. Están en `reference/template.html` ya resueltas: esta
lista explica *por qué* el código está como está, para no deshacerlas al modificar la
plantilla.

### Estructura de capítulos y publicación

- **Cuando el libro organiza un capítulo en secciones con letra (A, B, C...), cada sección
  es un ARTEFACTO/ARCHIVO SEPARADO.** Nunca varias secciones en un único artefacto, ni con
  `blocks` múltiples ni de ninguna otra forma. Convención establecida en TODO el repo: A1 y
  B1 llevan un `.html` (y un artefacto publicado, con su propio código de acceso) por cada
  sección (`cuaderno-unidad1a_encantado_interactivo.html`,
  `cuaderno-unidad1b_a-que-te-dedicas_interactivo.html`, ...), nunca un "Unidad 1"
  combinado. Cada archivo usa la plantilla tal cual: un único `block` con `num: 1` (no una
  letra), sin píldoras de navegación entre secciones, porque cada sección ES el documento
  entero. El campo `blocks` (varios bloques en un archivo) SOLO es para una guía de repaso
  que de verdad es un único documento con varias secciones temáticas (la guía de repaso B1,
  de 12 secciones), nunca para dividir un capítulo normal del cuaderno.
  Ante una corrección de estructura, comprueba primero cómo la resuelven capítulos ya
  existentes de OTRO nivel (`ls docencia-espanol/materiales/a1/`, `.../b1/`) antes de
  inventar un mecanismo nuevo: la respuesta ya estaba en el repo, con 30+ archivos de
  precedente. (Las unidades 1-3 de A2 se rehicieron como 9 archivos separados tras
  publicarse primero numeradas seguidas y luego con tres `blocks` en un artefacto.)
- **Dividir un artefacto ya publicado en varios (o renumerar/renombrar capítulos) exige
  volver a publicar el índice y `codigos-acceso.html`.** Un `git push` de los archivos fuente
  NO actualiza esas dos páginas, que viven como artefactos aparte. Aplica también al EDITAR
  un capítulo existente: cualquier alta, baja o edición de fila no cuenta como hecha hasta
  que se ve reflejada en la URL pública, no en el archivo del repo. Si no tienes la URL a
  mano, `Artifact` con `action: "list"` la encuentra por título ("Clases de Español —
  Índice", "Códigos de acceso — Clases de Español").
- **Un bug de motor encontrado por revisión se arregla en `reference/template.html` Y en la
  copia horneada de CADA capítulo ya construido en esa rama.** Cada `..._interactivo.html`
  es una copia independiente del motor con los datos insertados, no hereda de la plantilla
  en tiempo real. Antes de cerrar un arreglo de motor, `grep` el patrón roto (o su versión
  arreglada) en todos los `..._interactivo.html` de la rama, uno por uno, y confirma que
  coinciden: no solo el que disparó el hallazgo (un bug de `match` se parcheó solo en 1B y
  no llegó a 1A/1C/2A/2B/2C, y en la ronda siguiente 1C se quedó fuera porque el script de
  parcheo asumía que ya tenía el primer arreglo). Cuando portes una mejora a un capítulo
  concreto, pásala también a `reference/template.html` en ese momento, o el siguiente
  capítulo la perderá.
- **Si tocas cómo se construye una fila, comprueba `extraer.mjs`.** Al pasar el ejercicio 5
  de Practica más 3 a columnas, el `.md` archivado empezó a salir con las respuestas pegadas
  (`**habla****regular**`): el separador que ponía el texto de `item.t` había desaparecido, y
  `extraer.mjs` necesitó reconocer `.item-pre` y añadir un espacio entre dos huecos
  consecutivos. Regenera y compara con `diff` **todos** los `.md` tras cualquier cambio
  estructural, no solo el del capítulo que tocas.
- **`ex.refHTML` y cualquier propiedad que el renderizador no lea se ignoran en silencio.**
  `refHTML` había nacido en Repaso B1 y se portó a mano solo a 6A; al montar 6B (un
  «relaciona» de diez ítems) se dio por hecho que la plantilla lo traía, y el artefacto se
  publicó con «Pon ___», «Habla ___»... y ninguna opción a la vista (irresoluble). Lo mismo
  pasó con `type: "open"` y con la transcripción plegable. Después de rellenar `blocks`,
  comprueba con `grep` por su nombre que cada propiedad que has usado la lee de verdad el
  renderizador.
- **Si el libro enseña al alumno unas opciones, el artefacto también tiene que
  enseñárselas** (banco de palabras, opciones a-j de un relacionar): un ejercicio sin las
  opciones a la vista es imposible, y así se publicó la primera versión de Repaso B1. Se
  ponen en `ex.refHTML`.

### Tipos de ejercicio

- **Sopa de letras: `type: "wordsearch"` interactiva (`ex.words[i] = {label, cells, img?}`).**
  Error real: la 1B sustituyó la sopa del libro (ocho profesiones, con dibujo cada una) por
  una lista "PR ___ (corta el pelo a un niño)"; el profesor lo corrigió: "cíñete al libro" y
  "una forma interactiva donde el alumno pueda seleccionar directamente en la sopa". La
  rejilla y las coordenadas de cada palabra se calculan con un script de búsqueda
  direccional sobre la transcripción de la página (nunca a mano: un error de una letra hace
  que `cells` no encaje con lo impreso). Segundo fallo del mismo arreglo: la primera versión
  corregida listaba el NOMBRE de cada profesión junto al dibujo, dándole la respuesta al
  alumno. Regla general: **cuando la pista del libro es un DIBUJO, el nombre o la respuesta
  nunca va visible hasta que el alumno la resuelve**, ni en `item.img` de "items" ni en
  `ex.words[i].img` de "wordsearch"; el texto se revela DESPUÉS de acertar, como un
  `.reveal` normal. Además, una sopa necesita una pista por hueco (los huecos se corrigen en
  orden fijo, así que sin pista cualquier palabra valdría en cualquier hueco): añade las dos
  primeras letras y di en el enunciado que es un añadido del artefacto. Y antes de darla por
  buena, **busca cada palabra del solucionario en la rejilla con un script, en las ocho
  direcciones** (en Practica más 3 «LECHUGA» va hacia la izquierda y a ojo no aparecía).
- **"Relaciona" con columnas de verdad (`type: "match"`).** El patrón antiguo (escribir la
  letra o el número de la pareja en un hueco de texto) no se parecía al ejercicio real
  (tocar/unir; 6A ej. 2 y 6B ej. 3 aún lo usan) y obligaba a aceptar muchas variantes de tecleo (`"d, 2"`, `"d,2"`, `"d 2"`,
  `"d2"`) porque `norm()` quita comas y puntos pero no espacios internos. `ex.columns` es un
  array de columnas (`{ label, items: [...] }`); `columns[0]` es la columna ancla (fija, una
  por fila) y las demás son elegibles. `ex.rows` es paralelo a `columns[0].items`:
  `{ solved: true }` para una fila ya resuelta en el libro (sin huecos ni botones), o
  `{ a: [spec1, spec2, ...] }` con un spec de `isCorrect()` por cada columna elegible, en
  orden. Se toca primero un elemento de la columna ancla (queda resaltado en dorado) y luego
  su pareja en la siguiente columna: se guarda en un `input type="hidden"` (el mismo truco
  del V/F, así que `gradeRange` lo trata como cualquier hueco de texto) y se dibuja una línea
  de color con un `<svg>` superpuesto a `.match-wrap`. Con 3 columnas la interacción
  encadena (ancla → columna 1, y sin desarmar la fila, columna 1 → columna 2). Una opción
  solo puede pertenecer a una fila a la vez: tocarla desde otra fila se la quita a la
  anterior.
  - **Trampa de timing:** `getBoundingClientRect()` de las fichas da 0,0,0,0 si se llama
    durante la construcción del ejercicio, porque el `<section>` del bloque aún no está
    insertado en `#main` (se inserta al final de `block.exercises.forEach`). `drawLines()`
    de cada "match" se guarda en `pendingMatchDraws` y se llama a todas una vez, tras
    `blocks.forEach(...)`. Un solo listener de `resize` (no uno por ejercicio) las repite.
  - **`extraer.mjs`:** el archivador nunca toca los botones (solo rellena `input.blank` de
    texto y pulsa "Corregir"), así que cada fila de "match" llega sin opción elegida, que es
    el caso en que `ex._onGraded()` rellena su `.match-row-reveal` con la respuesta completa;
    el archivador lee `.match-anchor`/`.match-solved` + el `.match-row-reveal` siguiente.
  - **El color de corrección no debe quedarse pegado:** `ex._onGraded()` solo añade
    `.match-correct`/`.match-incorrect` a la ficha elegida en ese momento. Se quitan esas dos
    clases de la ficha abandonada (y de la recién elegida, por si venía de otra fila ya
    corregida) en el propio manejador de clic de `mwrap`, no solo en `_onGraded()`.
  - **`columns[1].items` (y toda columna no ancla) van SIEMPRE en un orden distinto al de
    `columns[0]`, nunca fila i con fila i.** Error real en 10C de A1: las columnas estaban
    en el mismo orden que la pareja correcta, así que el ejercicio salía ya resuelto con
    unir en horizontal. No se toca `rows` (el emparejamiento es por contenido): basta
    revolver `items` de la columna no ancla, con un derangement completo si es fácil o al
    menos sin filas alineadas por casualidad. Mira la captura del ejercicio renderizado y
    confirma que ninguna pareja correcta queda en la misma fila visual.
  - **Un ítem que admite varias letras** (en Practica más 3 el aceite está en tres platos):
    genera las permutaciones con espacio tras la coma (`"a, b, c"`). Ya no hace falta la
    variante sin espacio: `norm()` sustituye la coma por un espacio y colapsa espacios
    seguidos, así que ambas formas normalizan igual.
  - **Cuando el ejercicio numere sus opciones con letras, numera los ítems
    (`ex.numbered`)**: ítems a., b., c. junto a opciones a-j crean dos series de letras que
    no significan lo mismo. El libro numera los ítems 1-10; cópialo.
- **Crucigrama real (`type: "crossword"`).** `ex.words` es una lista de
  `{ num, clue, answer, row, col, dir: "A"|"D", solved? }`; el renderizador calcula una sola
  vez la celda de cada cruce (sin dos inputs superpuestos) y reutiliza el motor de corrección
  (cada celda es un `makeInput([letra], ...)` normal, así que se colorea sola). `extraer.mjs`
  no tenía `.item-row` que recorrer: las celdas llevan `data-w<num>="<índice>"` y
  `data-letter` para reconstruir cada palabra sin depender de un `.reveal`. **Lección:** leer
  las coordenadas EXACTAS de la rejilla del libro celda a celda con análisis de píxeles
  (`PIL`+`numpy`) es fiable para los primeros cruces y deja de serlo según uno se aleja de
  una referencia clara; y un cruce mal leído no marca una respuesta como incorrecta,
  **hace el crucigrama irresoluble** (dos palabras que deberían compartir letra y no la
  comparten). En cuanto la lectura de píxeles deje de ser sólida, deja de perseguir el layout
  del libro y **diseña una rejilla propia** con las mismas palabras y definiciones: coloca
  los cruces confirmados y busca por código (no a ojo) una letra compartida real para el
  resto (bloque de placement con `can_place`/`find_crossings`). No será pixel-perfect pero
  está garantizada correcta por construcción.
- **Si el libro marca las respuestas como «posibles respuestas», el ejercicio no puntúa.**
  Corregirlo contra una sola solución marcaría en rojo respuestas correctas. Va como
  `type: "open"`, con los enunciados a la vista, las del solucionario en un plegable para
  comparar y **una nota con la regla que se está practicando** (en la 5A: tras *para que*,
  subjuntivo; tras *para*, infinitivo), para que el alumno pueda autocorregirse aunque su
  frase no sea la del libro. `type: "open"` no genera huecos, no puntúa y **no lleva botón
  "Corregir"** (un botón que no hace nada es peor que no tenerlo); es la salida cuando un
  ejercicio del original no tiene respuesta única (transcribirlo así, no omitirlo ni
  inventarle una respuesta). El motor añade solo, bajo `ex.html`, un aviso ("esto no se
  corrige aquí, lo revisará tu profesor") y un `<textarea>` (`.open-answer`); ese texto se
  guarda en `openAnswers` (junto a `allInputs` y `allExercises`) y `buildSummary()` lo añade
  tal cual, con número y título, al resumen que se envía al profesor.
- **Hueco de verdadero/falso (`item.vf: true`): el input real se queda, solo se oculta.**
  `gradeRange`, `isCorrect` y `extraer.mjs` dependen de encontrar un `input.blank` real para
  leer/escribir su `.value`, así que el input sigue existiendo como `type="hidden"` y dos
  `<button>` visibles le escriben `"V"`/`"F"` al hacer clic. Como un input oculto no se ve,
  se añadió un hook genérico `rec.onGrade(ok)` que `makeVfButtons` usa para colorear el
  botón elegido. **`extraer.mjs` tuvo que aprender la envoltura `.vf-wrap`**; sin eso el
  texto de los botones se colaba literal en la frase archivada (`→ **?**VF`). Si añades otro
  hueco "no-texto" (chips, slider...) que oculte el input real, revisa si necesita el mismo
  ajuste en `extraer.mjs`. `vf` acepta además un par cualquiera y puede aplicarse a un solo
  hueco: `vf: true` (V/F en todos los huecos del ítem), `vf: ["regular","irregular"]` (ese
  par) y `vf: { 1: [...] }` (solo el hueco {1}); la tercera forma hace falta cuando un ítem
  mezcla escribir y elegir («hablar → [imperativo] [regular|irregular]»).
- **El ítem que el libro trae resuelto va con `item.solved: true`, no como hueco.** Casi
  todos los ejercicios traen el primer ítem hecho como modelo; ponerlo como hueco pide al
  alumno algo ya impreso en su cuaderno y descuadra la puntuación. Con `solved: true` la fila
  se pinta en gris cursiva, se ve y no genera hueco. El texto extraído del PDF no siempre
  delata cuál es (en 6B es una línea dibujada entre columnas): si el capítulo viene solo del
  PDF, sospecha del ítem 1 de cada ejercicio.
- **Un listado que en realidad es una tabla, hazlo tabla (`conjTable`/`conjTables`).** El
  ejercicio 4 de Repaso B1 (imperativos irregulares) eran 16 filas «VERBO · persona →
  afirmativo ___, negativo ___» como `items`: sin alineación posible (la etiqueta mide
  distinto en cada fila) y las dos filas medio resueltas, con un solo hueco, se estiraban
  (`.tail-blank`) mientras las otras catorce no. Como cuadro de conjugación (un cuadro por
  verbo, columnas «Afirmativo»/«Negativo», formas dadas como **cadena** en vez de array para
  que salgan fijas y no cuenten como hueco) todo cae en columnas. Si las filas comparten
  estructura y no son frases, es una tabla. La plantilla trae `conjTable` (un cuadro);
  `conjTables` (varios cuadros en un ejercicio, con un solo botón «Corregir») es un añadido
  de Repaso B1: cópialo de ahí. Si el documento estrecha los huecos de las tablas (Repaso B1
  pone `.exercise-table input.blank` a 6.4 em), ensancha los cuadros de solo dos columnas de
  respuesta con `tr:has(td:nth-child(3)):not(:has(td:nth-child(4)))` (con 6.4 em «no vengáis»
  se cortaba) y da aire entre cuadros consecutivos (`.table-wrap + .table-wrap`). En una
  tabla, una celda ya resuelta en el libro va con spec como **cadena**, no como array (en 6B
  las filas de «cerrar» y «seguir» y el presente de «guardar»); `ex.subjectLabel` cambia el
  encabezado de la primera columna, fijado a «Sujeto», que en una tabla de infinitivos no
  significa nada.
- **Cuando todas las filas de un ejercicio tienen la misma forma, alinéalas en columnas con
  `item.pre`.** Un listado «palabra → casilla → botones» con la palabra dentro de `item.t`
  empieza cada casilla donde acaba su palabra: casillas de distinto ancho, botones a distinta
  altura. `item.pre` saca la etiqueta a un elemento propio de ancho fijo y la fila pasa a ser
  un flex con columnas. Hay que fijar tres cosas: la etiqueta (`flex: 0 0 8.8em`), la
  **letra del ítem** (`i.` y `m.` no miden lo mismo y arrastran la diferencia) y el **ancho
  de los botones** cuando son palabras (`.vf-toggle.vf-words`, que `makeVfButtons` marca sola
  al ver opciones de más de un carácter). Usa `flex-basis` fijo, no `min-width`: con
  `min-width` la etiqueta más larga del grupo empuja su fila.
- **`isCorrect()` NO soporta mezclar cadenas exactas y `{flex:[...]}` dentro del mismo
  array.** Spec real: `a: [["curar"]]` (array de cadenas, comparación exacta) O
  `a: {flex:["curar"]}` (objeto suelto, todas las claves deben aparecer); nunca los dos
  mezclados (`a: [["curar"], {flex:["cura"]}]`). Con un array, `isCorrect()` hace
  `spec.some(a => norm(a) === n)`: si un elemento es un objeto `{flex:...}`, `norm(objeto)`
  revienta (`objeto.toLowerCase is not a function`) y esa excepción sin capturar **aborta
  silenciosamente `gradeRange()` para TODOS los huecos restantes de la página**, sin error
  visible para el alumno (solo en la consola). Trampa de test: la suite de regresión que
  rellena siempre la respuesta PRIMARIA no lo detecta, porque `some()` corta en cuanto
  encuentra la cadena correcta sin evaluar el elemento roto; hace falta una prueba que
  escriba cada alternativa. Para aceptar varias formas cortas en un hueco, lístalas todas
  como cadenas: `a: [["reproductor de música", "reproductor", "mp3"]]`.
- **`flex` es un Y de palabras clave y no expresa alternativas.** Si el ejercicio admite de
  verdad varias respuestas distintas (vosotros/ustedes, `-ara`/`-ase`, *«Hacía calor»*/*«Hacía
  sol»*), hace falta un array (que sí es un O) con `conSinTildes([...])`, que amplía una
  lista de respuestas aceptadas con su versión sin tildes. La vía de array es estricta con
  los acentos a propósito y eso es correcto cuando el acento ES lo que se evalúa
  (`está`/`esta`, `trabajo`/`trabajó`); en respuestas abiertas de léxico o de fórmulas
  (*«Hacía mucho viento»*, *«¿Podrías…?»*) exigir tilde convierte el ejercicio en un dictado,
  así que úsalo solo ahí, nunca en huecos de forma verbal. Al revés, para descartar un error
  concreto sin castigar la tilde, una clave de `flex` bien elegida lo hace sola (`"le dé
  azúcar"` acepta *dé* y *de*, pero rechaza *des*).
- **Tildes estrictas por diseño**: no es un bug a "arreglar" aflojando `norm()` /
  `isCorrect()` globalmente sin consultar al profesor (ver el paso 3).

### Layout de huecos, diálogos y fotos

- **`item.wide`: cuatro opciones.** Ningún `wide` = una palabra corta, un hueco por ítem;
  `"narrow"` (4.2em) = una palabra muy corta pero VARIOS huecos en la misma frase
  (preposiciones, artículos; con el ancho por defecto de 8.5em, 3-4 huecos así no caben en
  una línea de móvil y cada uno salta a la suya); `true` = una o dos palabras algo largas;
  `"full"` = hueco que sustituye una frase entera propia. `"full"` pone el input en
  `display: block; width: 100%`: cualquier texto que venga después del hueco en esa línea de
  plantilla (una palabra, «?», lo que sea) se empuja a SU PROPIA línea, huérfano. Si después
  del `{0}` queda CUALQUIER cosa más que un salto de línea (`\n`), el hueco NO es de frase
  entera: quítale `wide: "full"`.
- **Preguntas completas con el interrogante fuera del hueco (`"A ¿{0}?\nB ..."`): el
  profesor SÍ quiere el «¿» y el «?» visibles como texto fijo a ambos lados del hueco, NO
  escondidos dentro de la respuesta** (un primer arreglo metió la pregunta entera en
  `a: [["¿Eres español?"]]` y se rechazó). El patrón correcto es
  `t: "A ¿{0}?\nB ..."`, `a: [["Eres español"]]`, con `wide: "full"`, y el arreglo va en el
  motor: la "cola" (lo que sigue al hueco) se calculaba recorriendo TODOS los hermanos
  siguientes sin parar en el primer `<br>`, así que en un diálogo A/B incluía la réplica de B
  y nunca pasaba el test de "solo puntuación de cierre"; ahora los dos bucles
  `let cola = ..., n = ...nextSibling; while (n) {...}` (huecos de texto y V/F) cortan en el
  primer `<br>` (`while (n && n.nodeName !== "BR")`). Si tras el hueco viene una PALABRA
  además del signo (`"A ¿{0} madrileñas?\nB ..."`, respuesta «Sois»), no es de frase entera:
  quita `wide: "full"` (`tail-blank` solo trata colas de puntuación pura).
- **El "tail-blank"/"vf-tail" NO se marca en la fila entera: se envuelve solo la línea del
  hueco en un `<span>` aparte.** Con `row.classList.add("tail-blank")` sobre la
  `.item-row` (`display:flex` en toda la fila, réplicas incluidas), un diálogo de 3+ turnos
  (A/B/C) descolocaba B y C: un `<br>` dentro de un contenedor flex no garantiza que la línea
  siguiente arranque en el borde izquierdo. En `reference/template.html` el CSS usa el selector
  descendiente `.item-row .tail-blank {...}` (igual para `.vf-tail`); el JS crea
  `const tailLine = document.createElement("span"); tailLine.className = "tail-blank";`, mueve
  a él `row.firstChild` mientras `row.firstChild.nodeName !== "BR"` (cabecera + hueco + cola
  de puntuación) y ese `tailLine` es lo que `row.insertBefore(...)` coloca; el resto (el
  `<br>` y las réplicas siguientes) queda en flujo de bloque normal, fuera del flex; y el
  deshacer el caso de un único tail-blank usa `wrap.querySelectorAll(".tail-blank")`. **No
  vuelvas a poner la clase en la fila.**
- **Hueco al final de la frase: se estira hasta el borde derecho, no baja de línea.** Es el
  caso más común («Pedro se encuentra mejor ______.»): el hueco es la continuación natural de
  la oración, empieza donde acaba el texto y **todos terminan en el mismo sitio**. La fila se
  marca sola `.tail-blank` y la casilla va en `flex: 1`. No bajes la casilla a su propia línea
  a ancho completo (iguala tamaños pero parte la oración en dos; el profesor lo rechazó).
  - **Detectar «al final»:** no vale `row.lastElementChild`, porque el texto que sigue al
    hueco son nodos de TEXTO, no elementos (se colaban frases como «¿Qué ___ (hacer) ayer?»,
    con el hueco dentro de la frase). Hay que mirar los nodos posteriores y aceptar solo
    puntuación de cierre.
  - **(a) Envuelve número + frase en un solo `<span class="tail-text">`.** Si se dejan
    sueltos, cada nodo de texto es un elemento flex independiente: una frase larga salta
    entera a la línea siguiente y el número se queda solo arriba (una «e.» huérfana).
  - **(b) Estira solo si hay más de una fila así en el ejercicio.** El estirón existe para
    que varias filas acaben en el mismo sitio; una sola, rodeada de frases con el hueco en
    medio, se ve como una raya larga y arbitraria. Tras montar las filas se cuentan las
    `.tail-blank` y, si hay exactamente una, se le quita la clase.
  - **Un salto de línea justo antes del hueco significa «esta respuesta va en su propia
    línea»** (ejercicios de «construye la frase», enunciado arriba y raya debajo): la
    detección lo respeta y no estira la casilla, que si no queda flotando a media altura.
  - **Una fila con foto nunca lleva el hueco estirado a la derecha:** el hueco va DEBAJO de
    la imagen («escribe debajo qué actividad es»). La detección excluye estas filas
    (`!row.querySelector(".foto-act")`); en móvil no se notaba, solo salía en escritorio.
  - **Bug de baseline:** un ítem con un solo hueco `{0}` y un `\n` ANTES de ese hueco
    (`"A ¿Qué tal?\nB Muy bien, fui. → {0}"`) pintaba la casilla flotando a media altura de
    la PRIMERA línea: el envoltorio flex con `align-items: baseline` usa la línea de base de
    la primera línea. Antes de envolver se comprueba si hay algún `<br>` en CUALQUIER punto
    anterior al hueco y, si lo hay, no se envuelve. Ya resuelto en la plantilla; si un
    capítulo copiado de una base más antigua muestra el síntoma, hay que portarlo.
- **Diálogos: los turnos (A, B, C... o `CELIA:`/`ANA:`) van SIEMPRE uno debajo de otro y
  alineados verticalmente, cada letra justo bajo la anterior** (instrucción explícita del
  profesor, repetida). Basta con `\n` entre réplicas dentro de `item.t` (o `ex.text` en tipo
  `"text"`): el motor inserta un `<br>` real por cada `\n`. Nunca escribas "A ... B ..." en
  la misma cadena sin `\n`, ni como atajo temporal. El primer turno arranca después del
  número de ítem y los siguientes no lo llevan, así que hay sangría francesa en
  `.dialog-row` (`padding-left: 1.9em`) con el número fuera de esa columna por margen
  negativo (`.dialog-row .item-letter { width: 1.9em; margin-left: -1.9em; }`); solo funciona
  si la fila NO es `display:flex` entera (por eso el `tail-blank` se envuelve en un span). El
  regex que detecta al interlocutor es `/^([A-ZÁÉÍÓÚÑÜ]{2,12}:|[A-Z])\s+/` (cualquier letra
  mayúscula suelta, no solo A y B, para soportar C, D...).
  - **Si un ejercicio usa turnos escritos con `\n`, ponle `ex.dialog: true`:** sin ese flag
    el motor no detecta ni formatea las letras de interlocutor (quedan como texto plano, sin
    color ni alineación). Lo que aporta el flag es el chip en negrita/dorado sobre la letra;
    las líneas se apilan igual con `\n`.
  - **`ex.dialog: true` detecta como interlocutor CUALQUIER línea que empiece por "A " o "B "
    seguido de espacio,** también la preposición "A" ("A los jóvenes españoles les
    encanta..."). No hay forma sintáctica fiable de distinguirlos con un regex: si un
    ejercicio mezcla diálogos reales con frases sueltas que puedan empezar por "A "/"B ", no
    actives `ex.dialog: true` (pierdes el chip de color pero evitas falsos interlocutores);
    actívalo solo cuando TODOS los ítems son diálogo de verdad.
- **Fotos, tablas y sopas de letras van SIEMPRE centradas** (instrucción explícita; una regla
  al final del `<style>` de la plantilla lo garantiza para `.foto-act`, `.wordsearch`,
  `table.gustos`, las imágenes de `.exercise-ref` y `.open-block`, y `.postcard`). Dos
  trampas: un bloque con `max-width` **no** se centra solo, necesita `margin-left/right:
  auto`; y un elemento con `white-space: pre` como la sopa necesita además
  `width: fit-content`. Una **fila de opciones que son dibujos** se centra en su contenido:
  `.ref-options:has(img) { justify-content: center }`. Las filas de opciones que son palabras
  se quedan a la izquierda a propósito. El reproductor de audio va también SIEMPRE centrado
  (`.exercise-audio { margin: 0 auto ... }`, con `.audio-label` centrada): no le quites el
  centrado al tocar ese CSS.
- **El recuadro `.exercise-ref` se ajusta a su contenido (`width: fit-content`), no al ancho
  de la tarjeta:** si no, el fondo dorado va de borde a borde y deja una franja enorme
  alrededor de una rejilla que ocupa un tercio. Cuando el contenido ya es ancho (una lista
  larga de opciones) se queda a lo ancho sin distinguir casos. El título (`.ref-label`) va
  centrado también.
- **Una fila con foto se centra entera, no solo la foto** (`.item-row:has(.foto-act)`):
  número, imagen y casilla. Centrar solo la imagen deja número y hueco pegados a la izquierda.
- **`item.img` pone una foto en la fila y va DESPUÉS del número** (al revés, cada número
  queda debajo de su foto y pegado a la siguiente). La foto se declara como campo del ítem,
  no como HTML dentro de `item.t`: meter marcado en los enunciados abre una puerta
  innecesaria.
- **Muchos dibujos pequeños van en rejilla, no en columna** (`ex.grid: true`, que pone la
  clase `.items-grid` con `grid-template-columns: repeat(auto-fill, minmax(140px, 1fr))`).
  Se activa por ejercicio a propósito, no por `:has(.foto-act)`: con el selector genérico las
  fotos grandes de Practica más 3 pasarían a celdas de 140 px con alto fijo. Los 18
  alimentos de la 5A en una columna eran una tira interminable; con 140 px salen cuatro por
  fila en ordenador y dos en móvil. Dales a todos la misma caja (`width: 100%; height:
  100px; object-fit: contain`): son de proporciones muy distintas y, a su ancho natural,
  unos se salen de su celda y los números quedan a distinta altura. Es para dibujos
  pequeños de vocabulario; las fotografías grandes de una actividad van una por fila.
- **Todo `<select>` necesita `max-width: 100%; overflow: hidden; text-overflow: ellipsis;
  white-space: nowrap;`.** Sin límite, el `<select>` cerrado se dibuja tan ancho como su
  opción más larga (en 12C, frases como "algo que se repite en el pasado y se acerca al
  presente") y en el teléfono desborda la pantalla. La plantilla compartida no usa
  `<select>`, así que solo aparece en ejercicios "a medida" como los de 12C. **No alinees los
  desplegables al borde derecho** (se probó con los de 12C y el profesor lo rechazó).
- **`.nav-dots` (la fila de píldoras "Sección N") nunca se oculta en móvil: se desliza en
  horizontal.** La plantilla traía `@media (max-width: 560px) { .nav-dots { display: none; }
  }`, y en un documento largo (Repaso B1 llegó a 12 secciones) quitaba al alumno la forma más
  cómoda de moverse. Ahora lleva `overflow-x: auto` (mismo patrón que `.table-wrap`) y, en la
  media query de 560px, `flex-basis: 100%; order: 3` para bajar a su propia fila deslizable.
  Si un ejercicio existente aún tiene `.nav-dots { display: none; }`, es la misma corrección.
- **Panel de resultados, progreso y scroll:**
  - El panel de resultados es de un solo tema, no adaptable: usa sus propias variables CSS
    fijas (`--rp-bg`, `--rp-text`, etc., definidas dentro de `.results-panel`), nunca los
    tokens `--ink`/`--paper-raised`/`--gold`, que invierten su significado en modo oscuro y
    dejan el panel ilegible.
  - `scroll-margin-top` en `.results-panel` (igual que en `.block`), o el scroll automático
    lo deja oculto tras la cabecera `sticky`.
  - El botón "Corregir todos" va al final, tras el último ejercicio, no en el hero.
  - Indicador de progreso obligatorio (`#progressHint`) mientras falten huecos por corregir;
    sin él, si el alumno se salta un ejercicio en una página larga, no aparece ninguna señal
    de por qué no sale el resumen final.
- **Seguridad y traducción:**
  - Escapa el texto que escribe el alumno antes de insertarlo en `innerHTML`
    (`escapeHtml()`, usado en la lista de fallos del panel de resultados): sin esto, `<algo>`
    en un hueco rompe el renderizado o ejecuta su propio HTML (self-XSS, bajo impacto pero
    bug genuino).
  - Todo número o letra estructural lleva `translate="no"` (`.item-letter`, `.exnum`,
    `#scoreNum`, `#scoreTotal`, `#totalBlanksLabel`, `#resScoreNum`, `#resScoreDen`, y en el
    índice `.level-badge`/`.chapter-num`). Con el traductor de página de Chrome móvil activo
    los números "1.", "2."... desaparecían (Google Translate reescribe el DOM y puede
    descartar nodos que son solo un número o puntuación sueltos junto a texto traducible).
    No desactives la traducción de toda la página (los alumnos rusohablantes pueden querer
    traducir el enunciado): marca solo lo puramente estructural. Si añades o tocas un tipo
    de ejercicio que muestre un número de fila/hueco/puntuación fuera de estos, añade
    `translate="no"` ahí también.

### Transcripciones y audio

- **Todo ejercicio con audio lleva su transcripción en un plegable (`ex.transcriptHTML`),
  nunca a la vista** (regla del profesor, sin excepciones, tengamos o no la grabación; de
  hecho sin ella hace más falta, porque el ejercicio es irresoluble en casa). En un
  ejercicio de comprensión oral la transcripción ES la solución: abierta, el ejercicio deja
  de existir; omitida, el alumno no puede autocorregirse. La plantilla la pinta en un
  `<details>` nativo al final de la tarjeta, tras las preguntas (accesible por teclado y sin
  JS); `ex.transcriptLabel` cambia el texto del resumen ("ábrela solo después de
  responder"). Si de verdad no aparece, dilo en el enunciado y pídesela al profesor, pero
  **nunca la inventes**: una transcripción escrita por Claude puesta como si fuera la del
  libro es material falso, y el alumno la usaría para autocorregirse.
- **El diálogo original no trae nombres:** el libro distingue las réplicas solo con dos
  símbolos que el OCR destroza. Deducirlos del contenido y escribirlos como `MARTA:` /
  `BEATRIZ:` es correcto (es el formato que el libro usa en otras unidades), pero déjalo
  dicho en una nota al pie de la transcripción para que nadie los tome por literales.
- **Dónde están las transcripciones y el solucionario de cada cuaderno** (páginas del propio
  PDF; no hay que pedirlas):
  - **A1:** 54-55 «Transcripciones», 56-61 «Soluciones», 62-64 glosario. Renderízalas con
    `paginas.sh` y tenlas delante antes de transcribir un capítulo (hasta la unidad 7A se
    estuvieron deduciendo respuestas y pidiendo fotos que ya estaban ahí). La sección de
    transcripciones titula las unidades con el nombre del **libro del alumno**, no del
    cuaderno (6A aparece como "¿Cómo se va a Plaza de España?" y en el cuaderno es "¿Cómo se
    va a Goya?"): guíate por número y letra. **El número de pista sácalo de ahí, no del
    iconito de la página**, que en el escaneado se lee fatal (en 7A se transcribió "pista
    19" y "pista 20" cuando eran la 9 y la 10).
  - **B1:** 64-68 transcripciones, 69-76 soluciones (las 52-63 son los textos de «Leer
    más»; la 76 son las soluciones de esas lecturas y la 77, la contracubierta). El PDF tiene
    77 páginas y su numeración coincide con la del libro, sin desfase. El índice de la página
    3 lista la página en la que EMPIEZA cada unidad, no la de cada sección (la unidad 5
    empieza en la 20: 5A en la 20, 5B en la 21, 5C en la 22). Este PDF tiene capa de texto,
    pero es OCR de ABBYY con codificación Custom y sale sucio («senala», «Buenos dlas»): vale
    para localizar, no para copiar. Transcribe mirando la página. No te fíes del número de
    páginas que anuncia el harness al adjuntar (dijo «103 pages» para un archivo de 77):
    comprueba con `d.page_count` y localiza el capítulo buscando su título con `get_text()`.
- **El texto que devuelve el conector de Drive de un PDF escaneado es OCR suyo, no una capa
  de texto.** El cuaderno de A1 no tiene fuentes (`pdffonts` vacío) y aun así
  `read_file_content` devuelve texto: lo reconoce él. Eso explica el orden de lectura que no
  coincide con el visual y los caracteres cambiados, y significa que ese texto no vale para
  transcribir, solo para localizar y leer de corrido. Aun así, la sección «Transcripciones» y
  el solucionario de A1 salen lo bastante limpios para leerlos de corrido (son texto seguido,
  sin gráficos que desordenen); para copiar el contenido, mira la página renderizada.
- **Audio: busca siempre en Drive antes de asumir que no existe.** Si un capítulo hace
  referencia a una "Pista N" (audición de comprensión oral), el profesor tiene los mp3
  reales en Drive y espera que se incrusten como audio reproducible, no solo como texto.
  Búscalos con `mcp__Google_Drive__search_files` (por ejemplo
  `title contains 'AUDIO CUADERNO'`, o navegando `Nuevo Español en Marcha/A1/AUDIO CUADERNO A1
  OK`, confirmada con el profesor); los archivos se llaman solo por el número de pista
  (`1.mp3`, `2.mp3`...). Descárgalos con `download_file_content` (mismo límite de tamaño que
  los PDF) y decodifica el base64. Incrusta el resultado como `<audio controls>` con el mp3
  en un `data:` URI base64 (rondan 1-2 MB, muy por debajo del límite de artefacto) en vez de
  dejar solo la transcripción en un `<details>`. Se omitió dos veces (A1, y A2 Unidad 1) por
  dar la transcripción por suficiente sin buscar: por eso también está en el checklist.
  - **Cuando sí hay grabación real, incrústala (`ex.audioSrc`); no basta con la
    transcripción.** La transcripción se queda igual, como apoyo.
  - **No te fíes de una carpeta de Drive por el nombre solo.** La primera carpeta que
    parecía obvia («АУДИО B1 Nuevo español en marcha», con «PISTA NN.mp3») era del **libro
    del alumno**, no del cuaderno de ejercicios: mismo manual, audio distinto. Verificación
    barata: la sección de «Transcripciones» del cuaderno (páginas 64-68 en B1) cita el número
    de pista más alto que usa; en B1 no pasa de la **19**. Sácalo del propio PDF con una
    regex sobre esas páginas; si la carpeta candidata tiene pistas por encima de ese máximo
    (esta llegaba hasta la 69), no es la del cuaderno.
  - **Las grabaciones pueden venir en `.wma`, que casi ningún navegador reproduce en
    `<audio>`.** Hay que convertirlas a mp3 antes de incrustarlas. El contenedor puede no
    tener `ffmpeg` del sistema, pero `pip install imageio-ffmpeg` trae un binario estático:
    ```python
    import imageio_ffmpeg; print(imageio_ffmpeg.get_ffmpeg_exe())  # ruta al binario
    ```
    ```bash
    "$FFMPEG" -y -i entrada.wma -codec:a libmp3lame -b:a 128k salida.mp3
    ```
    Comprueba con `mutagen` (`from mutagen.mp3 import MP3; MP3(ruta).info.length`) que la
    duración del mp3 coincide con la del wma (`from mutagen.asf import ASF`); si no, la
    conversión se cortó a medias.
  - **Verifica con Playwright que el audio carga de verdad:** el motor usa
    `preload="none"`, así que hay que forzar `audio.load()` y esperar `loadedmetadata` (o
    `error`) para comprobar la duración; contar `<audio>` en el DOM no basta.
  - Incrustar el audio es una excepción deliberada a la regla del `README.md` raíz («archivos
    pesados de audio/video no se suben a este repositorio»), que apunta a grabaciones de
    clase enteras (`docencia-espanol/grabaciones/`, solo en Drive). Aquí el audio incrustado
    *es* el contenido del ejercicio y el artefacto tiene que ser autocontenido. Precedente
    fusionado en `main`: 5B y 5C de B1, cada uno con su `data:` URI de varios MB.
- **Fotos reales incrustadas:** si el ejercicio necesita una imagen real (p. ej. la foto de
  un autor), pide al profesor que la **adjunte como archivo**, no pegada en el cuerpo del
  mensaje (las imágenes pegadas no siempre se guardan como archivo accesible), e
  incrústala como `data:` URI en base64.

### Recortes: anclar a bordes reales

- **No uses bandas de posición fija para recortar dibujos de una página escaneada.** En la 5A
  el plato del filete salió partido por la mitad: en dos de las seis filas los dibujos casi
  se tocan y la banda fija los cortaba. Detecta las separaciones por **columnas sin tinta**
  (separación mínima pequeña, ~14 px: subirla vuelve a fundir dibujos vecinos), recorta el
  blanco sobrante de cada uno y **monta una hoja de contacto con los recortes y míralos**
  antes de incrustarlos: es la única forma de ver que están enteros y que cada uno
  corresponde a la respuesta del solucionario.
- **Un recorte que parece limpio a menudo no lo está.** En la guía de repaso A1, 7 de 10
  recortes dados por buenos en la primera pasada tenían defectos al reexaminarlos: texto de
  un enunciado vecino por arriba (el "3 Mira el árbol genealógico..." dentro del recorte del
  árbol), contenido cortado por abajo (la fila de fotos d-g de profesiones, con "Hospital"
  partido) y márgenes puestos a ojo sin anclar (una habitación con la cama y el brazo
  cortados). La causa no era la técnica de rejilla sino dar por bueno un recorte sin releerlo
  con ojo escéptico. Corrección: (1) si la fuente tiene un borde de caja limpio (sopa de
  letras, tabla), ancla el recorte a ese borde exacto; (2) si no hay borde (una ilustración
  suelta), usa la rejilla sobre la página COMPLETA y lee los bordes reales del dibujo antes
  de cortar; (3) tras cada recorte, reléelo con el propósito explícito de buscarle un
  defecto (dos lecturas distintas; solo la primera no encuentra el problema); (4) si no cabe
  entero sin arrastrar un elemento ajeno (un pie de página), recorta al máximo real y tapa de
  blanco solo la franja ajena, en vez de aceptar el corte o encoger el contenido bueno.
  - **Incluso ancladas "al borde", las coordenadas leídas a ojo sobre la rejilla pueden
    fallar por poco:** el recorte de la sopa de letras del capítulo 1, ya revisado, seguía
    sin la columna de letras más a la derecha (9 de 10). Se encontró con `opencv-python`
    (`pip install opencv-python-headless`): `cv2.adaptiveThreshold` +
    `cv2.morphologyEx(..., MORPH_CLOSE)` + `cv2.findContours` sobre la página completa,
    filtrando por área (2-60 % de la página) y por relación área-contorno/área-caja (>0.5,
    para exigir un rectángulo relleno de verdad), da el rectángulo de tinta exacto de una caja
    con borde (sopa, tabla). Úsalo como primer intento y recurre a la rejilla solo si no hay
    contorno rectangular claro (dibujos sueltos sin caja, como el árbol genealógico).
- **Recortar formas circulares/curvas: `cv2.floodFill` con tolerancia de tono.** Cuando
  `findContours` por área no basta (una forma redonda, ovalada o irregular: retrato circular,
  viñeta, globo de cómic), el equivalente a la "varita mágica" de un editor es `cv2.floodFill`:
  parte de un punto semilla en el FONDO (una esquina vacía pegada a la forma) y rellena hacia
  fuera todo lo que esté dentro de una tolerancia de tono (`loDiff`/`upDiff`); se detiene donde
  el tono cambia más de lo permitido, así que sigue la silueta real:
  ```python
  import cv2, numpy as np
  img = cv2.imread("pagina.jpg")
  h, w = img.shape[:2]
  mask = np.zeros((h + 2, w + 2), np.uint8)  # floodFill exige 2px de margen
  seed = (x_fondo, y_fondo)  # un punto DENTRO del fondo, pegado a la forma
  # loDiff/upDiff: cuánto puede oscurecerse/aclararse un píxel del fondo y seguir
  # contando como fondo. Empieza con (10,10,10); sube si deja huecos sin rellenar
  # (fondo con textura/ruido de escaneo); baja si se "escapa" hacia dentro de la forma
  # (el caso típico: fondo GRIS claro que se confunde con líneas grises de la
  # ilustración: baja la tolerancia o cambia el punto semilla).
  cv2.floodFill(img, mask, seed, (255,255,255), (10,10,10), (10,10,10),
                cv2.FLOODFILL_FIXED_RANGE)
  content_mask = 1 - mask[1:-1, 1:-1]  # invierte: 1 = forma, 0 = fondo rellenado
  ys, xs = np.where(content_mask)
  x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()  # bounding box real de la forma
  ```
  El resultado es el rectángulo mínimo que contiene la forma irregular completa (se sigue
  recortando en rectángulo, porque un `<img>` no puede tener máscara libre sin `clip-path`),
  pero anclado a los píxeles reales de la silueta. Si el fondo no es uniforme (varias zonas de
  blanco/gris separadas por líneas) puede hacer falta más de un punto semilla: combina las
  máscaras con `|=` antes de invertir. Para depurar, guarda `content_mask * 255` como PNG y
  míralo con `Read`: un hueco negro dentro de la forma es tolerancia insuficiente; una mancha
  blanca fuera es tolerancia excesiva o un segundo punto de fondo sin su propio floodFill.

### PDF y herramientas del contenedor

- **`/mnt/skills/public/pdf-reading/SKILL.md`** — guía de lectura de PDF que viene con el
  entorno pero **no aparece entre las skills activables**, así que se abre con `Read`. Léela
  antes de pelearte con un PDF. Las dos que más valen: `pdffonts` dice de antemano si hay
  capa de texto (sin fuentes = escaneado, no gastes tiempo con `pdftotext`) y si el encoding
  es `Custom` o `Identity-H`, que **predice** que el texto extraído saldrá con caracteres
  cambiados aunque parezca correcto (lo que pasaba con ПК Гонсалес, `tъ`/`йl` por
  `tú`/`él`). Trae además `pdfdetach` para adjuntos y el aviso de que `pdfimages` no ve los
  gráficos vectoriales. `paginas.sh` incorpora sus diagnósticos, pero la guía tiene más
  (tablas con pdfplumber, campos de formulario, coste en tokens de rasterizar).
- **OCR: `tesseract` puede no estar.** Si hace falta un borrador gratis y local, se intenta
  instalar y, si no se puede, se lee el render con `Read` (acierta donde `pdftotext` se
  equivoca): el procedimiento y el orden de prioridad están en `docencia-espanol/CLAUDE.md`
  (instalar si se puede; si no, leer el render). Comprobado que **no** hay `qpdf`, `mutool`
  ni `pdftk`, y que `pypdf` y `pdfplumber` **se instalan pero revientan al importarse** (el
  binding de `cryptography` lanza un `PanicException` de Rust). Sin OCR no se puede generar un
  PDF con capa de texto buscable.
- **`poppler` NO está en todos los contenedores, y `PyMuPDF` sí se instala: es el plan B.**
  Medido en la sesión de la 5C: `pdftoppm`/`pdftotext`/`pdffonts` no existían,
  `apt-get install poppler-utils` falla con **404** (índice de paquetes caducado que
  `apt-get update` no arregla), y sin `pdftoppm` **la herramienta `Read` tampoco puede abrir
  un PDF**. La salida es `python3 -m pip install pymupdf`, que hace todo lo de `paginas.sh`:

  ```python
  import pymupdf
  d = pymupdf.open(PDF)
  print(d.page_count)                       # y d[n].get_text() para localizar
  d[n-1].get_pixmap(dpi=170).save("p.png")  # renderizar y MIRAR la página con Read
  # y para leer letra pequeña, un recorte a más dpi:
  # d[n-1].get_pixmap(dpi=300, clip=pymupdf.Rect(x0, y0, x1, y1)).save("crop.png")
  ```

  El recorte a 300 dpi es lo que hace legibles el artículo del ejercicio 1 y el prospecto del
  5 de la 5C, que a página completa no se leen.

### Canal por canal (la parte que más costó)

Cada botón de "enviar al profesor" tuvo su propia trampa de plataforma. La regla general:
**usa siempre un enlace `https://` normal (`<a target="_blank" rel="noopener">`), nunca
`window.open()` desde JavaScript ni un protocolo que no sea http(s).** WhatsApp siempre
funcionó porque siempre fue así; todo lo que se rompió fue lo que no la cumplía.

**Por qué no es negociable:** en un intento de combinar copiar-al-portapapeles con abrir el
correo, el botón de Correo se convirtió en un `<button onclick="...">` que llamaba a
`window.open()`, y dejó de redirigir **en escritorio y en móvil a la vez** (confirmado por el
profesor en dispositivo real). El permiso "bloquear ventanas emergentes" de Chrome es **por
sitio y persiste entre sesiones**: se había acumulado durante las propias pruebas (tras varios
popups de prueba, Chrome empieza a bloquear ese sitio en silencio). Un `<a target="_blank">`
nativo está exento; un `window.open()` desde script no, ni siquiera síncrono dentro del clic.
La corrección fue volver a un `<a href>` normal con la copia al portapapeles enganchada como un
`addEventListener("click", ...)` **aditivo**, que no sustituye ni compite con la navegación
nativa. **Nunca reintroduzcas `window.open()` ni `<button onclick>` para estos botones.**

- **WhatsApp** (`https://wa.me/<número>?text=<encoded>`): funciona de fábrica, sin trucos.
- **Correo: nunca `mailto:`.** El artefacto se sirve en un iframe con sandbox cuando se
  comparte públicamente, y ese sandbox bloquea cualquier protocolo que no sea `https://`
  (`<a href="mailto:">`, `window.open()` síncrono o asíncrono, con o sin `target="_blank"`:
  todo falla en silencio o deja la página en blanco si no hay cliente de correo). Sí funciona
  un enlace de redacción de Gmail
  (`https://mail.google.com/mail/?view=cm&fs=1&to=...&su=...&body=...`), de la misma clase
  que WhatsApp; confirmado en escritorio, donde abre Gmail web con los campos rellenados.
- **Correo en Android: límite conocido y aceptado, no lo sigas "arreglando".** En móvil ese
  enlace a veces abre el navegador en vez de la app (aunque "Abrir vínculos admitidos" de
  Gmail esté activado), y cuando abre la app, esta no entiende `view=cm`/`su`/`body` y abre un
  correo en blanco. El esquema propio de la app (`googlegmail://co?to=...&subject=...&body=...`,
  condicionado por `navigator.userAgent` solo en móvil) **dejó de abrir nada en absoluto** en
  la prueba real y se revirtió sin fusionar. No sigas probando esquemas de URL de apps
  nativas sin documentarlos: no se pueden comprobar desde este entorno y cada intento fallido
  es un ciclo de "el profesor prueba en su teléfono y reporta que empeoró". Lo único
  100 % fiable en móvil es el respaldo de copiar-al-portapapeles con mensaje explícito (ver
  más abajo): trátalo como la solución real. El profesor lo aceptó como límite conocido; no
  reabras este hilo sin que él lo pida.
- **Telegram:** los enlaces con número (`t.me/+<número>`) nunca precargan texto; el parámetro
  `?text=` solo funciona con un `@usuario` (`t.me/<usuario>?text=...`). Pide el `@usuario` de
  Telegram del profesor si no lo tienes. Además `t.me` (nginx) devuelve **400 Bad Request**
  con URLs mucho más cortas que el límite que WhatsApp tolera (~1200-1500 caracteres ya
  codificados es un margen seguro comprobado; ~4650 ya falla): trunca con
  `truncateForUrl()` (ya en la plantilla) antes de meter el texto en el enlace.
- **Teams:** su parámetro `?message=` nunca se confirmó fiable, así que, a diferencia de
  WhatsApp/Telegram/Correo, Teams lleva el respaldo "copiar al portapapeles + mensaje
  explícito" (`copyText(...)` con algo como "pégalo en el chat que se acaba de abrir"; un
  "¡Copiado!" genérico pasa desapercibido justo cuando la pantalla cambia de app).
  **Codifica siempre `TEACHER.teamsEmail` con `encodeURIComponent`** al construir el
  `?users=` (`https://teams.microsoft.com/l/chat/0/0?users=...`): ese campo era el único que
  se insertaba sin codificar. Es una corrección de consistencia, no la solución a un límite
  observado: en escritorio Teams pega el mensaje pero **no selecciona automáticamente al
  destinatario** (hay que elegirlo a mano), mientras que en móvil sí. Es una app nativa
  honrando solo parte de los parámetros de un enlace web, fuera del control de la página; el
  mensaje de respaldo ya nombra el paso manual ("elige a " + TEACHER.teamsEmail + "..."). No
  fuerces la selección automática en escritorio sin que el profesor lo pida.
- **Copia + `window.open()` en el mismo clic** (ya no necesario para Correo/Telegram, pero
  relevante para un canal futuro): el navegador concede "permiso de interacción del usuario"
  una vez por gesto. Si `window.open()` va primero, la copia posterior falla en silencio. La
  copia va primero, síncrona (`execCommand('copy')`, no la API asíncrona de portapapeles, que
  perdería el permiso esperando su promesa), y `window.open()` justo después.
- **Longitud de URL:** cualquier canal que meta el resumen en una URL (`?text=`, `body=`)
  puede topar con límites del servidor mucho antes de los ~2000 caracteres "de libro". Usa
  siempre `truncateForUrl(text, maxEncodedLen)`: mide la longitud **ya codificada**
  (`encodeURIComponent` puede casi triplicar el tamaño con tildes, saltos de línea y emojis).

### Otras

- **El acceso con código es solo un disuasivo, no seguridad real:** cualquiera que vea el
  código fuente ve el `CODE`. Comunícaselo así al profesor siempre que se mencione, sin
  matices ambiguos.
- **La lista "Artefactos" de la app móvil de Claude no es la misma galería** que los
  artefactos de Código: son sistemas separados. Si el profesor pregunta por qué no ve sus
  artefactos en el móvil, confirma primero en qué pantalla o app está mirando.

## Archivos de referencia

- `reference/template.html` — plantilla completa, con todas las correcciones aplicadas.
  Punto de partida obligatorio para cualquier ejercicio nuevo.
- `docencia-espanol/materiales/b1/nuevo-espanol-en-marcha-3_repaso-b1_interactivo.html` —
  **documento largo de repaso**, útil cuando el material no es un capítulo suelto sino un
  cuadernillo entero. Añade sobre la plantilla cosas que conviene copiar de ahí en vez de
  reinventar:
    - `block.introHTML` — teoría no interactiva antes de los ejercicios de cada sección.
    - `ex.refHTML` — recuadro de referencia dentro de un ejercicio (conectores, banco de
      opciones, sopa de letras).
    - `type: "conjTables"` — varios cuadros de conjugación en un ejercicio, con un único
      botón "Corregir"; una celda cuyo spec es una **cadena** se pinta fija (ya resuelta en
      el libro) y no cuenta como hueco.
    - **Panel de resultados por sección** (`createResultsPanel()`): cada sección tiene su
      puntuación, sus fallos y sus botones de envío, además del panel global; en documentos
      largos permite entregar por partes. El resumen enviado nombra la sección y el nombre
      del alumno se comparte entre paneles. Al replicarlo: los paneles se generan por
      **clases dentro de cada panel**, nunca por `id` global (habría duplicados), y cualquier
      atajo que corrija "todo" (la tecla Enter, por ejemplo) debe acotarse a la sección, o
      destapará las respuestas de las secciones que el alumno aún no ha hecho.
    - `conSinTildes([...])` — ver la lección sobre `flex` y alternativas.
- `docencia-espanol/materiales/indice-clases-de-espanol.html` — el artefacto "Clases de
  Español", índice manual → nivel → capítulo (paso 6). Actualízalo con cada capítulo nuevo.
  Es público (o puede llegar a serlo si el profesor lo comparte): nunca le añadas los códigos
  de acceso.
- `docencia-espanol/materiales/codigos-acceso.html` — referencia privada del profesor con el
  código de cada capítulo (paso 7). Actualízala con cada capítulo nuevo; no la enlaces desde
  ningún material que puedan ver los alumnos.
- `docencia-espanol/fuentes/` — transcripciones en texto plano de todo lo escaneado, con sus
  respuestas, más `extraer.mjs`, que las genera desde el artefacto publicado. Antes de pedir
  fotos al profesor de un capítulo, mira aquí.
- `docencia-espanol/fuentes/paginas.sh` — dado un PDF y un rango de páginas, diagnostica el
  archivo (`pdffonts`, `pdfdetach`), saca el texto con `pdftotext -layout`, renderiza cada
  página a JPEG para poder mirarla y extrae las imágenes incrustadas. Es la herramienta del
  paso 1 cuando el profesor adjunta el PDF. Escribe fuera del repo a propósito: las páginas
  de un libro con copyright son material de trabajo, no se versionan (la única excepción es
  `fuentes/pendientes/`, que se borra en cuanto el capítulo se publica); lo que se archiva es
  la transcripción.
- `PRODUCT.md` y `DESIGN.md` (raíz del repo) — el sistema de diseño compartido por todos los
  artefactos de esta biblioteca (paleta papel/tinta, tipografía, componentes). Cualquier
  página nueva (ejercicio o índice) debe extender estos tokens, no inventar los suyos; los
  valores exactos y las reglas nombradas ("The Fixed Panel Rule", etc.) están en `DESIGN.md`.
