# Instrucciones para Claude en este repositorio

## Flujo de trabajo obligatorio para Pull Requests

**Abrir un PR no dispara nada más automáticamente.** Se puede abrir un
Pull Request con su descripción y dejarlo ahí, esperando, sin gastar una
revisión todavía — sobre todo si va a seguir cambiando o el profesor
todavía no ha pedido fusionarlo. Esto es así para no gastar tokens en
revisiones de PRs que pueden cambiar antes de fusionarse.

Los otros dos pasos van juntos y **solo se ejecutan cuando el profesor
pide explícitamente fusionar/mergear un PR concreto** (o cuando así lo
indique una tarea autónoma que el profesor haya autorizado de antemano
para ese fin). En ese momento, y en ese orden:

1. **Lanzar una revisión con un agente independiente** (por ejemplo, la
   skill `review`), justo antes de fusionar — no una revisión antigua
   lanzada al abrir el PR, sino una que verifique el estado actual del
   PR (puede haber cambiado desde que se abrió).
2. **Fusionar (merge) el PR**, salvo que la revisión detecte problemas
   bloqueantes — en ese caso, corregirlos primero y repetir el ciclo
   (nueva revisión, luego fusión).

No omitir la revisión aunque el cambio parezca trivial (por ejemplo,
cambios solo de documentación), y no omitirla aunque ya exista una
revisión de una versión anterior del PR.

**Regla dura, sin excepciones:** nunca hacer `merge` de un PR sin haber
completado antes una revisión con un agente independiente sobre su
estado actual. Si por cualquier motivo la revisión no se pudo lanzar o
no terminó, el PR no se fusiona hasta que exista esa revisión. Y nunca
lanzar la revisión (ni fusionar) solo por haber abierto el PR — hace
falta que el profesor pida fusionar primero.

**Refuerzo técnico parcial, no sustituye la disciplina.** Un hook
`PreToolUse` (`check-pr-review.sh`) bloquea la llamada MCP
`merge_pull_request` si no encuentra, para ese owner/repo/PR exacto, un
marcador reciente (<60 min, fail-closed ante cualquier error) **y con el
mismo SHA que el HEAD actual del PR** — lo comprueba en vivo contra la
API de GitHub con el `GITHUB_TOKEN`/`GH_TOKEN` del entorno, así que un
push nuevo tras la revisión invalida el marcador aunque sea reciente.
`enable_pr_auto_merge` se deniega siempre, sin excepción: fusiona más
tarde de forma asíncrona en el commit que sea HEAD en ese momento
futuro, algo que este hook no puede verificar ahora — usar
`merge_pull_request` directo tras revisar, no auto-merge. En cuanto la
revisión de un PR salga limpia (o tras corregir sus hallazgos), antes
de fusionar, dejar constancia con:
`.claude/hooks/mark-pr-reviewed.sh <owner> <repo> <PR> <head_sha> "<resumen>"`.
**No cubre** fusionar por otras vías (ej. `gh pr merge` por Bash, si
`gh` estuviera disponible) — la regla dura sigue aplicando igual a esos
caminos, solo que sin gate técnico. Detalle completo del diseño y sus
límites en `recursos-generales/herramientas-ia/novedades.md`.

## Regla: 3+ rondas de revisión sobre lo mismo → guardar la lección

Si corregir un mismo archivo/hook/PR para dejarlo limpio necesita **3 o
más rondas** del ciclo revisión→corrección→revisión (la misma familia
de fallo reaparece una y otra vez, no hallazgos nuevos e independientes
cada vez), eso es la señal: antes de dar el trabajo por terminado,
parar y guardar explícitamente qué patrón de error se repitió y cómo se
corrigió, para no repetirlo en una tarea futura. No hace falta que el
profesor lo pida cada vez — aplicar esto solo, siempre que pase.

Dónde guardarlo, según el caso:
- Si es un hook de Claude Code (`.claude/hooks/*.sh`): añadir un punto
  nuevo a `.claude/skills/hook-hardening/SKILL.md` (ya es el lugar
  pensado para esto — así nacieron sus puntos actuales).
- Si no es un hook pero el patrón es específico de un dominio de código
  con una skill propia en este repo, añadirlo ahí en vez de en
  `hook-hardening`.
