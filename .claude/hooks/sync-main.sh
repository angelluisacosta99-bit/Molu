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

if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  echo "[session-start] rama $BEHIND commits por detrás de origin/main, pero hay cambios sin comitear -- no se actualiza sola para no tocar ese trabajo; si hace falta, comitear/guardar y luego 'git merge origin/main' a mano"
  exit 0
fi

if git merge --ff-only origin/main >/dev/null 2>&1; then
  echo "[session-start] rama puesta al día con origin/main automáticamente ($BEHIND commits, fast-forward limpio -- sin commits propios que pudieran perderse)"
else
  AHEAD="$(git rev-list --count origin/main..HEAD 2>/dev/null)"
  echo "[session-start] rama $BEHIND commits por detrás de origin/main y con ${AHEAD:-?} commits propios -- no se actualiza sola (evita fusionar sin revisar); si notas algo desactualizado (una skill, un hook), 'git merge origin/main' a mano"
fi
