#!/bin/bash
# SessionStart hook, SOLO en arranque real (matcher "startup" en
# .claude/settings.json -- nunca resume/clear/compact): trae origin/main
# automáticamente cuando es seguro hacerlo, para que una rama base vieja
# no se quede atrás sin funciones ya fusionadas sin que nadie lo note.
#
# Motivo real: la sesión "Nivel B2" arrancó desde un commit anterior a
# que `.claude/hooks/caveman-mode.sh` existiera siquiera -- `/caveman` no
# funcionaba ahí, y nada lo avisó hasta que Angel preguntó por qué. Este
# hook detecta y corrige ese caso (o al menos avisa) en el arranque, en
# vez de dejar que se descubra por sorpresa sesiones después.
#
# Por qué SOLO "startup": un merge a mitad de una tarea (resume/clear/
# compact) tocaría el árbol de trabajo bajo los pies de una sesión con
# cambios sin comitear -- justo el efecto secundario que hook-hardening
# (punto 7) pide evitar. En un arranque real todavía no hay nada propio
# que perder.
#
# Best-effort, jamás bloquea el arranque: sin red, sin remoto, árbol
# sucio, o rama con commits propios que divergen de main -> informa (o
# ni eso) y sigue, nunca falla la sesión.
#
# DISEÑO (tras 6 rondas de revisión sobre una versión anterior más
# "inteligente" -- ver hook-hardening punto 9 y la entrada de
# 2026-09-07 en novedades.md para el historial completo): esta versión
# usa deliberadamente el chequeo MÁS SIMPLE posible -- "¿hay algún
# archivo sin trackear o ignorado en el árbol?" -- en vez de intentar
# detectar con precisión si ese archivo colisiona con lo que
# origin/main va a cambiar. La versión "precisa" (comparar listas de
# rutas con `git diff`/`git ls-files`) tardó 6 rondas en cerrar tres
# bypasses reales de pérdida de datos (citado inconsistente entre
# comandos, colapso de directorios, colisión archivo-vs-carpeta), y una
# 7ª ronda encontró que la propia comparación (un bucle anidado en
# bash) no tenía cota de tamaño -- con una rama muy por detrás y muchos
# archivos sueltos, podía colgar el arranque de sesión durante segundos
# o minutos, justo lo que este hook promete no hacer nunca. La
# alternativa simple no necesita comparar nada (solo mirar si la salida
# de un comando está vacía), así que no puede sufrir ninguna de las seis
# clases de bug encontradas, ni la de rendimiento -- a cambio de que el
# auto-heal dispare menos veces en este repo en concreto (que
# rutinariamente tiene artefactos ignorados de `graphify`/
# `check-pr-review.sh` presentes). Ese es el trade-off aceptado: menos
# veces se actualiza sola, pero de forma mucho más simple de razonar y
# sin ningún hueco conocido.
#
# `git merge --ff-only` ya protege por sí solo, sin ayuda de este
# script, cualquier cambio local sin comitear en un archivo TRACKEADO --
# verificado en vivo: aborta limpio ("Your local changes... would be
# overwritten by merge"), exit != 0, contenido local intacto. Lo único
# que NO protege es un archivo local SIN TRACKEAR (incluido uno
# ignorado por .gitignore) -- ahí el fast-forward puede sobrescribirlo
# en silencio. Por eso cualquier archivo sin trackear o ignorado, sin
# excepción, cuenta como "no seguro" aquí.

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

if ! timeout 15 git fetch origin main >/dev/null 2>&1; then
  echo "[session-start] no se pudo comprobar origin/main (red o remoto no disponible) -- rama sin cambiar"
  exit 0
fi

BEHIND="$(git rev-list --count HEAD..origin/main 2>/dev/null)"
[ -n "$BEHIND" ] || exit 0
[ "$BEHIND" -gt 0 ] || exit 0

if [ -n "$(git status --porcelain --ignored 2>/dev/null)" ]; then
  echo "[session-start] rama $BEHIND commits por detrás de origin/main, pero hay archivos sin trackear o ignorados en el árbol -- no se actualiza sola (uno de ellos podría colisionar con algo que origin/main cambia y perderse en el fast-forward sin aviso); si hace falta, comitear/mover esos archivos y luego 'git merge origin/main' a mano"
  exit 0
fi

if git merge --ff-only origin/main >/dev/null 2>&1; then
  echo "[session-start] rama puesta al día con origin/main automáticamente ($BEHIND commits, fast-forward limpio)"
else
  echo "[session-start] rama $BEHIND commits por detrás de origin/main -- no se pudo actualizar sola (commits propios que divergen, o cambios locales sin comitear en archivos que origin/main también modifica; git lo rechazó limpio sin perder nada); si notas algo desactualizado (una skill, un hook), 'git merge origin/main' a mano"
fi
