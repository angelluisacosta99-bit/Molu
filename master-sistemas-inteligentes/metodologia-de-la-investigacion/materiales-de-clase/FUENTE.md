# Materiales de clase — Metodología de la Investigación (2026-2027)

Enviados por Angel el 2026-09-28 (material que facilita la prof. Vivian
López Batista en Studium).

- `presentacion-asignatura-2026-2027.pdf` — presentación de la asignatura:
  temario, fechas (entrega obligatoria 30-nov-2026) y trabajo final
  (artículo LNCS en LaTeX + póster).
- `ejemplos/articulo-operadores-logicos-espejo.pdf` — Espejo, Hervás,
  Ventura y Romero (Univ. Córdoba), *Elección de operadores lógicos para
  la inducción de conocimiento comprensible*, Revista Iberoamericana de
  Inteligencia Artificial. Es el artículo del que sale el ejemplo de
  hipótesis de la diapositiva 69 de "Técnicas de Investigación". Modelo
  útil: hipótesis comparativa y sin cifras en la Introducción, contraste
  con ANOVA + Bonferroni/Tamhane (α = 0,05), y la hipótesis **no se
  cumple** y aun así se publica.
- `ejemplos/poster-correlated-events-cordon.pdf` — póster de un alumno de
  la USAL (inglés, 4 columnas, plantilla tipo Gemini).
- `ejemplos/poster-prospectos-caballero.pdf` — póster de un alumno de la
  USAL (español, 3 columnas, colores USAL).
- `fuentes-de-informacion-en-ciencia-y-tecnologia.pdf` (enviado el
  2026-09-30, 23 págs., texto de 2003 con enlaces antiguos) — teoría:
  obras de referencia directas/indirectas y 15 tipos de fuentes. Útil
  para el artículo: las normas UIT-T que citemos (p. ej. G.652) son
  «fuentes técnicas» y el TFG es «literatura gris» (fuentes inéditas).
- `redaccion-y-citas/` (enviados el 2026-09-30):
  - `10-consejos-articulo-terrible-blocken-2017.pdf` — Bert Blocken
    (Elsevier, 2017), lo que NO hay que hacer: no leer la literatura,
    plagiar, omitir partes (estado del arte, hueco, novedad, método,
    resultados, conclusiones), despreciar trabajos previos, sobrevalorar
    la aportación, ambigüedad/terminología inconsistente, afirmaciones sin
    referencia, adjetivos subjetivos en vez de cifras, descuidar
    ortografía/figuras/tablas, ignorar a los revisores.
  - `escritura-estructurada-cameron.pdf` — Rob Cameron: escribir con un
    esquema en árbol (título → secciones → subsecciones → párrafos) con
    una extensión asignada a cada parte ANTES de redactar; luego rellenar
    cada bloque por separado. Encaja con el Paso 4.
  - `iso-690-documentos-impresos.pdf` e `iso-690-2-documentos-electronicos.pdf`
    — guías de la norma ISO 690 / 690-2 para referencias bibliográficas
    (formato APELLIDO, Nombre. Título...). La plantilla LNCS usa su propio
    estilo (`splncs.bst`, numérico [1]), que es el que pidió la profesora
    para el artículo (2026-09-30).
  - `como-elaborar-referencias-une-50-104.pdf` y
    `como-elaborar-referencias-iso-690-sevilla.pdf` — otras dos guías de
    la misma norma (UNE 50-104 = ISO 690, adaptación de la Univ. de
    Sevilla). Mismo contenido que las anteriores, con más ejemplos.
  - `quindos-2009-factor-impacto-indice-h.pdf` — Quindós, G. (2009), Rev.
    Iberoam. Micol. 26(2): factor de impacto, índice h y «valor Q». Idea
    clave: el factor de impacto sirve para comparar revistas de un mismo
    área, no para valorar a un investigador. Útil para justificar la
    calidad de las revistas elegidas en el Paso 2.
- `poster/el-poster-guardiola-2002.pdf` (enviado el 2026-09-30) — Elena
  Guardiola, guía para hacer un póster de congreso. Pautas para el Paso 5:
  título ≥ 36 pt en negrita, autores/apartados ≥ 30 pt, subapartados
  ≥ 24 pt, texto ≥ 20 pt sin negrita; tipografía sencilla (Arial/Helvetica,
  no Times), como mucho dos tipos; nada solo en mayúsculas; ≥ 50 % de
  superficie para figuras y tablas; columnas; cada tabla/figura con pie;
  cifras coherentes con el texto; «un póster no es un artículo en letra
  grande»; legible a 1-2 m.

