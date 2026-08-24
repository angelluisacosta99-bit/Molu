---
name: ejercicio-interactivo
description: "Use when Angel asks to build a new interactive Spanish grammar/vocabulary exercise page with instant grading — a self-contained HTML artifact where a student fills in blanks, gets corrected instantly, and can send their results to the teacher via WhatsApp/Telegram/Teams/Correo. Also use when asked to add a new chapter/unit to this format, or to fix/extend an existing one (e.g. the A1 \"Presente, gerundio, indefinido\" or B2 12C \"¿Sigues pintando?\" exercises already in docencia-espanol/materiales/). Triggers: \"ejercicio interactivo\", \"como el de A1/12C\", \"corrección instantánea\", \"página interactiva para practicar\", \"haz lo mismo con otro capítulo\"."
version: 1.9.0
user-invocable: true
license: Apache 2.0
---

# Ejercicio interactivo con corrección instantánea

Construye páginas HTML autocontenidas (sin backend) donde un alumno completa huecos, los
corrige al instante, y puede enviar su resumen de resultados al profesor. Este formato ya
existe en dos ejercicios reales — A1 (`docencia-espanol/materiales/a1/...interactivo.html`)
y B2 12C (`docencia-espanol/materiales/b2/...interactivo.html`) — y pasó por **más de una
docena de PRs de corrección de bugs reales en producción** (PRs #19 a #31, ver la sección
de lecciones abajo) antes de quedar sólido, sobre todo en los botones de "enviar al
profesor". No repitas esos errores: usa la plantilla ya corregida (`reference/template.html`)
como punto de partida siempre, no escribas esto desde cero.

**Si te piden tocar los botones de envío (WhatsApp/Telegram/Correo/Teams) de un ejercicio
ya publicado**: lee primero la sección "Canal por canal" de este documento entera. Ese
código es el resultado de mucho ensayo-error en dispositivos reales; una idea que "debería
funcionar" (otro `window.open()`, otro esquema de URL de app) ya se intentó y falló al
menos una vez. Antes de proponer un cambio nuevo en esta zona, confirma qué PRs concretos
tocaron esas líneas (`git log -p --follow <archivo>` o revisa los PRs #19-#31 con
`pull_request_read`) en vez de fiarte de la memoria — así se detectó, por ejemplo, que
PR #22 invertía el orden que PR #20 daba por bueno.

## Flujo de trabajo

1. **Fundamenta el contenido en material real.** Por este orden:

   1. **Mira primero `docencia-espanol/fuentes/`** (ver su README). Ahí están, en texto
      plano y con sus respuestas, todos los capítulos ya transcritos. Si el que necesitas
      está, no pidas fotos ni vuelvas a transcribir: parte de ese archivo. Mira también
      **`fuentes/pendientes/`**: ahí se deja el material de partida de un capítulo que se
      preparó en una sesión y se construye en otra —el PDF adjunto no sobrevive al cambio
      de sesión, el repositorio sí—. Si el capítulo que te piden está ahí, tienes ya el
      texto, las respuestas, la transcripción del audio y los dibujos recortados, y no hace
      falta el PDF. Al publicarlo, genera su archivo con `extraer.mjs` y **borra su carpeta
      de `pendientes/`**, o quedarán dos versiones del mismo capítulo.
   2. **Si no está, baja el PDF entero a disco.** Lo que hace falta siempre es el archivo,
      no su texto: con él funciona todo `poppler`, y `docencia-espanol/fuentes/paginas.sh`
      saca de un tirón el diagnóstico, el texto en orden de lectura, la página renderizada
      como imagen y las imágenes incrustadas a resolución original. Dos vías:

      - **`download_file_content` del conector de Drive** (ver `CLAUDE.md` de la raíz para
        el enlace y el orden de prioridad: Nuevo Español en Marcha > ПК Гонсалес > Temas).
        Devuelve el archivo en base64; se decodifica con
        `python3 -c "import json,base64; d=json.load(open(RUTA)); open(SALIDA,'wb').write(base64.b64decode(d['content']))"`.
        La respuesta será demasiado grande para el contexto y se volcará a un archivo — eso
        **no es un error**, es justo lo que interesa: se decodifica desde ahí.
      - **Que el profesor lo adjunte al chat.** Los adjuntos llegan a
        `/root/.claude/uploads/<sesión>/`. Es la vía para los PDF grandes (ver abajo).

   3. **Ojo con el límite de tamaño de `download_file_content`, porque miente al fallar.**
      Por encima de unos pocos MB devuelve **«MCP server "Google_Drive" session expired»**,
      que suena a sesión caducada y no lo es: el resto del conector sigue respondiendo con
      normalidad en la misma llamada siguiente. Medido en este repo: 74 KB, 844 KB y 2,74 MB
      bajan enteros y válidos; 8,42 MB y 8,83 MB fallan siempre. Si ves ese error, **no
      concluyas que el conector está roto ni te lances a pedir fotos**: es un PDF grande, y
      la salida es pedir que lo adjunte al chat. Este error ya costó una tanda entera de
      fotos de páginas que no hacían falta.

      `read_file_content` es otra cosa y no sustituye a la descarga: devuelve el texto ya
      aplanado, y desordenado en cuanto la página lleva un gráfico incrustado (el plano de
      metro de la 6A). Sirve para localizar y para leer texto corrido, no para transcribir.
      La descarga directa por HTTP no es opción: el proxy la bloquea y el archivo es privado.
   4. **Fotos de las páginas: último recurso, no el segundo.** Solo si el profesor no puede
      adjuntar el PDF. Con el PDF en disco no hacen falta ni para las ilustraciones
      (`pdfimages` las saca mejor que una foto) ni para los escaneos sin texto (se renderiza
      cada página con `pdftoppm` y se transcribe mirándola).

   Todo lo que llegue por fotos hay que archivarlo después en `fuentes/` (paso 8): esa
   carpeta existe justo para que no se vuelva a fotografiar dos veces el mismo capítulo.

   **Y mires lo que mires, mira la página.** Antes de dar por buena una transcripción,
   renderiza la página y ábrela con `Read`, aunque el texto se haya extraído perfectamente.
   Hay contenido que el texto **no puede** representar y que cambia las respuestas: las
   líneas de un ejercicio de relacionar, los ítems que el libro ya trae resueltos, las
   respuestas rodeadas, las flechas. En la 6B el ejercicio 1 se transcribió con diez huecos
   cuando el libro trae el primero resuelto —con una línea dibujada de «Pon» a «g la
   televisión»— y no se detectó hasta ver la página. El texto extraído tampoco es fiable al
   pie de la letra: en un PDF de ПК Гонсалес `pdftotext` devuelve `tъ` y `йl` donde la
   página pone claramente **tú** y **él**.

2. **Copia la plantilla, no la reescribas.** `cp .claude/skills/ejercicio-interactivo/reference/template.html <destino>`.
   Sustituye **todos** los marcadores `{{...}}` (grep por `{{` para confirmar que no quede
   ninguno) y rellena `blocks` con los ejercicios reales, siguiendo los cinco tipos ya
   soportados por el motor de renderizado (`items`, `text`, `table2`, `conjTable`,
   `agenda` — documentados con ejemplos dentro de la propia plantilla). Si necesitas un tipo
   nuevo, tendrás que extender también el renderizador (busca `ex.type ===` en el archivo).
   Dentro de `items`, para un hueco de verdadero/falso pon `vf: true` en el item en vez de
   escribir un tipo de ejercicio nuevo — cambia el input de texto por dos botones "V"/"F"
   sin tocar el motor de corrección (la respuesta sigue siendo `["V"]`/`["F"]`); ver el
   ejemplo ya incluido en la propia plantilla y la lección más abajo.

3. **Tildes: decide, no asumas.** La corrección del camino principal (`isCorrect`/`norm`)
   exige tilde exacta por diseño — en la mayoría de ejercicios de gramática la tilde
   distingue tiempos verbales o palabras distintas ("trabaja"/"trabajó", "esta"/"está"). Si
   el ejercicio es de respuesta abierta donde la tilde no es lo evaluado, usa el spec
   `{flex:[...]}` (accent-insensitive) solo en esos huecos. Si tienes dudas sobre qué
   comportamiento quiere el profesor para un ejercicio nuevo, pregúntale — no lo cambies
   por tu cuenta (ver la lección "Tildes" abajo).

4. **Verifica antes de publicar.** Usa Playwright (Chromium en `/opt/pw-browsers/chromium`,
   módulo en `NODE_PATH=/opt/node22/lib/node_modules`) para: desbloquear la puerta con el
   código, rellenar cada hueco con la respuesta correcta y confirmar que puntúa 100%,
   probar una respuesta deliberadamente mala y confirmar que se marca como error, y
   comprobar los cuatro botones de envío (ver checklist de canales abajo). Toma capturas en
   viewport móvil para revisar que no se rompa el layout.

   **Advertencia importante**: probar con `file://` local **no reproduce** el iframe con
   sandbox que usa el artefacto cuando se comparte públicamente. Varios bugs reales (ver
   lecciones) solo aparecían en el artefacto publicado, nunca en `file://`. No declares
   "funciona" solo por pasar las pruebas locales — publica y, si es posible, pide al
   profesor que lo pruebe en un dispositivo real antes de darlo por cerrado.

