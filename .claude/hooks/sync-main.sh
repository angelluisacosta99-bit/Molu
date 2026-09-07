#!/bin/bash
# SessionStart hook, SOLO en arranque real (matcher "startup" en
# .claude/settings.json -- nunca resume/clear/compact): trae origin/main
# automáticamente cuando es seguro hacerlo, para que una rama base vieja
# no se quede atrás sin funciones ya fusionadas sin que nadie lo note.
#
# Motivo real: la sesión "Nivel B2" arrancó desde un commit anterior a
# que `.claude/hooks/caveman-mode.sh` existiera siquiera -- `/caveman` no
# funcionaba ahí, y nada lo avisó hasta que Angel preguntó por qué. Este
# hook detecta y corrige ese caso (o al menos avisa) en el arranque, en
# vez de dejar que se descubra por sorpresa sesiones después.
#
# Por qué SOLO "startup": un merge a mitad de una tarea (resume/clear/
# compact) tocaría el árbol de trabajo bajo los pies de una sesión con
# cambios sin comitear -- justo el efecto secundario que hook-hardening
# (punto 7) pide evitar. En un arranque real todavía no hay nada propio
# que perder.
#
# Best-effort, jamás bloquea el arranque: sin red, sin remoto, árbol
# sucio, o rama con commits propios que divergen de main -> informa (o
# ni eso) y sigue, nunca falla la sesión.

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

if ! timeout 15 git fetch origin main >/dev/null 2>&1; then
  echo "[session-start] no se pudo comprobar origin/main (red o remoto no disponible) -- rama sin cambiar"
  exit 0
fi

BEHIND="$(git rev-list --count HEAD..origin/main 2>/dev/null)"
[ -n "$BEHIND" ] || exit 0
[ "$BEHIND" -gt 0 ] || exit 0

# `git merge --ff-only` ya protege por sí solo, sin ayuda de este script,
# cualquier cambio local sin comitear en un archivo TRACKEADO -- verificado
# en vivo: aborta limpio ("Your local changes... would be overwritten by
# merge"), exit != 0, contenido local intacto. Lo único que NO protege es
# un archivo local SIN TRACKEAR (incluido uno ignorado por .gitignore) que
# coincide con una ruta que origin/main empieza a trackear -- ahí el
# fast-forward lo sobrescribe en silencio, sin conflicto, exit 0
# (verificado en vivo destruyendo un "secreto local" de prueba). Por eso
# la única comprobación propia que hace falta aquí es esa colisión de
# rutas, no un chequeo genérico de "árbol sucio" -- uno genérico
# (`git status --porcelain --ignored` a secas) bloquea el auto-heal casi
# siempre en este repo en concreto, porque `graphify`/`check-pr-review.sh`
# dejan artefactos ignorados de forma rutinaria (cache, marcadores de
# revisión) que no tienen nada que ver con lo que va a cambiar.
CHANGED_PATHS="$(git diff --name-only HEAD..origin/main 2>/dev/null)"
if [ -n "$CHANGED_PATHS" ]; then
  LOCAL_STRAY="$(git status --porcelain --ignored=matching 2>/dev/null | grep -E '^(\?\?|!!) ' | cut -c4-)"
  if [ -n "$LOCAL_STRAY" ] && printf '%s\n' "$CHANGED_PATHS" | grep -qFxf <(printf '%s\n' "$LOCAL_STRAY"); then
    echo "[session-start] rama $BEHIND commits por detrás de origin/main, pero hay un archivo local sin trackear (posiblemente ignorado por .gitignore) en una ruta que origin/main también toca -- no se actualiza sola para no sobrescribirlo en silencio; si hace falta, mover/comitear ese archivo y luego 'git merge origin/main' a mano"
    exit 0
  fi
fi

if git merge --ff-only origin/main >/dev/null 2>&1; then
  echo "[session-start] rama puesta al día con origin/main automáticamente ($BEHIND commits, fast-forward limpio)"
else
  echo "[session-start] rama $BEHIND commits por detrás de origin/main -- no se pudo actualizar sola (commits propios que divergen, o cambios locales sin comitear en archivos que origin/main también modifica; git lo rechazó limpio sin perder nada); si notas algo desactualizado (una skill, un hook), 'git merge origin/main' a mano"
fi
