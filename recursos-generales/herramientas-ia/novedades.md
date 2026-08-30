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

## 2026-08-30 — Memory de Anthropic: memoria compartida entre chats (nativo, oficial)

**Contexto:** Angel pidió explícitamente algo para que Claude "tenga
memoria de todos los chats" y conecte lo hablado en una conversación con
otra independiente. Fuentes oficiales:
[claude.com/blog/memory](https://claude.com/blog/memory) y
[anthropic.com/news/memory](https://www.anthropic.com/news/memory)
(anuncio del 2026-08-25, cinco días antes de esta pasada).

**Qué es:** función nativa de Anthropic, no un conector ni un plugin —
nada que instalar. Claude procesa las conversaciones automáticamente
(aprox. cada 24h) y extrae un resumen de lo que vale la pena recordar a
largo plazo (profesión, preferencias, herramientas que usas a menudo,
contexto personal recurrente) — no guarda la transcripción literal.
Activada por defecto desde marzo de 2026 para cuentas Free/Pro/Max.
La novedad del 25 de agosto es que ahora esa memoria se **comparte
entre el chat normal de claude.ai y Claude Cowork** — lo que se cuenta
en un chat puede informar una tarea de Cowork, y viceversa.

**Por qué le sirve a Angel en concreto:** es justo lo que pidió — deja
de tener que re-explicar contexto (qué libro de texto usa, qué alumnos
tiene, qué convenciones sigue en `telecomunicaciones/` o el máster) cada
vez que abre un chat nuevo sin relación con este repo. Y si usa
**Proyectos** en claude.ai, la memoria queda separada por proyecto — un
proyecto de "docencia de español" no mezcla su memoria con uno de
"máster" o "traducción", que es exactamente como ya tiene organizado
este propio repositorio por carpetas de dominio.

**Seguridad/privacidad, la parte que Angel pidió comprobar
explícitamente ("no malignas"):** la memoria queda ligada solo a la
cuenta de Angel, nunca se comparte con otros usuarios, y no se usa para
entrenar a Claude salvo que él mismo active compartir datos de
entrenamiento (`Ajustes > Privacidad > Help improve Claude`, opt-in, no
por defecto). Desde el propio anuncio del 25 de agosto, además, hay
categorías sensibles que se excluyen por defecto sin acción suya: salud,
raza/etnia, creencias religiosas, política, identidad de género.

**Cómo comprobarlo/gestionarlo:** `Ajustes > Capacidades > Memory` en
claude.ai — ver, editar o borrar recuerdos concretos, pausar la memoria,
o resetearla entera. Es un ajuste de cuenta personal, no algo que se
pueda activar desde aquí (barrera de plataforma, igual que un
conector) — Angel tiene que revisarlo él mismo en sus ajustes.

**Duda honesta sin verificar:** no está confirmado si la unificación
chat↔Cowork del 25 de agosto ya cubre su plan concreto — varias fuentes
la describen empezando a desplegarse primero para cuentas Team/Enterprise;
la memoria base (desde marzo) sí debería estar activa ya para Free/Pro/Max.
Comprobar en `Ajustes > Capacidades > Memory` si ya aparece la opción
compartida con Cowork, en vez de asumirlo.

---

## 2026-08-30 — Compactación de contexto: palancas oficiales para ahorrar tokens

**Contexto:** pedido explícito de Angel — herramientas "realmente
efectivas y oficiales, no malignas" para ahorrar tokens. Fuentes, todas
oficiales esta vez: `code.claude.com/docs/en/context-window`,
`code.claude.com/docs/en/costs`, `code.claude.com/docs/en/best-practices`.

### Aplicado: instrucción de preservación al compactar, en `CLAUDE.md`

**Qué es:** Claude Code respeta instrucciones explícitas en `CLAUDE.md`
sobre qué conservar durante el resumen automático de contexto (ej.
"When compacting, always preserve the full list of modified files and
any test commands").

**Por qué le sirve a Angel en concreto:** este mismo archivo ya sufrió
el problema contrario (PR #63, entrada del 2026-08-16): podar
`CLAUDE.md` perdió hechos verificados y hicieron falta 6-7 rondas de
revisión para recuperarlos. Esta instrucción ataca la causa (qué
sobrevive a una compactación), no solo el síntoma de podar con cuidado
después del hecho.

**Cómo se aplicó:** nueva línea en la sección "Ahorro de tokens" de
`CLAUDE.md`, en el bloque de `/compact`.

### Anotado, no aplicado (palancas oficiales sin necesidad clara todavía)

- **`/autocompact <tamaño>`** — fija a mano el umbral de compactación
  automática (ej. `/autocompact 500k`) en vez de esperar al límite del
  modelo. Útil para sesiones largas como las de revisión de PRs de este
  repo, pero no se ha fijado un valor por defecto — depende del modelo
  activo en cada sesión, sin un tamaño "típico" claro todavía.
- **`/compact <instrucciones>`** — variante manual, dirige qué preservar
  en una compactación puntual (ej. `/compact Focus on the API changes`).
- **Umbral ~60-70% de contexto** para lanzar `/compact`, en vez de
  esperar al 90%+ — ya añadido como práctica en `CLAUDE.md`.
- **`MAX_THINKING_TOKENS`** (variable de entorno) — limita el gasto en
  tokens de pensamiento extendido. No activada: sin evidencia de que las
  sesiones de este repo gasten de más ahí, y capar el límite arriesga
  recortar razonamiento donde sí hace falta.
- **Delegar en subagentes las tareas de lectura pesada de contexto** —
  confirmado como práctica oficial recomendada
  (`code.claude.com/docs/en/costs`). Este repo ya lo hace de forma
  consistente (`Explore`, `cavecrew`) — sin acción nueva, solo confirma
  que la práctica actual va en la dirección correcta.

### Fuera de alcance de Claude Code, mencionado para completar el cuadro

**Context Editing API + Memory Tool** (Claude Developer Platform, beta,
`claude.com/blog/context-management`) — recorta hasta 84% el consumo de
tokens en bucles largos de uso de herramientas, pero es una función de
la API/SDK de Anthropic, no del chat de Claude Code. Solo relevante si
Angel construye sus propios agentes con el SDK (la skill `claude-api`
ya instalada cubre esto) — no aplica a esta sesión directamente.

---

## 2026-08-30 — Pasada del radar: dos funciones nativas nuevas, sin hallazgos de terceros

**Contexto:** pasada pedida explícitamente por Angel tras preguntar por
Gemini Notebook, para repasar qué se ha recomendado y no se ha instalado
(ver correcciones más arriba: Brisk Teaching y Learn with Coursera
resultaron ya activos, sin que este registro lo reflejara) y qué hay
nuevo hoy. Fuentes consultadas: `code.claude.com/docs/en/whats-new`
(semana 34, 17-21 agosto 2026), `SearchMcpRegistry`/`SearchPlugins`
para telecomunicaciones/ferrocarril/traducción/Python/docencia (sin
resultados relevantes — solo herramientas de empresa sin relación,
tipo Honeycomb/DataRobot/Twilio/Auth0), y `anthropic.com/news` (solo
anuncios corporativos: chips propios, Model Hardware Standard para
robots/laboratorio, marca de agua en contenido generado — ninguno
aplica a este repo).

### Auto-continue al resetear el límite de uso (nativo, activado por defecto)

**Qué es:** Claude Code sigue la sesión automáticamente en cuanto se
resetea el límite de uso de 5h, en vez de quedarse parado esperando a
que Angel vuelva a escribir. Activado por defecto desde la versión
2.1.234; se puede desactivar en `/config` → "Continue automatically at
usage limit".

**Por qué le sirve a Angel:** complementa directamente la práctica ya
registrada el 2026-08-18 ("desplazar la ventana de 5h mandando un
mensaje corto al empezar") — ahora, además de desplazar cuándo empieza
la ventana, Claude Code no pierde tiempo muerto en cuanto se resetea.

**Cómo probarlo:** nada que instalar — ya viene activado. Revisar
`/config` si se prefiere desactivarlo.

### Estilo de salida "Concise" (nativo)

**Qué es:** nuevo output style incorporado (`/config` o `settings.json`,
desde la versión 2.1.237) que recorta la narración de relleno y
antepone el resultado a la explicación.

**Por qué probablemente no aporta aquí:** `caveman` (activo en todas las
sesiones) ya cubre ese mismo objetivo con más matices propios
(niveles de intensidad, reglas de cuándo NO comprimir). Mencionado por
completitud, no se recomienda activarlo también — redundante con lo
que ya tienes.

### Sin hallazgos nuevos de terceros en los dominios de Angel

Ninguna skill, plugin o conector nuevo relevante para
docencia-espanol/python/telecomunicaciones/traduccion/máster esta
pasada — los resultados de `SearchMcpRegistry`/`SearchPlugins` para esos
dominios fueron herramientas de empresa (DevOps, observability, CRM) sin
relación real. No se crea nada más en este registro por esta parte de
la pasada.

---

## 2026-08-30 — Gemini Notebook (antes NotebookLM): sin opción segura, no adoptado

**Nota sobre cómo se activó:** a petición explícita de Angel ("quiero
conectarte a Gemini Notebook, encuentra todas las formas que existen y
selecciona la más segura"). Búsqueda vía `SearchMcpRegistry` (nada
relevante — el único resultado fue "Goodnotes", sin relación),
`SearchSkills` (vacío) y búsqueda web.

**Qué es:** Google renombró NotebookLM a **Gemini Notebook** el
2026-07-16. Es la herramienta de notas/investigación con fuentes
propias de Google — encajaría con `docencia-espanol/`, `python/`,
`telecomunicaciones/` y el máster como espacio de apuntes con RAG sobre
material propio.

**Por qué no se adoptó ninguna opción:** no existe API de consumidor
todavía (Google la tiene "en desarrollo", sin fecha) ni conector MCP
oficial. Solo hay una API Enterprise (requiere proyecto de Google Cloud
+ licencia Gemini Enterprise/Education Premium, no aplica a una cuenta
personal) y un puñado de proyectos de comunidad no oficiales
(`teng-lin/notebooklm-py` ~18.5k★, `roomi-fields/notebooklm-mcp` 16★,
más wrappers finos de menor reputación como `DevstackK/Notebooklm-Unofficial-API-MCP`
y `moodRobotics/notebooklm-mcp-server`) — todos hacen ingeniería inversa
de la API interna de Google o automatizan el navegador con Playwright.

La diferencia real frente a los conectores ya activos (Google
Drive/Calendar): esos usan OAuth con alcance acotado y revocable en un
clic; **todas** las opciones de Gemini Notebook necesitan en cambio las
cookies completas de la sesión de Google (`__Secure-1PSID`/`-1PSIDTS`)
o un login real vía Playwright — acceso de facto a toda la cuenta
(Gmail, Drive, Calendar...), no solo a Notebook, y con el añadido de
incumplir los términos de Google sobre acceso automatizado. Ningún
proyecto de la lista cambia esa arquitectura de fondo, así que ninguno
cruza la barra de seguridad que sí cumplen los conectores oficiales que
Angel ya usa.

**Decisión:** no instalar nada ahora. Si en el futuro Angel quiere
probarlo pese al riesgo, hacerlo solo desde una cuenta de Google
secundaria (nunca la personal) y con `teng-lin/notebooklm-py` (el más
usado y mantenido de los no oficiales) en vez de los forks con menos
reputación. Revisar de nuevo cuando Google publique la API de
consumidor que ya confirmó — en ese momento sí encajaría con el criterio
normal de esta lista.

❌ No adoptado — revisar si Google publica una API de consumidor oficial.

---

## 2026-08-23 — 7 skills más de JuliusBrussee/caveman: activadas

**Nota sobre cómo se activó:** a petición explícita de Angel, tras
preguntar qué más se recomendaba en combinación con lo ya activo. Del
mismo repo que `caveman`, del que ya se conocían estas 7 skills desde
la instalación accidental de antes (revisadas byte a byte en aquella
revisión, así que no eran una sorpresa esta vez).

**Qué son:** `investigate-first` (diagnostica la causa real antes de
tocar código), `safe-refactor` (reestructura preservando
comportamiento), `surgical-patch` (arregla en la capa más estrecha
posible), `lean-build` (construye funcionalidad nueva con alcance
estricto), `verify-and-stop` (comprueba que un trabajo cumple lo
pedido sin ampliar alcance), `migration` (transiciones reversibles de
esquema/API/dependencias), y `cavecrew` (guía para delegar en
subagentes con salida comprimida estilo `caveman`, ahorra contexto).

**Por qué le sirven a Angel:** complementan a `ponytail` (anti
sobre-ingeniería) y `hook-hardening` (checklist propio) desde ángulos
que esos dos no cubren — diagnóstico antes de editar, alcance
disciplinado en features nuevas, verificación sin ampliar el trabajo.

**Cómo se activaron:** `npx skills add JuliusBrussee/caveman --skill
investigate-first safe-refactor surgical-patch lean-build
verify-and-stop migration cavecrew` — especificando los 7 nombres
exactos para no repetir el error de la instalación de `caveman` (que
sin `--skill` trajo 19). Verificado tras instalar: exactamente 7
carpetas nuevas en `.agents/skills/`, ninguna de más; `.claude/settings.json`
sin cambios (comparado con una copia guardada justo antes de instalar,
per el punto 7 de `hook-hardening`). Puro Markdown, sin binario propio
— no hizo falta tocar `session-start.sh`.

**Revisión antes de fusionar encontró un hallazgo real:** `cavecrew`
instrucciona delegar en tres subagentes
(`cavecrew-investigator`/`-builder`/`-reviewer`), pero `npx skills add
--skill cavecrew` solo trae la guía en Markdown, no las definiciones de
esos subagentes — esas viven en `agents/` en el repo original y solo
las instala el plugin completo (`claude plugin install`), no el CLI de
skills. Sin ellas, `cavecrew` quedaba decorativo: la delegación habría
fallado o caído a un agente genérico sin las instrucciones
comprimidas. Corregido copiando los tres archivos de agente reales
(verificados fieles al repo original) a `.claude/agents/` — la
convención real de Claude Code para subagentes de proyecto — en vez de
dejar la skill a medias o quitarla.

**Segunda ronda:** `cavecrew-investigator` y `cavecrew-reviewer` se
describen a sí mismos como "solo lectura"/"nunca comandos que mutan",
pero ambos declaran `Bash` sin acotar en su `tools:` — comprobado que
el campo `tools:` de un subagente no admite patrones tipo `Bash(git
log:*)` como sí admite el sistema de permisos general, así que esa
promesa de "solo lectura" la sostenía solo el texto del prompt. Primer
intento: documentarlo como límite aceptado, sin arreglo técnico
posible.

**Tercera ronda, corrigiendo el propio diagnóstico de la segunda:** esa
conclusión era incorrecta — sí existe un gate técnico real. Confirmado
contra la documentación oficial de hooks que el input de `PreToolUse`
lleva `agent_type` cuando la llamada viene de un subagente, y este repo
ya tiene las dos mitades del patrón funcionando (`check-pr-review.sh`
ya parsea `tool_name`/`tool_input` del JSON del hook; el propio
`matcher: "Bash|Grep"` del hook-guard de graphify ya prueba que un hook
sobre `Bash` funciona en este `settings.json`). Añadido
`.claude/hooks/restrict-cavecrew-bash.sh`: un `PreToolUse` nuevo sobre
`Bash` que, solo si `agent_type` es `cavecrew-investigator` o
`cavecrew-reviewer`, exige un único comando `git` de lectura
(`log`/`blame`/`show`/`diff`/`grep`/`status`/`ls-files`/`rev-parse`)
sin metacaracteres de encadenado, sustitución, o redirección — deniega
cualquier otra cosa. El hilo principal y cualquier otro subagente no se
tocan. Fail-open a propósito si `jq` falta o el input no se puede leer
(es una restricción nueva sobre un permiso que ya existía, no una
garantía crítica que se esté quitando).

Verificado en vivo con 8 casos: hilo principal sin restringir,
`cavecrew-investigator`/`-reviewer` con comandos de lectura permitidos,
comando mutante denegado, tres formas de escape (`;`, `$()`, `|`)
denegadas, y `jq` ausente permitiendo (fail-open confirmado).

**Cuarta ronda, tres bypasses de RCE reales en el diseño de la
tercera:** permitir un subcomando de `git` sin restringir sus flags no
cierra nada — `git grep -O'sh -c "..."'` (`--open-files-in-pager`)
ejecuta un comando arbitrario como "paginador", y `git log
--output=<ruta>` escribe contenido controlado por el propio comando en
cualquier archivo — ambos pasaban el filtro anterior (ningún
metacarácter de shell, subcomando permitido) y se reprodujeron en vivo
creando/escribiendo archivos de verdad. Además, un salto de línea
*literal* dentro de `tool_input.command` rompía tanto la lista negra de
metacaracteres como la de subcomandos permitidos, porque `grep -q` sin
`-z` ancla `^`/`$` por línea, no por cadena completa — una segunda
línea sin restringir se colaba entera.

Corregido con una regla mucho más simple que enumerar flags peligrosos
subcomando por subcomando (imposible de cerrar del todo — `git` tiene
demasiados escapes distintos): **ningún token puede empezar por `-` en
ningún punto del comando**, sin excepción — ni siquiera flags
realmente inocuos como `--oneline`. Y el salto de línea se comprueba
aparte, con un patrón de bash sobre la cadena completa, no con `grep`
línea a línea. Reverificados en vivo los 8 casos anteriores (sin
regresión) más los 3 bypasses nuevos, ahora denegados los tres, y un
caso de referencia bare sin flags (`git show HEAD`) que sigue
permitido.

**Quinta ronda, la regla de la cuarta se leía sobre texto crudo, no
sobre lo que la shell real ve:** `grep -qE '(^|[[:space:]])-'` mira la
cadena literal de `tool_input.command`, pero comillas y barras
invertidas no son "un `-`" para ese `grep` aunque sí lo sean para la
shell que ejecuta el comando de verdad. `git log '--output=/tmp/x'`,
`git log "--output=/tmp/x"`, y `git log \--output=/tmp/x` esconden el
`-` inicial detrás de una comilla o una barra en el texto que ve el
`grep`, pasan el filtro, y la shell real —que sí quita esas comillas
antes de invocar a `git`— entrega el flag peligroso igual. Reproducido
en vivo escribiendo en tres archivos de marca distintos antes de este
arreglo.

Corregido tokenizando el comando con las mismas reglas de comillas que
usaría la shell real, en vez de mirar el texto crudo: `eval "set --
$CMD"` puebla `$@` exactamente como lo haría la shell al ejecutar
`$CMD`, y cada `$TOK` ya resuelto (sin comillas) se comprueba por
separado. Seguro de invocar aquí porque el bloque de metacaracteres
(`;&|<>`, backtick, `$(`) ya corrió antes y ya rechazó cualquier cosa
que permita encadenar o sustituir — este `eval` no puede ejecutar nada
que ese bloque no dejara pasar primero. Un `eval` que falla (comillas
sin cerrar) también deniega, en vez de dejar pasar un comando que ni
siquiera se pudo interpretar con seguridad.

Reverificados en vivo los casos de la tercera y cuarta ronda (9, sin
regresión) más los 4 nuevos de esta ronda (`--output=` entre comillas
simples, dobles, escapado con barra, y `-O` de `git grep` entre
comillas simples) — los 4 ahora denegados, cero archivos de marca
escritos.

**Riesgo residual aceptado, no corregido — depende de una condición
previa fuera del alcance de este filtro:** `git diff`/`git status` sin
ningún flag pueden disparar ejecución de código igualmente si
`.git/config` ya trae `diff.external`/`core.fsmonitor` apuntando a un
programa, o `.gitattributes` ya trae una regla `textconv` — pero solo
si esa configuración maliciosa ya estaba plantada por otro medio
*antes* de que este hook entre en juego. Ninguno de los dos subagentes
restringidos puede escribir esa configuración ellos mismos (`config` no
está en la lista de subcomandos permitidos), así que cerrar esto
exigiría que el hook se convirtiera en un auditor completo de la
configuración de git, no un filtro del texto de un comando — fuera de
alcance para lo que este filtro intenta ser. Mismo criterio que otros
límites ya aceptados en este repo: depende de un compromiso previo que
un filtro de argumentos de Bash no está pensado para cubrir.

**Coste aceptado, no corregido:** `cavecrew-investigator.md` documenta
`find` como atajo válido ("`find` when faster") — ahora denegado,
porque `find` tiene sus propios escapes (`-exec`, `-delete`) tan
peligrosos como los de `git`, y no compensa reabrir esa puerta para un
atajo opcional cuando el subagente ya tiene `Read`/`Grep`/`Glob` para
lo mismo. Restricción más estrecha que lo que el propio subagente dice
usar, a propósito.

**Notas menores sin corregir (contenido vendido tal cual del repo
original, no tocado para no perder la fidelidad byte a byte):** el
`README.md` de `cavecrew` enlaza a `../../agents/*.md` y
`../../README.md`, rutas del layout del repo original que no existen
en este repo (los agentes reales están en `.claude/agents/`, no en
`.agents/agents/`); documenta variables `CAVECREW_*_MODEL` que solo
funcionan con una instalación vía plugin completo, no con este método
de copiar archivos a mano; y el `SKILL.md` de `cavecrew` recomienda
`feature-dev:code-architect` para refactors grandes, una skill que no
está instalada en este repo.

✅ Activadas el 2026-08-23.

## 2026-08-23 — statusline de ponytail: configurado

**Qué es:** badge (`[PONYTAIL]` / `[PONYTAIL:ULTRA]`) en la barra de
estado de Claude Code que muestra si `ponytail` está activo y en qué
nivel de intensidad, sin tener que preguntármelo. El propio plugin lo
trae (`ponytail-statusline.sh`), pero no se activa solo al instalarlo —
hace falta declarar `statusLine` en `settings.json` a mano.

**Cómo se configuró (con un ajuste sobre el aviso original del
plugin):** el aviso de `ponytail` sugería apuntar a
`~/.claude/plugins/cache/ponytail/ponytail/4.9.0/hooks/...` — una ruta
con el número de versión incrustado, que se rompería en cuanto
`ponytail` se actualice. Se apuntó en su lugar a
`~/.claude/plugins/marketplaces/ponytail/hooks/ponytail-statusline.sh`
— la copia dentro del propio clon del marketplace, sin versión en la
ruta, y que además ya se mantiene poblada cada sesión gracias a la
sección de `ponytail` que ya existía en `.claude/hooks/session-start.sh`
(no hizo falta tocar ese archivo para nada esta vez).

Verificado en vivo simulando un contenedor limpio de verdad (caché de
`ponytail` borrada): `session-start.sh` repuebla el clon del
marketplace, el script del statusline existe en la ruta correcta
después, y el comando exacto de `settings.json` lo ejecuta y devuelve
el badge esperado.

✅ Configurado el 2026-08-23.

## 2026-08-22 — caveman (JuliusBrussee): activado para todas las sesiones

**Nota sobre cómo se activó:** a petición explícita de Angel, tras
preguntar por la herramienta al ver que el propio `ponytail` la
recomienda en su FAQ ("Caveman shrinks what the agent says; ponytail
shrinks what it builds").

**Qué es:** modo de comunicación ultra-comprimido — quita relleno,
cortesías y hedging de mis respuestas en el chat, manteniendo intacta
la exactitud técnica (código, comandos, mensajes de error). Seis
niveles (`lite`/`full`/`ultra`/`wenyan-*`), activable con `/caveman
[modo]`. Recupera prosa normal automáticamente ante avisos de
seguridad, confirmaciones irreversibles, o si la compresión crearía
ambigüedad. **No afecta a lo que queda escrito en el repo** (código,
comentarios, mensajes de commit, documentación) — solo al chat.

**Hallazgo real durante la instalación:** `npx skills add
JuliusBrussee/caveman` sin especificar skill instaló **19 skills**, no
solo la pedida — incluyendo varias atadas a un servicio de pago
("Caveman Cloud": `caveman-setup`, `caveman-manage`, `caveman-optimize`,
`caveman-discover`, `caveman-evidence-review`, que piden URL de gateway
y API key) y otras sin relación con "prosa breve" en absoluto
(`lean-build`, `migration`, `safe-refactor`, `surgical-patch`,
`investigate-first`, `verify-and-stop`, `cavecrew`). Descubierto
*antes* de comitear (comprobando `git status` tras instalar, per el
punto 7 de `hook-hardening`) — descartado todo con `rm -rf` y
reinstalado con `npx skills add JuliusBrussee/caveman --skill caveman`,
que sí trae solo la skill pedida.

**Cómo se activó:** igual que `find-skills` — puro Markdown
(`.agents/skills/caveman/SKILL.md`, symlinkeado desde
`.claude/skills/caveman`), sin binario ni CLI propio que instalar. No
hizo falta tocar `.claude/hooks/session-start.sh`. Verificado que
`.claude/settings.json` no cambió ni un byte tras la instalación (se
guardó una copia de antes para comparar).

✅ Activado el 2026-08-22.

## 2026-08-22 — ponytail (DietrichGebert): activado para todas las sesiones

**Nota sobre cómo se activó:** a petición explícita de Angel ("sí, pero
actívalo para todas las sesiones actuales y futuras"), tras preguntar
por la herramienta.

**Qué es:** `ponytail` (MIT,
[github.com/DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail),
106.000+ estrellas). Inyecta una "escalera de decisiones" antes de
escribir código: ¿hace falta que exista? → omitir; ¿ya existe en el
repo? → reutilizar; ¿lo tiene la stdlib? → usarla; ¿una línea basta? →
una línea; solo entonces, lo mínimo viable. Resultados medidos por el
autor sobre un repo real: -54% líneas de código, -22% tokens, -20%
coste, sin perder validación ni manejo de errores.

**Por qué le sirve a Angel:** es el problema inverso a `hook-hardening`
— esa skill evita que yo me salte comprobaciones necesarias en código
crítico (hooks); `ponytail` evita que añada complejidad innecesaria en
el resto del código. Complementarios, no se pisan. También encaja
directo con reglas ya existentes del propio repo (no añadir
abstracciones más allá de lo necesario, tres líneas parecidas mejor que
una prematura) — automatiza algo que ya se pedía a mano.

**Cómo se activó (a nivel de proyecto, no de usuario):**
`claude plugin marketplace add DietrichGebert/ponytail --scope project`
+ `claude plugin install ponytail@ponytail --scope project`. A
diferencia de `mcp-server-dev`/`agent-browser`, la *declaración*
(`extraKnownMarketplaces`/`enabledPlugins` en `.claude/settings.json`)
queda commiteada en el repo, así que el proyecto "sabe" del plugin
desde el primer momento en cualquier sesión futura — no hace falta
volver a declararlo. Pero el contenido real clonado del marketplace
vive en `~/.claude/plugins/marketplaces/`, que sigue siendo caché de
contenedor, no parte del repo — verificado en vivo que si se borra esa
carpeta pero `settings.json` queda intacto, el plugin pasa a `Status: x
failed to load / cache-miss`. Por eso también hace falta una sección en
`.claude/hooks/session-start.sh` para repoblar esa caché cada sesión.

**Hallazgo real durante la instalación:** `claude plugin marketplace
add` no arregla de forma fiable una caché corrompida — verificado en
vivo que si el manifest global de marketplaces conocidos todavía tiene
un registro de "ponytail" pero su carpeta de clon ha desaparecido, `add`
responde "already on disk" y no vuelve a clonar, dejando el plugin
roto. `claude plugin marketplace update <nombre>` sí fuerza un
re-clonado real. Diseño final: `add` solo si el marketplace no se
conoce en absoluto todavía (contenedor nunca visto), `update` solo si el
plugin no aparece ya como `enabled` tras comprobar el estado real — no
las dos siempre, y siempre re-verificando el estado en vez de asumir
que el comando funcionó.

Verificado en vivo con tres escenarios reales (marketplace/caché
borrados de verdad, no simulados): estado normal (ya cacheado y
activo), caché corrompida (registrado pero sin clonar — el bug de
arriba), y contenedor 100% fresco (ni rastro en el manifest global).
También verificado que el peor caso combinado con `agent-browser`/
`mcp-server-dev` colgados a la vez (con un `claude` de mentira) se
acota en ~65s, muy por debajo del límite real de 600s del hook
`SessionStart`.

**Segunda ronda (revisión antes de fusionar):** tres hallazgos.

1. La primera lectura de `claude plugin marketplace list` en esta misma
   sección se quedó sin `timeout`, a pesar de que el bloque gemelo de
   `mcp-server-dev` justo arriba sí lo tenía — reproducido en vivo que
   un colgado ahí bloqueaba el arranque de la sesión sin límite.
   Corregido con el mismo `timeout 15` que ya usa el resto de lecturas.
   Se planteó extraer una función compartida entre `mcp-server-dev` y
   `ponytail` (dado que este mismo tipo de bug ya se había colado dos
   veces por duplicación) — descartado: usan mecanismos de recuperación
   distintos (`install`+`disable` en uno, `update` en el otro), así que
   una función común metería ramas para casos que no son iguales. Se
   prefirió el arreglo puntual de una línea.
2. `claude plugin marketplace add`/`update` imprimen su propio
   presupuesto de clonado ("timeout: 120s") — verificado en vivo — pero
   el script los envolvía con `timeout 90`, pudiendo matar un clonado
   legítimamente lento pero que iba a terminar bien. Subido a `timeout
   130` en las tres llamadas de este tipo (la de `mcp-server-dev`
   incluida, con el mismo problema desde antes). `install`/`disable` no
   clonan nada, se quedan en 90s.
3. La cifra de "~65s" de peor caso combinado (arriba) era de antes de
   que esta sección tuviera su propio `timeout`, y nunca se sumó al
   cálculo. Recalculado con los timeouts reales de todo el archivo tras
   este arreglo: graphify (90s) + agent-browser (hasta 200s, contando
   la rama sin Chromium de Playwright) + mcp-server-dev (385s) +
   ponytail (305s) = **hasta ~980s en el peor caso absoluto** — por
   encima del límite real de 600s del hook `SessionStart` si de verdad
   *todas* las llamadas de *las cuatro* secciones se cuelgan a la vez.
   Decisión: no reducir más los timeouts individuales (ya están
   ajustados a presupuestos reales de red observados, no arbitrarios) ni
   añadir un circuito de corte global — ese escenario exige un fallo de
   red total y sostenido sobre cuatro integraciones independientes a la
   vez, y si ocurriera, la consecuencia es que el hook se corta y la
   sesión arranca igual sin alguna integración opcional lista esa
   sesión — no pérdida de datos ni fallo de seguridad. Documentado como
   límite conocido y aceptado en vez de sobre-diseñar contra un
   escenario extremo.

Reverificados en vivo los tres escenarios (normal, caché corrompida,
contenedor 100% fresco) tras ambos cambios.

✅ Activado el 2026-08-22.

## 2026-08-21 — mcp-server-dev (Anthropic): activado, deshabilitado por defecto

**Nota sobre cómo se activó:** a petición explícita de Angel ("actívalo
para un futuro"), tras preguntar por las ventajas de MCP Builder sobre
lo que ya tiene. No es un conector — es una skill guía para *construir*
un servidor MCP nuevo cuando exista un sistema concreto sin conector
todavía (ej. el campus del máster, una herramienta interna del sector
ferroviario/telecom). No aporta nada sobre los conectores ya activos.

**Qué es:** plugin oficial `mcp-server-dev` (Anthropic,
`anthropics/claude-plugins-official`), con 3 skills:
`build-mcp-server`, `build-mcpb`, `build-mcp-app`. Antes de escribir
código, interroga sobre el caso de uso y recomienda una arquitectura
concreta (servidor HTTP remoto, local `stdio` solo para prototipo,
etc.), un patrón de herramientas, y el SDK (TypeScript oficial o
FastMCP 3.x en Python).

**Cómo se activó (a nivel de usuario, no del proyecto):**
`claude plugin marketplace add anthropics/claude-plugins-official` +
`claude plugin install mcp-server-dev@claude-plugins-official`. Se
guarda en `~/.claude/`, no en el repo, así que — como los git hooks de
graphify y el binario de `agent-browser` — no sobrevive a un
contenedor nuevo. Añadido a `.claude/hooks/session-start.sh` para
reinstalarlo cada sesión (ambos comandos confirmados idempotentes en
vivo, con `timeout` y verificación del estado real vía `claude plugin
list`, no solo del código de salida).

**Decisión: instalado pero deshabilitado por defecto.** `claude plugin
details mcp-server-dev` reporta ~502 tokens siempre-activos por sesión
solo por estar habilitado, y esto es "para un futuro", no de uso
inmediato — no tiene sentido pagar ese coste sesión tras sesión sin una
tarea concreta todavía. Se intentó primero `skillOverrides:
"name-only"` (el mecanismo que ya usa este repo para skills de poco
uso) pero **no aplica a skills de plugins** — la documentación oficial
de Claude Code lo dice explícitamente ("Plugin skills are not affected
by skillOverrides. Manage those through /plugin instead."),
comprobado antes de aplicarlo mal. La alternativa real:
`claude plugin disable mcp-server-dev` tras cada instalación (también
en `session-start.sh`, porque un contenedor nuevo activaría el plugin
por defecto al instalarlo, deshaciendo la decisión). Reactivarlo cuando
haga falta de verdad: `claude plugin enable mcp-server-dev`.

Verificado en vivo con `claude plugin marketplace remove` +
`claude plugin uninstall` para simular un contenedor limpio de
verdad (no binarios de mentira): el hook reinstala y deja deshabilitado
correctamente, es idempotente en una segunda corrida, y se degrada sin
romper nada si el CLI `claude` no está en el PATH.

**Segunda ronda (revisión antes de fusionar):** encontró, con razón,
que la propia sección nueva no aplicaba el checklist de `hook-hardening`
que este mismo PR añadía. Tres problemas reales: (1) `claude plugin
install` no es un no-op sobre un plugin ya deshabilitado — reproducido
en vivo que lo vuelve a activar cada vez que corre — así que el diseño
original dependía por completo de que el `disable` posterior
funcionara, sin comprobar su código de salida ni re-verificar el
estado después; un `disable` real puede fallar (reproducido en vivo
contra un nombre de plugin inventado, exit 1), y en ese caso el script
seguía imprimiendo "deshabilitado por defecto" con el plugin en
realidad activo. (2) Los `grep` contra `claude plugin list`/
`marketplace list` no anclaban la coincidencia, así que cualquier otra
entrada que contuviera el mismo texto como subcadena podría dar un
falso positivo. (3) El timeout de `disable` (30s) no tenía por qué ser
distinto del resto (90s), sin ninguna razón declarada. Corregido:
ahora solo se llama a `install`/`disable` cuando el estado real (leído
con un `grep` anclado a la línea exacta `> nombre`) muestra que hace
falta, y se vuelve a comprobar el estado tras `disable` antes de
reportar nada — si sigue activo, lo dice explícitamente en vez de
mentir. Verificado en vivo con cuatro casos reales: ya
instalado-y-deshabilitado (más rápido ahora, sin llamadas de más),
estaba activado a mano y vuelve a desactivarse, `disable` fallando de
verdad (con un `claude` envuelto que solo intercepta ese subcomando) y
avisando en vez de mentir, y contenedor limpio desde cero.

**Tercera ronda:** encontró que las propias lecturas de solo consulta
(`claude plugin list`/`marketplace list`, añadidas para verificar el
estado en vez de asumirlo) no tenían `timeout` — verificado con
`strace` que sí hacen una conexión de red real, y que con una ruta
bloqueada pueden tardar varios segundos en vez de fallar rápido — y que
se repetía la misma consulta varias veces sin motivo (hasta 6 llamadas
en el caso normal). Corregido: cada lectura lleva su propio `timeout`,
y el resultado se guarda en una variable y solo se vuelve a pedir justo
después de algo que pudiera haberlo cambiado (`add`/`install`/
`disable`), no de forma repetida para el mismo estado. El caso normal
(ya instalado y deshabilitado) bajó de ~4,5s a ~1,6s. Reverificados los
cuatro casos en vivo tras el cambio: todos siguen correctos.

✅ Activado (deshabilitado) el 2026-08-21.

## 2026-08-21 — find-skills (Vercel Labs): activado

**Nota sobre cómo se activó:** igual que `agent-browser`, a petición
explícita de Angel en esta misma conversación, no de la Routine
semanal del radar.

**Qué es:** `find-skills` — skill del mismo repo `vercel-labs/skills`
(el CLI `npx skills`, ya usado para instalar `agent-browser`). Cuando
alguien pregunta "¿cómo hago X?" o "¿hay una skill para X?", busca en
el ranking de [skills.sh](https://skills.sh/), en GitHub, y con
`npx skills find <consulta>`, y solo ofrece instalar tras presentar
opciones y recibir confirmación — no busca ni instala nada por su
cuenta sin que se le pida.

**Por qué le sirve a Angel:** las herramientas propias (`SearchSkills`/
`SearchPlugins`) solo ven el catálogo de su cuenta de claude.ai;
`find-skills` llega también al ecosistema abierto de GitHub (de donde
salió `agent-browser`), así que son complementarias. Aplica un filtro
de calidad explícito: prefiere skills con 1.000+ instalaciones,
desconfía de menos de 100, y valida fuentes oficiales (Vercel Labs,
Anthropic, Microsoft) frente a repos con pocas estrellas.

**Cómo se activó:** una sola parte, a diferencia de `agent-browser` —
es puro Markdown (`npx skills add vercel-labs/skills --skill
find-skills`, deja el stub en `.agents/skills/find-skills/SKILL.md`
symlinkeado desde `.claude/skills/find-skills`), sin binario propio
que instalar ni reinstalar cada sesión: invoca `npx skills find/add`
bajo demanda cuando de verdad se usa, no al arrancar la sesión. No hizo
falta tocar `.claude/hooks/session-start.sh`.

✅ Activado el 2026-08-21.

## 2026-08-20 — agent-browser (Vercel Labs): activado

**Nota sobre cómo se activó esta vez:** a diferencia del resto de este
registro, esto no salió de la Routine semanal del radar ni de una
tarjeta de sugerencia — Angel pidió explícitamente en esta misma
conversación "instala para todas las sesiones", tras haber preguntado
por la herramienta y haber recibido la comparación con las otras
opciones de navegador (Claude in Chrome, `browser-use`). La regla del
radar de "proponer con tarjeta, nunca instalar por Angel" es para
hallazgos que yo traigo por iniciativa propia — no aplica cuando el
propio Angel pide la instalación directamente, como aquí.

**Qué es:** `agent-browser` — CLI de automatización de navegador en Rust
puro (Apache-2.0, [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser),
41.000+ estrellas). Controla Chrome/Chromium vía CDP con snapshots de
árbol de accesibilidad y referencias compactas `@eN` en vez de
coordenadas de píxel — pensado para agentes de código, no para
navegación genérica.

**Por qué le sirve a Angel:** los ejercicios interactivos de
`docencia-espanol/materiales/` (HTML autocontenido con JS de corrección
instantánea) hoy solo se verifican leyendo el código o probándolos a
mano. `agent-browser` permite clicar, rellenar huecos y comprobar que la
lógica de corrección funciona de verdad en un navegador real, con
auditoría de accesibilidad (axe-core) incluida — cosa que ni
`impeccable` (trae su propia automatización de navegador, pero para
crítica de diseño visual, no QA funcional) ni ningún otro skill del
repo hacían hasta ahora.

**Cómo se activó:** en dos partes, porque el contenedor de cada sesión
es efímero:
1. **Skill** (`npx skills add vercel-labs/agent-browser`) — deja el
   stub en `.agents/skills/agent-browser/SKILL.md` con
   `.claude/skills/agent-browser` como symlink hacia él. Es texto
   ligero, versionado en Git, así que sobrevive solo con el commit —
   no hace falta reinstalarlo cada sesión.
2. **Binario CLI** (`npm install -g agent-browser`, versión fijada a
   propósito por seguridad de cadena de suministro) — no sobrevive a
   un contenedor nuevo, igual que los git hooks de graphify. Añadido a
   `.claude/hooks/session-start.sh` para que se reinstale solo al
   principio de cada sesión, con `timeout` en cada paso para que un
   fallo o cuelgue nunca bloquee el arranque de la sesión.

**Hallazgo durante la instalación:** `agent-browser install` (el paso
que descarga su propio Chrome) falla siempre aquí — no es un fallo de
red pasajero, es una denegación de política confirmada en vivo (403 al
intentar conectar con `googlechromelabs.github.io`, ver
`/root/.ccr/README.md`: reportar, no rodear). Solución real, sin rodear
la política: apuntar `agent-browser` al Chromium que este entorno ya
trae preinstalado para Playwright (`/opt/pw-browsers/chromium`) vía
`AGENT_BROWSER_EXECUTABLE_PATH`, en vez de dejar que intente descargar
el suyo.

**Primer intento fallido, corregido en la siguiente revisión:** esa
variable tiene que llegar a los shells que arranca el Bash tool
*después* de que este hook termine, y un `export` dentro del hook no
se propaga a un shell nuevo. El primer intento la escribía en
`/etc/profile.d/agent-browser-executable.sh` (mismo mecanismo que usa
el proxy de este contenedor para `HTTPS_PROXY`) y se dio por probado de
punta a punta — pero esa prueba usó `bash -lc` (shell de *login* a
propósito), y el Bash tool real invoca cada comando como `bash -c` (sin
`-l`), que nunca lee `/etc/profile.d/`. Confirmado en vivo con una
llamada nueva del propio Bash tool: la variable salía vacía pese al
archivo de profile.d ya escrito. Corregido usando `$CLAUDE_ENV_FILE`
(mecanismo documentado en la skill `session-start-hook` para persistir
variables de sesión — `echo 'export X=Y' >> "$CLAUDE_ENV_FILE"`),
verificado con una llamada real del Bash tool tras el fix, no solo con
un shell manual.

Misma revisión encontró y corrigió otros dos "éxito falso": `graphify
hook install` no comprobaba su código de salida tras el `timeout`
añadido (un cuelgue/fallo se reportaba igual como instalado), y el pin
de versión de `agent-browser` solo se comprobaba con `command -v`
(presencia), no con la versión real instalada — un contenedor cacheado
con una versión distinta nunca habría reinstalado. Ambos ahora
comparan explícitamente antes de reportar éxito.

**Tercera pasada, con el revisor puesto en modo escéptico a propósito**
(la ronda anterior de "arreglado y probado" había resultado no
funcionar de verdad): encontró que la propia comprobación de versión
nueva (`agent-browser --version`) no tenía `timeout`, así que un
binario colgado bloquearía el arranque de la sesión indefinidamente —
justo el mismo tipo de fallo que este archivo ya llevaba dos rondas
corrigiendo en otros puntos, reintroducido en el código nuevo de esta
misma ronda. Y si la reinstalación por pin fallaba (red bloqueada,
igual que con el Chrome de `agent-browser install`), el script no
volvía a comprobar la versión después del intento — seguía reportando
"listo" con el binario viejo, sin avisar de que el pin no se había
podido aplicar. Ambos corregidos: `timeout` en las dos llamadas a
`--version`, y una segunda comprobación tras el intento de
reinstalación, que ahora sí avisa explícitamente si sigue en una
versión distinta a la fijada. Verificado con binarios simulados
(`agent-browser`/`npm` de mentira) para los tres casos: colgado,
reinstalación fallida, y caso normal.

**Cuarta pasada** (siguiendo escéptica a propósito, dado el historial de
esta misma sección): encontró que avisar del desajuste de versión y
*seguir adelante igual* con el binario no vetado deshacía el propósito
del pin declarado en el propio comentario del script — cualquier
comando de `agent-browser` corriendo el resto de la sesión lo haría con
el permiso general `Bash(agent-browser:*)` que la skill preautoriza,
sin ninguna revisión, sobre una versión que nunca se vetó para eso.
Corregido: si la versión sigue sin coincidir con el pin tras el intento
de reinstalación, esa sesión simplemente no configura ni usa
`agent-browser` (se trata como si no estuviera disponible), en vez de
usarlo con una advertencia. Verificado que el caso normal sigue
funcionando igual y que el caso de desajuste ya no escribe
`AGENT_BROWSER_EXECUTABLE_PATH` en ningún sitio.

**Quinta pasada, límite honesto que queda sin cerrar del todo:**
encontró que ese "saltar la sesión" solo evita que este *hook* configure
o dependa del binario no vetado — no impide técnicamente que se le
llame por Bash directamente el resto de la sesión, a diferencia del
gate real que sí existe para fusionar PRs
(`.claude/hooks/check-pr-review.sh`, con su propio `PreToolUse` en
`.claude/settings.json`). Aquí no hay un hook equivalente para
`agent-browser`, así que el pin de versión protege el paso de
*instalación* (este script nunca instala nada sin fijar versión) pero
no un paso de *ejecución* — cerrarlo del todo pediría un gate técnico
dedicado, coste desproporcionado para instalar una herramienta de
navegador, así que queda documentado como límite conocido en los
propios comentarios del script en vez de resuelto. Corregido en la
misma pasada un comentario impreciso (atribuía un `$CLAUDE_ENV_FILE`
vacío a "un entorno no remoto" sin haberlo comprobado — reproducido en
vivo que puede pasar igual con `CLAUDE_CODE_REMOTE=true`).

✅ Activado el 2026-08-20.

## 2026-08-18 — Práctica: desplazar la ventana de 5h de límite de uso

Hallazgo de práctica, no herramienta instalable (sin tarjeta). La
ventana de uso de 5 horas de Claude no reinicia a una hora fija: empieza
a contar desde el primer mensaje que se envía. Mandar un mensaje corto
en cuanto se empieza a trabajar (en vez de dejar que la ventana llevara
un rato corriendo antes del primer uso real) desplaza el reinicio hacia
el horario real de trabajo, en vez de perder parte del bloque al
principio. Aplica sobre todo a sesiones largas como las de revisión de
PRs de este repo. Fuente: [soporte oficial de Claude](https://support.claude.com/en/articles/11647753-how-do-usage-and-length-limits-work)
(no se pudo verificar el texto exacto en esta sesión — `support.claude.com`
está bloqueado por la política de red del entorno — reconstruido por
búsqueda cruzando varias fuentes que lo citan).

## 2026-08-18 — MarkItDown (Microsoft): herramienta puntual, no instalada

**Qué es:** `markitdown` (Microsoft, MIT,
[github.com/microsoft/markitdown](https://github.com/microsoft/markitdown)) —
librería/CLI de Python que convierte PDF, DOCX, PPTX, XLSX, HTML, audio,
EPUB, ZIP y más a Markdown limpio. No es un conector MCP instalable
(`SearchMcpRegistry` no devuelve nada para este nombre) — es un paquete
pip que se instala bajo demanda, igual que `tesseract`/`poppler`.

**Por qué no se activa como dependencia fija:** los formatos que más usa
Angel ya están cubiertos por skills dedicadas y más completas
(`docx`/`pptx`/`xlsx`, que además editan, no solo leen) o por el flujo
ya hardened de `docencia-espanol/fuentes/paginas.sh` para PDF
escaneados — ahí el coste en tokens no está en la extracción de texto
(que ya es gratis con `pdftotext -layout`), sino en el paso 3
obligatorio de ver la imagen renderizada, algo que MarkItDown no puede
sustituir (es solo extracción de texto, no lee líneas dibujadas, ítems
ya resueltos a mano ni manuscrito).

**Cuándo sí usarlo:** formatos sueltos sin skill propia en este repo —
`.epub`, `.html` guardado en local, transcripción de audio, o
convertir varios archivos mixtos con una sola llamada. Instalar con
`pip install markitdown` (o `markitdown[all]` para todos los formatos
opcionales) solo cuando aparezca ese caso concreto, no de antemano.

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

**Séptima ronda (encontró una regresión introducida por la sexta):** el
cambio de la sexta ronda -- pasar el token por `curl -K -` en vez de
`-H` en argv, para no exponerlo vía `/proc/<pid>/cmdline` -- interpolaba
`$TOKEN` sin validar dentro del heredoc que `curl -K` parsea como
config, donde `"` cierra un valor y `\n` empieza una directiva nueva.
Probado en vivo con un token fabricado con un salto de línea seguido de
una directiva `url = "..."`: `curl` hacía **una segunda petición HTTP**
a esa URL inyectada, reenviando la cabecera `Authorization: Bearer
<token real>` también ahí -- una vía de exfiltración nueva, peor que el
problema que la sexta ronda arreglaba, y que el código *anterior* a esa
ronda no tenía. Corregido validando `$TOKEN` contra una lista blanca de
caracteres (`^[A-Za-z0-9._~+/=:-]+$`, el charset real de un token de
GitHub) **antes** de interpolarlo en cualquier parte -- si no cumple, se
deniega sin siquiera intentar la petición. También cerró un hallazgo
menor: `mark-pr-reviewed.sh` podía dejar un archivo temporal huérfano en
`.claude/.pr-review-state/` si `jq` fallaba a mitad de escritura (sin
impacto de seguridad, solo basura) -- añadido un `trap 'rm -f "$TMP"'
EXIT`.

**Lección de esta ronda:** un arreglo de seguridad puede introducir un
problema peor que el que resuelve, si mueve el dato sensible de un
contexto ya bien entendido (argv) a otro con sus propias reglas de
escapado que no se validaron con el mismo cuidado (aquí, la sintaxis de
config de `curl`). Cada ronda de este hook se sigue verificando en vivo,
no solo por lectura -- fue precisamente esa prueba en vivo (un servidor
HTTP local recibiendo la segunda petición) la que confirmó el problema
en vez de quedarse en una sospecha teórica.

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

✅ Activado (visto conectado vía `ListConnectors` el 2026-08-30, sin
fecha exacta de activación registrada — corregido este marcador con
retraso). Nota: `connected: true` pero `enabledInChat: false` la última
vez que se comprobó — está autenticado a nivel de cuenta pero apagado
para esta conversación en concreto; activarlo en los ajustes de
conectores de este chat si se quiere usar aquí.

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
  ✅ Activado (visto `enabled: true` vía `ListPlugins` el 2026-08-30, sin
  fecha exacta de activación registrada — corregido este marcador con
  retraso).

**Learning Commons sigue sin activar** (`ListConnectors` no lo encuentra,
comprobado el 2026-08-30) — sigue siendo de baja prioridad para el
perfil de alumnos de Angel (adultos rusohablantes, no K-12), no se
insiste más salvo que aparezca algo nuevo sobre él.
