#!/bin/bash
# PreToolUse hook para mcp__github__merge_pull_request y
# mcp__github__enable_pr_auto_merge. Convierte la regla dura de
# CLAUDE.md ("nunca fusionar sin revisión independiente previa") de una
# instrucción advisory en un bloqueo técnico: exige un marcador
# reciente Y con el SHA correcto (verificado en vivo contra la API de
# GitHub) para ese owner/repo/PR exacto.
#
# Diseño fail-closed a propósito: NO usa `set -e` (un error a mitad de
# script bajo set -e sale con un exit code que Claude Code trata como
# "sin decisión" -> permite la herramienta). deny() no depende de jq
# (usa printf a mano) para que un jq roto o ausente no impida denegar.
# Cualquier fallo de red/API al verificar el SHA también deniega.
#
# enable_pr_auto_merge se deniega SIEMPRE, sin excepción: ese comando
# no fusiona en el momento, solo programa que GitHub fusione más tarde
# cuando pasen los checks -- en el commit que sea HEAD en ese momento
# futuro, no en el que se revisó ahora. Este hook no tiene forma de
# interceptar ese evento posterior, así que "proteger" auto-merge con
# el mismo marcador sería una falsa sensación de seguridad, peor que no
# cubrirlo. Usar merge_pull_request directo tras revisar, no auto-merge.
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

TOOL_NAME=$(jq -r '.tool_name // empty' <<<"$INPUT" 2>/dev/null)
if [ "$TOOL_NAME" = "mcp__github__enable_pr_auto_merge" ]; then
  deny "enable_pr_auto_merge no está soportado por este gate: GitHub fusiona más tarde, de forma asíncrona, en el commit que sea HEAD en ese momento futuro -- este hook no puede verificar ese SHA todavía. Corre la revisión y usa merge_pull_request directamente después, no auto-merge."
fi

PR_NUMBER=$(jq -r '.tool_input.pullNumber // empty' <<<"$INPUT" 2>/dev/null)
OWNER=$(jq -r '.tool_input.owner // empty' <<<"$INPUT" 2>/dev/null)
REPO=$(jq -r '.tool_input.repo // empty' <<<"$INPUT" 2>/dev/null)

# Validación estricta: pullNumber debe ser un entero simple y owner/repo
# nombres razonables -- se usan para construir una ruta de archivo y una
# URL de API, y no queremos que un valor raro (../../ intentando escapar
# el directorio, o caracteres de URL) llegue más lejos.
if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
  deny "check-pr-review.sh: tool_input.pullNumber ausente o no es un entero válido -- bloqueando por seguridad (fail-closed)."
fi
if ! [[ "$OWNER" =~ ^[A-Za-z0-9._-]+$ ]] || ! [[ "$REPO" =~ ^[A-Za-z0-9._-]+$ ]]; then
  deny "check-pr-review.sh: tool_input.owner/repo ausentes o con formato inesperado -- bloqueando por seguridad (fail-closed)."
fi

# El marcador se identifica por owner/repo/PR, no solo por número de PR:
# los SHA de git son portables entre repos (son direcciones de
# contenido), así que un marcador solo-por-número permitiría reusar la
# revisión de un repo para fusionar un PR con el mismo número en otro
# repo distinto si alguien reproduce el mismo commit ahí.
DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/.pr-review-state"
OWNER_LOWER=$(printf '%s' "$OWNER" | tr '[:upper:]' '[:lower:]')
REPO_LOWER=$(printf '%s' "$REPO" | tr '[:upper:]' '[:lower:]')
MARKER="$DIR/${OWNER_LOWER}__${REPO_LOWER}__${PR_NUMBER}.json"

if [ ! -f "$MARKER" ]; then
  deny "No hay marcador de revisión para $OWNER/$REPO#$PR_NUMBER. Corre una revisión independiente (skill code-review) sobre el estado actual del PR y, si sale limpia, deja constancia con: .claude/hooks/mark-pr-reviewed.sh $OWNER $REPO $PR_NUMBER <head_sha> \"<resumen>\" -- antes de intentar fusionar de nuevo."
fi