- `latex/` (enviados el 2026-09-30; no estaban ni en el repo ni en el
  Drive de Arlet) — manuales de LaTeX en español para el Paso 5:
  - `introduccion-a-latex-lopez-batista.pdf` — **diapositivas de la propia
    profesora** (70 págs., 2013): estructura de un `.tex`, formato, listas,
    figuras (`figure` con `[htbp]`, subfiguras), tablas (`tabular`),
    referencias cruzadas (`\label`/`\ref`/`\pageref`, la forma de citar
    tablas y figuras antes de que aparezcan), ecuaciones y BibTeX
    (`\bibliographystyle` + `\bibliography` + `\cite`, compilar
    LaTeX → BibTeX → LaTeX ×2). Partes anticuadas: instalar MiKTeX/
    TeXnicCenter e `inputenc[latin1]`; en Overleaf no hace falta instalar
    nada y se usa UTF-8.
  - `ejemplos-latex-profesora/` (enviado el 2026-09-30 como `Ej_Latex.zip`,
    de 2015; no estaba ni en el repo ni en el Drive de Arlet) — los 5
    ejercicios de clase: `Ejercicio1.tex` tipos y tamaños de letra,
    `verbatim`; `Ejercicio2.tex` fórmulas en línea y centradas, nota al pie;
    `Ejercicio3.tex` listas, tablas `tabular`, cajas; `Ejercicio4.tex`
    figuras flotantes (`tiger.pdf`), matrices, `eqnarray` con `\label`;
    `Ejercicio5.tex` libro con título, índice, capítulos, ecuaciones y
    bibliografía con `thebibliography`. Se omiten `.DS_Store` y
    `__MACOSX/` del zip. Algunos acentos de los ejercicios 2-4 vienen
    dañados en el original.
  - `introduccion-a-latex-randez-2013.pdf` — Luis Rández (Univ. Zaragoza),
    40 págs.: la más corta para empezar (fórmulas, tablas, figuras).
  - `bibliografia-en-latex-bibtex-mata-2014.pdf` — Miguel Mata, 14 págs.:
    `thebibliography` y BibTeX (`\cite`, `\bibliography`, estilos).
  - `una-descripcion-de-latex2e-oetiker.pdf` — traducción de *The Not So
    Short Introduction to LaTeX2e* (Oetiker et al., v0.4b, 1998), 86 págs.
  - `manual-latex-mora-borbon-2005.pdf` — Mora y Borbón (TEC Costa Rica),
    57 págs. Es el mismo archivo que trae `Plantilla_IT_05022007.rar`.

Enviados también el 2026-09-30 y **no copiados aquí** porque ya estaban en
`../../trabajo-fin-de-master/`: `DPTOIA-IT-2000-001.pdf` (idéntico, byte a
byte) y `Plantilla_IT_05022007.rar` (versión de 2007 de la plantilla de
informe técnico; en el TFM ya está la de 2021). Tampoco
`Plantilla_Tesis_05022007.rar`: es la plantilla LaTeX de **tesis
doctoral** de la USAL (2007, clase `book`), no se usa en el máster.

No copiados (demasiado grandes o ya extraídos en la sesión):
`Arquitectura_de_la_Investigacion_Cientifica.pdf` (26 MB, práctica por
días) y `Tecnicas_Investigacion23_24.pdf` (10 MB, teoría).

Revisados de nuevo el 2026-10-03 (Angel los volvió a enviar junto con
`1cr-1r-2r.pdf` = `ejemplos/articulo-operadores-logicos-espejo.pdf`,
`Presen_metodologico_ampliado26_27.pptx.pdf` =
`presentacion-asignatura-2026-2027.pdf` y `llncs2e.zip` = `../practica-del-problema-al-articulo/plantilla-lncs/`,
los tres idénticos a lo ya guardado):
- **Arquitectura…** (21 diapositivas, «Bootcamp intensivo»): los
  enunciados de los Pasos 1-5, ya copiados literalmente en
  `../practica-del-problema-al-articulo/enunciados-studium.md`, más
  diapositivas-imagen. Lo que añade: el Día 5 incluye «maquetación en
  LaTeX **y póster científico**» (póster con plantilla LaTeX dedicada);
  regla de oro del Día 2: «nunca escribas una referencia a mano,
  automatiza el flujo» (Scopus/WoS → gestor → .bib); Día 3: el
  experimento debe ser reproducible y refutable (pruebas estadísticas);
  Día 4: «asigna un límite de palabras a cada bloque antes de redactar».
- **Técnicas de Investigación** (82 diapositivas): teoría general del
  método científico, marco teórico, hipótesis (diap. 67-69) y
  comunicación; el informe debe indicar si la hipótesis se comprueba o
  no (diap. 80). Ningún requisito de formato nuevo.

## Plantillas de póster (enviadas el 2026-10-03)

`poster/plantillas-poster-clase.rar` — `Posters.rar`, las «5 plantillas
suministradas» del trabajo final (contiene `poster1.rar` … `poster5.rar`).
Revisadas:

1. **CIT** (`04/CITposter.tex`, `scrartcl`, Caltech, sgeier.net): cajas
   simples, fondo verde-azulado, 30×31 cm. Ejemplo «Big posters directly in LaTeX».
2. **IRF** (`07/irfPosterExample.tex`, `a0poster` apaisado, Swedish Institute
   of Space Physics): cabecera azul con logo, fondo azul oscuro, cajas
   blancas; con `references.bib`. La más vistosa de las cinco.
3. **EHU** (`ehu/poster-florence.tex`, `a0poster` vertical): sobria, cajas
   azules, mucha fórmula.
4. **Granada** (`granada/poster.tex`, `article` 42×30 cm): escudo de la UGR,
   cajas de color crema; aspecto académico clásico.
5. **RUM** (`rum/Template_Posters_RUM/Cesar_poster.tex`, `a0poster`, Univ. de
   Puerto Rico Mayagüez): título rojo, 3 columnas, logos; el `RUM_ESPANOL/`
   adjunto es una plantilla de **tesis**, no de póster.

Las cinco son de los años 2000 (`a0poster`/`scrartcl`, compilación DVI → PS,
figuras EPS). Además: `poster-correlated-events-cordon.pdf` y
`poster-prospectos-caballero.pdf` (ejemplos de alumnos) y la guía de
Guardiola, ya en `ejemplos/` y `poster/`.
