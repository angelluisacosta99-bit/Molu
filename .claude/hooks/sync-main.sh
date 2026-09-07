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
# `-z` en ambos lados, siempre: `git status`/`git diff --name-only` sin
# `-z` citan (comillas + escapes estilo C) cualquier ruta con espacio o
# carácter no-ASCII, y los dos comandos no citan igual -- verificado en
# vivo que sin `-z` una ruta real ("mi secreto.txt") sale citada de un
# lado y sin citar del otro, así que la comparación de cadena exacta
# nunca coincide y una colisión real pasa desapercibida. `-z` desactiva
# el citado en ambos, dejando la ruta tal cual.
#
# `git status --porcelain`, incluso con `--ignored=matching`, colapsa un
# directorio entero a una sola línea cuando el propio patrón de
# `.gitignore` apunta al directorio (no a los archivos de dentro) --
# verificado en vivo contra los propios directorios ignorados de este
# repo (`.claude/.pr-review-state/`, `graphify-out/cache/`): sale la
# línea del directorio, nunca los archivos de dentro, así que una
# colisión con un archivo *dentro* de esos directorios no se detectaría.
# `git ls-files --others --exclude-standard` (sin trackear) y `--ignored
# --exclude-standard` (ignorados) sí expanden cada archivo
# individualmente sin colapsar directorios -- verificado en vivo.
CHANGED_PATHS="$(git diff --name-only -z HEAD..origin/main 2>/dev/null | tr '\0' '\n')"
if [ -n "$CHANGED_PATHS" ]; then
  LOCAL_STRAY="$( { git ls-files --others --exclude-standard -z; git ls-files --others --ignored --exclude-standard -z; } 2>/dev/null | tr '\0' '\n')"
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
