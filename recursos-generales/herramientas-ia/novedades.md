# Novedades de herramientas de IA

Registro de novedades relevantes para el trabajo de Angel en este
repositorio: funciones nuevas de Claude Code, skills, plugins,
conectores MCP, modelos, herramientas de terceros, y estrategias/buenas
prácticas de uso (cómo sacarle más partido a Claude Code). Mantenido por
una Routine semanal de Claude Code (ver `## Radar de herramientas de IA`
en `CLAUDE.md`), más las pasadas que se hagan a mano.

## Cómo se usa

- Las entradas nuevas se añaden arriba de todo (orden cronológico
  inverso — lo más reciente primero).
- Antes de añadir una entrada, revisar que no esté ya aquí, para no
  repetir la misma recomendación dos veces.
- Formato por entrada: qué es, por qué le sirve a Angel en concreto, y
  cómo activarlo o probarlo.

El criterio de qué cuenta como "relevante" (para no acabar volcando aquí
todo lo que existe en el mercado) vive en `CLAUDE.md`, sección
`## Radar de herramientas de IA` — no se repite aquí para no tener dos
copias que puedan desincronizarse.

---

## 2026-08-16 — Segunda pasada: hooks vs. CLAUDE.md, y prácticas de la comunidad

Angel señaló que la primera pasada se quedó corta — solo profundizó en
una fuente (la guía oficial) en vez de seguir con el resto de resultados
de búsqueda ya localizados. Esta pasada sí los recorre.

### Aplicado: hook `Stop` con estado de git ("radical transparency")

**Qué es:** `.claude/hooks/session-end-status.sh`, registrado como hook
`Stop` en `.claude/settings.json` — al final de cada turno imprime
`git status --short` si hay cambios sin commitear. Patrón tomado de
`awattar/claude-code-best-practices` (repo comunitario, no oficial).

**Por qué le sirve a Angel:** en esta misma sesión hubo varias veces en
las que el hook `post-checkout`/`post-commit` de graphify dejó
`graphify-out/` con cambios sin comitear sin que se notara hasta el
siguiente `git status` manual. Este hook lo hace visible siempre, sin
depender de acordarse.

**Cómo probarlo:** ya está activo — se ve solo al final de cualquier
turno con cambios pendientes.

### Aplicado (tras profundizar): hook que bloquea merge sin revisión

**Qué es:** hallazgo de una búsqueda general: las instrucciones de
`CLAUDE.md` se siguen ~70% de las veces según reportan varios
desarrolladores — aceptable para preferencias de estilo, arriesgado
para reglas críticas. Un hook sí garantiza el 100%, porque es
determinista. Implementado como `check-pr-review.sh` (`PreToolUse`,
matcher `mcp__github__merge_pull_request|mcp__github__enable_pr_auto_merge`,
ver `.claude/settings.json`): bloquea la llamada si no encuentra, para
ese PR exacto, un marcador escrito en los últimos 60 minutos por
`.claude/hooks/mark-pr-reviewed.sh` (documentado como paso obligatorio
en la regla dura de `CLAUDE.md`).

**Por qué le sirve a Angel:** este repo tiene esa regla dura exacta
("nunca fusionar sin revisión") y además usa `defaultMode: dontAsk`,
que quita el cortafuegos de permisos interactivo por completo — así que
antes no había ninguna red de seguridad técnica, solo disciplina de
turno a turno.

**Iteración real, no de un tirón — tres rondas de revisión, cada una
encontrando algo que de verdad rompía el propósito del hook:**

1. La primera versión fallaba **abierta** exactamente en los casos que
   debía bloquear — un marcador corrupto o `jq` ausente hacían que el
   script muriera bajo `set -e` con un exit code que Claude Code trata
   como "sin decisión" (permite la herramienta). Rediseñado fail-closed:
   sin `set -e`, con una función `deny()` que no depende de `jq` (usa
   `printf` a mano) para que no falle precisamente cuando más se la
   necesita.
2. Solo cubría `merge_pull_request`, no `enable_pr_auto_merge` — otro
   camino real de fusión sin gate. Añadido al matcher.
