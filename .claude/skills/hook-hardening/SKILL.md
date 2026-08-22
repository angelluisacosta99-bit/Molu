---
name: hook-hardening
description: "Use before declaring \"done\", \"tested\", or \"ready to commit\" on any shell script that runs unattended in a future session or on behalf of the harness — SessionStart/PreToolUse/Stop hooks, or any fail-open/fail-closed security gate. Also use before writing one, not just after. Checklist to catch a known family of bugs before an external review has to."
---

# hook-hardening

Nace de varias sagas reales en este repo — `.claude/hooks/check-pr-review.sh`
(7 rondas de revisión), y `.claude/hooks/session-start.sh` a lo largo de
la instalación de `agent-browser` (6 rondas), `mcp-server-dev` (4 rondas)
y `ponytail` (3 rondas) — donde la misma familia de errores se repitió
una y otra vez, cada vez detectada por una revisión externa en vez de
por mí mismo antes de declarar el trabajo terminado. Esta skill es esa
lista de comprobación, para correrla *antes* de decir "hecho", no como
sustituto de la revisión, sino para que la revisión encuentre cada vez
menos.

**No es una lista de buenas intenciones — cada punto lleva el
comando/patrón exacto que lo comprueba.** Si no puedes marcar un punto
con algo concreto que corriste, no está comprobado todavía.

## 1. Todo código de salida se comprueba antes de declarar éxito

**El error real:** añadir `timeout N comando` y seguir imprimiendo
"instalado"/"listo" en la línea siguiente, sin mirar si `comando`
falló, fue matado por el timeout, o tuvo éxito.

**Comprobación:** para cada `comando externo` (binario de terceros,
`npm install`, `git`, `curl`...) en el script, ¿el mensaje de éxito está
dentro de un `if comando; then éxito; else fallo (non-blocking); fi`, o
es una línea suelta después de un `comando >/dev/null 2>&1` sin usar su
`$?`? Si es lo segundo, es el bug.

```bash
# mal: dice éxito pase lo que pase
timeout 30 graphify hook install >/dev/null 2>&1
echo "instalado"

# bien
if timeout 30 graphify hook install >/dev/null 2>&1; then
  echo "instalado"
else
  echo "falló o se agotó el tiempo (non-blocking)"
fi
```

## 2. Cada comando externo nuevo tiene `timeout`, sin excepción

**El error real:** un chequeo de versión (`binario --version`) añadido
para arreglar OTRO bug se coló sin `timeout`, reintroduciendo en código
nuevo el mismo fallo de "puede colgarse para siempre" que el resto del
archivo ya llevaba dos rondas corrigiendo en otros sitios.

**Comprobación:** `grep -n "^\s*[a-zA-Z_.-]\+ .*\$" archivo.sh` (o
simplemente leer el script entero de arriba a abajo) — todo comando que
no sea un builtin de bash (`[`, `test`, `command -v`, `echo`, `cd`) y
que dependa de un binario externo, ¿lleva `timeout N` delante? Si el
script ya tiene el patrón establecido en un sitio, un comando nuevo que
no lo copie es sospechoso por definición.

## 3. Antes de inventar un mecanismo, buscar si ya existe uno oficial

**El error real:** para persistir una variable de entorno de un hook
`SessionStart` hacia las llamadas de Bash tool posteriores, escribí en
`/etc/profile.d/` por analogía con cómo el proxy de este contenedor
persiste `HTTPS_PROXY` — sin comprobar antes si Claude Code tiene su
propio mecanismo documentado para exactamente este caso (lo tiene:
`$CLAUDE_ENV_FILE`, en la skill `session-start-hook`).

**Comprobación:** si el problema es "¿cómo persiste X entre A y B en
este entorno concreto de Claude Code?", cargar primero la skill
relevante del propio harness (`session-start-hook`,
`fewer-permission-prompts`, `update-config`...) antes de copiar un
patrón de otra herramienta que resuelve un problema parecido pero no
idéntico. Un mecanismo "parecido" que funciona para una cosa (CA certs
de un proxy) no implica que funcione igual para otra (env vars hacia el
Bash tool) — son consumidores distintos con reglas de arranque
distintas.

## 4. "Probado de punta a punta" solo cuenta si reproduce la invocación real

