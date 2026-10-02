# Cómo quiere la profesora el LaTeX, y qué haremos en el Paso 5

Resumen de sus diapositivas `../materiales-de-clase/latex/introduccion-a-latex-lopez-batista.pdf`
(70 págs., revisadas completas el 2026-09-30). **Regla:** se sigue lo que ella
enseña; solo se cambia algo cuando es anticuado o menos eficiente, y aquí se
explica por qué y qué se usa en su lugar.

**Modelo de artículo:** la profesora indica que `plantilla-lncs/typeinst.pdf`
(con su fuente `typeinst.tex`) es el ejemplo por el que guiarse. El artículo
del Paso 5 parte de `typeinst.tex` como esqueleto: misma estructura
(`\title`, `\author`, `\institute`, resumen, `\keywords`, secciones, figuras,
tabla, bibliografía) con nuestro contenido. Ejercicios de clase de apoyo en
`../materiales-de-clase/latex/ejemplos-latex-profesora/`.

## Lo que se sigue tal cual

| Qué enseña ella | Diapositivas | Cómo lo aplicaremos |
|---|---|---|
| Estructura: preámbulo (clase + paquetes) → `\begin{document}` … `\end{document}` | 24-28, 33-38 | Igual, con la clase `llncs` de la plantilla que ella dio |
| `\title`, `\author`, `\maketitle` | 28, 42-43 | Igual (en LNCS además `\institute` y `\keywords`) |
| Secciones `\section`, `\subsection` | 42, 44 | Igual (LNCS no usa `\chapter`) |
| Listas `itemize`, `enumerate`, `description` | 54-56 | Igual |
| Figuras: entorno `figure` con `[htbp]`, `\centering`, `\includegraphics`, `\caption`, `\label` | 57-58 | Igual, con nuestras figuras en PDF vectorial (`figuras/*.pdf`) |
| Tablas con `tabular` | 60 | Igual; la tabla ya generada `tabla_resultados.tex` se inserta con `\input` (diap. 40) |
| Referencias cruzadas `\label` / `\ref` / `\pageref` | 61-62 | **Obligatorio**: cada tabla y figura se cita con `\ref` en el texto *antes* de aparecer (regla de la profesora) |
| Bibliografía con BibTeX: `\bibliographystyle` + `\bibliography` + `\cite` | 66-68 | Igual, con `referencias.bib` del Paso 2 y el estilo numérico [1] de la plantilla (`splncs`), confirmado por ella |
| Guiones: `-` palabra compuesta, `--` rangos (págs. 1--12), `---` raya | 53 | Igual (también en el `.bib`) |
| Idioma español con `babel` | 38, 69 | Igual: `\usepackage[spanish,es-tabla]{babel}` (ver nota 3) |
| Comentarios con `%` y caracteres especiales `\# \$ \% \& \_ \{ \}` | 47 | Igual (ojo: el `%` de «30 %» se escribe `30~\%`) |

## Lo que se cambia, por qué y por qué no afecta a lo que pide

1. **Instalar MiKTeX + Ghostscript + GSview + TeXnicCenter (diap. 14-23) → Overleaf.**
   Por qué: son 4 programas, configuración de idiomas y paquetes, y horas de
   instalación; Overleaf es LaTeX en el navegador, sin instalar nada, con el
   mismo compilador. Ella misma lo sugiere en la diapositiva 13:
   «En la página www.writelatex.com podemos comenzar a escribir documentos
   LaTeX sin necesidad de instalar ningún programa» — WriteLaTeX es el nombre
   antiguo de Overleaf. Y la práctica pide explícitamente Overleaf en el Paso 5.

2. **Compilar LaTeX ×3 → BibTeX ×2 → LaTeX ×3 → dvips → PostScript (diap. 29-32) → pdfLaTeX automático.**
   Por qué: la ruta DVI/PostScript es de los años 90 y no admite figuras PNG ni
   PDF (solo EPS). Overleaf usa pdfLaTeX y repite solo las pasadas de LaTeX y
   BibTeX que hagan falta al pulsar *Recompile*. El resultado es el mismo
   (las referencias y citas se resuelven), directamente en PDF.

3. **`\usepackage[latin1]{inputenc}` y acentos con `\'a`, `\~n` (diap. 38-40) → UTF-8, acentos escritos tal cual.**
   Por qué: desde 2018 LaTeX lee UTF-8 por defecto y Overleaf guarda en UTF-8;
   poner `latin1` hoy estropea las tildes. Escribir `canción` en vez de
   `canci\'on` evita errores y se lee mejor. Además `babel` en español llama
   «Cuadro» a las tablas por defecto; la opción `es-tabla` hace que ponga
   «Tabla», que es lo que usamos en el texto.

4. **`epsfig` y figuras `.eps` (diap. 36, 57) → `graphicx` con PDF.**
   Por qué: `epsfig` está obsoleto; `graphicx` es el que ella usa en la
   diapositiva 38 y el que trae la plantilla LNCS. Nuestras figuras ya están en
   PDF vectorial (se ven nítidas a cualquier tamaño).

5. **`\bf`, `\it`, `\rm` (diap. 39, 49-50) → `\textbf{}`, `\textit{}` / `\emph{}`.**
   Ella da las dos formas; las antiguas (`\bf`) están desaconsejadas porque no
   se combinan bien (negrita + cursiva). Usaremos las nuevas, que también
   aparecen en sus diapositivas.

6. **`eqnarray` (diap. 65) → `align` del paquete `amsmath`** (solo si ponemos
   ecuaciones, por ejemplo la del factor Q o la de McNemar).
   Por qué: `eqnarray` deja espacios incorrectos alrededor del `=` y está
   desaconsejado en las guías de LaTeX actuales; `align` se escribe igual.

7. **Subfiguras con `\subfigure` (diap. 59) → paquete `subcaption`**, solo si
   hiciera falta juntar figuras. `subfigure` está retirado. Con 3 figuras
   sueltas no lo necesitamos.

8. **Estilo `plain` del ejemplo de bibliografía (diap. 68) → `splncs` de la plantilla.**
   No es un cambio de criterio: la profesora confirmó el estilo numérico [1] de
   LNCS para el artículo.

9. **Corrección ortográfica copiando diccionarios `.aff`/`.dic` a TeXnicCenter
   (diap. 69) → corrector de Overleaf** en *Menu → Spell check → Spanish*.

## Detalles que hay que vigilar

- `\label` siempre **después** de `\caption`; si va antes, `\ref` da un número
  equivocado.
- La plantilla que dio es `llncs` **v2.14 (2004)** con `splncs.bst`. Funciona
  en Overleaf. Springer tiene una versión nueva (`splncs04`); **se usa la de la
  profesora** salvo que ella diga otra cosa (pregunta pendiente).
- La tabla generada (`tabla_resultados.tex`) usa `\toprule`/`\midrule`/`\bottomrule`,
  que necesitan `\usepackage{booktabs}`; es el estilo recomendado para
  artículos (líneas solo arriba, bajo la cabecera y abajo). Si ella prefiere
  el estilo de su diapositiva 60 (`\hline`), se cambian 3 líneas.
- Cada figura/tabla: primero la frase «… como muestra la Tabla~\ref{tab:resultados}»,
  después el entorno. El `~` evita que «Tabla» y el número queden en líneas
  distintas.