3. `reviewed_at` se validaba solo con `date -d`, que acepta texto suelto
   tipo `"now"` como si fuera una fecha real -- un marcador con ese
   valor pasaba como "reciente" sin serlo. Y el campo `head_sha` se
   grababa pero **nunca se comparaba con nada** — un PR con commits
   nuevos después de la revisión seguía fusionándose sin problema
   dentro de la ventana de 60 minutos. Corregido de raíz: `reviewed_at`
   ahora exige el formato exacto AAAA-MM-DDTHH:MM:SSZ antes de
   parsearlo, y el hook **consulta en vivo la API de GitHub**
   (`GITHUB_TOKEN`/`GH_TOKEN` sí están disponibles en el entorno) para
   comparar el SHA grabado contra el HEAD actual del PR — un push nuevo
   tras la revisión invalida el marcador aunque sea reciente. También
   se validó que `pullNumber`/`owner`/`repo` tengan formato razonable
   antes de usarlos para construir una ruta de archivo o una URL.

Verificado en vivo con 6+ casos contra el PR real #66 (sin marcador,
`reviewed_at` con formato laxo, SHA equivocado, SHA real correcto,
`pullNumber` con intento de path traversal, sin `GITHUB_TOKEN`) — todos
deniegan salvo el del SHA real correcto.

**Cuarta ronda, tras la verificación en vivo:** una tercera revisión
encontró que cubrir `enable_pr_auto_merge` con el mismo marcador daba
**falsa** confianza, no protección real -- ese comando no fusiona en el
momento, programa que GitHub fusione más tarde, de forma asíncrona,
cuando pasen los checks, en el commit que sea HEAD *en ese momento
futuro*. El hook no tiene forma de interceptar ese evento posterior, así
que "permitirlo si hay marcador fresco" no protegía nada — un push
nuevo después de activar auto-merge se fusionaría igual, sin revisión,
sin que el hook se enterara. Corregido: `enable_pr_auto_merge` se
deniega siempre, sin excepción, con el mensaje de usar
`merge_pull_request` directo en su lugar. También encontró que el
marcador se identificaba solo por número de PR, no por owner/repo — como
los SHA de git son direcciones de contenido portables entre repos,
alguien con acceso de escritura a cualquier repo podía reproducir el
mismo commit ahí y reusar la revisión de un PR ajeno con el mismo
número. Corregido añadiendo owner/repo a la clave del marcador (y a los
argumentos de `mark-pr-reviewed.sh`). Y la comparación de SHA era
sensible a mayúsculas y exigía coincidencia exacta, así que un SHA corto
o en mayúsculas (como los que uso yo mismo al citar commits en esta
conversación) hacía fallar la comparación contra un PR sin cambios de
verdad — corregido a comparación por prefijo, insensible a mayúsculas.

**Quinta ronda:** también encontró que `check-pr-review.sh` confiaba en
que `head_sha` del marcador ya venía validado por `mark-pr-reviewed.sh`
— pero un marcador escrito por otra vía (a mano, por un bug) con un
`head_sha` corto y basura (ej. un solo carácter) que por casualidad
fuera prefijo del SHA real en vivo pasaba la comparación igual,
reproducido en vivo contra el PR #66 real. Corregido validando el mismo
formato `^[0-9a-fA-F]{7,40}$` dentro del propio script gate, sin confiar
en el escritor. Y el escapado a mano de `deny()` (con `sed`) solo cubría
backslash y comillas, no caracteres de control como un salto de línea —
un marcador manipulado con `\n` dentro de `head_sha` o `reviewed_at`
producía JSON de salida inválido, que por el propio diseño fail-open de
Claude Code ante salida no reconocible se trataría como "sin decisión ->
permite", justo lo contrario de la intención. Corregido usando `jq -cn
--arg` para construir el JSON de `deny()` (escapa todo correctamente),
dejando el escapado a mano solo para el único `deny()` que dispara antes
de confirmar que `jq` existe (mensaje fijo, sin datos externos). También
se combinaron dos lecturas separadas del marcador en una sola invocación
de `jq` con salida `@tsv`, para evitar una lectura no atómica si el
archivo se reescribe a mitad de lectura (severidad baja dado el flujo
secuencial de un solo agente, pero real). Verificado con 10 casos en
vivo contra el PR #66 real, incluyendo un `head_sha` con salto de línea
embebido (confirma que la salida de `deny()` sigue siendo JSON válido) y
`jq` ausente del `PATH` (confirma que sigue fallando cerrado).

**Sexta ronda:** encontró tres cosas más. (1) El token
(`GITHUB_TOKEN`/`GH_TOKEN`) se pasaba a `curl` como `-H "Authorization:
Bearer $TOKEN"` en la línea de comandos, legible por cualquier otro
proceso con permiso para ver `/proc/<pid>/cmdline` mientras `curl`
corría -- corregido pasándolo por `curl -K -` (config leída de stdin),
que no queda expuesto ahí. (2) `mark-pr-reviewed.sh` escribía el
marcador con una redirección `>` directa (trunca y luego escribe), no
atómica -- una lectura de `check-pr-review.sh` justo en ese hueco podía
ver un archivo vacío o a medio escribir y denegar por "marcador
corrupto" aunque uno válido se estuviera escribiendo (falla cerrado, no
explotable, pero contradice el propósito de la lectura atómica de la
quinta ronda). Corregido escribiendo a un temporal en el mismo
directorio y moviéndolo (`mv` es atómico dentro del mismo filesystem).
(3) **Límite estructural sin arreglo posible desde este hook, documentado
en vez de corregido:** entre que este script consulta el SHA en vivo y
la llamada real a `merge_pull_request`, hay una ventana -- un push justo
ahí se fusionaría sin revisar. `mcp__github__merge_pull_request` no
expone un parámetro de SHA esperado para que GitHub rechace la fusión si
el HEAD cambió, y un hook `PreToolUse` no puede reescribir los
argumentos de la llamada que autoriza, solo permitir o denegar. Riesgo
bajo en la práctica (requiere un push adversario en ese instante
exacto), incluso en un repo personal, pero real -- queda anotado en los
comentarios del propio script en vez de reclamar una garantía que este
diseño no puede dar.

