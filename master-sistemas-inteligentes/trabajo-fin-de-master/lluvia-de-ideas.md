# Lluvia de ideas — TFM

Log libre, entrada nueva arriba con fecha. Aquí va todo lo suelto:
ideas, novedades, temas, marco teórico, hallazgos — sin estructura
rígida, antes de que decante en algo formal para `main.tex` o para
`ideas-tfm-energias-renovables.md`.

---

## 2026-09-13 (continuación: dominios bloqueados para docs oficiales + para la sesión que retome esto)

**Para quien retome esta sesión:** se acaba de fusionar el PR #111
(arreglo de `picins.sty`, ver más abajo) y Angel abrirá una **sesión
nueva** en un entorno con permisos de red ampliados. Contexto necesario
que esa sesión debe tener claro de entrada:

- El TFM es: sistemas inteligentes aplicados a energías renovables —
  predicción de generación (deep learning) + módulo de decisión difuso.
  Ver `ideas-tfm-energias-renovables.md` para el planteamiento completo
  y `preparacion/plan-de-entrenamiento.md` para las 7 fases.
- `main.tex` es la fuente única de la memoria (normativa DPTOIA-IT del
  departamento) — no se cambia a Word como documento principal. Por
  cada capítulo cerrado se entrega un `.docx` de repaso (skill `docx`)
  y el `.pdf` recompilado como archivo, nunca solo un enlace de GitHub
  (ver entrada de más abajo, "formato de entrega para Angel", para el
  razonamiento completo).
- Hay dos artefactos de índice/lección publicados y mantenidos entre
  sesiones — al actualizarlos, republicar con el mismo `url`, no crear
  uno nuevo: **"Preparación del TFM"**
  (`https://claude.ai/code/artifact/83deaf92-8d01-48bb-80c7-d9bb8b88e737`,
  índice de fases + enlaces a GitHub de `lluvia-de-ideas.md`/
  `ideas-tfm-energias-renovables.md`/`main.tex`) y **"NumPy y Pandas
  desde Cero"** (`https://claude.ai/code/artifact/b04569b0-a083-4a05-972d-1bcbe8b5a453`,
  Lección 1 de la Fase 0).

**El motivo concreto de la sesión nueva — dominios de red:** al ampliar
la teoría de la Lección 1 (NumPy/Pandas) con fuentes oficiales
verificadas, `numpy.org` y `pandas.pydata.org` dieron
`EGRESS_BLOCKED` (política de red del entorno de esta sesión). Angel va
a autorizar esos dos dominios en la configuración de red del entorno
(`code.claude.com/docs/en/claude-code-on-the-web`) antes de abrir la
sesión nueva. La ampliación de esta vez se hizo solo con los dos
cuadernos oficiales de Géron (abiertos, sin bloqueo) — sirvió, pero es
menos completo que tener también la documentación oficial.

**Qué hacer en la sesión nueva con esos dominios ya disponibles:**
1. Confirmar que `numpy.org` y `pandas.pydata.org` responden (probar un
   fetch simple antes de dar por hecho que el permiso ya está activo).
2. Volver a la Lección 1 (artefacto de arriba) y reforzar/contrastar la
   teoría ya añadida (reglas de broadcasting, por qué NumPy es rápido
   con vectorización/tipos fijos, `resample`/`interpolate` de Pandas)
   contra la documentación oficial — citarla igual que se citó el
   cuaderno de Géron, con el mismo cuidado de no inventar nada sin
   fuente. No hace falta repetir lo ya verificado con los cuadernos,
   solo completar lo que quedó pendiente por el bloqueo.
3. A partir de ahí, seguir con las siguientes lecciones del plan de
   entrenamiento (Fase 1 en adelante) ya sin esa limitación de red.

## 2026-09-13 (continuación: formato de entrega para Angel)

Angel preguntó en qué formato podría ver/editar la tesis ("tipo Word,
tipo artefacto..."). Aclarado: `main.tex` es el código fuente (no
legible), el PDF compilado es el resultado legible/imprimible — un
artefacto de claude.ai no aplica aquí (es para páginas web
interactivas, no para el documento de la tesis).

**Decisión de flujo, elegida explícitamente por Angel entre dos
opciones:** `main.tex` sigue siendo la fuente única de la tesis (ya
tiene la bibliografía y el formato del departamento funcionando, ver
más abajo) — no se cambia a Word como documento principal, para no
tener dos documentos de la tesis compitiendo. Como complemento, no
sustituto: cada vez que se cierre un capítulo real de `main.tex`, se
entrega también una copia `.docx` de esa misma versión (vía la skill
`docx`) para que Angel pueda tocar texto suelto sin depender de LaTeX.
Si edita esa copia, debe decírselo a la sesión para trasladar el
cambio a `main.tex` — el `.docx` es solo una copia de trabajo, nunca la
fuente. Del mismo modo, tras cada capítulo se le entrega el `main.pdf`
recompilado como archivo (no un enlace a GitHub, que solo muestra el
código fuente sin formato).

## 2026-09-13

Arranque del apartado. Contexto ya fijado en
`ideas-tfm-energias-renovables.md` (Opción A: predicción de generación
renovable + módulo de decisión difuso) y `preparacion/plan-de-entrenamiento.md`
(7 fases desde cero). Este archivo es para todo lo que no encaje
todavía en esos dos, o que sea demasiado crudo para ir directo a la
tesis en `main.tex`.

### Cómo citar (norma real del Departamento, no una convención inventada)

