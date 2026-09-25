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

command -v jq >/dev/null 2>&1 || {
  echo "mark-permission-scan.sh: falta jq, no se puede escribir el marcador." >&2
  exit 1
}

# La raíz del proyecto se resuelve UNA vez, aquí, y todo lo de abajo usa
# $ROOT -- nunca "${CLAUDE_PROJECT_DIR:-.}" repetido.
#
# El motivo es concreto, no estilístico: este script lo invoca el Bash
# tool de la sesión (se lo pide la instrucción que inyecta
# fewer-permission-prompts-reminder.sh), no el harness, y
# CLAUDE_PROJECT_DIR **no está definida en el Bash tool** -- solo la
# reciben los procesos de hook. Así que el ":-." caía siempre en el cwd
# de la llamada: invocado desde una subcarpeta, escribía y comiteaba el
# marcador en <subcarpeta>/.claude/ en vez de en la raíz. El hook que
# luego LEE ese marcador sí recibe CLAUDE_PROJECT_DIR del harness y mira
# la raíz, así que no lo encontraba nunca: el recordatorio se repetiría
# en cada arranque sin avanzar los 7 días (el bug del punto 11 de
# hook-hardening por otra vía), dejando además un .claude/ espurio
# comiteado donde no toca.
#
# git rev-parse funciona desde cualquier cwd dentro del repo y no
# depende de ninguna variable del harness. Si tampoco hay repo git, se
# cae a "." y el chequeo de más abajo ya avisa y sale limpio.
ROOT="${CLAUDE_PROJECT_DIR:-}"
if [ -z "$ROOT" ]; then
  ROOT="$(timeout 15 git rev-parse --show-toplevel 2>/dev/null)" || ROOT=""
fi
[ -n "$ROOT" ] || ROOT="."

cd "$ROOT" || exit 1

DIR="$ROOT/.claude"
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

# El commit se acota a este único archivo (git commit -- "$MARKER_REL"),
# pero `git push` sube el estado completo de la rama, no solo este
# commit -- si la sesión tenía otros commits locales sin subir en la
# misma rama, este script los publica también. Aceptado a propósito:
# este hook solo tiene sentido invocarlo en una sesión que ya está
# trabajando (y por tanto subiendo) en esa rama con normalidad, igual
# que el resto de este repo empuja cambios sin esperar a acumular un
# lote.
# Tres presupuestos de timeout distintos, no uno solo para todo:
# - GIT (15s): comandos locales puros (add/diff/commit/branch) que
#   nunca tocan disco pesado ni red.
# - GIT_REBASE (30s): rebase/abort son locales pero pueden tener que
#   reaplicar un commit grande ya en cola (este repo empuja
#   regeneraciones de graphify-out de cientos de miles de líneas) --
#   más margen que un comando trivial, sin llegar al de red.
# - GIT_NET (30s): push/fetch, que sí van por red.
# Nota sobre el límite externo: la propia llamada a este script desde
# la sesión pasa por el Bash tool, que tiene su propio timeout (120s
# por defecto) fuera del control de este script -- sumando el peor
# caso de todos los pasos (varios locales + fetch + rebase + reintento
# de push) se puede superar esa cota externa en una red muy lenta. No
# se persigue una garantía matemática de quedar siempre por debajo:
# encoger más los timeouts de red para "caber seguro" reintroduciría
# el problema original (un push legítimamente grande fallando por
# quedarse corto de tiempo). Si el Bash tool mata este script a mitad,
# el fallo es seguro igual -- el marcador ya quedó escrito en el JSON
# local antes de tocar git (líneas de arriba), nunca se pierde el
# dato, solo no llega a subirse esta vez y el recordatorio se repite
# la próxima sesión -- exactamente el coste "best-effort" que este
# hook ya asume desde su diseño, no una regresión nueva.
GIT() { timeout 15 git -C "$ROOT" "$@"; }
GIT_REBASE() { timeout 30 git -C "$ROOT" "$@"; }
GIT_NET() { timeout 30 git -C "$ROOT" "$@"; }

if ! GIT rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Aviso: no es un repo git, el marcador se queda solo en local." >&2
  exit 0
fi

GIT add -- "$MARKER_REL" || {
  echo "Aviso: no se pudo git add el marcador, se queda solo en local." >&2
  exit 0
}

if GIT diff --cached --quiet -- "$MARKER_REL"; then
  echo "Marcador sin cambios respecto al commit anterior, nada que subir."
  exit 0
fi

if ! GIT commit -m "Actualizar marcador de fewer-permission-prompts ($SUMMARY)" -- "$MARKER_REL" >/dev/null 2>&1; then
  echo "Aviso: git commit del marcador falló, se queda solo en local." >&2
  exit 0
fi

BRANCH="$(GIT branch --show-current 2>/dev/null)"
if [ -z "$BRANCH" ]; then
  echo "Aviso: HEAD separado, no se puede subir el marcador (queda comiteado en local)." >&2
  exit 0
fi

if GIT_NET push origin "$BRANCH" >/dev/null 2>&1; then
  echo "Marcador comiteado y subido a $BRANCH."
  exit 0
fi

# Un solo reintento tras traer lo nuevo del remoto -- cubre el caso más
# probable de rechazo (la rama avanzó mientras tanto, ej. otra sesión
# subió su propio marcador o un rebuild de graphify-out) sin reintentos
# sin cota. Si el rebase choca (conflicto real en el propio marcador,
# muy improbable en un JSON de 2 campos pero posible), se aborta y se
# deja todo como estaba -- nunca se fuerza un push.
if GIT_NET fetch origin "$BRANCH" >/dev/null 2>&1; then
  if GIT_REBASE rebase "origin/$BRANCH" >/dev/null 2>&1; then
    if GIT_NET push origin "$BRANCH" >/dev/null 2>&1; then
      echo "Marcador comiteado y subido a $BRANCH (tras un rebase)."
      exit 0
    fi
  else
    # Solo abortar si de verdad se llegó a iniciar un rebase -- si fue
    # el fetch el que falló, no hay nada que abortar.
    GIT_REBASE rebase --abort >/dev/null 2>&1
  fi
fi

echo "Aviso: git push del marcador falló incluso tras reintentar (queda comiteado en local, sin subir)." >&2
