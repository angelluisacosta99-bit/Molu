# Capítulos preparados, todavía sin publicar

Esta carpeta existe por una razón muy concreta: **los PDF que el profesor adjunta al chat
viven solo en esa sesión**. Se guardan en `/root/.claude/uploads/<sesión>/` y desaparecen
con ella. Todo lo demás del repositorio (la skill, la plantilla, `CLAUDE.md`, los ajustes de
permisos, las transcripciones ya archivadas) se hereda solo al abrir una sesión nueva,
porque se clona el repositorio — pero el libro, no.

Así que cuando un capítulo se va a hacer **en otra sesión**, aquí se deja todo lo que hace
falta para construirlo sin volver a pedirle nada al profesor:

- El **texto de la página**, transcrito mirándola (no copiado del OCR).
- Las **respuestas del solucionario oficial**, con la página de la que salen.
- La **transcripción del audio**, si el capítulo tiene alguno.
- Los **dibujos** que haya que incrustar, ya recortados.
- La **página entera** en imagen, para poder comprobar la transcripción.

## Diferencia con `fuentes/nuevo-espanol-en-marcha/`

No son lo mismo y no se confunden:

| | `pendientes/` | `nuevo-espanol-en-marcha/` |
| --- | --- | --- |
| Qué es | material de partida para un capítulo **por hacer** | archivo de un capítulo **ya publicado y verificado** |
| Cómo se escribe | a mano, transcribiendo la página | lo genera `extraer.mjs` del artefacto publicado |
| Fiabilidad | hay que verificarlo contra la página al usarlo | es exactamente lo que se verificó que funciona |

Cuando el capítulo se publica, se genera su archivo de verdad con `extraer.mjs` y **se borra
la carpeta correspondiente de `pendientes/`**. Si se queda, la próxima vez habrá dos
versiones del mismo capítulo y no se sabrá cuál manda.

## Lo que hay ahora

Nada pendiente: la carpeta está vacía. La 5B del cuaderno de B1 («Las otras medicinas»,
página 21) era el último capítulo preparado aquí y ya está publicada y archivada en
`nuevo-espanol-en-marcha/b1/cuaderno-unidad5b_las-otras-medicinas.md`.
