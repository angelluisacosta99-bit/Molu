# Lluvia de ideas — TFM

Log libre, entrada nueva arriba con fecha. Aquí va todo lo suelto:
ideas, novedades, temas, marco teórico, hallazgos — sin estructura
rígida, antes de que decante en algo formal para `main.tex` o para
`ideas-tfm-energias-renovables.md`.

---

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
al compilar. Causa real: le faltaba `\makeatletter`/`\makeatother`
alrededor de sus 380 comandos con `@` (`\@BILD`, `\old@par`...) —
sin eso, TeX leía `\@BILD` como el primitivo `\@` seguido del texto
literal "BILD", rompiendo el resto del parseo — más un typo de
transcripción en la línea 455 (`Llong\def` en vez de `\long\def`).
Corregido y verificado: `pdflatex main.tex` + `bibtex main` compilan
limpio a PDF de 11 páginas, sin warnings de `Bibliografia.bib`. Ver
PR #111.
