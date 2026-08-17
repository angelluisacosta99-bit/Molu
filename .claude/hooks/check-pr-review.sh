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
# "sin decisión" -> permite la herramienta). deny() usa `jq` para
# construir el JSON de salida (escapa comillas, backslashes Y
# caracteres de control como saltos de línea correctamente -- un
# escapado a mano con sed/printf se dejaba los de control, y un
# marcador manipulado con un salto de línea en head_sha producía JSON
# de salida inválido, que cae en el mismo "sin decisión -> permite" de
# arriba). jq ya está confirmado disponible en todo punto donde deny()
# recibe texto no controlado por este script (el único deny() antes de
# esa comprobación es el propio "jq no disponible", con mensaje fijo,
# sin datos externos). Cualquier fallo de red/API al verificar el SHA
# también deniega.
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
#
# Límite estructural sin arreglo posible desde este hook: entre que este
# script consulta el SHA en vivo y devuelve "allow", y que la llamada
# merge_pull_request de verdad se ejecuta, hay una ventana -- si alguien
# empuja un commit nuevo justo en ese hueco, se fusiona sin revisar.
# mcp__github__merge_pull_request no expone un parámetro de SHA esperado
# (confirmado en su esquema: solo owner/repo/pullNumber/merge_method/
# commit_title/commit_message) para que GitHub rechace la fusión si el
# HEAD cambió desde la comprobación, y un hook PreToolUse no puede
# reescribir los argumentos de la llamada que autoriza, solo permitir o
# denegar. Riesgo bajo en la práctica (requiere un push adversario justo
# en ese instante), pero real -- documentado en vez de reclamar una
# garantía que este diseño no puede dar.

MAX_AGE_SECONDS=3600  # 60 minutos

deny() {
  # $1 = razón, en texto plano (puede contener cualquier cosa si viene
  # de un campo de marcador no fiable). jq -n --arg lo escapa entero y
  # correctamente, incluidos saltos de línea y otros caracteres de
  # control, a diferencia de un escapado a mano con sed.
  if command -v jq >/dev/null 2>&1; then
    jq -cn --arg reason "$1" \
      '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
  else
    # Solo se llega aquí para el deny() de "jq no disponible" (mensaje
    # fijo, sin datos externos interpolados) -- el escapado a mano es
    # seguro en ese único caso porque el texto lo controlamos nosotros.
    local reason_escaped
    reason_escaped=$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason_escaped"
  fi
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

# Una sola invocación de jq (un solo open()+parse del archivo) para leer
# ambos campos, en vez de dos llamadas separadas -- evita una lectura
# "rota" si mark-pr-reviewed.sh reescribe el marcador justo a mitad de
# la lectura. @tsv escapa tabs/saltos de línea dentro de cada campo, así
# que dividir por el tab real entre campos es seguro.
IFS=$'\t' read -r REVIEWED_AT REVIEWED_SHA < <(jq -r '[.reviewed_at // "", .head_sha // ""] | @tsv' "$MARKER" 2>/dev/null)
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

# El token va por -K - (config leída de stdin, no -H en argv, para que
# no quede expuesto vía /proc/<pid>/cmdline mientras curl corre) -- pero
# ese formato de config usa `"` para delimitar valores y `\n` para
# separar directivas, así que un token con esos caracteres podría
# inyectar una directiva nueva (ej. una segunda URL que reenvíe la
# cabecera Authorization real a un host distinto). Los tokens de GitHub
# reales no llevan comillas, saltos de línea ni espacios, así que
# valida el charset antes de interpolarlo -- si no cumple, no se
# interpola nunca en el config.
if ! [[ "$TOKEN" =~ ^[A-Za-z0-9._~+/=:-]+$ ]]; then
  deny "check-pr-review.sh: GITHUB_TOKEN/GH_TOKEN tiene un formato inesperado (caracteres fuera de lo típico de un token de GitHub) -- bloqueando por seguridad (fail-closed) para evitar inyección en la config de curl."
fi
API_RESPONSE=$(curl -sS --max-time 15 -K - <<CURLCFG 2>/dev/null
url = "https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER"
header = "Authorization: Bearer $TOKEN"
header = "Accept: application/vnd.github+json"
CURLCFG
)
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
