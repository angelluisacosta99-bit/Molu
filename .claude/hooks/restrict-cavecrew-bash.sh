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

# Sin metacaracteres de shell que permitan encadenar, sustituir, o
# redirigir -- ni siquiera pipes: un solo comando git de solo lectura,
# nada más. No es un parser de shell real, es un filtro conservador:
# ante la duda, deniega.
if printf '%s' "$CMD" | grep -qE '[;&|<>]|`|\$\('; then
  deny "$AGENT_TYPE es de solo lectura -- comando con metacaracteres de shell (encadenado, sustitución, o redirección) denegado: $CMD"
fi

if printf '%s' "$CMD" | grep -qE '^[[:space:]]*git[[:space:]]+(log|blame|show|diff|grep|status|ls-files|rev-parse)([[:space:]]|$)'; then
  allow
fi

deny "$AGENT_TYPE es de solo lectura -- solo se permiten comandos git de lectura sin encadenar (log/blame/show/diff/grep/status/ls-files/rev-parse): $CMD"
