# Novedades de herramientas de IA

Registro de novedades relevantes para el trabajo de Angel en este
repositorio: funciones nuevas de Claude Code, skills, plugins,
conectores MCP, modelos, o herramientas de terceros. Mantenido por una
Routine semanal de Claude Code (ver `## Radar de herramientas de IA` en
`CLAUDE.md`), más las pasadas que se hagan a mano.

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