- Si no encaja en ninguna skill existente, anotarlo como entrada propia
  en `recursos-generales/herramientas-ia/novedades.md` (mismo formato
  que ya se usa para sagas de varias rondas), o crear una skill nueva
  si el patrón es lo bastante recurrente para merecerla.

No es solo para hooks de seguridad — aplica a cualquier tipo de tarea
(código, configuración, contenido) donde el mismo tipo de error se
repita 3+ veces antes de salir limpio.

## Diseño visual: usar siempre la skill `impeccable`

Cuando la tarea implique diseñar, rediseñar, criticar, auditar o pulir
una **interfaz frontend** (sitios web, landing pages, dashboards, UI de
producto, componentes, formularios, pantallas de onboarding, etc.),
usar siempre la skill `impeccable` (`.claude/skills/impeccable/`), en
lugar de hacer el trabajo de diseño "a mano".

Nota de alcance: `impeccable` es para interfaces frontend, no genera ni
edita documentos de Word ni presentaciones de PowerPoint. Para esos
formatos usar las skills `docx` y `pptx` respectivamente.

Como segunda pasada tras `impeccable` (no como sustituto), repasar
`recursos-generales/herramientas-ia/vercel-web-interface-guidelines.md`
— checklist externo de más de 100 reglas concretas de calidad de
interfaz (Vercel, MIT), copiado en local para no depender de una
petición web en cada sesión.

## Materiales de referencia para clases de español

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
contenido a mano — ver la sección `## graphify` más abajo.

### Procesar PDFs escaneados: OCR local antes que visión

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

## Nombre del profesor: sin tilde

El nombre del usuario/profesor es **Angel Luis Acosta González**.
"Angel" en este contexto **no lleva tilde** (no es "Ángel"). Al
escribir su nombre en cualquier material, documento, commit, código o
respuesta, usar siempre "Angel" sin acento.

**La regla es solo para él, no para la palabra.** Si aparece un
personaje ficticio llamado Ángel —por ejemplo en una frase de ejemplo de
un libro de texto que se está transcribiendo—, lleva su tilde normal:
*"Ángel dijo: «Os llamaré mañana»"*. Quitarle la tilde a un Ángel que no
es el profesor es un error de ortografía, no una aplicación de esta
regla.

## Presentaciones (.pptx): sin firma final

