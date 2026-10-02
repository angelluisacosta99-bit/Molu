---
name: hook-hardening
description: "Use before declaring \"done\", \"tested\", or \"ready to commit\" on any shell script that runs unattended in a future session or on behalf of the harness — SessionStart/PreToolUse/Stop hooks, or any fail-open/fail-closed security gate. Also use before writing one, not just after. Checklist to catch a known family of bugs before an external review has to."
---

# hook-hardening

Nace de varias sagas reales en este repo — `.claude/hooks/check-pr-review.sh`
(7 rondas de revisión), `.claude/hooks/session-start.sh` a lo largo de
la instalación de `agent-browser` (6 rondas), `mcp-server-dev` (4 rondas)
y `ponytail` (3 rondas), `.claude/hooks/restrict-cavecrew-bash.sh`
(4 rondas solo para cerrar los bypasses de su filtro de comandos), y
`.claude/hooks/sync-main.sh` (7 rondas: un bug real de pérdida de
datos, una corrección que casi inutilizaba la función entera, un
mensaje de diagnóstico engañoso, un chequeo de colisión de rutas roto
por citado/colapso de directorios, una colisión archivo-vs-carpeta sin
detectar, y finalmente un bug de rendimiento sin cota que llevó a
abandonar la comparación precisa entera por el chequeo simple
original) —
donde la misma familia de errores se repitió una y otra vez, cada vez
detectada por una revisión externa en vez de por mí mismo antes de
declarar el trabajo terminado. Esta skill es esa lista de comprobación,
para correrla *antes* de decir "hecho", no como sustituto de la
revisión, sino para que la revisión encuentre cada vez menos.

**Regla general, no solo para hooks:** si corregir el mismo
archivo/hook/PR para dejarlo limpio necesita 3 o más rondas de
revisión→corrección, eso es la señal de guardar la lección — para un
hook, aquí; para otro tipo de código, en la skill de ese dominio o en
`recursos-generales/herramientas-ia/novedades.md` (ver
`CLAUDE.md`, sección "3+ rondas de revisión sobre lo mismo").

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

**Corolario: el texto que un hook INYECTA no lo ejecuta el hook.** Si un
hook `SessionStart` inyecta una instrucción con un comando dentro, ese
comando lo correrá el Bash tool de la sesión, no el proceso del hook —
y no comparten entorno. En concreto, `CLAUDE_PROJECT_DIR` **sí** existe
para los procesos de hook (el harness se la pasa) pero **no** está
definida en el Bash tool (verificado en vivo: `echo
"${CLAUDE_PROJECT_DIR:-<VACIA>}"` desde una llamada normal de Bash
devuelve vacío). Así que "anclar la ruta a `$CLAUDE_PROJECT_DIR` en vez
de dejarla relativa al cwd", que es la corrección correcta *dentro* de
un script de hook, la rompe *dentro del texto inyectado*: se expande a
`/.claude/hooks/...` y falla siempre. Para una ruta dentro de una
instrucción inyectada, usar algo que el Bash tool sí pueda resolver por
sí mismo — `$(git rev-parse --show-toplevel)` en un repo — nunca una
variable que solo existe del lado del hook.

**Tercera ronda sobre esto mismo, y la lección de verdad: arreglar la
ruta del script no basta si el script tampoco puede fiarse de esa
variable.** La corrección de arriba (cambiar la ruta *dentro del texto
inyectado*) cerró dónde *estaba* el script, pero `mark-permission-scan.sh`
seguía resolviendo la raíz del proyecto con `"${CLAUDE_PROJECT_DIR:-.}"`
en cinco sitios (el `cd`, el `DIR` del marcador y las tres funciones
`GIT*`). Como la variable está vacía en el Bash tool, ese `:-.` caía
siempre en el cwd: invocado desde una subcarpeta, el script escribía **y
comiteaba** el marcador en `<subcarpeta>/.claude/` — reproducido en vivo —
mientras el hook que lo lee sí recibe la variable del harness y mira la
raíz, así que no lo encontraba nunca. El recordatorio se repetiría en
cada arranque sin avanzar los 7 días: el bug del punto 11 otra vez, por
una vía nueva, más un `.claude/` espurio comiteado donde no toca. Una
revisión externa lo encontró *después* de que la ronda anterior diera el
problema por cerrado.

