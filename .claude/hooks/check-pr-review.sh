#!/bin/bash
# PreToolUse hook para mcp__github__merge_pull_request. Convierte la
# regla dura de CLAUDE.md ("nunca fusionar sin revisión independiente
# previa") de una instrucción advisory en un bloqueo técnico: exige un
# marcador reciente escrito por mark-pr-reviewed.sh para ese PR exacto.
#
# No verifica la calidad de la revisión ni el SHA en vivo de GitHub
# (este hook no tiene credenciales de GitHub propias) -- solo que el
# paso de "dejar constancia" ocurrió hace poco para este número de PR.
# Eso basta para hacer imposible el olvido, que es el fallo real que
# intenta prevenir (ver recursos-generales/herramientas-ia/novedades.md).

set -euo pipefail

MAX_AGE_SECONDS=3600  # 60 minutos

INPUT=$(cat)
PR_NUMBER=$(jq -r '.tool_input.pullNumber // empty' <<<"$INPUT")

if [ -z "$PR_NUMBER" ]; then
  # No debería pasar para esta herramienta, pero si el campo no viene,
  # no hay nada verificable -- bloquear en vez de asumir que está bien.
  jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: "check-pr-review.sh: no se pudo leer tool_input.pullNumber, bloqueando por seguridad."}}'
  exit 0
fi

DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/.pr-review-state"
MARKER="$DIR/$PR_NUMBER.json"

if [ ! -f "$MARKER" ]; then
  jq -n --arg pr "$PR_NUMBER" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: ("No hay marcador de revisión para el PR #" + $pr + ". Corre una revisión independiente (skill code-review) sobre el estado actual del PR y, si sale limpia, deja constancia con: .claude/hooks/mark-pr-reviewed.sh " + $pr + " <head_sha> \"<resumen>\" -- antes de intentar fusionar de nuevo.")}}'
  exit 0
fi

REVIEWED_AT=$(jq -r '.reviewed_at // empty' "$MARKER")
if [ -z "$REVIEWED_AT" ]; then
  jq -n --arg pr "$PR_NUMBER" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: ("Marcador de revisión del PR #" + $pr + " está corrupto o incompleto. Vuelve a correr la revisión y a escribir el marcador.")}}'
  exit 0
fi

REVIEWED_EPOCH=$(date -u -d "$REVIEWED_AT" +%s 2>/dev/null || echo 0)
NOW_EPOCH=$(date -u +%s)
AGE=$((NOW_EPOCH - REVIEWED_EPOCH))

if [ "$AGE" -gt "$MAX_AGE_SECONDS" ] || [ "$AGE" -lt 0 ]; then
  jq -n --arg pr "$PR_NUMBER" --arg age "$((AGE / 60))" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: ("El marcador de revisión del PR #" + $pr + " tiene " + $age + " minutos -- demasiado viejo (máximo 60). El PR pudo cambiar desde entonces. Vuelve a revisar el estado actual y a escribir el marcador antes de fusionar.")}}'
  exit 0
fi

# Marcador válido y reciente: permitir la fusión.
exit 0
