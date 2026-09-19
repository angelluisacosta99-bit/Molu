#!/bin/bash
# PreToolUse hook para Write/Edit, pero solo actúa sobre el subagente
# cavecrew-reviewer (agents/cavecrew-reviewer.md, nativo y su espejo en
# plugins/caveman-cavecrew/agents/).
#
# Motivo: verificado en vivo (2026-09-19) que este entorno de Claude
# Code NO concede automáticamente Read/Write/Edit al activar
# `memory: project` en el frontmatter de un subagente, pese a que la
# documentación oficial de subagentes lo describe así ("Read, Write,
# and Edit tools are automatically enabled") -- un subagente de prueba
# con memory: project confirmó "Write or Edit tool available: NO". Para
# que la memoria persistente de cavecrew-reviewer funcione de verdad en
# este entorno hace falta darle Write/Edit explícito en `tools:` --
# pero cavecrew-reviewer se autodescribe "solo lectura, sin comandos
# que mutan" (mismo motivo que ya tiene restrict-cavecrew-bash.sh para
# Bash), así que un Write/Edit sin acotar sería justo la clase de scope
# creep que este repo evita en otros hooks -- este acota esa concesión
# a escribir SOLO dentro de su propio directorio de memoria
# (.claude/agent-memory/cavecrew-reviewer/), nada más.
#
# A diferencia de restrict-cavecrew-bash.sh (que solo AÑADE una
# restricción sobre un permiso de Bash que ya existía sin acotar antes
# del hook, así que fallar abierto solo vuelve al estado previo al
# hook), este hook es la ÚNICA razón por la que Write/Edit es seguro de
# conceder a cavecrew-reviewer en el frontmatter -- fallar abierto aquí
# cuando SÍ se puede identificar que es cavecrew-reviewer intentando
# escribir fuera de su carpeta sería un regreso real de seguridad
# (revisor "de solo lectura" editando cualquier archivo del repo en
# silencio). Por eso la rama "es cavecrew-reviewer pero no se puede
# verificar la ruta" deniega (fail-closed), igual que
# check-pr-review.sh para su propio gate -- pero la rama "no se puede
# ni determinar si es cavecrew-reviewer" (jq ausente, entrada
# ilegible) sí falla abierto, igual que el resto de hooks best-effort
# de este repo: no hay forma de distinguir esa llamada de una del hilo
# principal o de otro subagente sin jq, y bloquear TODO Write/Edit del
# repo entero cada vez que jq falte sería un daño mucho mayor que el
# riesgo que este hook cierra -- jq ya es una dependencia dura de otros
# tres hooks de este repo (restrict-cavecrew-bash.sh,
# check-pr-review.sh, mark-permission-scan.sh), así que si faltara, el
# entorno ya estaría degradado de formas peores que esta.

allow() { exit 0; }
deny() {
  jq -cn --arg reason "$1" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
  exit 0
}

command -v jq >/dev/null 2>&1 || allow
command -v realpath >/dev/null 2>&1 || allow

INPUT=$(cat) || allow

AGENT_TYPE=$(jq -r '.agent_type // empty' <<<"$INPUT" 2>/dev/null)
[ "$AGENT_TYPE" = "cavecrew-reviewer" ] || allow

# A partir de aquí SÍ sabemos que es cavecrew-reviewer -- cualquier
# fallo de verificación a partir de este punto deniega, no permite.
FILE_PATH=$(jq -r '.tool_input.file_path // empty' <<<"$INPUT" 2>/dev/null)
if [ -z "$FILE_PATH" ]; then
  deny "cavecrew-reviewer: Write/Edit sin tool_input.file_path -- no se puede verificar que caiga dentro de su carpeta de memoria, denegado por defecto."
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
TARGET_DIR="$(realpath -m -- "$PROJECT_DIR/.claude/agent-memory/cavecrew-reviewer")" || \
  deny "cavecrew-reviewer: no se pudo resolver su directorio de memoria -- denegado por defecto."
RESOLVED_PATH="$(realpath -m -- "$FILE_PATH")" || \
  deny "cavecrew-reviewer: no se pudo resolver la ruta destino '$FILE_PATH' -- denegado por defecto."

case "$RESOLVED_PATH" in
  "$TARGET_DIR"/*)
    allow
    ;;
  *)
    deny "cavecrew-reviewer es de solo lectura fuera de su propia memoria -- Write/Edit solo permitido dentro de $TARGET_DIR/, ruta pedida: $RESOLVED_PATH"
    ;;
esac
