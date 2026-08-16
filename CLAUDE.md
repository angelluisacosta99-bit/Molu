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
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).

### Extracción semántica: `GEMINI_API_KEY` y qué hacer si se agota la cuota

Este repo tiene configurada `GEMINI_API_KEY` en `.claude/settings.local.json`
(nunca en Git). Con la key presente, `/graphify` usa la API de Gemini para
la extracción semántica de documentos/imágenes en vez de subagentes de
Claude — más rápido y sin gastar tokens de Claude en esa parte.

La decisión de "Gemini vs. subagentes" se toma una sola vez al arrancar
`/graphify`, según si la key está configurada — no se re-evalúa a mitad de
la corrida. Si un chunk falla porque la cuota está agotada (no es un 429
transitorio, que ya se reintenta solo), graphify lo salta y sigue con el
resto — no aborta la corrida completa, pero tampoco cae automáticamente en
subagentes de Claude para ese chunk. Como el resultado de cada archivo se
cachea, los que fallaron quedan pendientes, no perdidos.

Qué hacer si pasa esto:
1. **Esperar y reintentar más tarde** — el free tier de Gemini se resetea
   diariamente. Correr `graphify --update` reprocesa solo lo pendiente.
2. **Terminar ahora con subagentes** — quitar temporalmente
   `GEMINI_API_KEY` de `.claude/settings.local.json` (o vaciar su valor) y
   volver a correr `/graphify --update`; lo pendiente se completará vía
   subagentes de Claude. Restaurar la key después si se quiere seguir
   usando Gemini en corridas futuras.
3. **Terminar ahora con Groq** — ver la sección siguiente. Es más rápido
   que esperar al reset diario y no gasta tokens de Claude como la
   opción 2.

### Groq como respaldo de `GEMINI_API_KEY`

graphify no tiene un backend `groq` propio (no existe un flag
`--backend groq`; es una petición abierta y sin resolver en su
repositorio upstream). Pero su backend `openai` usa el SDK oficial de
OpenAI por debajo, y ese SDK respeta las variables de entorno estándar
de OpenAI para redirigir a cualquier endpoint compatible — incluido el
de Groq. Así que Groq funciona hoy como respaldo, aunque no sea un
backend soportado oficialmente por graphify:

- `OPENAI_API_KEY` — la key de Groq (empieza por `gsk_`).
- `OPENAI_BASE_URL` — `https://api.groq.com/openai/v1`.
- `OPENAI_MODEL` — el modelo de Groq a usar (ej.
  `llama-3.3-70b-versatile`).

Igual que `GEMINI_API_KEY`, estas tres van en
`.claude/settings.local.json` (nunca en Git). Usarlas junto con
`GEMINI_API_KEY` — no en lugar de ella — funciona como la opción 3 de
la lista anterior: cuando la cuota de Gemini se agota, quitar
`GEMINI_API_KEY` temporalmente hace que graphify caiga al backend
`openai`/Groq en vez de a subagentes de Claude, siempre que estas tres
variables ya estén puestas.

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