El propio Departamento de Informática y Automática, en su norma de
informes técnicos DPTOIA-IT (el mismo formato que usa `main.tex` —
documento `DPTOIA-IT-2000-001.pdf`, ya en esta carpeta), deja libertad
de estilo de cita **siempre que sea coherente en todo el documento**,
y pone como ejemplos el estilo ACM (numérico) o **Apalike** (autor-año,
más informativo). Se eligió **Apalike** — coincide además con que la
USAL en general sigue normas tipo APA para TFG/TFM.

**Actualización 2026-09-13 (tarde): comparado contra la memoria real de
Arlet** (`Memoria_TFM__Arlet_Acosta_González.pdf`, aprobada por el mismo
departamento) — **no coincidía**. Ella usó el otro ejemplo que da la
norma (cita numérica entre corchetes `[1]`, `[2]`... estilo "ACM"), no
Apalike. Un precedente real ya aprobado pesa más que la suposición de
"la USAL en general usa APA" — se cambió `\bibliographystyle` de
`apalike` a **`unsrt`** (numérico, orden de aparición — coincide con el
orden real de sus referencias, no alfabético como `plain`). Nota: su
lista de referencias tiene DOI/ISSN/fecha de "visitado" con un formato
muy rico que probablemente viene de un gestor tipo Zotero, no de BibTeX
puro — esa parte no se replicó, solo el estilo de cita numérica en el
cuerpo del texto, que es lo que de verdad exige la norma del
departamento.

**Sobre la fuente de esta comparación** — la memoria de Arlet
(`Memoria_TFM__Arlet_Acosta_González.pdf`) **no está en este repo**,
a propósito: `FUENTE.md` de esta misma carpeta la lista en "No copiado,
deliberadamente" porque es su trabajo particular sobre Tor, no material
reutilizable de plantilla. La comparación se hizo leyendo el archivo
directamente de Google Drive en la sesión (fileId
`13nWgUX5QomM-0mXeNyXbM6sIZwy9Dokk`, carpeta "TFM, Arlet Acosta
González"), no de una copia en el repo — si hace falta reverificar esto
en otra sesión, hace falta acceso a Drive, no basta con grepear el
repo.

**Flujo a seguir de aquí en adelante, para no acumular deuda:**
1. Toda fuente nueva (libro, paper, página web, tesis) que se use en
   una lección, en `ideas-tfm-energias-renovables.md` o en `main.tex`
   se añade a `Bibliografia.bib` **en el momento en que se usa**, no
   al final.
2. Antes de añadirla, verificarla (autor/título/año/editorial reales —
   ver la lección de esta sesión: hasta la propia guía docente de la
   USAL tuvo dos citas mal fechadas/editorial, encontradas por un
   agente independiente). No copiar una cita de memoria sin comprobar.
3. En `main.tex`, citar con `\cite{clave}` en el punto exacto del texto
   donde se usa el dato/afirmación — nunca meter la cita solo al final
   en la bibliografía sin un `\cite` en el cuerpo.
4. `\bibliographystyle{unsrt}` ya configurado en `main.tex` — no
   cambiarlo sin motivo, para mantener coherencia en todo el documento
   (la propia norma del departamento lo exige).

Bibliografía ya cargada en `Bibliografia.bib` con las fuentes usadas
hasta ahora en la preparación (Jang/Sun/Mizutani, Haykin, Gulli et al.,
Géron, Hernández/Ramírez/Ferri, Zaki & Meira, Shalev-Shwartz & Ben-David,
Driankov et al., la tesis de Pablo Chamoso, la línea de energía de
BISITE, el paper Grid-Agent, la API de REData, y los dos notebooks de
Géron) — lista para citar con `\cite{}` en cuanto haya texto real que
las use.

**Resuelto (2026-09-13):** `picins.sty` daba "Missing \begin{document}"
al compilar. **Causa real, corregida tras una revisión independiente
del PR:** un único typo de transcripción en la línea 455
(`Llong\def\frameenv` en vez de `\long\def\frameenv` — la "L" suelta se
interpretaba como texto en modo vertical, disparando ese error). Eso
era lo único que hacía falta arreglar. El `\makeatletter`/`\makeatother`
que se añadió a la vez **no era necesario y no hacía nada**: LaTeX ya
activa el catcode de letra para `@` automáticamente mientras procesa un
`\usepackage`/`\RequirePackage` (documentado en `clsguide.pdf`) — los
380 comandos con `@` del archivo (`\@BILD`, `\old@par`...) nunca
estuvieron rotos por eso. Verificado compilando ambas variantes por
separado: quitar el `makeatletter`/`makeatother` y dejar solo el typo
corregido compila igual de limpio; dejar el `makeatletter`/`makeatother`
y no tocar el typo sigue fallando con el mismo error. Se dejó el
`makeatletter`/`makeatother` en el archivo de todas formas (es
inofensivo, y documentar explícitamente el catcode de `@` no hace daño
en un archivo con historial de transcripción a mano), pero que quede
claro aquí para no repetir este diagnóstico equivocado en un futuro
"Missing \begin{document}" de otro archivo legado: la primera sospecha
debería ser una palabra suelta sin barra invertida en modo vertical,
no el catcode de `@`.

De paso, la misma revisión encontró un bug latente ya existente (no
introducido por este PR) en `\endovalenv`: `\advance\d@tmpa
by\p\env@box` usaba la secuencia de control indefinida `\p` en vez del
primitivo real `\dp` (profundidad de una caja) — corregido también,
aunque `\ovalenv`/`\endovalenv` no se usa actualmente en `main.tex`.

Compilado y verificado tras ambas correcciones: `pdflatex main.tex` +
`bibtex main` compilan limpio a PDF de 11 páginas, sin warnings de
`Bibliografia.bib`. Ver PR #111.