En la diapositiva de cierre de cualquier presentación, no añadir una
firma del tipo "— Angel Luis Acosta González, tu profesor de español".
El pie de página con el nombre del autor (ej. "© Angel Luis Acosta
González" o "Material elaborado por...") sí puede mantenerse, pero no
esa línea de firma personalizada al final del mensaje de cierre.

## Organización de carpetas: subcarpetas temáticas en kebab-case

Cada carpeta de primer nivel del repositorio (`python/`, `docencia-espanol/`,
`telecomunicaciones/`, etc.) se organiza internamente en **subcarpetas por
tema o área**, no en una lista plana de archivos sueltos — por ejemplo
`python/ejercicios/` + `python/proyectos/`, o
`docencia-espanol/planificacion/` + `materiales/` + `grabaciones/`.

Nombres de subcarpeta siempre en **kebab-case** (minúsculas, sin tildes,
palabras separadas por guiones), igual que la regla ya existente para
archivos en el `README.md` raíz.

Al crear una carpeta de primer nivel nueva (o al añadir contenido que no
encaje en la estructura actual de una carpeta existente), aplicar este
mismo patrón por defecto en vez de inventar una organización distinta
cada vez.

*(Este patrón ya se repetía de forma independiente en varias áreas del
repo — `graphify` lo detectó como una conexión semántica entre
`python/README.md` y `docencia-espanol/README.md` sin que estuviera
escrito como regla en ningún sitio; se formaliza aquí para que sea
explícito y consistente hacia adelante.)*

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing. Regenerar con `graphify export wiki` tras cambios grandes en el grafo (no lo actualiza ningún hook automáticamente). Si `graphify-out/.graphify_labels.json` no existe en la sesión (es intermedio, no se versiona), reconstruirlo primero a partir del campo `community_name` que ya trae cada nodo de `graph.json` — si no, la wiki sale con nombres de comunidad genéricos en vez de los curados. **Antes de exportar, desambiguar nombres de comunidad repetidos** (varias comunidades distintas pueden compartir el mismo nombre curado) numerándolos `"Nombre (1)"`, `"Nombre (2)"`... en ese mismo diccionario — si no, `graphify export wiki` sí escribe los artículos con archivos separados (`_1.md`, `_2.md`...) pero el índice y las secciones "Relationships" enlazan todos al primero, dejando rota la navegación de cualquier nombre repetido (bug de graphify, no de este repo).
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
- Tras responder con `graphify query`/`path`/`explain`, guardar el resultado con
  `graphify save-result --question "..." --answer "..." --type query --nodes N1 N2 --outcome useful|dead_end|corrected`
  (y `--correction "..."` si se corrige algo). Esto alimenta
  `graphify-out/reflections/LESSONS.md` — fuentes preferidas, caminos muertos
  a evitar, y correcciones previas. Al empezar a trabajar con el grafo, correr
  `graphify reflect --if-stale` (barato, determinista, sin LLM) y leer ese
  archivo antes de repetir una búsqueda ya hecha.
- `/graphify add <url>` mete una URL directo al corpus (YouTube, artículos,
  PDFs, tuits, arXiv) y actualiza el grafo — preferible a copiar contenido a
  mano cuando se referencia un recurso externo, sobre todo para
  docencia-espanol (ver esa sección más abajo).
- Si `GRAPH_REPORT.md` muestra nombres de comunidad genéricos (nombre de
  archivo/función en vez de un nombre curado) después de varios rebuilds de
  código, es la señal de que toca recurar. `graphify` no tiene un subcomando
  `label` — el único mecanismo real es el Step 5 de `SKILL.md`: leer
  `graphify-out/.graphify_analysis.json`, escribir un nombre de 2-5 palabras
  por comunidad (a mano, o con Gemini/Groq como backend LLM si están
  configuradas — ver la sección de abajo), y regenerar el reporte pasando
  ese diccionario de labels.

### Extracción semántica: prioridad Gemini → Groq → subagentes

En `.claude/settings.local.json` (nunca en Git) puede haber:
- `GEMINI_API_KEY` / `GOOGLE_API_KEY` — backend `gemini` nativo de graphify.
- `OPENAI_API_KEY` (la key de Groq — empieza por `gsk_`) +
  `OPENAI_BASE_URL=https://api.groq.com/openai/v1` +
  `OPENAI_MODEL` (ej. `llama-3.3-70b-versatile`) — backend `openai` de
  graphify apuntado a Groq. graphify no tiene backend `groq` propio (la
  lista real es `gemini|kimi|openai|deepseek|claude-cli`, ver
  `references/github-and-merge.md`), pero el SDK de OpenAI que usa por
  debajo lee `OPENAI_API_KEY`/`OPENAI_BASE_URL` de forma nativa.
  `OPENAI_MODEL` no es una variable del SDK (el SDK de OpenAI no lee el
  modelo del entorno, se pasa explícito en cada llamada) — que graphify
  sí la lea está verificado en vivo (llamada real de chat completion
  contra Groq con las tres variables puestas así) pero no contra su
  código fuente; si un día no surte efecto, probar `GRAPHIFY_OPENAI_MODEL`
  (el prefijo que sí documenta el resto de overrides de modelo de esta
  skill: `GRAPHIFY_GEMINI_MODEL` en SKILL.md:162, `GRAPHIFY_WHISPER_MODEL`
  en `references/transcribe.md`).

**Orden obligatorio para la extracción semántica (docs, papers,
imágenes) de `/graphify`, anulando la autodetección de
`.claude/skills/graphify/SKILL.md` (líneas 157, 164 — dice, citando
textual, que graphify "no lee `OPENAI_API_KEY` ni ninguna otra key" y
que sin Gemini cae a subagentes; eso describe su comportamiento por
defecto, no un límite real de graphify):**

1. **Gemini primero**, sin cambios, si `GEMINI_API_KEY`/`GOOGLE_API_KEY`
   está puesta.
2. **Groq si Gemini falta o se agota — invocando el backend `openai`
   explícitamente**, nunca quitando solo `GEMINI_API_KEY` y esperando
   que la skill elija Groq sola: su autodetección solo mira las keys de
   Gemini, nunca `OPENAI_API_KEY` — un `graphify --update` sin Gemini
   cae directo a subagentes, no a Groq.
   graphify fija el backend una vez al arrancar y no se re-evalúa a
   mitad de corrida: un chunk que falla por cuota agotada (no un 429
   transitorio, que ya se reintenta solo) se salta, no aborta, y lo ya
   resuelto queda cacheado. Completar lo pendiente por Groq **sin
   preguntar**, pero **dentro de Part B (la fase de extracción semántica
   de la skill) de la siguiente pasada**, no después:
   `.graphify_uncached.txt` es temporal y Part B lo borra al
   terminar (SKILL.md:357), pero el manifest incremental (Step 9) deja
   sin "stampear" los archivos fallidos, así que el próximo
   `graphify --update` los vuelve a detectar. En el momento en que el
   propio Step B0 de esa pasada recalcule `.graphify_uncached.txt`
   (antes de que la misma pasada lo borre), llamar
   `graphify.llm.extract_corpus_parallel(uncached_files, backend="openai")`
   sobre esa lista — la misma función que usa Part B para Gemini
   (SKILL.md:162), con el backend fijado a mano. No usar
   `graphify extract <path>` como atajo: es una extracción completa y
   fresca, no incremental, y podría reprocesar contra Groq lo que Gemini
   ya resolvió. No hace falta tocar `settings.local.json` — solo forzar
   el backend en la llamada puntual.
3. **Subagentes de Claude, solo como último recurso** — únicamente si
   ni Gemini ni Groq están configuradas, o ambas se agotaron y aun así
   quedan archivos pendientes. Es lo único que gasta tokens de Claude en
   esta extracción, así que es intencionalmente la última opción, no la
   primera alternativa a Gemini.

**Nunca pegar una API key en el chat ni en una captura.** Si pasa,
rotarla ya en la consola del proveedor — quedar expuesta en una
conversación cuenta como comprometida aunque el archivo esté fuera de Git.

## Ahorro de tokens: prácticas activas en este repo

- **`GEMINI_API_KEY` para graphify** (ver sección anterior) — evita
  subagentes de Claude en la extracción semántica. `OPENAI_API_KEY` +
  `OPENAI_BASE_URL` + `OPENAI_MODEL` apuntando a Groq sirven de
  respaldo con el mismo efecto.
- **`graphify query/path/explain`** en vez de leer archivos crudos para
  preguntas sobre el código — ya reforzado por el hook `PreToolUse`.
- **`skillOverrides` en `.claude/settings.json`** — las skills que se usan
  poco se pueden marcar como `"name-only"` (siguen funcionando con
  `/nombre`, pero no aparecen con descripción completa en cada turno).
  **Cuidado:** esto solo es seguro para skills sin una regla de "usar
  siempre" en este archivo — quitar la descripción le quita también la
  señal que permite reconocer cuándo activarla por lenguaje natural. Por
  eso `impeccable` (que sí tiene esa regla, más arriba) se queda fuera de
  `skillOverrides`; no aplicarlo ahí sin revisar antes si existe una
  regla equivalente para la skill en cuestión.
- **Skill `hook-hardening`** (`.claude/skills/hook-hardening/`) — checklist
  de 6 puntos a correr antes de declarar "hecho"/"probado" cualquier
  script de hook (SessionStart/PreToolUse/Stop). Nace de dos sagas reales
  en este repo (7 y 6 rondas de revisión respectivamente) donde la misma
  familia de errores se repitió una y otra vez — se activa sola por su
  descripción, no hace falta invocarla a mano.
- **`/compact`** — en conversaciones largas, correrlo en puntos de corte
  naturales (por ejemplo, al terminar una tarea grande y empezar otra sin
  relación) comprime el historial en vez de dejar que crezca sin límite.
  No hace falta automatizarlo; es una práctica a tener presente cuando la
  sesión se alarga mucho.
- **Podar este archivo, no solo hacerlo crecer.** Según la guía oficial
  (`code.claude.com/docs/en/best-practices`): "Bloated CLAUDE.md files
  cause Claude to ignore your actual instructions" — para cada línea,
  preguntar si quitarla haría que Claude se equivocara; si no, cortarla.
  Al añadir una sección grande (como pasó con Groq/Gemini y el radar),
  revisar después si se puede decir lo mismo con menos palabras sin
  perder ningún hecho verificado.

## Radar de herramientas de IA

Una Routine semanal (`trig_01Jx2UqBq8ezuTzpknMj7SAW`, configurada fuera
del repo vía `create_trigger`) busca novedades para el trabajo de Angel:
funciones nuevas de Claude Code, skills, plugins, conectores MCP,
modelos, terceros (como graphify, que Angel encontró navegando por su
cuenta antes de que existiera este radar), **y estrategias/buenas
prácticas de uso** — cómo sacarle más partido a Claude Code (gestión de contexto,
subagentes, hooks, automatización) de fuentes como
`code.claude.com/docs/en/best-practices` y el canal oficial de Anthropic
(igual criterio de relevancia de abajo decide si algo encontrado por
búsqueda web general cuenta, sin una lista aparte de fuentes
"reconocidas"). Registro:
`recursos-generales/herramientas-ia/novedades.md` — leerlo antes de
proponer algo, para no repetir una recomendación.

**Fuentes:** (1) oficiales — lo de arriba más `whats-new`, el blog de
`claude.com`, `anthropic.com/news`, los marketplaces
`anthropics/claude-plugins-official`/`-community`; (2) terceros
relevantes para docencia de español, traducción, Python,
telecomunicaciones o el máster, vía
`SearchMcpRegistry`/`SearchPlugins`/`SearchSkills` (catálogo real de
Angel, más fiable que la web genérica) y búsqueda web como respaldo.

Un hallazgo de práctica/estrategia (no una herramienta instalable) no
lleva tarjeta — se aplica directamente si es claramente buena (ej.
podar este archivo, ajustar cómo delego en subagentes) y se anota en
`novedades.md` en una línea.

**Relevancia:** debe resolver una necesidad real de una carpeta de
primer nivel del repo o del propio flujo de Claude Code aquí — no
volcar todo el mercado. Sin hallazgos, no se toca el registro ni se
crea rama/PR, y el mensaje final lo dice explícito. Eso sí lo controla
este repo; lo que no: la Routine tiene notificaciones push/email a
nivel de plataforma ("cuando termine con algo que merezca la pena"),
criterio que decide la plataforma, no este texto — una pasada en blanco
podría igual notificar "corrida completada". Si molesta, desactivar
`notifications` en el trigger y depender solo del registro versionado.

**Proponer instalación con tarjeta, nunca instalar por Angel** (barrera
de plataforma: conectores piden su login, plugins/skills su clic).
Aplica solo a hallazgos con `directoryUuid`/`pluginId`/id de skill real
— no a funciones nativas, modelos o marketplaces en sí, que no tienen
tarjeta y se documentan en prosa. Para los que sí aplica, cada hallazgo
nuevo va acompañado, en el mismo turno, de `SuggestConnectors`
(conectores, vía `directoryUuid` de `SearchMcpRegistry`),
`SuggestPluginInstall` (`pluginId` de `SearchPlugins`) o `SuggestSkills`
(de `SearchSkills`, solo para skills que Angel no tenga ya) — nunca solo
texto, la tarjeta es el mecanismo real de un clic.

**Antes de volver a mencionar algo ya registrado**, comprobar con
`ListConnectors`/`ListPlugins`/`ListSkills`: si ya está activo, marcar
la entrada como adoptada ("✅ Activado el AAAA-MM-DD") y no repetirla;
si sigue sin activar, no insistir cada semana (Angel ya la vio), salvo
que haya algo *nuevo* que añadir sobre esa herramienta concreta; si
`ListConnectors` devuelve `connected: null` (falló la comprobación esa
semana), tratarlo como desconocido, no como "sigue sin activar": dejar
la entrada tal cual y probar de nuevo en la siguiente pasada.
`ListPlugins`/`ListSkills` no documentan ese estado nulo (su `enabled`
es un booleano simple) — para plugins y skills, tratar lo que devuelvan
como fiable, sin esta rama de duda.