5. **Publica con el tool `Artifact`.** Elige un favicon distinto por asignatura/nivel para
   reconocerlo rápido en la lista (✅ para A1, 🎨 para 12C, 🏛️ para 12B, 📖 para Repaso B1).
   Al actualizar un artefacto ya publicado, pasa siempre el mismo `url` para no crear uno
   nuevo. Título del artefacto: sigue la convención
   `Nuevo Español en Marcha · <Nivel> · <Capítulo> — <Tema>` (ver los ejemplos ya
   publicados) para que se lea claro tanto en la lista plana de Artefactos como en el
   índice del paso siguiente.

   **Publicar NO es terminar.** Los pasos 6 y 7 forman parte de publicar un capítulo, no
   son opcionales ni "para luego" — ver la checklist del final de esta sección.

6. **Añade el capítulo al índice.** `docencia-espanol/materiales/indice-clases-de-espanol.html`
   es el artefacto "Clases de Español" — la página de entrada que organiza todo por manual →
   nivel → capítulo (ver PRODUCT.md/DESIGN.md en la raíz del repo para el sistema de diseño
   compartido). Al publicar un capítulo nuevo: dentro de la tarjeta `.level-card` del nivel
   correspondiente, sustituye la fila `.chapter-row.empty` de "Próximo capítulo, pronto" por
   una fila real (`<a class="chapter-row" href="<url del artefacto>" target="_blank"
   rel="noopener">` con `.chapter-num`/`.chapter-title`/flecha, copiando el patrón de las
   filas ya existentes) y añade una nueva fila `.empty` al final si quieres dejar sitio para
   el siguiente. Vuelve a publicar el índice con el mismo `url` (no crees uno nuevo). Si
   algún día se añade un manual nuevo (ПК Гонсалес, Temas — ver la nota "Próximos manuales"
   del índice), duplica el bloque `.manual-section` completo para ese manual en vez de
   mezclar niveles de manuales distintos dentro de la misma sección.

7. **Añade el código a `docencia-espanol/materiales/codigos-acceso.html`.** Es la
   referencia privada del profesor (nivel, capítulo, código, enlace) para cuando un alumno
   pide el código en clase — añade una fila a la tabla y vuelve a publicar con el mismo
   `url`. **Nunca enlaces esta página desde el índice público ni desde ningún material que
   puedan ver los alumnos** — no por seguridad real (el código sigue siendo solo un
   disuasivo, visible en el código fuente de cada ejercicio), sino porque no tiene sentido
   poner todos los códigos juntos a la vista de cualquiera que reciba el enlace.

8. **Archiva la transcripción en `docencia-espanol/fuentes/`. Siempre, sin excepción.**
   Es una instrucción explícita del profesor: no quiere volver a escanear ni fotografiar un
   capítulo que ya se transcribió una vez. En cuanto el artefacto esté publicado y
   verificado, genera su archivo de texto:

   ```bash
   cd docencia-espanol/fuentes
   NODE_PATH=/opt/node22/lib/node_modules node extraer.mjs \
     ../materiales/<archivo>.html <CÓDIGO> > nuevo-espanol-en-marcha/<nivel>/<capítulo>.md
   ```

   `extraer.mjs` abre el artefacto en un navegador, rellena los huecos con texto imposible,
   corrige y recoge del DOM cada enunciado con la respuesta que revela el propio motor.
   **No transcribas ese archivo a mano**: lo que se archiva así es exactamente lo que se
   verificó, y no una segunda transcripción que podría desviarse. Si más adelante se corrige
   una respuesta en el artefacto, **regenera** el archivo en vez de editarlo.

   Añade también su fila a la tabla de `fuentes/README.md`, anotando de dónde salieron las
   respuestas: del solucionario del libro, o deducidas. Esa distinción es la que evita que
   dentro de unos meses se tomen por buenas unas respuestas que en realidad están sin
   confirmar.

9. **Sigue el flujo de PR de este repositorio, sin excepciones.** `CLAUDE.md` en la raíz
   exige: abrir el PR (esto no dispara nada más — puede quedarse esperando) y, **solo
   cuando el profesor pida fusionar ese PR**, lanzar una revisión con un agente
   independiente (`Agent` tool, `run_in_background: true`, dale contexto completo y pídele
   que verifique en vivo con Playwright, no que confíe en la descripción del PR) sobre el
   estado actual del PR → fusionar solo si no hay hallazgos bloqueantes. Nunca te saltes la
   revisión antes de fusionar, ni para cambios que parezcan triviales, y nunca la lances
   (ni fusiones) solo por haber abierto el PR.

   **Nota sobre el historial de la rama**: los PRs anteriores en esta rama se fusionaron con
   `squash`, así que los commits viejos de la rama dejan de ser ancestros literales de
   `main` tras cada merge. Antes de abrir un PR nuevo, si `git merge-base --is-ancestor
   <último-commit> origin/main` falla, resetea la rama: `git fetch origin main && git
   checkout -B <rama> origin/main`, y vuelve a aplicar (`git stash`/cherry-pick) solo los
   commits todavía no fusionados. Nunca fuerces un push sin antes confirmar qué commits se
   perderían.

### Checklist antes de dar por publicado un capítulo

Repásala **cada vez**, aunque el capítulo haya costado mucho y parezca acabado. Con Repaso
B1 se publicó el artefacto, se verificó, se abrió el PR y se fusionó —y aun así los pasos 6
y 7 se quedaron sin hacer: la tarjeta de nivel B1 del índice seguía diciendo "todavía sin
capítulos publicados" y el código no estaba en la lista del profesor. Lo detectó él, no yo.
El fallo no fue no saber los pasos, fue no volver a mirarlos al final.

- [ ] Artefacto publicado, y **con el mismo `url`** si ya existía.
- [ ] Fila añadida en `indice-clases-de-espanol.html`, en la tarjeta del nivel correcto, y
      el índice republicado (paso 6).
- [ ] Fila añadida en `codigos-acceso.html` con su código, y republicado (paso 7).
- [ ] Transcripción archivada en `docencia-espanol/fuentes/` con `extraer.mjs`, y su fila
      en el README de esa carpeta indicando el origen de las respuestas (paso 8).
- [ ] No queda ningún marcador `{{...}}` ni la cabecera de la plantilla sin adaptar (esa
      cabecera se publica en el código fuente que ve el alumno).
- [ ] Si el material no viene claramente de un manual concreto, **pregúntale al profesor**
      en vez de archivarlo por deducción. `RepasoB1.pdf` era un PDF suelto y se colocó bajo
      "Nuevo Español en Marcha 3" por parecido de formato; el profesor confirmó después que
      era correcto, pero la deducción se dio por buena sin preguntar y podría no haberlo
      sido. Preguntar cuesta una frase; moverlo después, rehacer índice y códigos.
- [ ] Si índice/códigos/README se sincronizaron copiando el estado ya publicado de una
      rama hermana todavía sin fusionar (para no revertir sus filas en vivo — ver más
      abajo), **revisa fila por fila que cada una tenga su archivo real en ESTA rama**
      antes de commitear. Copiar el `README.md` de otra rama trae también SUS filas de
      archivo (`.md` de unidades que esa otra rama sí construyó pero la tuya no) — índice
      y códigos solo enlazan a artefactos ya publicados (válido, aunque el `.html` fuente
      no esté en tu rama), pero una fila de README que dice "archivado, ver este .md" para
      un archivo que no existe en tu checkout es una afirmación falsa, no una excepción
      aceptable. Encontrado en revisión de PR (unidad 2 de B1): tres filas de unidad 6
      quedaron copiadas del README de la rama de la unidad 6, sin que sus `.md` vinieran
      con ellas.

## Lecciones aprendidas (no las repitas)

Cada una de estas causó un PR de corrección real. Están en `reference/template.html` ya
resueltas — esta lista es para que entiendas *por qué* el código está como está, y para que
no las deshagas sin querer al modificar la plantilla.

- **Un bug de motor encontrado por revisión hay que arreglarlo en `reference/template.html`
  Y en la copia horneada de CADA capítulo ya construido en esa misma rama** — cada
  `..._interactivo.html` es una copia independiente del motor con los datos ya insertados,
  no algo que herede de la plantilla en tiempo real. Arreglar solo el capítulo donde se vio
  el bug dos veces seguidas (en la revisión de la unidad 2 de B1, un bug de "match" se
  parcheó primero solo en 1B — el único con un ejercicio "match" real — y quedó sin
  propagar a 1A/1C/2A/2B/2C, que llevan el mismo código de motor aunque no lo usen; en la
  siguiente ronda, al propagar el SIGUIENTE bug a los seis archivos, 1C se quedó otra vez
  fuera porque el script de parcheo asumía por error que ya tenía el primer arreglo). Antes
  de dar por cerrado un arreglo de motor: `grep` el patrón roto (o su versión ya arreglada)
  en los seis `..._interactivo.html` de la rama, uno por uno, y confirma que todos
  coinciden — no solo el que disparó el hallazgo.
- **El panel de resultados debe ser de un solo tema, no adaptable.** Usa sus propias
  variables CSS fijas (`--rp-bg`, `--rp-text`, etc., definidas dentro de `.results-panel`),
  nunca los tokens intercambiables `--ink`/`--paper-raised`/`--gold` del resto de la página
  — esos invierten su significado en modo oscuro y dejan el panel ilegible.
