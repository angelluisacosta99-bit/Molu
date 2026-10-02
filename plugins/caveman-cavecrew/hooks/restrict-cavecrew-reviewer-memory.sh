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

INPUT=$(cat) || allow

AGENT_TYPE=$(jq -r '.agent_type // empty' <<<"$INPUT" 2>/dev/null)
[ "$AGENT_TYPE" = "cavecrew-reviewer" ] || allow

# A partir de aquí SÍ sabemos que es cavecrew-reviewer -- cualquier
# fallo de verificación a partir de este punto deniega, no permite.
#
# realpath se comprueba AQUÍ, no junto a jq más arriba: jq hace falta
# para IDENTIFICAR al agente (sin él no se distingue esta llamada de
# una del hilo principal, de ahí su fail-open documentado arriba),
# pero realpath solo hace falta para VERIFICAR LA RUTA de un agente ya
# identificado -- es decir, cae exactamente en la rama que la cabecera
# define como fail-closed. Comprobarlo antes del agent_type lo dejaba
# fallando abierto, devolviendo a cavecrew-reviewer el Write/Edit sin
# acotar sobre todo el repo que este hook existe para cerrar.
command -v realpath >/dev/null 2>&1 || \
  deny "cavecrew-reviewer: falta realpath, no se puede verificar que la ruta caiga dentro de su carpeta de memoria -- denegado por defecto."

FILE_PATH=$(jq -r '.tool_input.file_path // empty' <<<"$INPUT" 2>/dev/null)
if [ -z "$FILE_PATH" ]; then
  deny "cavecrew-reviewer: Write/Edit sin tool_input.file_path -- no se puede verificar que caiga dentro de su carpeta de memoria, denegado por defecto."
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
TARGET_DIR="$(realpath -m -- "$PROJECT_DIR/.claude/agent-memory/cavecrew-reviewer")" || \
  deny "cavecrew-reviewer: no se pudo resolver su directorio de memoria -- denegado por defecto."

# FILE_PATH puede llegar relativa (el Write/Edit tool no la fuerza a
# absoluta en todos los casos) -- si se resuelve con realpath contra el
# $PWD real de este hook en vez de anclarla a $PROJECT_DIR (igual que
# TARGET_DIR arriba), diverge en cuanto el hook se invoque desde un
# directorio de trabajo distinto de $CLAUDE_PROJECT_DIR (un worktree,
# un cambio de cwd del harness) -- verificado en vivo como un falso
# "denegado" real en ese caso, encontrado por revisión externa antes de
# fusionar. Anclar explícitamente a $PROJECT_DIR cuando no es absoluta,
# nunca dejarlo en el $PWD implícito de realpath.
case "$FILE_PATH" in
  /*) ;;
  *) FILE_PATH="$PROJECT_DIR/$FILE_PATH" ;;
esac
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
