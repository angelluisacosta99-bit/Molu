# Instrucciones para Claude en este repositorio

## Flujo de trabajo obligatorio para Pull Requests

**Abrir un PR no dispara nada más automáticamente.** Se puede abrir un
Pull Request con su descripción y dejarlo ahí, esperando, sin gastar una
revisión todavía — sobre todo si va a seguir cambiando o el profesor
todavía no ha pedido fusionarlo. Esto es así para no gastar tokens en
revisiones de PRs que pueden cambiar antes de fusionarse.

Los otros dos pasos van juntos y **solo se ejecutan cuando el profesor
pide explícitamente fusionar/mergear un PR concreto** (o cuando así lo
indique una tarea autónoma que el profesor haya autorizado de antemano
para ese fin). En ese momento, y en ese orden:

1. **Lanzar una revisión con un agente independiente** (por ejemplo, la
   skill `review`), justo antes de fusionar — no una revisión antigua
   lanzada al abrir el PR, sino una que verifique el estado actual del
   PR (puede haber cambiado desde que se abrió).
2. **Fusionar (merge) el PR**, salvo que la revisión detecte problemas
   bloqueantes — en ese caso, corregirlos primero y repetir el ciclo
   (nueva revisión, luego fusión).

No omitir la revisión aunque el cambio parezca trivial (por ejemplo,
cambios solo de documentación), y no omitirla aunque ya exista una
revisión de una versión anterior del PR.

**Regla dura, sin excepciones:** nunca hacer `merge` de un PR sin haber
completado antes una revisión con un agente independiente sobre su
estado actual. Si por cualquier motivo la revisión no se pudo lanzar o
no terminó, el PR no se fusiona hasta que exista esa revisión. Y nunca
lanzar la revisión (ni fusionar) solo por haber abierto el PR — hace
falta que el profesor pida fusionar primero.

## Diseño visual: usar siempre la skill `impeccable`

Cuando la tarea implique diseñar, rediseñar, criticar, auditar o pulir
una **interfaz frontend** (sitios web, landing pages, dashboards, UI de
producto, componentes, formularios, pantallas de onboarding, etc.),
usar siempre la skill `impeccable` (`.claude/skills/impeccable/`), en
lugar de hacer el trabajo de diseño "a mano".

Nota de alcance: `impeccable` es para interfaces frontend, no genera ni
edita documentos de Word ni presentaciones de PowerPoint. Para esos
formatos usar las skills `docx` y `pptx` respectivamente.

## Materiales de referencia para clases de español

Al crear tareas, ejercicios, presentaciones o cualquier material nuevo
para las clases de español, basarse en el contenido real que el usuario
ya usa con sus alumnos, disponible en esta carpeta de Google Drive:

<https://drive.google.com/drive/folders/1YM1M17tG5C4kxEWIK6Dh-BoSdqR0CcZv>

Contiene tres subcarpetas. Orden de prioridad de uso (de más a menos
frecuente):

1. **Nuevo Español en Marcha** — libro de texto principal, el que más
   se usa.
2. **ПК Гонсалес** ("полный курс" González, es decir, el curso completo
   de González) — segundo material más usado.
3. **Temas** — recursos adicionales organizados por tema.

Antes de generar un ejercicio, tarea o presentación nueva, consultar el
contenido de estas carpetas (vía el conector de Google Drive) para
mantener consistencia con la progresión, el vocabulario y la
metodología que el alumno ya conoce, en vez de crear contenido genérico
desde cero.

## Nombre del profesor: sin tilde

El nombre del usuario/profesor es **Angel Luis Acosta González**.
"Angel" en este contexto **no lleva tilde** (no es "Ángel"). Al
escribir su nombre en cualquier material, documento, commit, código o
respuesta, usar siempre "Angel" sin acento.

## Presentaciones (.pptx): sin firma final

En la diapositiva de cierre de cualquier presentación, no añadir una
firma del tipo "— Angel Luis Acosta González, tu profesor de español".
El pie de página con el nombre del autor (ej. "© Angel Luis Acosta
González" o "Material elaborado por...") sí puede mantenerse, pero no
esa línea de firma personalizada al final del mensaje de cierre.