REVIEWED_AT=$(jq -r '.reviewed_at // empty' "$MARKER" 2>/dev/null)
REVIEWED_SHA=$(jq -r '.head_sha // empty' "$MARKER" 2>/dev/null)
if [ -z "$REVIEWED_AT" ] || [ -z "$REVIEWED_SHA" ]; then
  deny "Marcador de revisión de $OWNER/$REPO#$PR_NUMBER está corrupto, incompleto, o no es JSON válido -- bloqueando por seguridad (fail-closed). Vuelve a correr la revisión y a escribir el marcador."
fi
# No confiar en que head_sha ya viene validado por mark-pr-reviewed.sh
# -- este script es el gate de seguridad real, así que valida su propio
# input igual de estricto, por si el marcador se escribió por otra vía
# (a mano, por un bug, etc.). Sin esto, un SHA corto/basura que por
# casualidad sea prefijo del SHA real pasaría la comparación.
if ! [[ "$REVIEWED_SHA" =~ ^[0-9a-fA-F]{7,40}$ ]]; then
  deny "Marcador de revisión de $OWNER/$REPO#$PR_NUMBER tiene head_sha con formato inválido (\"$REVIEWED_SHA\") -- bloqueando por seguridad (fail-closed)."
fi
REVIEWED_SHA_LOWER=$(printf '%s' "$REVIEWED_SHA" | tr '[:upper:]' '[:lower:]')

# Formato estricto AAAA-MM-DDTHH:MM:SSZ (el que escribe mark-pr-reviewed.sh
# con `date -u +%Y-%m-%dT%H:%M:%SZ`). `date -d` por sí solo acepta texto
# suelto tipo "now" o "5 minutes ago" -- sin este filtro, un marcador
# corrupto con ese tipo de valor pasaría como "reciente" sin serlo.
if ! [[ "$REVIEWED_AT" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]; then
  deny "Marcador de revisión de $OWNER/$REPO#$PR_NUMBER tiene reviewed_at con formato inesperado (\"$REVIEWED_AT\") -- bloqueando por seguridad (fail-closed)."
fi

REVIEWED_EPOCH=$(date -u -d "$REVIEWED_AT" +%s 2>/dev/null)
if [ -z "$REVIEWED_EPOCH" ]; then
  deny "Marcador de revisión de $OWNER/$REPO#$PR_NUMBER tiene una fecha ilegible (\"$REVIEWED_AT\") -- bloqueando por seguridad (fail-closed). Vuelve a correr la revisión y a escribir el marcador."
fi

NOW_EPOCH=$(date -u +%s)
AGE=$((NOW_EPOCH - REVIEWED_EPOCH))

if [ "$AGE" -gt "$MAX_AGE_SECONDS" ] || [ "$AGE" -lt 0 ]; then
  deny "El marcador de revisión de $OWNER/$REPO#$PR_NUMBER tiene $((AGE / 60)) minutos -- demasiado viejo (máximo 60) o con fecha futura. El PR pudo cambiar desde entonces. Vuelve a revisar el estado actual y a escribir el marcador antes de fusionar."
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
  deny "check-pr-review.sh: no se pudo consultar el estado en vivo de $OWNER/$REPO#$PR_NUMBER en GitHub (curl exit $CURL_EXIT) -- bloqueando por seguridad (fail-closed) en vez de asumir que no cambió."
fi

LIVE_SHA=$(jq -r '.head.sha // empty' <<<"$API_RESPONSE" 2>/dev/null)
if [ -z "$LIVE_SHA" ]; then
  deny "check-pr-review.sh: la respuesta de la API de GitHub para $OWNER/$REPO#$PR_NUMBER no trae head.sha (¿error de la API, rate limit, o PR inexistente?) -- bloqueando por seguridad (fail-closed)."
fi
LIVE_SHA_LOWER=$(printf '%s' "$LIVE_SHA" | tr '[:upper:]' '[:lower:]')

# Comparación por prefijo (insensible a mayúsculas): el marcador puede
# traer un SHA corto (mark-pr-reviewed.sh acepta 7-40 hex), y el SHA
# real de GitHub siempre viene completo en minúsculas.
if [[ "$LIVE_SHA_LOWER" != "$REVIEWED_SHA_LOWER"* ]]; then
  deny "$OWNER/$REPO#$PR_NUMBER cambió desde la revisión: se revisó el commit $REVIEWED_SHA pero el HEAD actual es $LIVE_SHA. Vuelve a revisar el estado actual y a escribir el marcador antes de fusionar."
fi

# Marcador válido, reciente, para el repo correcto, y con el SHA
# correcto: permitir la fusión.
allow