- **`scroll-margin-top` en `.results-panel`** (igual que en `.block`) — si no, el scroll
  automático deja el panel oculto detrás de la cabecera fija (`sticky`).
- **El botón "Corregir todos" va al final**, después del último ejercicio, no en el hero —
  así el alumno lo encuentra donde naturalmente termina de responder.
- **Indicador de progreso obligatorio** (`#progressHint`) mientras falten huecos por
  corregir. Sin él, si el alumno se salta un ejercicio en una página larga, no aparece
  ninguna señal de por qué no sale el resumen final — "no pasa nada" desde su punto de
  vista.
- **`isCorrect()` NO soporta mezclar cadenas exactas y `{flex:[...]}` dentro del mismo
  array — un solo hueco con varias formas cortas aceptadas va TODO como cadenas.** Spec
  real: `a: [["curar"]]` (array de cadenas, comparación exacta) O `a: {flex:["curar"]}`
  (objeto suelto, todas las claves deben aparecer) — nunca los dos mezclados dentro de un
  mismo array (`a: [["curar"], {flex:["cura"]}]`). `isCorrect()` hace
  `spec.some(a => norm(a) === n)` sobre cada elemento cuando `spec` es un array: si un
  elemento es un objeto `{flex:...}` en vez de una cadena, `norm(objeto)` revienta
  (`objeto.toLowerCase is not a function`), y esa excepción sin capturar **aborta
  silenciosamente `gradeRange()` para TODOS los huecos restantes de la página**, no solo
  el roto — sin ningún error visible para el alumno, solo en la consola del navegador.
  Encontrado en revisión de PR (unidad 2 de B1, ej. 5 de 2C: `reproductor de música` /
  `lavaplatos` con alternativas `{flex:...}` mezcladas) y agravado por una trampa real:
  **la suite de regresión que rellena siempre la respuesta PRIMARIA nunca lo detecta**,
  porque `Array.prototype.some()` corta en cuanto encuentra la cadena correcta (la
  primera, siempre una cadena válida) sin llegar a evaluar el elemento roto — hace falta
  una prueba dedicada que escriba explícitamente cada alternativa. Para aceptar varias
  formas cortas en un mismo hueco, simplemente lístalas todas como cadenas:
  `a: [["reproductor de música", "reproductor", "mp3"]]`.
- **Escapa el texto que escribe el alumno antes de insertarlo en `innerHTML`**
  (`escapeHtml()`, usado en la lista de fallos del panel de resultados). Sin esto, un
  alumno que escribe `<algo>` en un hueco rompe el renderizado o ejecuta su propio HTML
  (self-XSS — bajo impacto real, pero un bug genuino).
- **Todo número/letra estructural lleva `translate="no"`** (`.item-letter`, `.exnum`,
  `#scoreNum`, `#scoreTotal`, `#totalBlanksLabel`, `#resScoreNum`, `#resScoreDen`, y en el
  índice `.level-badge`/`.chapter-num`). Bug real visto en producción: en 12C, con el
  traductor de página de Chrome móvil activo, los números "1.", "2."... de la lista de
  ejercicios desaparecían (mientras el resto del contenido de esa misma fila — la frase, el
  desplegable — seguía renderizando bien), porque Google Translate reescribe el DOM al
  traducir y puede descartar nodos que son solo un número/puntuación sueltos, sobre todo
  cuando conviven como hermanos de texto sí-traducible dentro del mismo contenedor armado
  con `innerHTML`. La solución NO es desactivar la traducción de toda la página (los
  alumnos rusohablantes pueden querer traducir el enunciado) — es marcar con
  `translate="no"` solo los elementos puramente estructurales/numéricos, que Google
  Translate respeta y deja intactos. La plantilla ya lo lleva en todos sus marcadores de
  número; si añades un tipo de ejercicio nuevo (o tocas uno existente, como los 5 tipos
  bespoke de 12C) que muestre un número de fila/hueco/puntuación fuera de estos, añade
  `translate="no"` ahí también — no lo des por hecho solo porque venga de la plantilla.
- **Tildes estrictas por diseño** — ver el paso 3 arriba. No es un bug a "arreglar"
  aflojando `norm()`/`isCorrect()` globalmente sin consultar al profesor primero.
