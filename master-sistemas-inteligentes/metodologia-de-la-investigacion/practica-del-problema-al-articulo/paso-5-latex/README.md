# Paso 5 — Artículo en LaTeX (plantilla LNCS)

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

Comprobado al compilar: sin referencias `??`, sin citas indefinidas, y cada
tabla y figura citada en el texto antes de aparecer.