**Límites honestos que siguen en pie, para que no se lea como más de lo
que es:**
- No verifica la calidad de la revisión en sí (que de verdad se leyera
  el diff, que los hallazgos se tomaran en serio) — solo que el paso de
  "dejar constancia" ocurrió, para el SHA correcto, hace poco.
- No protege contra que yo decida ignorar mis propias reglas a
  propósito (soy quien escribe el marcador) — el problema real que
  ataca es el olvido bajo sesión larga, que es justo lo que reporta el
  hallazgo del 70%, y es exactamente lo que me pasó hoy mismo con el
  trigger de Groq que se me olvidó crear.
- **Cobertura parcial, no total:** solo intercepta esas dos llamadas
  MCP concretas. Fusionar por otra vía (ej. `gh pr merge` por Bash, si
  `gh` estuviera disponible en el entorno) no pasa por este hook. La
  regla dura de `CLAUDE.md` sigue aplicando por disciplina en esos
  caminos, sin gate técnico.
- El marcador vive en `.claude/.pr-review-state/` (gitignored, estado
  de sesión efímero, no versionado).

### Anotado, no aplicado: patrones de `awattar/claude-code-best-practices`

Repo comunitario (no oficial) con varios patrones más, ninguno aplicado
todavía por no encajar de forma obvia con este repo (personal,
multi-dominio, sin CI):
- **Permisos por nivel de riesgo** (`allow` para comandos seguros, `ask`
  para arriesgados, `deny` para secretos) — este repo ya usa
  `defaultMode: dontAsk`, lo opuesto; cambiarlo es una decisión de
  fondo sobre fricción vs. seguridad, no algo para decidir de pasada.
- **Subagentes de dominio** (`.claude/agents/`, ej. un revisor de
  seguridad dedicado) — este repo no tiene subagentes propios definidos
  todavía; podría valer la pena para tareas recurrentes específicas
  (ej. revisión de ejercicios interactivos) si aparece la necesidad.
- **Comandos personalizados** (`/commit`, `/issue`, `/reviewpr`) para
  flujos repetibles con entrada explícita — este repo ya cubre buena
  parte de esto con skills que se activan solas (`graphify`,
  `impeccable`, `ejercicio-interactivo`); no está claro que comandos
  explícitos añadan algo que no exista ya.

---

## 2026-08-16 — Guía oficial de buenas prácticas de Claude Code

**Qué es:** `code.claude.com/docs/en/best-practices` — la guía oficial de
Anthropic sobre cómo sacarle más partido a Claude Code: gestión de
contexto (es el recurso más limitado, el rendimiento cae al llenarse),
`CLAUDE.md` conciso ("bloated CLAUDE.md files cause Claude to ignore
your actual instructions"), verificación del trabajo (tests/build/capturas
en vez de confiar a ciegas), modo plan para tareas grandes, subagentes
para investigación sin gastar el contexto principal, revisión adversarial
con subagente antes de dar algo por terminado, y automatización
(`claude -p`, fan-out, sesiones paralelas).

