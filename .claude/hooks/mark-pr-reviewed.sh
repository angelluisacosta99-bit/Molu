#!/bin/bash
# Deja constancia de que una revisión independiente (skill code-review)
# terminó limpia para un PR concreto, justo antes de fusionarlo. La
# consume el hook PreToolUse check-pr-review.sh, que bloquea
# mcp__github__merge_pull_request si no encuentra un marcador reciente,
# con el SHA correcto, para el mismo owner/repo/PR.
#
# Uso: mark-pr-reviewed.sh <owner> <repo> <pr_number> <head_sha> <resumen corto>
# Ej:  mark-pr-reviewed.sh angelluisacosta99-bit molu 65 a1b2c3d4e5f6... "limpia, sin hallazgos"

set -euo pipefail

OWNER="${1:?falta el owner del repo}"
REPO="${2:?falta el nombre del repo}"
PR_NUMBER="${3:?falta el número de PR}"
HEAD_SHA="${4:?falta el head SHA revisado}"
SUMMARY="${5:-revisión completada}"

if ! [[ "$OWNER" =~ ^[A-Za-z0-9._-]+$ ]] || ! [[ "$REPO" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "mark-pr-reviewed.sh: <owner>/<repo> tienen formato inesperado (recibido: $OWNER/$REPO)" >&2
  exit 1
fi
if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
  echo "mark-pr-reviewed.sh: <pr_number> debe ser un entero (recibido: $PR_NUMBER)" >&2
  exit 1
fi
if ! [[ "$HEAD_SHA" =~ ^[0-9a-fA-F]{7,40}$ ]]; then
  echo "mark-pr-reviewed.sh: <head_sha> no parece un SHA de git válido (recibido: $HEAD_SHA)" >&2
  exit 1
fi

# Este script NO es un hook registrado en .claude/settings.json: lo
# invoca la sesión por el Bash tool, y ahí CLAUDE_PROJECT_DIR no está
# definida (solo la reciben los procesos de hook). Con el antiguo
# "${CLAUDE_PROJECT_DIR:-.}" el marcador se escribía relativo al cwd de
# la llamada, así que invocarlo desde una subcarpeta lo dejaba donde
# check-pr-review.sh -- que sí es hook y sí recibe la variable -- nunca
# lo buscaría: el merge quedaba bloqueado sin explicación. git rev-parse
# resuelve la raíz desde cualquier cwd dentro del repo y no depende del
# harness. Ver el punto 4 de .claude/skills/hook-hardening/SKILL.md.
ROOT="${CLAUDE_PROJECT_DIR:-}"
if [ -z "$ROOT" ]; then
  ROOT="$(timeout 15 git rev-parse --show-toplevel 2>/dev/null)" || ROOT=""
fi
[ -n "$ROOT" ] || ROOT="."

DIR="$ROOT/.claude/.pr-review-state"
mkdir -p "$DIR"

OWNER_LOWER=$(printf '%s' "$OWNER" | tr '[:upper:]' '[:lower:]')
REPO_LOWER=$(printf '%s' "$REPO" | tr '[:upper:]' '[:lower:]')
MARKER="$DIR/${OWNER_LOWER}__${REPO_LOWER}__${PR_NUMBER}.json"

# Escribe en un archivo temporal en el mismo directorio y luego lo mueve
# (mv dentro del mismo filesystem es atómico): así check-pr-review.sh
# nunca puede leer un archivo a medio escribir (truncado, con 0 bytes o
# contenido parcial) si ambos scripts llegan a solaparse en el tiempo.
TMP="$(mktemp "$DIR/.tmp.${OWNER_LOWER}__${REPO_LOWER}__${PR_NUMBER}.XXXXXX")"
trap 'rm -f "$TMP"' EXIT
jq -n \
  --arg owner "$OWNER" \
  --arg repo "$REPO" \
  --arg pr "$PR_NUMBER" \
  --arg sha "$HEAD_SHA" \
  --arg summary "$SUMMARY" \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{owner: $owner, repo: $repo, pr_number: $pr, head_sha: $sha, summary: $summary, reviewed_at: $ts}' \
  > "$TMP"
mv -f "$TMP" "$MARKER"

echo "Marcador escrito: $OWNER/$REPO#$PR_NUMBER revisado en $HEAD_SHA ($SUMMARY)"