**Comprobación, y es la que resume las tres rondas:** cuando descubras
que una variable del entorno no llega a un consumidor, `grep` esa
variable en **todo** el camino de ejecución —el hook, el texto que
inyecta, y cada script que ese texto invoca— y arréglalos todos de una
vez. Arreglar solo el sitio donde saltó el síntoma es dejar el mismo bug
vivo un nivel más abajo. En la práctica: resolver la raíz **una sola
vez** al principio del script, con un respaldo que no dependa del
harness (`git rev-parse --show-toplevel`), y usar esa variable en todas
partes — nunca repetir `"${CLAUDE_PROJECT_DIR:-.}"` inline, porque cada
repetición es un sitio más donde el fallback silencioso puede morder.

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

## 8. Un filtro de texto sobre un comando de shell debe operar sobre lo
que la shell real interpreta, no sobre la cadena cruda

**El error real:** `restrict-cavecrew-bash.sh` denegaba cualquier token
que empezara por `-` con un `grep` de texto crudo sobre
`tool_input.command` — pero comillas y barras invertidas no son "un
`-`" para ese `grep`, aunque para la shell real que ejecuta el comando
sí lo sean una vez las quita. `git log '--output=/tmp/x'` (o con
comillas dobles, o con `\-\-output=` escapado) esconde el `-` inicial
detrás de una comilla en la cadena literal, pasa el filtro, y la shell
real entrega el flag peligroso a `git` igual — reproducido en vivo
escribiendo en archivos reales antes del arreglo. Cuatro rondas
completas hicieron falta solo en este hook: una para el diseño inicial
del filtro, dos para bypasses de RCE vía flags concretos (`git grep
-O`, `git log --output=`) y salto de línea embebido, y una cuarta para
este bypass de comillas.

**Comprobación:** cualquier chequeo de "¿este comando tiene X"
(un flag, un subcomando, una palabra prohibida) sobre una variable de
shell debe tokenizar primero con las mismas reglas de comillas que
usará la shell que ejecute el comando de verdad (`eval "set --
$CMD"` puebla `$@` así, y es seguro de invocar únicamente si un chequeo
previo ya rechazó metacaracteres de encadenado/sustitución como
`;&|<>`, backtick y `$(` — si no, el propio `eval` reabre justo el
hueco que se intenta cerrar) — nunca hacer `grep`/`case` sobre el texto
crudo cuando el objetivo es razonar sobre argumentos ya separados por
espacios/comillas.

## 9. Comparar rutas de archivo entre dos comandos de git exige el mismo
formato sin citar en ambos lados, y ningún comando que colapse directorios

**El error real:** `sync-main.sh` compara la lista de rutas que
`origin/main` cambiaría contra la lista de archivos locales sin
trackear/ignorados, para bloquear un `git merge --ff-only` automático
si hay colisión (evitar sobrescribir en silencio un archivo local). La
primera versión usó `git diff --name-only HEAD..origin/main` contra
`git status --porcelain --ignored=matching` — dos fallos reales,
encontrados por una revisión externa y reproducidos en vivo, no
teóricos:

1. **Citado inconsistente entre comandos.** Sin `-z`, `git status`
   cita (comillas + escapes estilo C) cualquier ruta con espacio o
   carácter no-ASCII; `git diff --name-only` no cita igual. Una ruta
   real colisionando sale como `"mi secreto.txt"` de un lado y `mi
   secreto.txt` del otro — la comparación de cadena exacta nunca
   coincide, la colisión pasa desapercibida, el archivo se sobrescribe
   sin aviso.
