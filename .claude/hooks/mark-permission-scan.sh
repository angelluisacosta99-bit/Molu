#!/bin/bash
# Deja constancia de cuándo se corrió por última vez la skill
# fewer-permission-prompts, para que fewer-permission-prompts-reminder.sh
# (hook SessionStart) sepa si hace falta recordarlo de nuevo. Mismo
# patrón de escritura atómica (mktemp + mv en el mismo filesystem) que
# ya usa mark-pr-reviewed.sh para su propio marcador.
#
# A diferencia de la primera versión de este script, este SÍ comitea y
# sube el marcador él mismo (git add + commit + push, solo ese
# archivo) en vez de dejar ese paso como una instrucción aparte que la
# sesión tenía que recordar seguir -- una revisión encontró que, en el
# caso más común (sin patrones nuevos que añadir), esa instrucción se
# saltaba con facilidad y el marcador se quedaba solo en el disco local
# del contenedor, perdiéndose al reciclarse y dejando el recordatorio
# disparándose en cada sesión sin avanzar nunca. Determinista > confiar
# en que el modelo no se salte un paso.
#
# A propósito NO crea una rama+PR nueva solo para esto (sería un PR
# borrador nuevo cada 7 días, acumulándose sin fusionarse nunca, per
# la regla de "nunca fusionar sin pedirlo Angel") -- en vez de eso,
# sube el commit directo a la rama que esté activa en ese momento,
# igual que ya se hace con las regeneraciones de graphify-out. Si la
# skill SÍ añadió patrones nuevos a .claude/settings.json, ese cambio
# de permisos sigue el flujo normal de rama+PR+revisión aparte -- este
# script solo se ocupa del marcador.
#
# Uso: mark-permission-scan.sh [resumen corto]
# Ej:  mark-permission-scan.sh "4 patrones nuevos añadidos"

set -uo pipefail

SUMMARY="${1:-sin cambios}"

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 1

DIR="${CLAUDE_PROJECT_DIR:-.}/.claude"
mkdir -p "$DIR"
MARKER="$DIR/.fewer-permission-prompts-last-run.json"
MARKER_REL=".claude/.fewer-permission-prompts-last-run.json"

TMP="$(mktemp "$DIR/.tmp.fewer-permission-prompts.XXXXXX")" || exit 1
trap 'rm -f "$TMP"' EXIT
jq -n \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg summary "$SUMMARY" \
  '{last_run: $ts, summary: $summary}' \
  > "$TMP" || exit 1
mv -f "$TMP" "$MARKER" || exit 1

echo "Marcador escrito: fewer-permission-prompts corrida el $(date -u +%Y-%m-%dT%H:%M:%SZ) ($SUMMARY)"

# Comitear y subir SOLO este archivo -- nunca arrastrar otros cambios
# sin comitear que la sesión pueda tener en curso.
if ! git -C "${CLAUDE_PROJECT_DIR:-.}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Aviso: no es un repo git, el marcador se queda solo en local." >&2
  exit 0
fi

git -C "${CLAUDE_PROJECT_DIR:-.}" add -- "$MARKER_REL" || {
  echo "Aviso: no se pudo git add el marcador, se queda solo en local." >&2
  exit 0
}

if git -C "${CLAUDE_PROJECT_DIR:-.}" diff --cached --quiet -- "$MARKER_REL"; then
  echo "Marcador sin cambios respecto al commit anterior, nada que subir."
  exit 0
fi

if ! git -C "${CLAUDE_PROJECT_DIR:-.}" commit -m "Actualizar marcador de fewer-permission-prompts ($SUMMARY)" -- "$MARKER_REL" >/dev/null 2>&1; then
  echo "Aviso: git commit del marcador falló, se queda solo en local." >&2
  exit 0
fi

BRANCH="$(git -C "${CLAUDE_PROJECT_DIR:-.}" branch --show-current 2>/dev/null)"
if [ -z "$BRANCH" ]; then
  echo "Aviso: HEAD separado, no se puede subir el marcador (queda comiteado en local)." >&2
  exit 0
fi

if timeout 30 git -C "${CLAUDE_PROJECT_DIR:-.}" push origin "$BRANCH" >/dev/null 2>&1; then
  echo "Marcador comiteado y subido a $BRANCH."
else
  echo "Aviso: git push del marcador falló o se agotó el tiempo (queda comiteado en local, sin subir)." >&2
fi
