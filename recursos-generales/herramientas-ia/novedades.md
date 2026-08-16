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

### Anotado, no aplicado: hooks para reglas duras, no solo CLAUDE.md

**Qué es:** hallazgo de una búsqueda general (no una fuente única
citable): las instrucciones de `CLAUDE.md` se siguen ~70% de las veces
según reportan varios desarrolladores — aceptable para preferencias de
estilo, pero arriesgado para reglas críticas tipo "nunca fusionar sin
revisión". Un hook sí garantiza el 100%, porque es determinista, no una
instrucción que el modelo pueda pasar por alto.

**Por qué le sirve a Angel:** este repo tiene una regla dura exacta de
ese tipo ("nunca hacer merge sin revisión independiente previa",
`CLAUDE.md`) y además usa `defaultMode: dontAsk`, que quita el
cortafuegos de permisos interactivo por completo. Hoy esa regla se
cumplió siempre porque se le puso énfasis fuerte ("Regla dura, sin
excepciones") y porque la seguí con disciplina turno a turno — pero
nada la hace estructuralmente imposible de saltarse en una sesión
futura.

**Por qué no se aplicó ya:** un hook que bloquee de verdad el merge sin
revisión necesitaría alguna forma de que la skill de revisión deje
constancia verificable (ej. un archivo marcador) que el hook pueda
comprobar antes de permitir `merge_pull_request` — eso significa tocar
también cómo se invoca la skill `code-review`, no es un cambio trivial
de una tarde. Queda anotado para diseñarlo con calma si Angel lo quiere,
en vez de montar algo a medias bajo prisa.

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
