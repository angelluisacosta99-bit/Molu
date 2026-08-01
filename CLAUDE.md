# Instrucciones para Claude en este repositorio

## Flujo de trabajo obligatorio para Pull Requests

Cada vez que se abra un Pull Request en este repositorio, seguir siempre
estos tres pasos, en este orden:

1. **Abrir el PR** con una descripción clara de los cambios.
2. **Lanzar una revisión con un agente independiente** (por ejemplo, la
   skill `review`) antes de fusionar.
3. **Fusionar (merge) el PR**, salvo que la revisión detecte problemas
   bloqueantes — en ese caso, corregirlos primero y repetir el ciclo.

No omitir la revisión aunque el cambio parezca trivial (por ejemplo,
cambios solo de documentación).

**Regla dura, sin excepciones:** nunca hacer `merge` de un PR sin haber
completado antes una revisión con un agente independiente. Si por
cualquier motivo la revisión no se pudo lanzar o no terminó, el PR no se
fusiona hasta que exista esa revisión.

## Diseño visual: usar siempre la skill `impeccable`

Cuando la tarea implique diseñar, rediseñar, criticar, auditar o pulir
una **interfaz frontend** (sitios web, landing pages, dashboards, UI de
producto, componentes, formularios, pantallas de onboarding, etc.),
usar siempre la skill `impeccable` (`.claude/skills/impeccable/`), en
lugar de hacer el trabajo de diseño "a mano".

Nota de alcance: `impeccable` es para interfaces frontend, no genera ni
edita documentos de Word ni presentaciones de PowerPoint. Para esos
formatos usar las skills `docx` y `pptx` respectivamente.