2. **Colapso de directorios.** `git status --porcelain`, incluso con
   `--ignored=matching`, colapsa un directorio entero ignorado (o
   enteramente sin trackear) a una sola línea (`!! carpeta/`) cuando el
   propio patrón de `.gitignore` apunta al directorio, no a los
   archivos de dentro — verificado en vivo contra los propios
   directorios ignorados de este repo (`.claude/.pr-review-state/`,
   `graphify-out/cache/`). Una colisión con un archivo *dentro* de esos
   directorios nunca aparece en la lista, así que tampoco se detecta.

**Comprobación:** para cualquier chequeo que compare rutas de archivo
sacadas de dos comandos de git distintos (o del mismo comando en dos
invocaciones):
- Usar `-z` en **todos** los lados de la comparación (`git diff
  --name-only -z`, `git status --porcelain -z`), nunca la salida
  humana por defecto — verificar con una ruta de prueba real que
  contenga un espacio o un carácter no-ASCII, no asumir que "debería
  funcionar igual".
- Si hace falta saber qué archivos concretos hay sin trackear o
  ignorados (no solo si "hay algo"), usar `git ls-files --others
  --exclude-standard -z` (sin trackear) y `git ls-files --others
  --ignored --exclude-standard -z` (ignorados) en vez de `git status
  --porcelain` — `ls-files` nunca colapsa un directorio a una línea,
  `status` sí. Probar contra un directorio ignorado con un archivo
  dentro, en vivo, para confirmarlo — no fiarse de la documentación del
  flag por sí sola (`--ignored=matching` sonaba como si debiera
  expandir, y no lo hacía).

**Segunda vuelta sobre el mismo punto (misma saga, una revisión más
tarde):** con `-z` y `ls-files` ya arreglados, una revisión siguiente
encontró que la comparación seguía siendo solo **igualdad exacta de
cadena** — no detecta que `origin/main` añada un archivo trackeado
*dentro* de una ruta que localmente es un archivo suelto (`foo` local
como archivo; `origin/main` trackea `foo/bar.txt`): ninguna ruta es
igual a la otra, pero el fast-forward destruye `foo` igual para
convertirlo en directorio — verificado en vivo, la misma clase exacta
de pérdida silenciosa que el punto 1 de más arriba, solo que un nivel
de ruta más profundo. **Comparar rutas nunca es solo "¿son iguales?" —
también "¿una es carpeta de la otra?"** en ambos sentidos. Corregido
comprobando, para cada par de rutas, tanto la igualdad como el prefijo
`ruta/` en los dos sentidos.

**Advertencia aparte, no otro bug de este mismo tipo:** si se usa
`case "$ruta_local" in "$ruta_cambiada"/*)` (patrón de `case` de bash)
para la comprobación de prefijo en vez de un `grep` con la ruta
escapada, cualquier carácter de glob literal en el nombre de archivo
(`*`, `?`, `[`) en la ruta usada como *patrón* se interpreta como
comodín, no como carácter literal — pero esto solo puede hacer que el
patrón case cuente *de más* como colisión (nunca de menos), así que el
único efecto es bloquear el auto-heal alguna vez sin que hiciera falta,
nunca dejar pasar una colisión real sin detectar. Aceptado así a
propósito, documentado para que quede claro que es una limitación
conocida y no otro hallazgo pendiente de arreglar.

