#!/bin/bash
# SessionStart hook: inyecta el ruleset completo de la skill `caveman`
# como contexto en el arranque principal de sesión (matcher `startup`
# de SessionStart), imitando el mecanismo que `ponytail` usa vía su
# propio hook de plugin -- `caveman` es una skill suelta (`npx skills
# add`, sin plugin ni hook propio, ver
# recursos-generales/herramientas-ia/novedades.md, entrada del
# 2026-08-22 corregida el 2026-08-30) y por tanto nunca se auto-disparaba
# sin este hook: solo se activaba con `/caveman` o su propio trigger de
# lenguaje natural, nunca "para todas las sesiones" pese a decir eso el
# registro original.
#
# Alcance más estrecho que `ponytail` a propósito: `ponytail` también
# se dispara en `SubagentStart` (verificado en vivo por una revisión de
# este mismo PR), este hook solo cubre `SessionStart` -- un subagente
# lanzado a mitad de sesión no hereda el modo caveman. Documentado como
# límite aceptado en vez de reclamar una paridad que no existe.
#
# Best-effort, no bloqueante: si falta `jq`, o el archivo de la skill no
# existe (symlink roto, repo movido), no pasa nada -- la sesión arranca
# igual, simplemente sin el modo caveman activado automáticamente esa
# vez (mismo fallback que ya existía: `/caveman` a mano sigue funcionando).

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

command -v jq >/dev/null 2>&1 || exit 0

SKILL_FILE=".claude/skills/caveman/SKILL.md"
[ -r "$SKILL_FILE" ] || exit 0

# `timeout` aquí porque `.claude/skills/caveman` es un symlink -- si
# algún día apuntara a algo que bloquea la lectura (montaje de red
# colgado, FIFO), este hook corre en CADA arranque/resume/clear/compact
# de sesión, así que un cuelgue aquí sin acotar bloquearía la sesión
# entera indefinidamente, justo lo que el resto del script evita a
# propósito (ver hook-hardening, punto 2).
CONTENT="$(timeout 5 cat "$SKILL_FILE" 2>/dev/null)"
[ -n "$CONTENT" ] || exit 0

jq -cn --arg ctx "CAVEMAN MODE ACTIVE

$CONTENT" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
