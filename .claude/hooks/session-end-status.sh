#!/bin/bash
# "Radical transparency": muestra el estado de git al terminar el turno,
# para no depender de acordarse de correr `git status` a mano. Práctica
# tomada de awattar/claude-code-best-practices (ver
# recursos-generales/herramientas-ia/novedades.md).
#
# Best-effort: cualquier fallo aquí no debe romper el turno.

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
command -v git >/dev/null 2>&1 || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

STATUS=$(git status --short 2>/dev/null)
if [ -n "$STATUS" ]; then
  echo "[git status: $(pwd)] Cambios sin commitear:"
  echo "$STATUS"
fi

exit 0
