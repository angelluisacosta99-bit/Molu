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

DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/.pr-review-state"
mkdir -p "$DIR"

OWNER_LOWER=$(printf '%s' "$OWNER" | tr '[:upper:]' '[:lower:]')
REPO_LOWER=$(printf '%s' "$REPO" | tr '[:upper:]' '[:lower:]')

jq -n \
  --arg owner "$OWNER" \
  --arg repo "$REPO" \
  --arg pr "$PR_NUMBER" \
  --arg sha "$HEAD_SHA" \
  --arg summary "$SUMMARY" \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{owner: $owner, repo: $repo, pr_number: $pr, head_sha: $sha, summary: $summary, reviewed_at: $ts}' \
  > "$DIR/${OWNER_LOWER}__${REPO_LOWER}__${PR_NUMBER}.json"

echo "Marcador escrito: $OWNER/$REPO#$PR_NUMBER revisado en $HEAD_SHA ($SUMMARY)"
