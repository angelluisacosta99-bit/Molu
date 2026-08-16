#!/bin/bash
# PreToolUse hook para mcp__github__merge_pull_request. Convierte la
# regla dura de CLAUDE.md ("nunca fusionar sin revisión independiente
# previa") de una instrucción advisory en un bloqueo técnico: exige un
# marcador reciente escrito por mark-pr-reviewed.sh para ese PR exacto.
#
# Diseño fail-closed a propósito: NO usa `set -e` (un error a mitad de
# script bajo set -e sale con un exit code que Claude Code trata como
# "sin decisión" -> permite la herramienta, justo lo contrario de lo
# que debe hacer un gate de seguridad). deny() no depende de jq (usa
# printf a mano) para que un jq roto o ausente no impida denegar.
#
# Cobertura conocida y limitada: solo intercepta la llamada MCP
# mcp__github__merge_pull_request. No cubre mcp__github__enable_pr_auto_merge
# ni `gh pr merge` por Bash -- ver la nota en CLAUDE.md y en
# recursos-generales/herramientas-ia/novedades.md.

MAX_AGE_SECONDS=3600  # 60 minutos

deny() {
  # $1 = razón, en texto plano. Escapado a mano (comillas y backslashes)
  # para no depender de jq -- este es el único camino que debe funcionar
  # siempre, pase lo que pase con el resto del script.
  local reason_escaped
  reason_escaped=$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason_escaped"
  exit 0
}

allow() {
  exit 0
}

if ! command -v jq >/dev/null 2>&1; then
  deny "check-pr-review.sh: jq no está disponible en este entorno, bloqueando por seguridad (fail-closed). Instala jq o corre la fusión desde una sesión donde esté disponible."
fi

INPUT=$(cat) || deny "check-pr-review.sh: no se pudo leer el input del hook (fail-closed)."

PR_NUMBER=$(jq -r '.tool_input.pullNumber // empty' <<<"$INPUT" 2>/dev/null)
if [ -z "$PR_NUMBER" ]; then
  deny "check-pr-review.sh: no se pudo leer tool_input.pullNumber del input del hook (JSON inválido o campo ausente) -- bloqueando por seguridad (fail-closed)."
fi

DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/.pr-review-state"
MARKER="$DIR/$PR_NUMBER.json"

if [ ! -f "$MARKER" ]; then
  deny "No hay marcador de revisión para el PR #$PR_NUMBER. Corre una revisión independiente (skill code-review) sobre el estado actual del PR y, si sale limpia, deja constancia con: .claude/hooks/mark-pr-reviewed.sh $PR_NUMBER <head_sha> \"<resumen>\" -- antes de intentar fusionar de nuevo."
fi

REVIEWED_AT=$(jq -r '.reviewed_at // empty' "$MARKER" 2>/dev/null)
if [ -z "$REVIEWED_AT" ]; then
  deny "Marcador de revisión del PR #$PR_NUMBER está corrupto, incompleto, o no es JSON válido -- bloqueando por seguridad (fail-closed). Vuelve a correr la revisión y a escribir el marcador."
fi

REVIEWED_EPOCH=$(date -u -d "$REVIEWED_AT" +%s 2>/dev/null)
if [ -z "$REVIEWED_EPOCH" ]; then
  deny "Marcador de revisión del PR #$PR_NUMBER tiene una fecha ilegible (\"$REVIEWED_AT\") -- bloqueando por seguridad (fail-closed). Vuelve a correr la revisión y a escribir el marcador."
fi

NOW_EPOCH=$(date -u +%s)
AGE=$((NOW_EPOCH - REVIEWED_EPOCH))

if [ "$AGE" -gt "$MAX_AGE_SECONDS" ] || [ "$AGE" -lt 0 ]; then
  deny "El marcador de revisión del PR #$PR_NUMBER tiene $((AGE / 60)) minutos -- demasiado viejo (máximo 60) o con fecha futura. El PR pudo cambiar desde entonces. Vuelve a revisar el estado actual y a escribir el marcador antes de fusionar."
fi

# Marcador válido y reciente: permitir la fusión.
allow
