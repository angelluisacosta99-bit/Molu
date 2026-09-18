#!/bin/bash
# SessionStart hook (matcher: startup): recuerda ejecutar la skill
# `fewer-permission-prompts` si han pasado 7+ días (o nunca se ha
# corrido en este repo), en vez de depender de que Angel se acuerde de
# pedirlo. Pedido explícitamente por Angel el 2026-09-18: quiere el
# allowlist de permisos manteniéndose solo, sin invocar la skill a mano
# cada vez, pero sin gastar la skill completa en CADA arranque de
# sesión (coste de tokens/tiempo) -- de ahí el umbral de días en vez de
# "siempre, literal".
#
# Mecanismo: un marcador JSON con timestamp -- misma FORMA de escritura
# atómica (mktemp + mv) que ya usa mark-pr-reviewed.sh (hook-hardening,
# punto 3: no inventar un mecanismo nuevo si ya hay uno establecido en
# este repo), pero NO el mismo patrón de versionado: el de
# mark-pr-reviewed.sh vive en .claude/.pr-review-state/, gitignorado a
# propósito (estado de sesión, nunca debe persistir entre sesiones por
# motivos de seguridad del gate de merge). Este marcador es justo lo
# contrario a propósito: SÍ se versiona, porque Angel pidió que el
# recordatorio funcione "en todas las sesiones" y los contenedores de
# este entorno son efímeros -- un marcador sin versionar nunca
# sobreviviría a un checkout fresco en un contenedor distinto (incluida
# la Routine semanal del Radar, que clona limpio cada vez). El coste
# aceptado de esa decisión: dos ramas que corran la skill en paralelo y
# comiteen el marcador a la vez producen un conflicto de merge normal y
# visible en este archivo -- no una pérdida de datos silenciosa, solo
# hay que resolverlo (quedarse con el timestamp más reciente) como
# cualquier otro conflicto de este repo.
# Lo escribe mark-permission-scan.sh, que esta sesión debe llamar tras
# correr la skill (instrucción va en el propio texto inyectado).
#
# Best-effort, no bloqueante: cualquier fallo (falta jq/date, marcador
# ausente o corrupto) deja la sesión arrancar igual, sin recordatorio
# esa vez -- nunca aborta el arranque. No es un gate técnico (no hay
# PreToolUse que fuerce nada) -- es un recordatorio en el contexto,
# igual de "blando" que el resto de reglas de CLAUDE.md: si la sesión
# no lo sigue, no pasa nada roto, solo se repite el recordatorio en el
# siguiente arranque.

DAYS_THRESHOLD=7
MARKER="${CLAUDE_PROJECT_DIR:-.}/.claude/.fewer-permission-prompts-last-run.json"

command -v jq >/dev/null 2>&1 || exit 0
command -v date >/dev/null 2>&1 || exit 0

NOW_EPOCH="$(date -u +%s 2>/dev/null)" || exit 0

TRIGGER=1
if [ -r "$MARKER" ]; then
  LAST_ISO="$(timeout 5 jq -r '.last_run // empty' "$MARKER" 2>/dev/null)"
  if [ -n "$LAST_ISO" ]; then
    LAST_EPOCH="$(date -u -d "$LAST_ISO" +%s 2>/dev/null)" || LAST_EPOCH=""
    if [ -n "$LAST_EPOCH" ]; then
      AGE_DAYS=$(( (NOW_EPOCH - LAST_EPOCH) / 86400 ))
      if [ "$AGE_DAYS" -lt "$DAYS_THRESHOLD" ]; then
        TRIGGER=0
      fi
    fi
  fi
fi

[ "$TRIGGER" -eq 1 ] || exit 0

jq -cn --arg ctx "Han pasado 7+ días (o nunca se ha corrido en este repo) desde la última pasada de la skill \`fewer-permission-prompts\`. En el primer momento natural de esta sesión, ejecútala (herramienta Skill, skill: \"fewer-permission-prompts\"). Al terminar -- haya añadido patrones nuevos a .claude/settings.json o no -- SIEMPRE, sin excepción: (1) deja constancia con bash .claude/hooks/mark-permission-scan.sh \"<resumen corto>\", y (2) comitea y sube ESE marcador (junto con settings.json si hubo cambios) a la rama en la que estés trabajando, siguiendo el flujo normal del repo (rama + PR en borrador, nunca fusionar sin pedirlo Angel). Es imprescindible subir el marcador SIEMPRE, incluso si no hubo cambios en el allowlist -- si se queda solo en el archivo local sin comitear, el marcador se pierde al reciclarse el contenedor y la siguiente sesión (checkout limpio) seguirá viendo el marcador antiguo: este recordatorio se repetiría en cada arranque sin avanzar nunca los 7 días, justo el problema de coste que este mecanismo existe para evitar." \
  '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
