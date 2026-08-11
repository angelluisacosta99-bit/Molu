---
name: ejercicio-interactivo
description: "Use when Angel asks to build a new interactive Spanish grammar/vocabulary exercise page with instant grading — a self-contained HTML artifact where a student fills in blanks, gets corrected instantly, and can send their results to the teacher via WhatsApp/Telegram/Teams/Correo. Also use when asked to add a new chapter/unit to this format, or to fix/extend an existing one (e.g. the A1 \"Presente, gerundio, indefinido\" or B2 12C \"¿Sigues pintando?\" exercises already in docencia-espanol/materiales/). Triggers: \"ejercicio interactivo\", \"como el de A1/12C\", \"corrección instantánea\", \"página interactiva para practicar\", \"haz lo mismo con otro capítulo\"."
version: 1.4.0
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

1. **Fundamenta el contenido en material real.** Antes de inventar frases, consulta la
   carpeta de Google Drive del profesor (ver `CLAUDE.md` de la raíz del repo para el enlace
   y el orden de prioridad: Nuevo Español en Marcha > ПК Гонсалес > Temas). Si
   `read_file_content` devuelve una cadena vacía, el PDF es escaneado/solo-imagen — pide al
   profesor fotos de las páginas en su lugar (funcionó bien para 12C).

2. **Copia la plantilla, no la reescribas.** `cp .claude/skills/ejercicio-interactivo/reference/template.html <destino>`.
   Sustituye **todos** los marcadores `{{...}}` (grep por `{{` para confirmar que no quede
   ninguno) y rellena `blocks` con los ejercicios reales, siguiendo los cinco tipos ya
   soportados por el motor de renderizado (`items`, `text`, `table2`, `conjTable`,
   `agenda` — documentados con ejemplos dentro de la propia plantilla). Si necesitas un tipo
   nuevo, tendrás que extender también el renderizador (busca `ex.type ===` en el archivo).

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
   reconocerlo rápido en la lista (✅ para A1, 🎨 para 12C). Al actualizar un artefacto ya
   publicado, pasa siempre el mismo `url` para no crear uno nuevo. Título del artefacto:
   sigue la convención `Nuevo Español en Marcha · <Nivel> · <Capítulo> — <Tema>` (ver los dos
   ejemplos ya publicados) para que se lea claro tanto en la lista plana de Artefactos como
   en el índice del paso siguiente.

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

7. **Sigue el flujo de PR de este repositorio, sin excepciones.** `CLAUDE.md` en la raíz
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

## Lecciones aprendidas (no las repitas)

Cada una de estas causó un PR de corrección real. Están en `reference/template.html` ya
resueltas — esta lista es para que entiendas *por qué* el código está como está, y para que
no las deshagas sin querer al modificar la plantilla.

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
- `docencia-espanol/materiales/indice-clases-de-espanol.html` — el artefacto "Clases de
  Español", índice manual → nivel → capítulo de toda la biblioteca (ver paso 6 del flujo de
  trabajo). Actualízalo cada vez que publiques un capítulo nuevo.
- `PRODUCT.md` y `DESIGN.md` (raíz del repo) — el sistema de diseño compartido por todos los
  artefactos de esta biblioteca (paleta papel/tinta, tipografía, componentes). Cualquier
  página nueva (ejercicio o índice) debe extender estos tokens, no inventar los suyos — ver
  `DESIGN.md` para los valores exactos y las reglas nombradas ("The Fixed Panel Rule", etc.).
