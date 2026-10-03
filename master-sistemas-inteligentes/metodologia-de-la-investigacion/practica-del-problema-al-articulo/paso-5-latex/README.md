# Paso 5 — Artículo en LaTeX (plantilla LNCS)

## Enunciado (Studium, publicado el 2026-10-01)

Apertura: viernes 2 de octubre de 2026, 12:00 · Cierre: **viernes 9 de octubre de 2026, 23:00**.

- **Objetivo:** integrar el contenido en las plataformas de edición técnica científica.
- **Tarea:** importar el texto a **Overleaf** con la plantilla **LNCS** e incluir los comandos de LaTeX para:
  - estructura de secciones (`\section{}`, `\subsection{}`);
  - ecuaciones y fórmulas numeradas (`\begin{equation}`);
  - figuras con `\includegraphics` y tablas;
  - citas cruzadas (`\label{}`, `\ref{}`) y bibliografía automatizada (`\cite{}`, `\bibliography{}`).

El enunciado no menciona el póster ni el formato de entrega (PDF, `.tex` o enlace de Overleaf).

`articulo/` es el proyecto LaTeX completo, listo para subir a Overleaf
(*New Project → Upload Project* con el zip de la carpeta) o compilar en local
con `latexmk -pdf main.tex`:

| Archivo | Qué es |
|---|---|
| `main.tex` | Artículo: clase `llncs`, `babel` en español, citas `\cite`, referencias cruzadas `\ref` |
| `llncs.cls`, `splncs.bst` | Plantilla LNCS v2.14 dada en clase (`../plantilla-lncs/`) |
| `referencias.bib` | Bibliografía (las 11 obras de `../paso-2-bibliografia/referencias.bib`, con los campos limpios) |
| `figuras/` | Figuras del Paso 3 en PDF vectorial |
| `main.pdf` | Resultado compilado |

`main.tex` se genera con `python generar_tex.py` a partir del texto del borrador
(`../paso-4-redaccion/contenido.py`), para que borrador y artículo no se
desincronicen. Si se edita `main.tex` directamente en Overleaf, ese pasa a ser
el original y no hay que volver a ejecutar el script.

**Guía explicada** para Angel (no se entrega): `guia-paso-5.pdf`, qué hace cada parte de `main.tex`
(se regenera desde el `.html` con Chromium).

Comprobado al compilar: sin referencias `??`, sin citas indefinidas, y cada
tabla y figura citada en el texto antes de aparecer.
