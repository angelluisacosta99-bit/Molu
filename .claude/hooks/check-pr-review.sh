#!/bin/bash
# PreToolUse hook para mcp__github__merge_pull_request y
# mcp__github__enable_pr_auto_merge. Convierte la regla dura de
# CLAUDE.md ("nunca fusionar sin revisión independiente previa") de una
# instrucción advisory en un bloqueo técnico: exige un marcador
# reciente Y con el SHA correcto (verificado en vivo contra la API de
# GitHub) para ese PR exacto.
#
# Diseño fail-closed a propósito: NO usa `set -e` (un error a mitad de
# script bajo set -e sale con un exit code que Claude Code trata como
# "sin decisión" -> permite la herramienta, justo lo contrario de lo
# que debe hacer un gate de seguridad). deny() no depende de jq (usa
# printf a mano) para que un jq roto o ausente no impida denegar.
# Cualquier fallo de red/API al verificar el SHA también deniega.
#
# Cobertura conocida y limitada: solo intercepta esas dos llamadas MCP.
# No cubre `gh pr merge` por Bash -- ver la nota en CLAUDE.md.

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
if ! command -v curl >/dev/null 2>&1; then
  deny "check-pr-review.sh: curl no está disponible en este entorno, no se puede verificar el PR en vivo -- bloqueando por seguridad (fail-closed)."
fi

INPUT=$(cat) || deny "check-pr-review.sh: no se pudo leer el input del hook (fail-closed)."

PR_NUMBER=$(jq -r '.tool_input.pullNumber // empty' <<<"$INPUT" 2>/dev/null)
OWNER=$(jq -r '.tool_input.owner // empty' <<<"$INPUT" 2>/dev/null)
REPO=$(jq -r '.tool_input.repo // empty' <<<"$INPUT" 2>/dev/null)

# Validación estricta: pullNumber debe ser un entero simple, no una
# cadena arbitraria -- se usa para construir una ruta de archivo y una
# URL de API, y no queremos que un valor raro (o ../../ intentando
# escapar el directorio) llegue más lejos.
if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
  deny "check-pr-review.sh: tool_input.pullNumber ausente o no es un entero válido -- bloqueando por seguridad (fail-closed)."
fi
if ! [[ "$OWNER" =~ ^[A-Za-z0-9._-]+$ ]] || ! [[ "$REPO" =~ ^[A-Za-z0-9._-]+$ ]]; then
  deny "check-pr-review.sh: tool_input.owner/repo ausentes o con formato inesperado -- bloqueando por seguridad (fail-closed)."
fi

DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/.pr-review-state"
MARKER="$DIR/$PR_NUMBER.json"

if [ ! -f "$MARKER" ]; then
  deny "No hay marcador de revisión para el PR #$PR_NUMBER. Corre una revisión independiente (skill code-review) sobre el estado actual del PR y, si sale limpia, deja constancia con: .claude/hooks/mark-pr-reviewed.sh $PR_NUMBER <head_sha> \"<resumen>\" -- antes de intentar fusionar de nuevo."
fi

REVIEWED_AT=$(jq -r '.reviewed_at // empty' "$MARKER" 2>/dev/null)
REVIEWED_SHA=$(jq -r '.head_sha // empty' "$MARKER" 2>/dev/null)
if [ -z "$REVIEWED_AT" ] || [ -z "$REVIEWED_SHA" ]; then
  deny "Marcador de revisión del PR #$PR_NUMBER está corrupto, incompleto, o no es JSON válido -- bloqueando por seguridad (fail-closed). Vuelve a correr la revisión y a escribir el marcador."
fi

# Formato estricto AAAA-MM-DDTHH:MM:SSZ (el que escribe mark-pr-reviewed.sh
# con `date -u +%Y-%m-%dT%H:%M:%SZ`). `date -d` por sí solo acepta texto
# suelto tipo "now" o "5 minutes ago" -- sin este filtro, un marcador
# corrupto con ese tipo de valor pasaría como "reciente" sin serlo.
if ! [[ "$REVIEWED_AT" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]; then
  deny "Marcador de revisión del PR #$PR_NUMBER tiene reviewed_at con formato inesperado (\"$REVIEWED_AT\") -- bloqueando por seguridad (fail-closed)."
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

# Verificación en vivo: ¿el PR sigue en el mismo SHA que se revisó?
# Si hubo commits nuevos después de la revisión, el marcador ya no
# vale para el estado actual, aunque sea reciente.
TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
if [ -z "$TOKEN" ]; then
  deny "check-pr-review.sh: no hay GITHUB_TOKEN/GH_TOKEN en el entorno para verificar el PR en vivo -- bloqueando por seguridad (fail-closed)."
fi

API_RESPONSE=$(curl -sS --max-time 15 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER" 2>/dev/null)
CURL_EXIT=$?

if [ "$CURL_EXIT" -ne 0 ] || [ -z "$API_RESPONSE" ]; then
  deny "check-pr-review.sh: no se pudo consultar el estado en vivo del PR #$PR_NUMBER en GitHub (curl exit $CURL_EXIT) -- bloqueando por seguridad (fail-closed) en vez de asumir que no cambió."
fi

LIVE_SHA=$(jq -r '.head.sha // empty' <<<"$API_RESPONSE" 2>/dev/null)
if [ -z "$LIVE_SHA" ]; then
  deny "check-pr-review.sh: la respuesta de la API de GitHub para el PR #$PR_NUMBER no trae head.sha (¿error de la API, rate limit, o PR inexistente?) -- bloqueando por seguridad (fail-closed)."
fi

if [ "$LIVE_SHA" != "$REVIEWED_SHA" ]; then
  deny "El PR #$PR_NUMBER cambió desde la revisión: se revisó el commit $REVIEWED_SHA pero el HEAD actual es $LIVE_SHA. Vuelve a revisar el estado actual y a escribir el marcador antes de fusionar."
fi

# Marcador válido, reciente, y con el SHA correcto: permitir la fusión.
allow