**Desenlace final de esta saga (6 rondas sobre la comparación precisa,
ver punto 10):** una 7ª ronda encontró que la propia comparación de
listas (un bucle anidado en bash) no tenía cota de tamaño y podía
colgar el arranque de sesión con una rama muy detrás y muchos archivos
sueltos — en ese punto, se abandonó la comparación precisa entera y se
volvió al chequeo más simple ("¿hay algo sin trackear o ignorado, sin
más?"), aceptando que el auto-heal dispare menos veces a cambio de no
tener ningún hueco de los seis encontrados, ni el de rendimiento. Este
punto 9 sigue siendo la lección correcta para el día que haga falta de
verdad comparar rutas con precisión en otro sitio — solo que para
*este* hook en concreto, no hizo falta al final: ver punto 10.

## 10. Antes de comparar/enumerar con precisión en un hook, preguntar
si el chequeo simple (con un coste de falsos positivos aceptable) ya basta

**El error real:** `sync-main.sh` empezó con un chequeo simple
("¿árbol sucio, sí o no?"), lo cambió por uno preciso (comparación de
rutas) para no penalizar el caso común de este repo, y esa precisión
costó 6 rondas de revisión cerrando bypasses reales uno a uno (citado,
colapso de directorios, colisión archivo-vs-carpeta) — hasta que una
7ª ronda encontró que la propia comparación, sin cota de tamaño, podía
colgar el arranque de sesión. El chequeo simple original nunca tuvo
ninguno de esos problemas, porque no compara nada: solo mira si una
salida está vacía.

**Comprobación:** antes de construir una comparación/enumeración
"inteligente" en un hook que debe ser best-effort y nunca bloquear,
preguntar primero: ¿el chequeo simple y conservador (que solo produce
falsos positivos — bloquea de más, nunca de menos) tiene un coste
aceptable? Si el peor caso de "bloquear de más" es solo "el hook avisa
en vez de actuar solo" (nunca pérdida de datos, nunca fallo de sesión),
el chequeo simple casi siempre gana: no tiene rutas de bug propias que
cerrar una por una, y no puede tener un coste de rendimiento que
escale con el tamaño del repo o del cambio. Reservar la comparación
precisa para cuando el falso positivo importa de verdad (bloquea algo
que el usuario necesita que pase sí o sí), y en ese caso, presupuestar
varias rondas de revisión para las sutilezas de las herramientas
subyacentes (aquí, git) antes de darla por simple.

## 11. Si el hook necesita que algo persista entre contenedores efímeros,
que lo persista el propio script, nunca una instrucción que el modelo
debe recordar seguir

**El error real:** `fewer-permission-prompts-reminder.sh` inyecta
contexto pidiéndole a la sesión que corra una skill y luego "deje
constancia" de que lo hizo, escribiendo un marcador con timestamp para
que el propio hook sepa cuándo volver a recordarlo. La primera versión
dejaba el paso de comitear y subir ese marcador como una instrucción
de texto aparte ("si añade patrones nuevos... comitea y sube") — una
revisión encontró que, en el caso más común (sin patrones nuevos que
añadir), esa instrucción nunca se disparaba: el script que escribe el
marcador (`mark-permission-scan.sh`) solo tocaba el disco local del
contenedor, nada lo subía a git, y ese archivo se pierde al reciclarse
el contenedor. Efecto real: el recordatorio se repetía en cada
arranque de sesión sin avanzar nunca los 7 días — exactamente el coste
que el mecanismo existía para evitar. Una segunda versión "arregló" el
texto de la instrucción (forzar "SIEMPRE comitea y sube") pero seguía
dependiendo de que la sesión no se saltara ese segundo paso — una
tercera ronda de revisión encontró que una sesión interrumpida entre
medias reproducía el mismo bug por una vía distinta, y que forzar
"rama+PR nuevo cada vez" además acumulaba PRs casi duplicados sin
fusionar nunca. Solo la cuarta versión, donde `mark-permission-scan.sh`
comitea y sube el marcador él mismo (con reintento tras rebase si el
push choca), quedó realmente determinista.

**Comprobación:** si un hook necesita que algo sobreviva a que el
contenedor se recicle (un marcador, un contador, cualquier estado que
tiene que verse desde la próxima sesión), preguntar desde el diseño
inicial: ¿quién garantiza que ese dato llega a git? Si la respuesta es
"una instrucción en el texto que se inyecta, que la sesión debe
recordar ejecutar", esa es la señal de la misma familia de bug —
moverlo al propio script que escribe el estado (o a un hook
determinista), no a una instrucción de la que depende que el modelo no
se distraiga, se interrumpa, o decida que "ya lo hizo" sin comprobarlo.

## Antes de pedir/lanzar la revisión externa

Repasar estos 11 puntos uno por uno contra el diff, con al menos un
comando ejecutado en vivo por punto que lo confirme (no solo "leído y
parece bien") — así cada ronda de revisión encuentra menos, en vez de
encontrar la misma clase de bug que un pase manual ya podría haber
descartado.
