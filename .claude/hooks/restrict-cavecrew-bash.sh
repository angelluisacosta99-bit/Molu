#!/bin/bash
# PreToolUse hook para Bash, pero solo actúa sobre dos subagentes
# concretos: cavecrew-investigator y cavecrew-reviewer
# (.claude/agents/cavecrew-{investigator,reviewer}.md). Ambos se
# autodescriben "solo lectura"/"sin comandos que mutan", pero el campo
# `tools:` de un subagente no admite acotar `Bash` a subcomandos (a
# diferencia del sistema de permisos general, que sí soporta
# `Bash(git log:*)`) -- confirmado contra la documentación oficial de
# Claude Code. Sin este hook, esa promesa de "solo lectura" la sostiene
# solo el texto del prompt del subagente, no un permiso técnico real.
#
# Best-effort, deliberadamente NO fail-closed: si el hook no puede
# decidir (jq ausente, input no parseable, agent_type ausente), permite
# -- esto añade una restricción NUEVA sobre un permiso que ya existía
# (Bash sin restringir para estos subagentes), no quita una garantía
# crítica ya establecida. El hilo principal y cualquier otro subagente
# (agent_type distinto o ausente) nunca se tocan aquí -- ver
# CLAUDE.md/novedades.md para el porqué de aceptar ese alcance limitado
# en vez de restringir Bash en todo el repo.
#
# Alcance: solo mira `tool_input.command` de una llamada a Bash. No
# cubre otras formas de ejecutar comandos (por ejemplo si algún día
# estos subagentes ganaran acceso a un MCP server con su propio
# shell), ni intenta ser un sandbox hermético contra un comando
# adversarialmente construido -- es un filtro razonable, no una
# garantía absoluta.

allow() { exit 0; }
deny() {
  jq -cn --arg reason "$1" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
  exit 0
}

command -v jq >/dev/null 2>&1 || allow

INPUT=$(cat) || allow

AGENT_TYPE=$(jq -r '.agent_type // empty' <<<"$INPUT" 2>/dev/null)
case "$AGENT_TYPE" in
  cavecrew-investigator|cavecrew-reviewer) ;;
  *) allow ;;
esac

CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT" 2>/dev/null)
[ -n "$CMD" ] || allow

# Un salto de línea literal dentro del comando rompe la comprobación de
# más abajo (grep -q sin -z ancla ^/$ por línea, no por cadena entera),
# permitiendo que una segunda línea sin restringir se cuele -- verificado
# en vivo. Se comprueba aparte, con un patrón de bash (no grep), antes
# de cualquier otra cosa.
case "$CMD" in
  *$'\n'*)
    deny "$AGENT_TYPE es de solo lectura -- comando con salto de línea embebido denegado: $CMD"
    ;;
esac

# Sin metacaracteres de shell que permitan encadenar, sustituir, o
# redirigir -- ni siquiera pipes: un solo comando git de solo lectura,
# nada más. No es un parser de shell real, es un filtro conservador:
# ante la duda, deniega.
if printf '%s' "$CMD" | grep -qE '[;&|<>]|`|\$\('; then
  deny "$AGENT_TYPE es de solo lectura -- comando con metacaracteres de shell (encadenado, sustitución, o redirección) denegado: $CMD"
fi

# Ningún flag/opción en absoluto, en ningún punto del comando -- ni
# siquiera los que "suenan" de solo lectura. git tiene demasiados
# escapes por subcomando para poder confiar en una lista negra de
# flags concretos: `git grep -O'sh -c ...'` (--open-files-in-pager)
# ejecuta un comando arbitrario como "paginador", y `git log
# --output=<ruta>` escribe contenido controlado por el propio comando
# en cualquier archivo -- ambos verificados en vivo como bypass real
# antes de esta comprobación. Cualquier token que empiece por "-" en
# cualquier posición (incluido un "--" suelto) se deniega, aunque eso
# también bloquee flags realmente inocuos como "--oneline": preferible
# a intentar enumerar cuáles de las decenas de flags de cada subcomando
# de git son de verdad seguras.
if printf '%s' "$CMD" | grep -qE '(^|[[:space:]])-'; then
  deny "$AGENT_TYPE es de solo lectura -- no se permite ningún flag/opción (demasiados subcomandos de git tienen escapes vía flags): $CMD"
fi

if printf '%s' "$CMD" | grep -qE '^[[:space:]]*git[[:space:]]+(log|blame|show|diff|grep|status|ls-files|rev-parse)([[:space:]]|$)'; then
  allow
fi

deny "$AGENT_TYPE es de solo lectura -- solo se permiten comandos git de lectura sin encadenar y sin flags (log/blame/show/diff/grep/status/ls-files/rev-parse): $CMD"
