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

## Diseño visual: usar siempre la skill `impeccable`

Cuando la tarea implique diseñar, rediseñar, criticar, auditar o pulir
una **interfaz frontend** (sitios web, landing pages, dashboards, UI de
producto, componentes, formularios, pantallas de onboarding, etc.),
usar siempre la skill `impeccable` (`.claude/skills/impeccable/`), en
lugar de hacer el trabajo de diseño "a mano".

Nota de alcance: `impeccable` es para interfaces frontend, no genera ni
edita documentos de Word ni presentaciones de PowerPoint. Para esos
formatos usar las skills `docx` y `pptx` respectivamente.

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

### Extracción semántica: orden de prioridad Gemini → Groq → subagentes

Este repo tiene (o puede tener) configuradas en `.claude/settings.local.json`
(nunca en Git):
- `GEMINI_API_KEY` / `GOOGLE_API_KEY` — backend `gemini` nativo de graphify.
- `OPENAI_API_KEY` + `OPENAI_BASE_URL` + `OPENAI_MODEL` — backend `openai`
  de graphify apuntado a la API de Groq (compatible con OpenAI), usado
  como respaldo. graphify no tiene un backend `groq` propio — no existe
  `--backend groq` (ver la lista real de backends en
  `.claude/skills/graphify/references/github-and-merge.md`:
  `gemini|kimi|openai|deepseek|claude-cli`) — pero su backend `openai`
  usa el SDK oficial de OpenAI por debajo, y ese SDK sí lee de forma
  nativa las dos variables estándar `OPENAI_API_KEY` y `OPENAI_BASE_URL`
  para redirigir a cualquier endpoint compatible — incluido el de Groq.
  `OPENAI_MODEL` no es una variable del SDK (el SDK de OpenAI no lee el
  modelo del entorno; se pasa explícito en cada llamada). Que sea
  graphify quien la lee bajo ese nombre exacto está verificado en vivo
  (llamada real de chat completion contra Groq, con las tres variables
  puestas así) pero no confirmado contra el código fuente de graphify —
  el resto de overrides de modelo que sí documenta esta skill usan el
  prefijo `GRAPHIFY_` (`GRAPHIFY_GEMINI_MODEL` en SKILL.md:162,
  `GRAPHIFY_WHISPER_MODEL` en `references/transcribe.md`). Si
  `OPENAI_MODEL` sola no surte efecto en una corrida futura, probar
  también `GRAPHIFY_OPENAI_MODEL` antes de asumir que el backend está
  roto:
  - `OPENAI_API_KEY` — la key de Groq (empieza por `gsk_`).
  - `OPENAI_BASE_URL` — `https://api.groq.com/openai/v1`.
  - `OPENAI_MODEL` — el modelo de Groq a usar (ej. `llama-3.3-70b-versatile`).

**Orden de prioridad exigido para la extracción semántica (docs, papers,
imágenes) en `/graphify`, en este repo.** `.claude/skills/graphify/SKILL.md`
(líneas 157 y 164) dice explícitamente que graphify "no lee
`OPENAI_API_KEY` ni ninguna otra key" y que sin `GEMINI_API_KEY` cae
directo a subagentes — esa frase describe la **detección automática** de
la skill (Part B), no una limitación real de graphify. Para este repo,
esa detección automática queda anulada por lo siguiente, que sí hay que
seguir:

1. **Gemini primero.** Si `GEMINI_API_KEY`/`GOOGLE_API_KEY` está
   configurada, úsala (comportamiento por defecto de la skill, sin
   cambios).
2. **Groq si Gemini falta o se agota — invocar el backend `openai`
   explícitamente, nunca simplemente quitar `GEMINI_API_KEY` y esperar
   que la skill elija Groq sola.** Quitar las variables de Gemini NO
   activa Groq: la detección automática de Part B (SKILL.md:157,164)
   solo comprueba `GEMINI_API_KEY`/`GOOGLE_API_KEY`; si no las
   encuentra, su único otro camino documentado es despachar subagentes
   de Claude — nunca revisa `OPENAI_API_KEY`. Así que un comando como
   `graphify --update` sin la key de Gemini cae directo a subagentes,
   no a Groq, y no cumple este orden de prioridad.

   graphify decide backend una sola vez al arrancar y no se re-evalúa a
   mitad de la corrida: si un chunk falla porque la cuota de Gemini está
   agotada (no un 429 transitorio, que ya se reintenta solo), lo salta y
   sigue con el resto — nada se pierde, cada archivo resuelto queda
   cacheado. Cuando queden archivos pendientes por cuota agotada (o si
   `GEMINI_API_KEY` no estaba configurada desde el principio), y
   `OPENAI_API_KEY`+`OPENAI_BASE_URL` estén configuradas, completar lo
   pendiente por Groq **sin preguntar**, pero **dentro de la propia
   ejecución de Part B de la siguiente pasada** — no después de que la
   corrida termine. `graphify-out/.graphify_uncached.txt` es un archivo
   temporal de esa misma pasada: Part B lo borra en su propio paso de
   limpieza nada más terminar (SKILL.md:357), así que no sirve como
   fuente a la que volver luego. Lo que sí persiste es el manifest
   incremental (Step 9): un archivo cuyo chunk falló por cuota queda sin
   "stampear", así que el siguiente `graphify --update` lo vuelve a
   detectar como pendiente por sí solo. Concretamente: al lanzar esa
   siguiente pasada, en el momento en que su propio Step B0 calcule de
   nuevo `.graphify_uncached.txt` (ahora con solo lo que de verdad sigue
   pendiente) y antes de que esa misma pasada lo borre, usar esa lista
   ahí mismo para llamar
   `graphify.llm.extract_corpus_parallel(uncached_files, backend="openai")`
   — la misma función que Part B ya usa para Gemini en SKILL.md:162,
   aquí con el backend fijado a mano en vez de dejar que la detección de
   claves lo decida. No usar `graphify extract
   <path>` como atajo: esa es una extracción completa y fresca sobre
   todo el path (ver
   `.claude/skills/graphify/references/github-and-merge.md`), no hay
   nada documentado que la limite a lo pendiente, así que podría
   reprocesar contra Groq archivos que Gemini ya resolvió. No hace falta
   tocar `.claude/settings.local.json` para nada de esto — no se quita
   ni se restaura ninguna key, solo se fuerza el backend en la llamada
   puntual.
3. **Subagentes de Claude, solo como último recurso.** Únicamente si ni
   Gemini ni Groq están configuradas, o ambas se agotaron y aun así
   quedan archivos pendientes, cae a dispatch de subagentes (Part B de
   la skill) — esto es lo único que gasta tokens de Claude en esta
   extracción, así que es intencionalmente la última opción, no la
   primera alternativa a Gemini.

**Nunca pegar una API key (de Groq, Gemini o cualquier otra) en el
chat ni en una captura de pantalla.** Si ocurre por accidente, rotarla
cuanto antes en la consola del proveedor — quedar expuesta en una
conversación cuenta como comprometida aunque el archivo donde se
guarde esté fuera de Git.

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
- **`/compact`** — en conversaciones largas, correrlo en puntos de corte
  naturales (por ejemplo, al terminar una tarea grande y empezar otra sin
  relación) comprime el historial en vez de dejar que crezca sin límite.
  No hace falta automatizarlo; es una práctica a tener presente cuando la
  sesión se alarga mucho.