**El error real, el más grave de los dos:** para probar que una
variable de entorno llegaba a una llamada nueva del Bash tool, usé
`env -i ... bash -lc '...'` — el flag `-l` (login shell) hace que se
lea `/etc/profile.d/`, que es justo lo que quería demostrar que
funcionaba. El Bash tool real invoca cada comando como `bash -c '...'`
(sin `-l`), que nunca lo lee. La prueba "pasó" solo porque yo mismo
activé, a mano, el comportamiento que estaba intentando validar.

**Comprobación:** antes de afirmar "probado de punta a punta", pregunta
explícitamente: ¿esta prueba usa el mismo binario, los mismos flags, y
el mismo mecanismo de invocación que el consumidor real? Si no estás
seguro de cómo invoca algo el consumidor real (el Bash tool, un hook
concreto, un CI), no lo asumas — comprébalo en vivo:

```bash
cat /proc/$$/cmdline | tr '\0' ' '; echo
```

en el contexto real (no en una subshell que tú mismo construiste a
medida) antes de diseñar la prueba alrededor de esa asunción.

## 5. Tras cualquier intento de arreglo, re-verificar, no asumir

**El error real:** tras detectar una versión desajustada y lanzar una
reinstalación, el script seguía sin volver a comprobar la versión
después del intento — si la reinstalación fallaba (red bloqueada), el
script igual reportaba éxito con el binario viejo.

**Comprobación:** todo `if condición_de_fallo; then intentar_arreglo;
fi` necesita, justo después, volver a evaluar la condición original
antes de decidir qué mensaje mostrar — nunca asumir que
`intentar_arreglo` funcionó solo porque se ejecutó.

## 6. Decir exactamente lo que un chequeo garantiza, ni más ni menos

**El error real:** un pin de versión que existe para que este *script*
nunca instale una versión sin fijar se documentó como si impidiera
"usar" el binario — pero solo evita que el hook lo configure/dependa de
él. No hay ningún `PreToolUse` que bloquee una llamada directa por Bash
a ese binario con otra versión (a diferencia de
`check-pr-review.sh`, que sí es un gate técnico real sobre
`merge_pull_request`).

**Comprobación:** para cada afirmación de tipo "esto impide X", pregunta
si es un gate técnico (algo que bloquea la acción en sí, verificable
con `.claude/settings.json` + un hook `PreToolUse`) o solo una
conveniencia de configuración (algo que deja de prepararse, pero sigue
siendo posible por otra vía). Si es lo segundo, decirlo así — "evita
que X se configure/dependa de esto", no "impide usar X".

## 7. Probar en vivo contra estado compartido puede ensuciar lo que vas a comitear

**El error real:** al probar en vivo hooks que llaman a un CLI con
estado global compartido fuera del repo (`claude plugin`,
`~/.claude/settings.json`, `~/.claude/plugins/...`), tanto mis propias
pruebas como las de una revisión posterior (que también reproduce en
vivo, incluso desde un worktree — comparte el mismo `HOME`) pueden
mutar ese estado compartido como efecto secundario. Si una parte de ese
estado compartido también se escribe en un archivo del *proyecto*
(`.claude/settings.json`, no solo en `~/.claude/`), una prueba ajena
puede dejar ahí un cambio que yo nunca pedí ni entiendo, listo para
comitearse sin que nadie lo note — pasó de verdad: apareció una entrada
de marketplace registrada a nivel de proyecto que no coincidía con el
diseño documentado, y no se pudo reproducir qué comando exacto la
escribió.

**Comprobación:** antes de comitear cualquier cambio en un archivo de
configuración compartido (`.claude/settings.json` y similares) tras una
tanda de pruebas en vivo — las tuyas o las de una revisión — mirar el
diff completo de ese archivo, no solo los archivos que creías haber
tocado. Si aparece algo que no coincide con lo que se pidió hacer
explícitamente, no comitearlo a ciegas: investigar primero (¿el comando
exacto documentado lo reproduce de nuevo, en un estado limpio?), y si
no se puede explicar su origen, descartarlo (`git stash drop` o
similar) en vez de asumir que es inofensivo solo porque no rompe nada
visible.

## Antes de pedir/lanzar la revisión externa

Repasar estos 7 puntos uno por uno contra el diff, con al menos un
comando ejecutado en vivo por punto que lo confirme (no solo "leído y
parece bien") — así cada ronda de revisión encuentra menos, en vez de
encontrar la misma clase de bug que un pase manual ya podría haber
descartado.
