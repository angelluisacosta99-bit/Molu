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

## 2026-09-09 — Skill "humanizer" (terceros, adaptada a mano)

Angel pidió instalar "Humanizer" tras ver un post de Instagram
(@cinthyasanchezai) que lo promocionaba como habilidad de Claude. No es
una función nativa de Anthropic — es un skill open-source de un tercero:
[`blader/humanizer`](https://github.com/blader/humanizer) (MIT).

**Qué es:** reescribe texto para quitar "tells" típicos de IA (aperturas
escenificadas, tríadas forzadas, palabras infladas tipo "clave"/
"panorama", negrita decorativa, coletillas de chatbot como "espero que
esto ayude"). 25 patrones en 5 categorías.

**Cómo se activó:** el repo original se instala con
`npx skills add blader/humanizer --global`, pero eso ejecuta un paquete
de npm de un tercero sin revisar y afecta fuera de este repo (`--global`).
En vez de eso, revisé `SKILL.md` del repo (solo texto, sin nada
sospechoso) y lo copié a mano a `.claude/skills/humanizer/SKILL.md`,
con nota de atribución/licencia. Cero código de terceros ejecutado.

**Aviso a Angel:** estas herramientas están pensadas para que un texto
no sea detectable como escrito por IA. Para tu caso (post de blog para
tu propio perfil) no hay nada deshonesto — pero si algún día lo usas en
un contexto donde declarar que el texto es asistido por IA importa
(una plataforma con esa política, un trabajo académico), ese es tu
criterio a aplicar, no algo que el skill decida por ti.

**Actualización 2026-09-09 — ampliada y verificada de nuevo:** a
petición de Angel, dos mejoras sobre la versión inicial:
- Los 25 patrones ahora aparecen nombrados uno a uno (antes solo se
  copió el resumen por categoría del `SKILL.md` original; los nombres
  concretos de cada patrón solo estaban en el `README.md` de la fuente).
- Añadida una sección de tics específicos del **español** ("no
  solo... sino también", "cabe destacar que", "en definitiva" como
  cierre automático) — el original está pensado para inglés y varios
  de sus patrones (dashes, "pivotal"/"landscape") no tienen equivalente
  directo.
- Reescaneado el archivo completo con un script de `unicodedata` en
  busca de caracteres Unicode ocultos/de control/homóglifos antes y
  después de la ampliación: 0 encontrados ambas veces.

**Actualización 2026-09-09 (2) — Angel pidió usarlo para su TFM/máster,
rechazado; luego ampliado más para blog con fuentes adicionales:**

Angel preguntó si podía usar este skill para sus trabajos de
universidad (máster) y su TFM. Se le explicó que eso es fraude
académico (evadir detección de IA en una evaluación formal es distinto
de raíz a un post de blog sin evaluación de por medio) y se rechazó
ampliarlo con ese fin. Angel aceptó la explicación y pidió continuar
solo con el uso de blog — el `description` del frontmatter ahora deja
explícito ese límite de alcance ("NO usar en trabajos de
universidad/máster ni en el TFM").

Con el alcance ya acotado a blog/redes, se buscaron más fuentes
open-source similares y se incorporaron ideas nuevas de:
- `conorbronsdon/avoid-ai-writing` (MIT) — perfil de voz (casual/
  profesional/cálido/directo) y el ciclo de "iterar hasta converger"
  (máximo 2 pasadas).
- `lguz/humanize-writing-skill` (MIT) — el marco de 3 pasadas
  (vocabulario → estructura → textura humana) y la idea de niveles de
  palabras prohibidas (Nivel 1 cortar siempre / Nivel 2 revisar caso a
  caso).

Ambas fuentes citan como referencia común el ensayo de Wikipedia
"Signs of AI writing" — no se pudo acceder directamente (`en.wikipedia.org`
bloqueado por el proxy de red de esta sesión), así que queda
referenciado de segunda mano vía esas dos fuentes, no leído en
directo. Reescaneado el archivo tras la ampliación: 2 caracteres "→"
(flecha derecha) encontrados por el umbral del script, revisados a
mano — son texto normal que escribí yo mismo ("vocabulario → estructura
→ textura humana"), no nada oculto ni inyectado.

**Actualización 2026-09-09 (3) — revisión con agente independiente,
6 hallazgos corregidos:** a petición de Angel, se lanzó un agente sin
contexto previo a revisar el post de blog, la skill `humanizer` y este
mismo registro. Encontró 6 problemas reales, todos corregidos en el
momento:

1. **Contradicción en `humanizer`:** "clave" estaba en Nivel 1 ("cortar
   siempre") y en Nivel 2 ("a veces preciso") a la vez. Corregido:
   "clave" solo en Nivel 2 con el matiz; Nivel 1 se queda con
   "fundamental"/"panorama".
2. **El mismo tic repetido en 3 sitios** sin remitirse entre sí (fruto
   de las 3 rondas de ampliación sin consolidar). Corregido: cada tic
   vive en un solo sitio; la sección de tics de español ahora solo
   tiene lo que no estaba ya cubierto.
3. **"Los 25 patrones" en realidad documentaba 27** (dos colados en un
   paréntesis del punto 11). Corregido: renumerados como 12-13
   explícitos, cabecera actualizada a "27 patrones" con nota de qué
   fuente aporta cuáles.
4. **La nota de "no usar en TFM" se leía como más sólida de lo que
   es.** Añadida una aclaración explícita: es documentación, no un
   bloqueo técnico — no impide reescribir algo a mano sin invocar el
   skill por su nombre.
5. **Meta-descripción del post en 165 caracteres** (por encima del
   límite de ~155-160 de Google). Acortada a 124.
6. **El enlace Markdown del CTA no sobrevive a un editor WYSIWYG.**
   Añadida una nota en el propio post explicando cómo recrearlo a mano
   en el editor de la plataforma.

El agente confirmó sin problemas: el contenido del blog no tiene datos
inventados (contrastado contra los README reales de
`docencia-espanol/`), las entradas de este registro coinciden con el
estado real de los archivos, y no hay nada tipo inyección de prompt en
`SKILL.md` (su propio escaneo con `unicodedata` también dio 0).

---

## 2026-09-07 — Búsqueda a mano: herramientas para posts de blog en plataformas de clases

Angel pidió una búsqueda exhaustiva mientras preparaba un post de blog
para el perfil de TusClasesParticulares (y potencialmente Superprof).
Revisado el catálogo completo de conectores MCP y plugins con
palabras clave de blog/SEO/marketing/tutoring — esto es lo que encajó.

### Plugin "Marketing" (`plugin_01Eeb9y5m4iFuY3yRtytYfdc`)

**Qué es:** paquete de skills para redactar contenido, planificar
campañas y analizar rendimiento. Incluye `marketing:draft-content`
(redactar un post con optimización SEO integrada), `content-creation`,
`seo-audit` y `brand-review`.

**Por qué le sirve a Angel:** encaja directo con el post que se acaba
de escribir a mano en `docencia-espanol/materiales/blog/` — la próxima
vez podría usarse `draft-content` para partir de una estructura ya
pensada para SEO, en vez de escribir el post desde cero.

**Cómo probarlo:** tarjeta de instalación ya mostrada en el chat.
Bastantes de los conectores que lista (Ahrefs, HubSpot, Klaviyo,
Supermetrics...) son opcionales — solo hacen falta si se usan las
skills de analítica, no para simplemente redactar un post.

### Plugin "SearchFit SEO" (`plugin_016u9h5nGGKuX18riDTJ7otg`)

**Qué es:** kit de SEO gratuito con IA — auditoría de sitio,
`content-brief`, `content-strategy`, `on-page-seo`,
`keyword-clustering`, generación de schema markup.

**Por qué le sirve a Angel:** más ligero que "Marketing", centrado solo
en SEO. Útil para revisar palabras clave antes de escribir (¿qué busca
alguien que quiere "clases de español para rusohablantes"?) y para que
el post aparezca mejor en buscadores, tal y como promete
TusClasesParticulares en su propia landing ("Tu post será visible en
los motores de búsqueda como Google").

**Cómo probarlo:** tarjeta de instalación ya mostrada en el chat.

### Mencionados pero no propuestos con tarjeta (por completitud, sin encajar tan bien ahora mismo)

- **Semrush** y **Ahrefs** (conectores MCP) — SEO avanzado, análisis de
  competencia, investigación de keywords. Herramientas de pago
  pensadas para negocios con varios sitios/canales; para un solo post
  de blog de un profesor particular son sobredimensionadas. Quedan
  anotadas por si en el futuro Angel monta una web propia y quiere
  hacer SEO en serio.
- **Metricool** (conector MCP) — programar y analizar publicaciones en
  redes sociales. No es blog, pero es la herramienta natural si
  algún día Angel quiere promocionar sus posts también en redes.
- **WordPress.com** (conector MCP) — gestión de sitios WordPress.
  Solo relevante si Angel tuviera su propia web en WordPress (no es el
  caso: publica en plataformas de terceros como TusClasesParticulares).
- Revisado también el resto del catálogo (CRM, ventas B2B, analítica
  empresarial, herramientas de desarrollo) — no aplica a este caso de
  uso, no se detalla aquí para no "volcar todo el mercado".

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
