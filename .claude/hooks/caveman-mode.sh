#!/bin/bash
# SessionStart hook: inyecta el ruleset completo de la skill `caveman`
# como contexto en cada sesión (arranque, resume, clear, compact),
# replicando a mano lo que `ponytail` ya hace solo por venir empaquetado
# como plugin con su propio hook -- `caveman` es una skill suelta (`npx
# skills add`, sin plugin ni hook propio, ver
# recursos-generales/herramientas-ia/novedades.md, entrada del
# 2026-08-22 corregida el 2026-08-30) y por tanto nunca se auto-disparaba
# sin este hook: solo se activaba con `/caveman` o su propio trigger de
# lenguaje natural, nunca "para todas las sesiones" pese a decir eso el
# registro original.
#
# Best-effort, no bloqueante: si falta `jq`, o el archivo de la skill no
# existe (symlink roto, repo movido), no pasa nada -- la sesión arranca
# igual, simplemente sin el modo caveman activado automáticamente esa
# vez (mismo fallback que ya existía: `/caveman` a mano sigue funcionando).

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

command -v jq >/dev/null 2>&1 || exit 0

SKILL_FILE=".claude/skills/caveman/SKILL.md"
[ -r "$SKILL_FILE" ] || exit 0

CONTENT="$(cat "$SKILL_FILE" 2>/dev/null)"
[ -n "$CONTENT" ] || exit 0

jq -cn --arg ctx "CAVEMAN MODE ACTIVE

$CONTENT" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