- **Todo `<select>` necesita `max-width: 100%` + `text-overflow: ellipsis`.** Bug real en
  12C (los 3 ejercicios con `select.blank-select` — "relaciona", "elige categoría", "banco
  de opciones"): sin un límite de ancho, el `<select>` cerrado se dibuja tan ancho como su
  opción más larga (aquí, frases como "algo que se repite en el pasado y se acerca al
  presente"), no como el contenedor de la fila — en el teléfono, eso desborda la pantalla y
  el desplegable queda cortado por ambos lados, ilegible. La plantilla compartida no usa
  `<select>` (los 5 tipos documentados son todos de texto libre), así que este bug solo
  puede aparecer en ejercicios "a medida" como los de 12C. Si añades un `<select>` en un
  ejercicio nuevo, dale siempre `max-width: 100%; overflow: hidden; text-overflow: ellipsis;
  white-space: nowrap;` — el desplegable nativo (las opciones, al abrirlo) no se ve
  afectado, solo el ancho de la caja cerrada.
- **`.nav-dots` (la fila de píldoras "Sección N" para saltar entre secciones) nunca se
  oculta en móvil — se desliza en horizontal.** Bug real: la plantilla traía
  `@media (max-width: 560px) { .nav-dots { display: none; } }` desde el origen, tolerable
  con pocas secciones pero que en un documento largo (Repaso B1 llegó a 12) le quita al
  alumno la forma más cómoda de moverse por el documento en el móvil — justo donde más la
  necesita. Ahora `.nav-dots` lleva `overflow-x: auto` (mismo patrón que `.table-wrap` para
  tablas anchas) y, en la media query de 560px, `flex-basis: 100%; order: 3` para que las
  píldoras bajen a su propia fila deslizable debajo de marca+puntuación en vez de compartir
  línea con ellas. Ya corregido en `reference/template.html` y en todos los documentos
  publicados (A1, 12B, Repaso B1); si tocas un ejercicio existente que todavía tuviera
  `.nav-dots { display: none; }`, es la misma corrección.
- **Hueco de verdadero/falso (`item.vf: true`): el input real se queda, solo se oculta.**
  Nació en el cuaderno A1 6A, a petición del profesor ("botoncitos V/F en vez de escribir").
  La tentación es sustituir el `<input class="blank">` por otra cosa — pero `gradeRange`,
  `isCorrect` y, sobre todo, `extraer.mjs` (el archivador de `fuentes/`) dependen de
  encontrar un `input.blank` real para leer/escribir su `.value`. La solución que no rompe
  nada de eso: el input sigue existiendo, `type="hidden"`, y dos `<button>` visibles le
  escriben `"V"`/`"F"` al hacer clic — el motor de corrección no se entera de la diferencia.
  Lo único que no podía reutilizarse tal cual: `gradeRange` coloreaba `rec.el` (el propio
  input) al corregir, pero un input oculto no se ve. Se añadió un hook opcional
  `rec.onGrade(ok)` — genérico, no solo para V/F — que `makeVfButtons` usa para colorear el
  botón elegido en vez del input. Y **`extraer.mjs` tuvo que aprender la envoltura
  `.vf-wrap`**: su recorrido del DOM solo reconocía `input.blank` como hijo directo de la
  fila con el `.reveal` como su hermano siguiente; con el input anidado dentro de
  `.vf-wrap`, sin este ajuste el texto de los botones ("V", "F") se colaba literal en la
  frase archivada (`→ **?**VF`) en vez de la respuesta real. Si añades otro hueco "no-texto"
  (chips, un slider, lo que sea) que también oculte el input real, revisa si necesita el
  mismo tipo de ajuste en `extraer.mjs` antes de darlo por archivable.

- **REGLA DEL PROFESOR, sin excepciones: todo ejercicio con audio lleva su transcripción en
  un plegable.** No es opcional ni depende de si tenemos la grabación — de hecho es cuando
  NO la tenemos cuando más falta hace, porque sin ella el ejercicio es irresoluble en casa.
  Si un capítulo tiene un ejercicio de audio, búscale la transcripción antes de publicarlo;
  y si de verdad no aparece, dilo en el enunciado y pídesela al profesor, pero **nunca la
  inventes**: una transcripción escrita por Claude puesta como si fuera la del libro es
  material falso, y encima el alumno la usaría para autocorregirse.
- **Cuando sí hay grabación real, incrústala (`ex.audioSrc`) — no basta con la
  transcripción.** Nació al añadir las pistas 6, 7 y 8 de B1 (5B y 5C). Dos lecciones
  reales de ese proceso:
  - **No te fíes de una carpeta de Drive por el nombre solo.** La primera carpeta que
    parecía obvia («АУДИО B1 Nuevo español en marcha», con archivos «PISTA NN.mp3»)
    resultó ser del **libro del alumno**, no del cuaderno de ejercicios — mismo manual,
    audio distinto. Se detectó a tiempo (antes de publicar) porque el profesor dudó y
    porque la propia sección de «Transcripciones» del cuaderno (páginas 64-68) cita
    explícitamente el número de pista más alto que usa en todo el libro — en B1 no pasa de
    la **19**, mientras que esa carpeta llegaba hasta la 69 por lo menos. Ese máximo,
    sacado del propio PDF con una regex simple sobre esas páginas, es la verificación
    barata: si la carpeta candidata tiene pistas por encima de ese máximo, no es la del
    cuaderno.
  - **Las grabaciones de este archivo pueden venir en `.wma` (Windows Media Audio), que
    casi ningún navegador reproduce en `<audio>`** (ni Chrome, ni Safari, ni el navegador
    del móvil). Hace falta convertirlas a mp3 antes de incrustarlas. Este contenedor no
    tiene `ffmpeg` del sistema (y `apt-get install` falla con 404, mismo problema que con
    `poppler-utils`), pero `pip install imageio-ffmpeg` **sí funciona** y trae un binario
    de ffmpeg estático listo para usar:
    ```python
    import imageio_ffmpeg; print(imageio_ffmpeg.get_ffmpeg_exe())  # ruta al binario
    ```
    ```bash
    "$FFMPEG" -y -i entrada.wma -codec:a libmp3lame -b:a 128k salida.mp3
    ```
    Comprueba después con `mutagen` (`from mutagen.mp3 import MP3; MP3(ruta).info.length`)
    que la duración del mp3 convertido coincide con la del wma original
    (`from mutagen.asf import ASF`) — si no coincide, la conversión se cortó a medias.
  - El audio va como `data:` URI en base64 (un artefacto no puede enlazar un archivo
    externo), igual que las imágenes. **La transcripción no se quita aunque haya audio
    real** — sigue siendo la regla del profesor de arriba, ahora como apoyo en vez de
    único recurso. Verifica con Playwright que carga de verdad: `preload="none"` en el
    motor por defecto significa que hay que forzar `audio.load()` y esperar el evento
    `loadedmetadata` (o `error`) para comprobar la duración, no basta con contar
    `<audio>` en el DOM.
  - **Esto es una excepción deliberada, no un descuido, a la regla general de
    `README.md` raíz** («archivos pesados de audio/video no se suben a este
    repositorio»): esa regla apunta a grabaciones de clase enteras
    (`docencia-espanol/grabaciones/`), que sí viven solo en Drive. Aquí el audio
    incrustado *es* el contenido del ejercicio publicado, no un archivo aparte que
    archivar — el artefacto tiene que ser autocontenido para funcionar (nada de
    referencias externas), así que no hay alternativa a incrustarlo. Precedente ya
    fusionado en `main`: 5B y 5C de B1 (PR #52), cada uno con su propio `data:` URI de
    varios MB.
- **El cuaderno de B1 también trae solucionario y transcripciones**, con el mismo reparto:
  **64-68 transcripciones, 69-76 soluciones** (las 52-63 son los textos de «Leer más», la
  76 son las soluciones de esas lecturas y la 77 es la contracubierta; el PDF tiene 77
  páginas y su numeración coincide con la del libro, sin desfase). Lo dice tal cual el
  índice de la página 3; aun así, confírmalo renderizando los límites. Ojo con una trampa
  de ese índice: lista la página en la que EMPIEZA cada unidad, no la de cada sección — la
  unidad 5 empieza en la 20, así que 5A está en la 20, 5B en la 21 y 5C en la 22. Este PDF sí tiene capa de texto,
  pero es OCR de ABBYY con codificación Custom y sale sucio («senala», «Buenos dlas»): vale
  para localizar en qué página está algo, no para copiar. Transcribe mirando la página.
- **Dónde están las transcripciones y el solucionario del cuaderno de A1.** El PDF del
  cuaderno los trae al final, y son páginas del propio PDF, no algo que haya que pedir:
  **54-55 «Transcripciones», 56-61 «Soluciones», 62-64 el glosario.** Renderízalas con
  `paginas.sh` y tenlas delante antes de transcribir un capítulo. Se descubrió tarde: hasta
  la unidad 7A se estuvieron deduciendo respuestas y pidiendo fotos que ya estaban ahí.
  Dos avisos: la sección de transcripciones titula las unidades con el nombre que llevan en
  el **libro del alumno**, no en el cuaderno (6A aparece como "¿Cómo se va a Plaza de
  España?" cuando en el cuaderno es "¿Cómo se va a Goya?" — guíate por número y letra); y
  **el número de pista sácalo de ahí, no del iconito de la página**, que en el escaneado se
  lee fatal: en 7A se transcribió "pista 19" y "pista 20" cuando eran la 9 y la 10.
- **Ejercicios de audio: la transcripción va plegada (`ex.transcriptHTML`), nunca a la
  vista.** En un ejercicio de comprensión oral la transcripción **es** la solución, así que
  si se pone abierta el ejercicio deja de existir; pero omitirla tampoco vale, porque está
  en el libro y sin audio a mano es lo único que le permite al alumno autocorregirse. La
  plantilla la pinta en un `<details>` nativo al final de la tarjeta, después de las
  preguntas (arriba se leería antes de responder). Nativo y no un desplegable a mano: sale
  accesible por teclado y sin JS. `ex.transcriptLabel` cambia el texto del resumen — usa uno
  que avise, del tipo "ábrela solo después de responder".
- **El texto que devuelve el conector de Drive de un PDF escaneado es OCR suyo, no una capa
  de texto.** El cuaderno de A1 no tiene fuentes (`pdffonts` vacío), y aun así
  `read_file_content` devuelve texto: lo está reconociendo él. Eso explica de una vez las
  dos rarezas que se le achacaban al PDF —el orden de lectura que no coincide con el visual
  y los caracteres cambiados— y significa que **ese texto no vale para transcribir**, solo
  para localizar y para leer de corrido. Baja el PDF y mira las páginas.
- **Aun siendo OCR, la sección «Transcripciones» y el solucionario del cuaderno de A1 salen
  lo bastante limpios para leerlos de corrido** (son texto seguido, sin gráficos que
  desordenen la lectura), así que sirven para localizar rápido en qué página está lo que
  buscas. Para copiar el contenido, mira la página renderizada: el OCR cambia caracteres.
- **El diálogo original no trae nombres.** El libro distingue las réplicas solo con dos
  símbolos, que además el OCR destroza. Deducirlos del contenido y escribirlos como
  `MARTA:` / `BEATRIZ:` es correcto (es el mismo formato que el libro usa en otras
  unidades) y se lee mucho mejor en pantalla — pero **déjalo dicho** en una nota al pie de
  la transcripción, para que dentro de unos meses nadie los tome por literales del original.

- **`ex.refHTML` ya está en la plantilla — pero antes no lo estaba, y por eso se publicó un
  ejercicio irresoluble.** Al montar el cuaderno A1 6B (un «relaciona» de diez ítems) se dio
  por hecho que la plantilla traía el recuadro de opciones, porque los capítulos anteriores
  lo tenían. No lo traía: `refHTML` había nacido en Repaso B1 y en 6A se había portado **a
  mano, solo a ese archivo**. Resultado: el artefacto se publicó con «Pon ___», «Habla ___»…
  y ninguna opción a la vista. El motor no avisa de esto —una propiedad que el renderizador
  no lee simplemente se ignora en silencio—, así que **después de rellenar `blocks`,
  comprueba que cada propiedad que has usado la lee de verdad el renderizador** (`grep` por
  su nombre en el archivo). Y cuando portes una mejora a un capítulo concreto, pásala
  también a `reference/template.html` en el mismo momento, o el siguiente capítulo la
  volverá a perder. Lo mismo pasó con `type: "open"` y con la transcripción plegable.
- **El ítem que el libro trae resuelto va con `item.solved: true`, no como hueco.** Casi
  todos los ejercicios de estos cuadernos traen el primer ítem hecho como modelo. Ponerlo
  como hueco le pide al alumno algo que en su cuaderno ya está impreso, y descuadra la
  puntuación. Con `solved: true` la fila se pinta en gris cursiva, se ve (está en el
  original y sirve de modelo) y no genera hueco. **El texto extraído del PDF no siempre
  delata cuál es**: en 6B, el ítem resuelto del ejercicio 1 es una **línea dibujada** entre
  las dos columnas, que en el texto no aparece por ningún lado — se descubrió al ver la foto
  de la página. Si el capítulo viene solo del PDF, sospecha del ítem 1 de cada ejercicio.
- **Los botones no son solo para V/F: `vf` acepta un par cualquiera, y se puede aplicar a un
  solo hueco.** `vf: true` da V/F en todos los huecos del ítem; `vf: ["regular","irregular"]`
  da ese par; y `vf: { 1: [...] }` lo aplica **solo al hueco {1}**. Esa tercera forma es la
  que hace falta cuando un ítem mezcla escribir y elegir —«hablar → [imperativo]
  [regular|irregular]»—, y nació de un fallo real: con `vf` declarado en el ítem, el hueco
  del imperativo también se convirtió en botones. Si un ejercicio del libro pide repartir
  cosas en dos columnas, esto es lo que traduce esa decisión a la pantalla.
- **Fotos, tablas y sopas de letras van SIEMPRE centradas.** Instrucción explícita del
  profesor, y hay una regla al final del `<style>` de la plantilla que lo garantiza para
  `.foto-act`, `.wordsearch`, `table.gustos`, las imágenes de `.exercise-ref` y de
  `.open-block`, y `.postcard`. Ojo con dos trampas: un bloque con `max-width` **no** se
  centra solo, necesita `margin-left/right: auto` (esto ya causó un arreglo real en
  `.open-block` y `.postcard`); y un elemento con `white-space: pre` como la sopa de letras
  necesita además `width: fit-content`, porque si no ocupa todo el ancho y centrar no hace
  nada visible. Para una **fila de opciones que son dibujos** el centrado no es del elemento
  sino de su contenido: `.ref-options:has(img) { justify-content: center }`. Las filas de
  opciones que son palabras se quedan a la izquierda a propósito — una lista se lee así.
- **Y el recuadro `.exercise-ref` se ajusta a su contenido (`width: fit-content`), no al
  ancho de la tarjeta.** Centrar la sopa de letras no bastaba: el fondo dorado seguía yendo
  de borde a borde y dejaba una franja de color enorme y vacía alrededor de una rejilla que
  ocupa un tercio. Con `fit-content` el recuadro encoge hasta su contenido, y cuando ese
  contenido ya es ancho —una lista larga de opciones— se queda a lo ancho como antes, sin
  necesidad de distinguir casos. Medido tras el cambio: la sopa ocupa el 38 % del ancho
  disponible, la tabla de gustos el 42 %, y las listas largas siguen al 100 %. El título del
  recuadro (`.ref-label`) va centrado también: con la caja ya ajustada, una etiqueta pegada a
  la esquina izquierda queda descolgada.
- **Cuando todas las filas de un ejercicio tienen la misma forma, alinéalas en columnas con
  `item.pre`.** Un listado de «palabra → casilla → botones» donde la palabra va dentro de
  `item.t` empieza cada casilla donde acaba su palabra: casillas de distinto ancho, botones a
  distinta altura, y el conjunto se ve descuadrado aunque cada fila por separado esté bien.
  `item.pre` saca esa etiqueta a un elemento propio de ancho fijo y la fila pasa a ser un
  flex con columnas. Tres cosas hay que fijar, no una: la etiqueta (`flex: 0 0 8.8em`), la
  **letra del ítem** (`i.` y `m.` no miden lo mismo y arrastran la diferencia a todo lo que
  va detrás) y el **ancho de los botones** cuando son palabras (`.vf-toggle.vf-words`, que
  `makeVfButtons` marca sola al ver opciones de más de un carácter). Y usa `flex-basis`
  fijo, no `min-width`: con `min-width`, la etiqueta más larga del grupo empuja su fila.
- **Hueco al final de la frase: se estira hasta el borde derecho, no baja de línea.** Es el
  caso más común («Pedro se encuentra mejor ______.»), y el criterio del profesor es claro:
  el hueco es la **continuación natural** de la oración, así que empieza justo donde acaba el
  texto, pero **todos terminan en el mismo sitio**. Eso es lo que hace que se vean parejos.
  La fila se marca sola como `.tail-blank` y pasa a ser flex con la casilla en `flex: 1`.
  Primero se probó bajando la casilla a su propia línea a ancho completo: iguala tamaños,
  sí, pero parte la oración en dos y el profesor lo rechazó.
  **Ojo con detectar «al final»**: no vale `row.lastElementChild`, porque el texto que sigue
  al hueco son nodos de TEXTO, no elementos, y con eso se colaban frases del tipo «¿Qué ___
  (hacer) ayer?» —donde el hueco va dentro de la frase y estirarlo la parte por la mitad—.
  Hay que mirar los nodos posteriores y aceptar solo puntuación de cierre.
  Dos correcciones más, ambas detectadas por el profesor mirando el resultado:
  **(a) Envuelve número + frase en un solo `<span class="tail-text">`.** Si se dejan sueltos,
  cada nodo de texto es un elemento flex independiente: una frase larga no cabe al lado del
  número, salta entera a la línea siguiente y el número se queda solo arriba (se veía una
  «e.» huérfana en «Formación de contrarios»). Con el envoltorio, el número va siempre pegado
  a su frase y es la frase la que parte por dentro.
  **(b) Estira solo si hay más de una fila así en el ejercicio.** El estirón existe para que
  varias filas acaben en el mismo sitio; una sola, rodeada de frases con el hueco en medio, se
  ve como una raya larga y arbitraria (ejercicio 6 de 12B). Tras montar las filas se cuentan
  las `.tail-blank` y, si hay exactamente una, se le quita la clase.
- **Un listado que en realidad es una tabla, hazlo tabla (`conjTable`/`conjTables`).** El
  ejercicio 4 de Repaso B1 (imperativos irregulares) eran 16 filas «VERBO · persona →
  afirmativo ___, negativo ___» como `items`. Ahí no hay alineación posible: la etiqueta mide
  distinto en cada fila y arrastra todo lo demás, y encima las dos filas que el libro trae
  medio resueltas tenían un solo hueco, así que se estiraban (`.tail-blank`) mientras las
  otras catorce no — el desorden que vio el profesor. Como cuadro de conjugación (un cuadro
  por verbo, columnas «Afirmativo»/«Negativo», y las formas dadas como **cadena** en vez de
  array para que salgan fijas y no cuenten como hueco) todo cae en columnas solo. Regla
  general: si las filas comparten estructura y no son frases, es una tabla, no una lista.
  La plantilla trae `conjTable` (un cuadro); **`conjTables`** (varios cuadros en el mismo
  ejercicio, con un solo botón «Corregir») es un añadido de Repaso B1: si lo necesitas,
  cópialo de ahí. Y si el documento estrecha los huecos de las tablas —Repaso B1 pone
  `.exercise-table input.blank` a 6.4 em porque sus cuadros de cinco columnas no caben de
  otra forma—, ensancha los cuadros de solo dos columnas de respuesta con
  `tr:has(td:nth-child(3)):not(:has(td:nth-child(4)))`: con 6.4 em, «no vengáis» se cortaba.
  Y da aire entre cuadros consecutivos (`.table-wrap + .table-wrap`), o los cuatro se leen
  como una sola tabla larga con cabeceras intercaladas.
- **Una fila con foto nunca lleva el hueco estirado a la derecha.** El hueco va DEBAJO de la
  imagen, que es lo que pide el enunciado del libro («escribe debajo qué actividad es»). Al
  marcarla como `.tail-blank` la fila se vuelve flex y la casilla sube al costado de la foto,
  que además deja de estar centrada porque el envoltorio anula sus `margin: auto`. La
  detección excluye estas filas (`!row.querySelector(".foto-act")`). En móvil no se notaba
  —el hueco no cabe al lado y baja igual—, así que solo salía en escritorio.
- **Si tocas cómo se construye una fila, comprueba `extraer.mjs`.** Al pasar el ejercicio 5
  de Practica más 3 a columnas, el `.md` archivado empezó a salir con las respuestas pegadas
  (`**habla****regular**`): el separador que antes ponía el texto de `item.t` había
  desaparecido. `extraer.mjs` necesitó reconocer `.item-pre` y añadir un espacio entre dos
  huecos consecutivos. Regenera y compara con `diff` **todos** los `.md` después de cualquier
  cambio estructural, no solo el del capítulo que estás tocando.
- **Una fila con foto se centra entera, no solo la foto** (`.item-row:has(.foto-act)`):
  número, imagen y casilla de escribir. Centrar solo la imagen deja el número y el hueco
  pegados a la izquierda y la fila se lee descolocada — lo detectó el profesor en cuanto se
  centró la foto sola.
- **`item.img` pone una foto en la fila, y va DESPUÉS del número.** Al revés (foto y luego
  número) cada número queda debajo de su propia foto y pegado a la siguiente, y no se sabe a
  cuál se refiere. La foto se declara como campo del ítem, no como HTML dentro de `item.t`:
  meter marcado en el texto de los enunciados abre una puerta que no hace falta abrir.
- **Muchos dibujos pequeños van en rejilla, no en columna** (`ex.grid: true`, que pone la
  clase `.items-grid` con `grid-template-columns: repeat(auto-fill, minmax(140px, 1fr))`).
  Va activada por el ejercicio a propósito, no por `:has(.foto-act)`: con el selector
  genérico, las fotos grandes de Practica más 3 pasarían también a celdas de 140 px con alto
  fijo, que es justo lo que no debe pasar. Los 18 alimentos de la 5A
  en una sola columna eran una tira interminable para un ejercicio que en el libro cabe en
  media página; con 140 px de mínimo salen cuatro por fila en el ordenador y dos en el
  móvil, sin tocar nada más. Y dales a todos la **misma caja**
  (`width: 100%; height: 100px; object-fit: contain`): son de proporciones muy distintas y,
  a su ancho natural, unos se salen de su celda y los números quedan a distinta altura.
  Ojo con la diferencia: esto es para dibujos pequeños de vocabulario; las **fotografías**
  grandes de una actividad (Practica más 3) siguen yendo una por fila.
- **Al recortar dibujos de una página escaneada, no uses bandas de posición fija.** En la 5A
  la primera tanda salió con el plato del filete partido por la mitad: en dos de las seis
  filas los dibujos casi se tocan y la banda fija los cortaba. Detecta las separaciones por
  **columnas sin tinta** (con una separación mínima pequeña, ~14 px: subirla vuelve a fundir
  dibujos vecinos), recorta el blanco sobrante de cada uno y **monta una hoja de contacto
  con los recortes y míralos** antes de incrustarlos. Es la única forma de ver que están
  enteros y que cada uno corresponde a la respuesta que dice el solucionario.
- **Un salto de línea justo antes del hueco significa «esta respuesta va en su propia
  línea».** La detección de hueco-de-cola lo respeta y no estira la casilla: si lo hace,
  queda flotando a media altura, ni en línea ni debajo. Es el caso de los ejercicios de
  «construye la frase», donde el enunciado va arriba y la raya de respuesta debajo, como en
  el libro.
- **Si el libro marca las respuestas como «posibles respuestas», el ejercicio no puntúa.**
  Corregirlo contra una sola solución marcaría en rojo respuestas correctas. Va como
  `type: "open"` con los enunciados a la vista, las del solucionario en un plegable para
  comparar, y —esto es lo que lo salva de ser un ejercicio muerto— **una nota con la regla
  que se está practicando** (en la 5A: después de *para que*, subjuntivo; después de *para*,
  infinitivo), para que el alumno pueda autocorregirse aunque su frase no sea la del libro.
- **Alinear los desplegables: probado y descartado.** Se llegó a estirar los `<select>` de
  12C hasta el borde derecho, igual que las casillas de texto y los botones V/F. El profesor
  lo vio y lo rechazó: los desplegables no necesitan alinearse. No lo vuelvas a proponer.
- **Un «relaciona» donde un ítem admite varias letras: genera las permutaciones.** En
  Practica más 3 el aceite está en tres platos. Basta con generar cada orden con espacio
  después de la coma (`"a, b, c"`) — **ya no hace falta además la variante sin espacio**
  (`"a,b,c"`, lo que hacía la función `combos()` de ese capítulo): `norm()` sustituye la
  coma por un espacio y colapsa espacios seguidos, así que las dos formas —y cualquier
  mezcla de espaciado— ya normalizan a la misma cadena (arreglado en revisión de PR,
  unidad 2 de B1; antes `norm()` solo borraba la coma sin más, y "a,b,c" sin espacio
  normalizaba distinto de "a, b, c").
- **Una sopa de letras necesita una pista por hueco, y comprobar la rejilla por programa.**
  Los huecos se corrigen en un orden fijo, así que sin pista cualquier palabra valdría en
  cualquier hueco: se añaden las dos primeras letras (y se dice en el enunciado que es un
  añadido del artefacto). Y antes de darla por buena, **busca cada palabra del solucionario
  en la rejilla con un script, en las ocho direcciones** — en Practica más 3 «LECHUGA» va
  hacia la izquierda y a ojo no aparecía.
- **Cuando el ejercicio numere sus opciones con letras, numera los ítems (`ex.numbered`).**
  En un «relaciona» con opciones a-j, dejar los ítems como a., b., c. crea dos series de
  letras que no significan lo mismo en la misma tarjeta. El libro numera los ítems 1-10:
  copia eso. Mismo problema, misma solución que en los diálogos con interlocutores A/B.
- **Celdas ya resueltas en una tabla (`conjTable`): spec como cadena, no como array.** En
  6B el libro trae resueltas las filas de «cerrar» y «seguir» y el presente de «guardar».
  Si se ponen como huecos, el alumno tiene que "adivinar" algo que en su cuaderno está
  impreso, y el total de huecos deja de coincidir con lo que hay que rellenar de verdad.
  `ex.subjectLabel` cambia además el encabezado de la primera columna, que estaba fijado a
  «Sujeto» y en una tabla de infinitivos no significa nada.
- **Crucigrama real (`type: "crossword"`), añadido en la 5B de B1.** Hasta entonces un
  crucigrama del libro se resolvía como lista de definiciones con la foto de la rejilla al
  lado (`ex.refHTML`) — funcionaba, pero el profesor pidió expresamente probar a construir
  la rejilla de verdad, con casillas que se cruzan. `ex.words` es una lista de
  `{ num, clue, answer, row, col, dir: "A"|"D", solved? }`; el renderizador calcula una
  sola vez la celda de cada cruce (no crea dos inputs superpuestos) y reutiliza el motor de
  corrección de siempre — cada celda es un `makeInput([letra], ...)` normal, así que se
  colorea sola en verde/rojo sin código nuevo. `extraer.mjs` no sabía leer esto (no hay
  `.item-row` que recorrer): las celdas llevan `data-w<num>="<índice>"` y `data-letter`
  precisamente para que el archivador reconstruya cada palabra sin depender de un
  `.reveal` — no cabe uno en una casilla de una letra.
  **La lección de verdad, la que hizo falta corregir a mitad de camino:** intentar leer
  las coordenadas EXACTAS de la rejilla del libro a partir del escaneo, celda a celda, con
  análisis de píxeles (`PIL`+`numpy`, detectando líneas de rejilla por franjas de
  oscuridad) es viable para los primeros cruces pero se vuelve poco fiable cuanto más se
  aleja uno de una referencia clara — en la 5B, los cinco primeros cruces (con
  `risoterapia` y `medicamento`) salieron confirmados dos veces por mediciones
  independientes y cuadraban perfectamente con las letras reales de las palabras; los dos
  últimos (filas 7 y 8) empezaron a dar posiciones inconsistentes según de qué zona se
  partiera, y forzar una coordenada dudosa en un crucigrama es peor que en cualquier otro
  ejercicio: un cruce mal leído no marca una respuesta como incorrecta, **hace el
  crucigrama irresoluble** (dos palabras que deberían compartir letra y no la comparten).
  La salida, y la que hay que repetir si esto vuelve a pasar: en cuanto la lectura de
  píxeles deje de ser sólida, dejar de perseguir el layout exacto del libro y **diseñar
  una rejilla propia** con las mismas palabras y definiciones, colocando los cruces que sí
  se confirmaron y buscando por código (no a ojo) una letra compartida real para los que
  faltan — ver el bloque de placement con `can_place`/`find_crossings` que se escribió
  para esto, reutilizable tal cual. El resultado no es pixel-perfect al libro, pero está
  garantizado correcto por construcción, que es lo que de verdad importa en un ejercicio
  que se publica para que un alumno lo resuelva.

- **"Relaciona" con columnas de verdad (`type: "match"`), añadido tras la unidad 6 de B1.**
  Hasta entonces, un ejercicio de "relaciona" (verbo → final, columna A → columna B) se
  resolvía escribiendo la letra/número de la pareja en un hueco de texto (ver 6A ej. 2 y 6B
  ej. 3, que se quedaron así — no se retocaron). Funcionaba, pero tenía dos problemas: no
  se parecía en nada al ejercicio real del libro (tocar/unir), y obligaba a aceptar un
  montón de variantes de tecleo para la misma respuesta (`"d, 2"`, `"d,2"`, `"d 2"`, `"d2"`)
  porque `norm()` quita comas y puntos pero no espacios internos, así que dos formas
  "iguales" a ojo no siempre normalizan a la misma cadena.
  El profesor pidió una interacción de tocar-para-conectar en vez de otra ronda de aceptar
  variantes de texto. `ex.columns` es un array de columnas (`{ label, items: [...] }`);
  `columns[0]` es la columna ancla, fija, una por fila — las demás son elegibles. `ex.rows`
  es paralelo a `columns[0].items`: `{ solved: true }` para una fila ya resuelta en el
  libro (sin huecos, sin botones), o `{ a: [spec1, spec2, ...] }` con un spec de
  `isCorrect()` por cada columna elegible, en orden. Se toca primero un elemento de la
  columna ancla (se arma, queda resaltado en dorado) y luego su pareja en la columna
  siguiente: se guarda en un `input type="hidden"` (el mismo truco que ya usaba el V/F de
  "items" para que `gradeRange`/gradeRange lo trate exactamente igual que cualquier otro
  hueco de texto) y se dibuja una línea de color entre ambos con un `<svg>` superpuesto a
  `.match-wrap`. Con 3 columnas la interacción encadena: primero columna ancla → columna 1,
  y sin desarmar la fila, columna 1 → columna 2 (la línea sigue el camino elegido tramo a
  tramo). Una opción solo puede pertenecer a una fila a la vez — tocarla desde otra fila se
  la quita a la que la tenía antes, para que no se pueda "hacer trampa" repitiendo la misma
  pareja en dos sitios.
  **Trampa de timing que costó encontrar:** `getBoundingClientRect()` de las fichas da
  0,0,0,0 si se llama durante la propia construcción del ejercicio, porque `<section>` del
  bloque todavía no está insertado en `#main` en ese momento (se inserta una vez por
  bloque, al final de `block.exercises.forEach`, no ejercicio a ejercicio). La función
  `drawLines()` de cada ejercicio "match" se guarda en un array (`pendingMatchDraws`) y se
  llama a TODAS una sola vez, justo después de que `blocks.forEach(...)` termina — ahí el
  documento ya tiene el layout real. Un solo listener de `resize` (no uno por ejercicio)
  las vuelve a llamar si la ventana cambia de tamaño.
  `extraer.mjs` no sabía leer esto (no hay `.item-row` ni `.reveal` por celda): como el
  archivador nunca toca los botones (solo rellena `input.blank` de texto y pulsa
  "Corregir"), cada fila de "match" llega sin ninguna opción elegida — exactamente el caso
  que hace que `ex._onGraded()` rellene su `.match-row-reveal` con la respuesta completa,
  el mismo mecanismo que ya usaba el crucigrama para su reveal-junto-a-la-definición. El
  archivador solo tiene que leer `.match-anchor`/`.match-solved` + el `.match-row-reveal`
  siguiente, si lo hay.
  **Bug real encontrado en revisión de PR (color de corrección que se queda pegado):**
  `ex._onGraded()` solo añade `.match-correct`/`.match-incorrect` a la ficha elegida en ese
  momento; nada las quitaba al desmarcar una ficha o al cambiar de elección dentro de la
  misma fila. Caso real: el alumno corrige, ve una ficha en rojo, rearma la fila y elige
  otra opción (correcta) — la ficha vieja se quedaba roja para siempre, porque nada vuelve
  a tocarla salvo que otra fila la reclame y la corrija de nuevo. Arreglado quitando esas
  dos clases de la ficha abandonada (y de la recién elegida, por si venía de otra fila ya
  corregida) en el propio manejador de clic de `mwrap`, no solo en `_onGraded()`.

### Canal por canal (la parte que más costó)

Cada botón de "enviar al profesor" tuvo su propia trampa específica de plataforma. La regla
general que emergió: **usa siempre un enlace `https://` normal (`<a target="_blank"
rel="noopener">`), nunca `window.open()` desde JavaScript ni un protocolo que no sea
http(s)** — WhatsApp siempre funcionó porque siempre fue así; todo lo que se rompió fue
justamente lo que no cumplía esta regla.

**Caso real de por qué esta regla no es negociable (PR #28 → #29)**: en un intento de
combinar copiar-al-portapapeles con abrir el correo, el botón de Correo se convirtió
temporalmente en un `<button onclick="...">` que llamaba a `window.open()` en vez de ser un
`<a href>`. El resultado, confirmado por el profesor en dispositivo real: el botón dejó de
redirigir **tanto en el navegador de escritorio como en el móvil, a la vez**. Causa: el
permiso "bloquear ventanas emergentes" de Chrome es **por sitio y persiste entre
sesiones** — se había ido acumulando durante las propias pruebas de desarrollo (cada clic
de prueba que abre un popup puede hacer que Chrome, tras varios, empiece a bloquear ese
sitio silenciosamente). Un `<a target="_blank">` nativo está exento de ese bloqueo; un
`window.open()` desde script no, ni siquiera si se ejecuta de forma síncrona dentro del
manejador del clic. La corrección (PR #29) fue volver a un `<a href>` normal con la lógica
de copiar-portapapeles enganchada como un `addEventListener("click", ...)` **aditivo** —
que no reemplaza ni compite con la navegación nativa, solo se ejecuta además de ella.
**Nunca reintroduzcas `window.open()` ni `<button onclick>` para estos botones**, aunque
parezca más "controlable" desde JS — ya se demostró que rompe el caso más básico.

- **WhatsApp** (`https://wa.me/<número>?text=<encoded>`): funciona de fábrica, sin trucos.
  Referencia de lo que SÍ funciona.
- **Correo**: **nunca uses `mailto:`.** El artefacto se sirve en un iframe con sandbox
  cuando se comparte públicamente (gente sin cuenta de Claude abriendo el enlace
  directamente), y ese sandbox bloquea cualquier protocolo que no sea `https://` — no
  importa si usas `<a href="mailto:">`, `window.open()` sincrónico o asíncrono, con o sin
  `target="_blank"`: todo falla en silencio o, peor, puede dejar la página en blanco si el
  sistema no tiene cliente de correo configurado. La solución que sí funciona: un enlace de
  redacción de Gmail (`https://mail.google.com/mail/?view=cm&fs=1&to=...&su=...&body=...`),
  exactamente de la misma clase que WhatsApp. Confirmado por el profesor: en escritorio
  abre Gmail web con todos los campos rellenados correctamente.
- **Correo en Android: límite conocido y aceptado, no lo sigas "arreglando".** En el móvil,
  este mismo enlace de Gmail web a veces abre el navegador en vez de la app (aunque el
  ajuste "Abrir vínculos admitidos" de Gmail esté activado — confirmado por el profesor con
  captura de pantalla, no es un problema de configuración del dispositivo), y cuando sí
  abre la app, esta no entiende los parámetros de redacción web (`view=cm`, `su`, `body`) y
  abre un correo en blanco. Se probó como alternativa el esquema propio de la app
  (`googlegmail://co?to=...&subject=...&body=...`), condicionado por `navigator.userAgent`
  solo en móvil (PR #31) — y en la prueba real en dispositivo **dejó de abrir nada en
  absoluto**, peor que el comportamiento anterior. Se revirtió por completo sin fusionar el
  PR. **Lección**: no sigas probando esquemas de URL de apps nativas sin
  documentar/verificar — no hay forma de comprobarlos desde este entorno (no se pueden
  lanzar apps nativas reales aquí) y cada intento fallido es un ciclo completo de "el
  profesor prueba en su teléfono y reporta que empeoró". El único mecanismo que demostró
  ser 100% fiable en móvil es el respaldo de copiar-al-portapapeles con mensaje explícito
  (ver más abajo) — trátalo como la solución real, no como un "por si acaso" secundario.
  Esto quedó aceptado explícitamente por el profesor como límite conocido, no como bug
  pendiente: no reabras este hilo sin que él lo pida.
- **Telegram**: los enlaces con número de teléfono (`t.me/+<número>`) nunca precargan texto
  — el parámetro `?text=` solo funciona con un `@usuario` (`t.me/<usuario>?text=...`). Pide
  el `@usuario` de Telegram del profesor si no lo tienes; no asumas que el número sirve.
  Además, el servidor de Telegram (`t.me`, nginx) devuelve **400 Bad Request** con URLs
  bastante más cortas que el límite que WhatsApp tolera sin problema (~1200-1500 caracteres
  ya codificados es un margen seguro comprobado; ~4650 ya falla). Trunca el texto con
  `truncateForUrl()` (ya en la plantilla) antes de meterlo en el enlace de Telegram.
- **Teams**: su parámetro `?message=` para precargar nunca se confirmó fiable. Por eso,
  a diferencia de WhatsApp/Telegram/Correo, Teams sigue llevando el respaldo de "copiar al
  portapapeles + mensaje explícito" (`copyText(...)` con un texto tipo "pégalo en el chat
  que se acaba de abrir" — un simple "¡Copiado!" genérico pasa desapercibido justo cuando la
  pantalla cambia de app). **Codifica siempre `TEACHER.teamsEmail` con `encodeURIComponent`**
  al construir el `?users=` del enlace (`https://teams.microsoft.com/l/chat/0/0?users=...`)
  — PR #30 corrigió una inconsistencia real donde ese único campo se insertaba sin codificar
  mientras todos los demás canales sí codificaban el suyo. Dicho esto, esa corrección es de
  consistencia, no una solución confirmada a un límite ya observado y aceptado: en
  escritorio, Teams pega el mensaje pero **no selecciona automáticamente al destinatario**
  (hay que elegirlo a mano), mientras que en móvil sí lo selecciona bien — de nuevo, un caso
  de una app nativa interceptando un enlace web y honrando solo parte de sus parámetros,
  fuera del control del HTML/JS de la página. El mensaje de respaldo ya nombra el paso
  manual exacto ("elige a " + TEACHER.teamsEmail + "..."); no sigas intentando forzar la
  selección automática en escritorio sin que el profesor lo pida de nuevo.
- **Al combinar una copia al portapapeles con `window.open()` en el mismo clic** (patrón ya
  no necesario para Correo/Telegram, pero relevante si se reutiliza en otro canal futuro):
  el navegador solo concede "permiso de interacción del usuario" una vez por gesto. Si
  `window.open()` se ejecuta primero, la copia posterior falla en silencio. La copia debe
  ir primero, de forma síncrona (`execCommand('copy')`, no la API de portapapeles asíncrona,
  que perdería el permiso esperando su promesa), y `window.open()` justo después.
- **Longitud de URL**: cualquier canal que meta el resumen dentro de una URL (`?text=`,
  `body=`) puede topar con límites del lado del servidor mucho antes de los ~2000
  caracteres "de libro". Usa siempre `truncateForUrl(text, maxEncodedLen)` — mide la
  longitud **ya codificada** (`encodeURIComponent` puede casi triplicar el tamaño con
  tildes, saltos de línea y emojis), no la longitud del texto sin codificar.

### Otras

- **El acceso con código es solo un disuasivo, no seguridad real** — cualquiera que vea el
  código fuente ve el `CODE`. Comunícaselo así al profesor siempre que se mencione, sin
  matices ambiguos.
- **La lista "Artefactos" de la app móvil de Claude no es la misma galería** que los
  artefactos de Código — son sistemas separados. Si el profesor pregunta por qué no ve sus
  artefactos en el móvil, primero confirma en qué pantalla/app está mirando antes de asumir
  que es un bug.
- **Fotos reales incrustadas**: si el ejercicio necesita una imagen real (p. ej. la foto de
  un autor), pide al profesor que la **adjunte como archivo** (no que la pegue en el cuerpo
  del mensaje — las imágenes pegadas directamente no siempre se guardan como archivo
  accesible). Incrústala como `data:` URI en base64 dentro del HTML.

## Archivos de referencia

- `reference/template.html` — plantilla completa, ya con todas las correcciones anteriores
  aplicadas. Punto de partida obligatorio para cualquier ejercicio nuevo.
- `docencia-espanol/materiales/b1/nuevo-espanol-en-marcha-3_repaso-b1_interactivo.html` —
  **documento largo de repaso** (12 secciones, 58 ejercicios, 522 huecos), útil como
  referencia cuando el material no sea un capítulo suelto sino un cuadernillo entero. Añade
  varias cosas sobre la plantilla que conviene copiar de ahí en vez de reinventar:
    - `block.introHTML` — teoría no interactiva antes de los ejercicios de cada sección.
    - `ex.refHTML` — recuadro de referencia dentro de un ejercicio (conectores, banco de
      opciones, sopa de letras). **Si el original enseña al alumno unas opciones, el
      artefacto también tiene que enseñárselas**: un ejercicio de relacionar sin las
      opciones a la vista es imposible de hacer, y así se publicó la primera versión.
    - `type: "conjTables"` — varios cuadros de conjugación en un mismo ejercicio, con un
      único botón "Corregir". Si el spec de una celda es una **cadena** en vez de un array,
      se pinta fija (ya resuelta en el libro) y no cuenta como hueco.
    - **Panel de resultados por sección** (`createResultsPanel()`): cada sección tiene su
      puntuación, sus fallos y sus botones de envío, además del panel global. En documentos
      largos es lo que permite al alumno entregar por partes en vez de abandonar a medias.
      El resumen enviado nombra la sección, y el nombre del alumno se comparte entre
      paneles. Ojo con dos cosas al replicarlo: los paneles se generan por **clases dentro
      de cada panel**, nunca por `id` global (habría duplicados), y cualquier atajo que
      corrija "todo" (la tecla Enter, sin ir más lejos) debe acotarse a la sección, o
      destapará las respuestas de las secciones que el alumno aún no ha hecho.
    - `conSinTildes([...])` — amplía una lista de respuestas aceptadas con su versión sin
      tildes. La vía de array es acentualmente estricta a propósito, y eso es correcto
      cuando el acento **es** lo que se evalúa (`está`/`esta`, `trabajo`/`trabajó`). Pero en
      respuestas abiertas de léxico o de fórmulas (*«Hacía mucho viento»*, *«¿Podrías…?»*)
      lo que se evalúa no es la tilde, y exigirla convierte el ejercicio en un dictado. Úsalo
      solo ahí, nunca en los huecos de forma verbal.
    - `type: "open"` — ejercicio de redacción libre. No genera huecos, no puntúa y **no lleva
      botón "Corregir"** (un botón que al pulsarlo no hace nada es peor que no tenerlo). Se
      incluye porque está en el libro y el alumno tiene que poder verlo. Cuando un ejercicio
      del original no tenga respuesta única, esta es la salida: transcribirlo así, no
      omitirlo ni inventarle una respuesta correcta.
      Desde que el profesor lo pidió, el motor añade automáticamente debajo de `ex.html`
      un aviso ("esto no se corrige aquí, lo revisará tu profesor") y un `<textarea>`
      (`.open-answer`) donde el alumno escribe su respuesta — no hay que montar nada de eso
      a mano en el chapter script. Ese texto se guarda en `openAnswers` (junto a `allInputs`
      y `allExercises`) y `buildSummary()` lo añade tal cual, con el número y título del
      ejercicio, al final del resumen que se envía por WhatsApp/Telegram/correo/Teams — así
      el profesor recibe la redacción del alumno en el mismo mensaje que la puntuación,
      sin tener que pedírsela aparte. No hace falta ninguna respuesta "correcta" para esto:
      es contenido libre que se reenvía tal cual, no se evalúa.
    - Cuando `flex` se quede corto, cambia el diseño del hueco antes que la respuesta.
      `flex` es un **Y** de palabras clave: no sabe expresar alternativas. Si el ejercicio
      admite de verdad varias respuestas distintas (vosotros/ustedes, `-ara`/`-ase`,
      *«Hacía calor»*/*«Hacía sol»*), hace falta un array —que sí es un **O**— con
      `conSinTildes`. Y al revés: para descartar un error concreto sin castigar la tilde,
      una clave de `flex` bien elegida lo hace sola (`"le dé azúcar"` acepta *dé* y *de*,
      pero rechaza *des*, que es justo lo que el ejercicio persigue).
- `docencia-espanol/materiales/indice-clases-de-espanol.html` — el artefacto "Clases de
  Español", índice manual → nivel → capítulo de toda la biblioteca (ver paso 6 del flujo de
  trabajo). Actualízalo cada vez que publiques un capítulo nuevo. Este es público (o puede
  llegar a serlo si el profesor lo comparte) — nunca le añadas los códigos de acceso.
- `docencia-espanol/materiales/codigos-acceso.html` — referencia privada del profesor con
  el código de cada capítulo (ver paso 7). Actualízala cada vez que publiques un capítulo
  nuevo; no la enlaces desde ningún material que puedan ver los alumnos.
- `docencia-espanol/fuentes/` — las transcripciones en texto plano de todo lo escaneado,
  con sus respuestas, más `extraer.mjs`, que las genera desde el artefacto publicado. Antes
  de pedirle fotos al profesor de un capítulo, **mira aquí**: puede que ya esté transcrito.
- `docencia-espanol/fuentes/paginas.sh` — dado un PDF y un rango de páginas, diagnostica el
  archivo (`pdffonts`, `pdfdetach`), saca el texto con `pdftotext -layout`, renderiza cada
  página a JPEG para poder mirarla, y extrae las imágenes incrustadas. Es la herramienta del
  paso 1 cuando el profesor adjunta el PDF. Escribe fuera del repo a propósito: las páginas
  de un libro con copyright son material de trabajo intermedio, no se versionan (la única
  excepción es `fuentes/pendientes/`, donde sí se guarda lo justo para poder construir un
  capítulo en otra sesión, y que se borra en cuanto ese capítulo se publica); lo que se
  archiva es la transcripción.
- **`/mnt/skills/public/pdf-reading/SKILL.md`** — guía completa de lectura de PDF que viene
  con el entorno pero **no aparece entre las skills activables**, así que hay que abrirla con
  `Read`. Léela antes de pelearte con un PDF: cubre cosas que aquí se aprendieron a base de
  fallar. Las dos que más valen: `pdffonts` dice de antemano si hay capa de texto (sin
  fuentes = escaneado, no gastes tiempo con `pdftotext`) y si el encoding es `Custom` o
  `Identity-H`, que **predice** que el texto extraído saldrá con caracteres cambiados aunque
  parezca correcto — es exactamente lo que pasaba con el PDF de ПК Гонсалес (`tъ`/`йl` por
  `tú`/`él`). Trae además `pdfdetach` para adjuntos y el aviso de que `pdfimages` no ve los
  gráficos vectoriales. `paginas.sh` ya incorpora sus diagnósticos, pero la guía tiene más
  (tablas con pdfplumber, campos de formulario, coste en tokens de rasterizar).
- **Lo que NO funciona en este contenedor**, comprobado, para no volver a intentarlo: no hay
  `tesseract` ni OCR, ni `qpdf`, ni `mutool`, ni `pdftk`. Y de las librerías de Python para
  PDF: `pypdf` y `pdfplumber` **se instalan pero revientan al importarse** (el binding de
  `cryptography` lanza un `PanicException` de Rust). No hace falta OCR para transcribir
  —leer el render con `Read` acierta donde `pdftotext` se equivoca— pero sí impide generar un
  PDF con capa de texto buscable.
- **`poppler` NO está en todos los contenedores, y `PyMuPDF` sí se instala: es el plan B.**
  Medido en la sesión de la 5C: `pdftoppm`/`pdftotext`/`pdffonts` no existían, `apt-get
  install poppler-utils` falla con **404** (el índice de paquetes viene caducado y
  `apt-get update` tampoco lo arregla), y sin `pdftoppm` **la herramienta `Read` tampoco
  puede abrir un PDF** — no solo `paginas.sh`. Parecía un callejón sin salida y no lo es:
  `python3 -m pip install pymupdf` **funciona** (la nota anterior de esta skill decía lo
  contrario; era de otro contenedor). Con eso se hace todo lo que hacía `paginas.sh`:

  ```python
  import pymupdf
  d = pymupdf.open(PDF)
  print(d.page_count)                       # y d[n].get_text() para localizar
  d[n-1].get_pixmap(dpi=170).save("p.png")  # renderizar y MIRAR la página con Read
  # y para leer letra pequeña, un recorte a más dpi:
  # d[n-1].get_pixmap(dpi=300, clip=pymupdf.Rect(x0, y0, x1, y1)).save("crop.png")
  ```

  El recorte a 300 dpi es lo que hace legibles el artículo del ejercicio 1 y el prospecto
  del 5 de la 5C, que a página completa no se leen.
- **No te fíes del número de páginas que anuncia el harness al adjuntar el PDF.** Con el
  cuaderno de B1 dijo «103 pages» cuando el archivo tiene **77**, que es justo lo que dice
  la nota de más arriba (numeración del PDF = numeración del libro, sin desfase).
  Compruébalo con `d.page_count` y localiza el capítulo buscando su título con `get_text()`
  antes de renderizar nada.
- `PRODUCT.md` y `DESIGN.md` (raíz del repo) — el sistema de diseño compartido por todos los
  artefactos de esta biblioteca (paleta papel/tinta, tipografía, componentes). Cualquier
  página nueva (ejercicio o índice) debe extender estos tokens, no inventar los suyos — ver
  `DESIGN.md` para los valores exactos y las reglas nombradas ("The Fixed Panel Rule", etc.).
