#!/bin/bash
# Deja constancia de que una revisión independiente (skill code-review)
# terminó limpia para un PR concreto, justo antes de fusionarlo. La
# consume el hook PreToolUse check-pr-review.sh, que bloquea
# mcp__github__merge_pull_request si no encuentra un marcador reciente.
#
# Uso: mark-pr-reviewed.sh <pr_number> <head_sha> <resumen corto>
# Ej:  mark-pr-reviewed.sh 65 a1b2c3d "limpia, sin hallazgos"

set -euo pipefail

PR_NUMBER="${1:?falta el número de PR}"
HEAD_SHA="${2:?falta el head SHA revisado}"
SUMMARY="${3:-revisión completada}"

DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/.pr-review-state"
mkdir -p "$DIR"

jq -n \
  --arg pr "$PR_NUMBER" \
  --arg sha "$HEAD_SHA" \
  --arg summary "$SUMMARY" \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{pr_number: $pr, head_sha: $sha, summary: $summary, reviewed_at: $ts}' \
  > "$DIR/$PR_NUMBER.json"

echo "Marcador escrito: PR #$PR_NUMBER revisado en $HEAD_SHA ($SUMMARY)"