**Por qué le sirve a Angel:** aplicado ya mismo — `CLAUDE.md` había
crecido de 178 a 359 líneas en una sola sesión (Groq/Gemini + el propio
radar); podado a poco más de 300 líneas siguiendo el criterio de la guía ("¿quitar
esta línea causaría un error? si no, córtala"). La primera pasada de
poda sí se pasó de tijera — cuatro rondas de revisión independiente
fueron encontrando hechos verificados que se habían caído (la
distinción 429-transitorio vs. cuota agotada, el "sin preguntar", una
excepción de re-mención, citas exactas de línea, el prefijo `gsk_` de
la key de Groq, entre otros) y se fueron restaurando uno a uno — la
lección real es que podar contenido técnico denso necesita revisión
tan cuidadosa como escribirlo, no una garantía de que "esta vez sí" se
capturó todo a la primera. El resto de prácticas (subagentes para
explorar, revisión adversarial antes de fusionar) ya eran costumbre en
este repo antes de leer la guía — confirma que van en la dirección
correcta.

**Cómo aplicarlo:** no hace falta activar nada — es una guía de
comportamiento, no una herramienta. Releerla periódicamente (el radar
la revisita cada semana por si cambia) y aplicar la poda de `CLAUDE.md`
cuando una sección crezca mucho.

---

## 2026-08-16 — Primera pasada del radar

### DeepL (conector MCP)

**Qué es:** conector oficial de DeepL — traduce texto y documentos en
más de 100 idiomas, con estilo propio configurable (glosarios, reglas de
estilo, corrección de texto).

**Por qué te sirve:** encaja directo con `traduccion/` — es un motor de
traducción profesional (mejor que traducir "a pelo" pidiéndomelo a mí),
con gestión de glosario para mantener terminología consistente entre
encargos.

**Cómo probarlo:** conectarlo desde los ajustes de conectores de
claude.ai (buscar "DeepL"). Una vez conectado, pedir una traducción
mencionando el conector, o dejar que yo lo use automáticamente cuando
detecte una tarea de traducción.

✅ Activado el 2026-08-16.

### Brisk Teaching (conector MCP)

**Qué es:** conector para generar actividades interactivas para
alumnos, materiales alineados a estándares educativos, y recursos de
enseñanza — con herramientas como `create_teaching_resource`,
`create_boost_activity`, `generate_next_ideas`.

**Por qué te sirve:** solapa en parte con la skill `ejercicio-interactivo`
que ya tienes (que genera ejercicios de gramática/vocabulario con
corrección instantánea) — no la sustituye, pero puede complementarla
para otros tipos de recurso (actividades más allá del ejercicio
autocorregible, ideas de seguimiento por alumno).

**Cómo probarlo:** conectarlo desde los ajustes de conectores de
claude.ai (buscar "Brisk Teaching"). Está pensado sobre todo para K-12
en inglés — probar con un caso concreto antes de adoptarlo, puede que
no encaje igual de bien con adultos rusohablantes aprendiendo español.

### Marketplaces de plugins de Claude Code (oficial y comunidad)

**Qué es:** Anthropic mantiene dos catálogos navegables de plugins
(skills + conectores MCP empaquetados juntos): el oficial
(`anthropics/claude-plugins-official`) y el de comunidad
(`anthropics/claude-plugins-community`, sincronizado cada noche desde
la revisión interna de Anthropic — todo lo que aparece ahí pasó un
escaneo de seguridad automático).

**Por qué te sirve:** es la fuente que este mismo radar va a seguir
consultando cada semana — mencionarlo aquí para que sepas que existe y
puedas navegarlo tú también si quieres adelantarte a una pasada semanal.

**Cómo probarlo:** `/plugin marketplace add anthropics/claude-plugins-community`
en cualquier sesión de Claude Code, y luego `/plugin` para navegar el
catálogo instalado.

### (Menor) Learning Commons y Learn with Coursera

Dos hallazgos menos prioritarios, mencionados por completitud:
- **Learning Commons** (conector MCP, sin autenticación) — estándares y
  progresiones de aprendizaje K-12. Menos relevante para tu perfil de
  alumnos (adultos rusohablantes), pero gratis de probar.
- **Learn with Coursera** (plugin) — convierte una intención de
  aprendizaje en una ruta personalizada de cursos de Coursera. Podría
  servirte para tu propio aprendizaje de Python o para el máster,
  requiere el conector de Coursera.
