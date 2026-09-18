#!/bin/bash
# SessionStart hook (plugin version): inyecta el ruleset completo de la
# skill `caveman` empaquetada dentro de este mismo plugin, como contexto
# en el arranque principal de sesión.
#
# A diferencia de la versión suelta original de este repo
# (.claude/hooks/caveman-mode.sh, que leía .claude/skills/caveman/SKILL.md
# relativo a $CLAUDE_PROJECT_DIR), esta versión lee el SKILL.md que viaja
# DENTRO del plugin (vía $CLAUDE_PLUGIN_ROOT) -- así funciona igual en
# cualquier repo donde se instale el plugin, sin depender de que ese repo
# tenga su propia copia de la skill.
#
# Mismo alcance que la versión original: solo SessionStart, no
# SubagentStart -- un subagente lanzado a mitad de sesión no hereda el
# modo caveman de este hook (para eso está la skill `cavecrew`, que
# compensa vía subagentes propios ya caveman-compressed).
#
# Best-effort, no bloqueante: si falta `jq`, o CLAUDE_PLUGIN_ROOT no
# está definido, o el SKILL.md no es legible, la sesión arranca igual
# sin caveman activado automáticamente esa vez (fallback: /caveman a
# mano sigue funcionando mientras la skill del plugin esté instalada).
#
# Si este plugin se instala DENTRO de un repo que ya trae su propia
# copia nativa de caveman con el mismo hook (como Molu, que tiene
# .claude/hooks/caveman-mode.sh + .claude/skills/caveman) hay que
# saltarse la inyección aquí -- si no, el contexto "CAVEMAN MODE
# ACTIVE" se duplica en cada arranque de sesión (dos copias del mismo
# SKILL.md, tokens desperdiciados). Se detecta comprobando si el propio
# repo anfitrión ya tiene esa skill nativa en su ruta de siempre.
if [ -r "${CLAUDE_PROJECT_DIR:-.}/.claude/skills/caveman/SKILL.md" ]; then
  exit 0
fi

command -v jq >/dev/null 2>&1 || exit 0

[ -n "$CLAUDE_PLUGIN_ROOT" ] || exit 0

SKILL_FILE="$CLAUDE_PLUGIN_ROOT/skills/caveman/SKILL.md"
[ -r "$SKILL_FILE" ] || exit 0

# `timeout` por la misma razón que en la versión original: este hook
# corre en cada arranque/resume/clear/compact de sesión, así que un
# cuelgue de lectura aquí no debe bloquear la sesión entera.
CONTENT="$(timeout 5 cat "$SKILL_FILE" 2>/dev/null)"
[ -n "$CONTENT" ] || exit 0

jq -cn --arg ctx "CAVEMAN MODE ACTIVE

$CONTENT" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
