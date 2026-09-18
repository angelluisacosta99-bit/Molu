#!/bin/bash
# Deja constancia de cuándo se corrió por última vez la skill
# fewer-permission-prompts, para que fewer-permission-prompts-reminder.sh
# (hook SessionStart) sepa si hace falta recordarlo de nuevo. Mismo
# patrón de escritura atómica (mktemp + mv en el mismo filesystem) que
# ya usa mark-pr-reviewed.sh para su propio marcador.
#
# Uso: mark-permission-scan.sh [resumen corto]
# Ej:  mark-permission-scan.sh "4 patrones nuevos añadidos"

set -euo pipefail

SUMMARY="${1:-sin cambios}"

DIR="${CLAUDE_PROJECT_DIR:-.}/.claude"
mkdir -p "$DIR"
MARKER="$DIR/.fewer-permission-prompts-last-run.json"

TMP="$(mktemp "$DIR/.tmp.fewer-permission-prompts.XXXXXX")"
trap 'rm -f "$TMP"' EXIT
jq -n \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg summary "$SUMMARY" \
  '{last_run: $ts, summary: $summary}' \
  > "$TMP"
mv -f "$TMP" "$MARKER"

echo "Marcador escrito: fewer-permission-prompts corrida el $(date -u +%Y-%m-%dT%H:%M:%SZ) ($SUMMARY)"
