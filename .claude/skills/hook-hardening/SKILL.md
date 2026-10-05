---
name: hook-hardening
description: "Use before declaring \"done\", \"tested\", or \"ready to commit\" on any shell script that runs unattended in a future session or on behalf of the harness — SessionStart/PreToolUse/Stop hooks, or any fail-open/fail-closed security gate. Also use before writing one, not just after. Checklist to catch a known family of bugs before an external review has to."
---

# hook-hardening

Lista de comprobación para scripts que corren sin supervisión (hooks de
`.claude/hooks/`, gates de seguridad). Cada punto nace de un bug real
que una revisión externa encontró después de dar el trabajo por
terminado. Córrela *antes* de decir "hecho": no sustituye a la revisión,
pero hace que encuentre cada vez menos.

**Regla general, no solo para hooks:** si dejar un mismo
archivo/hook/PR limpio necesita 3 o más rondas de revisión→corrección,
guarda la lección: para un hook, aquí; para otro tipo de código, en la
skill de ese dominio o en `recursos-generales/herramientas-ia/novedades.md`
(ver `CLAUDE.md`, sección "3+ rondas de revisión sobre lo mismo").

**Cada punto lleva el comando o patrón exacto que lo comprueba.** Si no
puedes marcar un punto con algo concreto que corriste, no está
comprobado.

## 1. Todo código de salida se comprueba antes de declarar éxito

**Error:** añadir `timeout N comando` y seguir imprimiendo "instalado"
en la línea siguiente, sin mirar si `comando` falló, lo mató el timeout
o tuvo éxito.

**Comprobación:** para cada comando externo (binario de terceros,
`npm install`, `git`, `curl`...), ¿el mensaje de éxito está dentro de
`if comando; then éxito; else fallo (non-blocking); fi`, o es una línea
suelta tras un `comando >/dev/null 2>&1` sin usar su `$?`? Lo segundo es
el bug.

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

**Error:** un chequeo de versión (`binario --version`) añadido para
arreglar otro bug se coló sin `timeout`, reintroduciendo el fallo de
"puede colgarse para siempre" que el resto del archivo ya corregía.

**Comprobación:** leer el script de arriba a abajo (o
`grep -n "^\s*[a-zA-Z_.-]\+ .*\$" archivo.sh`): todo comando que no sea
un builtin de bash (`[`, `test`, `command -v`, `echo`, `cd`) y dependa
de un binario externo, ¿lleva `timeout N` delante? Un comando nuevo que
no copie el patrón ya establecido en el archivo es sospechoso por
definición.

## 3. Antes de inventar un mecanismo, buscar si ya existe uno oficial

**Error:** para persistir una variable de entorno de un hook
`SessionStart` hacia las llamadas posteriores del Bash tool se escribió
en `/etc/profile.d/`, por analogía con cómo el proxy del contenedor
persiste `HTTPS_PROXY`. Claude Code tiene un mecanismo documentado para
exactamente eso: `$CLAUDE_ENV_FILE` (skill `session-start-hook`).

**Comprobación:** si la pregunta es "¿cómo persiste X entre A y B en
este entorno?", carga primero la skill relevante del propio harness
(`session-start-hook`, `fewer-permission-prompts`, `update-config`...)
antes de copiar un patrón de otra herramienta. Un mecanismo parecido que
funciona para una cosa (certificados CA de un proxy) no implica que
funcione para otra (variables de entorno hacia el Bash tool): son
consumidores distintos con reglas de arranque distintas.

## 4. "Probado de punta a punta" solo cuenta si reproduce la invocación real

**Error:** para probar que una variable llegaba a una llamada nueva del
Bash tool se usó `env -i ... bash -lc '...'`. El `-l` (login shell) lee
`/etc/profile.d/`, que era justo lo que había que demostrar. El Bash
tool real invoca `bash -c '...'` (sin `-l`), que no lo lee: la prueba
pasó porque se activó a mano el comportamiento que se validaba.

**Comprobación:** ¿la prueba usa el mismo binario, los mismos flags y el
mismo mecanismo de invocación que el consumidor real (Bash tool, hook,
CI)? Si no estás seguro de cómo invoca algo el consumidor, compruébalo
en vivo en el contexto real, no en una subshell construida a medida:

```bash
cat /proc/$$/cmdline | tr '\0' ' '; echo
```

**Corolario: el texto que un hook INYECTA no lo ejecuta el hook.** Un
comando dentro de una instrucción inyectada por `SessionStart` lo corre
el Bash tool de la sesión, que no comparte entorno con el hook. En
concreto, `CLAUDE_PROJECT_DIR` existe para los procesos de hook pero
**no** está definida en el Bash tool (`echo "${CLAUDE_PROJECT_DIR:-<VACIA>}"`
desde una llamada normal devuelve vacío). Anclar una ruta a
`$CLAUDE_PROJECT_DIR` es correcto *dentro* del script del hook, pero
*dentro del texto inyectado* se expande a `/.claude/hooks/...` y falla
siempre. En una instrucción inyectada usa algo que el Bash tool resuelva
solo, como `$(git rev-parse --show-toplevel)`.

**Mismo error, un nivel más abajo:** arreglar la ruta del texto inyectado
no basta si el script que invoca también se fía de la variable. Un
script que resolvía la raíz con `"${CLAUDE_PROJECT_DIR:-.}"` en cinco
sitios caía siempre en el cwd (la variable está vacía en el Bash tool):
invocado desde una subcarpeta, escribía y comiteaba el marcador en
`<subcarpeta>/.claude/`, mientras el hook que lo lee miraba la raíz y no
lo encontraba nunca. El recordatorio se repetía en cada arranque (el
bug del punto 11 por otra vía).

**Comprobación:** cuando descubras que una variable no llega a un
consumidor, haz `grep` de esa variable en **todo** el camino de
ejecución (el hook, el texto que inyecta y cada script que ese texto
invoca) y arréglalos a la vez. Resuelve la raíz **una sola vez** al
principio del script, con un respaldo que no dependa del harness
(`git rev-parse --show-toplevel`), y usa esa variable en todas partes:
cada `"${CLAUDE_PROJECT_DIR:-.}"` repetido es un sitio más donde el
fallback silencioso puede morder.

## 5. Tras cualquier intento de arreglo, re-verificar, no asumir

**Error:** tras detectar una versión desajustada y lanzar una
reinstalación, el script no volvía a comprobar la versión: si la
reinstalación fallaba (red bloqueada), reportaba éxito con el binario
viejo.

**Comprobación:** todo `if condición_de_fallo; then intentar_arreglo; fi`
necesita, justo después, volver a evaluar la condición original antes de
decidir qué mensaje mostrar. Que `intentar_arreglo` se ejecutara no
prueba que funcionara.

## 6. Decir exactamente lo que un chequeo garantiza, ni más ni menos

**Error:** un pin de versión que impide que este *script* instale una
versión sin fijar se documentó como si impidiera "usar" el binario. Solo
evita que el hook lo configure o dependa de él: ningún `PreToolUse`
bloquea una llamada directa por Bash con otra versión (a diferencia de
`check-pr-review.sh`, un gate técnico real sobre `merge_pull_request`).

**Comprobación:** para cada afirmación "esto impide X", ¿es un gate
técnico (bloquea la acción; verificable en `.claude/settings.json` más un
hook `PreToolUse`) o una conveniencia de configuración (algo deja de
prepararse, pero sigue siendo posible por otra vía)? Si es lo segundo,
escribe "evita que X se configure/dependa de esto", no "impide usar X".

## 7. Probar en vivo contra estado compartido puede ensuciar lo que vas a comitear

**Error:** probar en vivo hooks que llaman a un CLI con estado global
fuera del repo (`claude plugin`, `~/.claude/settings.json`,
`~/.claude/plugins/...`) puede mutar ese estado, tanto con tus pruebas
como con las de una revisión (que comparte el mismo `HOME`, incluso
desde un worktree). Si parte de ese estado también se escribe en un
archivo del *proyecto* (`.claude/settings.json`), una prueba ajena puede
dejar ahí un cambio no pedido, listo para comitearse: apareció una
entrada de marketplace a nivel de proyecto que no coincidía con el
diseño y no se pudo reproducir qué comando la escribió.

**Comprobación:** antes de comitear un archivo de configuración
compartido (`.claude/settings.json` y similares) tras pruebas en vivo,
mira el diff completo de ese archivo, no solo los que creías haber
tocado. Si aparece algo que no pediste, investiga primero (¿el comando
documentado lo reproduce en un estado limpio?). Si no puedes explicar su
origen, descártalo (`git stash drop` o similar) en vez de asumir que es
inofensivo porque no rompe nada visible.

## 8. Un filtro de texto sobre un comando de shell debe operar sobre lo que la shell real interpreta

**Error:** `restrict-cavecrew-bash.sh` denegaba tokens que empezaran por
`-` con un `grep` de texto crudo sobre `tool_input.command`. Comillas y
barras invertidas no son `-` para ese `grep`, pero la shell las quita:
`git log '--output=/tmp/x'` (o con comillas dobles, o `\-\-output=`)
pasa el filtro y la shell entrega el flag peligroso a `git`; se
reprodujo escribiendo en archivos reales. Otros bypasses del mismo
filtro: flags concretos que dan ejecución de código (`git grep -O`,
`git log --output=`) y saltos de línea embebidos.

**Comprobación:** cualquier chequeo "¿este comando tiene X?" (un flag,
un subcomando, una palabra prohibida) debe tokenizar primero con las
mismas reglas de comillas que usará la shell real: `eval "set -- $CMD"`
puebla `$@` así, y solo es seguro si un chequeo previo ya rechazó los
metacaracteres de encadenado/sustitución (`;&|<>`, backtick, `$(`); si
no, el propio `eval` reabre el hueco. Nunca hagas `grep`/`case` sobre el
texto crudo cuando el objetivo es razonar sobre argumentos ya separados.

## 9. Comparar rutas entre dos comandos de git exige el mismo formato sin citar y ningún comando que colapse directorios

**Error:** `sync-main.sh` comparaba las rutas que `origin/main`
cambiaría con los archivos locales sin trackear o ignorados, para
bloquear un `git merge --ff-only` automático ante una colisión. Con
`git diff --name-only HEAD..origin/main` contra
`git status --porcelain --ignored=matching` hubo tres fallos reales,
reproducidos en vivo:

1. **Citado inconsistente.** Sin `-z`, `git status` cita (comillas y
   escapes estilo C) las rutas con espacio o no-ASCII y
   `git diff --name-only` no: `"mi secreto.txt"` frente a
   `mi secreto.txt` nunca coinciden, la colisión pasa y el archivo se
   sobrescribe sin aviso.
2. **Colapso de directorios.** `git status --porcelain`, incluso con
   `--ignored=matching`, colapsa un directorio ignorado (o entero sin
   trackear) a una línea (`!! carpeta/`) cuando el patrón de
   `.gitignore` apunta al directorio. Una colisión con un archivo
   *dentro* nunca aparece (verificado con `.claude/.pr-review-state/` y
   `graphify-out/cache/`).
3. **Solo igualdad exacta.** Si `foo` es un archivo suelto local y
   `origin/main` trackea `foo/bar.txt`, ninguna ruta es igual a la otra,
   pero el fast-forward destruye `foo` al convertirlo en directorio.

**Comprobación:** para cualquier chequeo que compare rutas de dos
comandos de git (o del mismo en dos invocaciones):
- Usa `-z` en **todos** los lados (`git diff --name-only -z`,
  `git status --porcelain -z`), nunca la salida humana, y verifica con
  una ruta real que tenga un espacio o un carácter no-ASCII.
- Si necesitas saber qué archivos concretos hay sin trackear o
  ignorados, usa `git ls-files --others --exclude-standard -z` y
  `git ls-files --others --ignored --exclude-standard -z`, no
  `git status --porcelain`: `ls-files` nunca colapsa un directorio.
  Pruébalo contra un directorio ignorado con un archivo dentro; no te
  fíes de la documentación del flag (`--ignored=matching` suena a que
  expande y no lo hace).
- Comparar rutas nunca es solo "¿son iguales?": comprueba también si una
  es carpeta de la otra, en ambos sentidos (igualdad y prefijo `ruta/`
  en los dos lados).
- Si usas un `case "$local" in "$cambiada"/*)` para el prefijo, un
  carácter de glob literal en el nombre (`*`, `?`, `[`) actúa como
  comodín en el patrón. Eso solo puede contar *de más* como colisión
  (bloquea el auto-heal alguna vez sin hacer falta), nunca de menos:
  limitación aceptada a propósito.
- Si tanta precisión no compensa, ver el punto 10: a menudo basta un
  chequeo simple con falsos positivos aceptables.

## 10. Antes de comparar o enumerar con precisión en un hook, preguntar si el chequeo simple (con falsos positivos aceptables) ya basta

**Error:** `sync-main.sh` pasó de "¿árbol sucio, sí o no?" a una
comparación precisa de rutas para no penalizar el caso común. Esa
precisión costó seis rondas cerrando bypasses (punto 9), y una séptima
encontró que la comparación (un bucle anidado en bash) no tenía cota de
tamaño y podía colgar el arranque de sesión con una rama muy detrás y
muchos archivos sueltos. Se volvió al chequeo simple, que nunca tuvo
esos problemas porque solo mira si una salida está vacía.

**Comprobación:** antes de construir una comparación "inteligente" en un
hook best-effort que nunca debe bloquear, pregunta si el chequeo simple y
conservador (solo falsos positivos: bloquea de más, nunca de menos) tiene
un coste aceptable. Si el peor caso es "el hook avisa en vez de actuar
solo" (nunca pérdida de datos ni fallo de sesión), casi siempre gana: no
tiene rutas de bug propias que cerrar una por una ni un coste que escale
con el tamaño del repo. Reserva la comparación precisa para cuando el
falso positivo bloquea algo que el usuario necesita que pase, y entonces
presupuesta varias rondas para las sutilezas de las herramientas
subyacentes (git).

## 11. Si el hook necesita que algo persista entre contenedores efímeros, que lo persista el propio script

**Error:** `fewer-permission-prompts-reminder.sh` inyecta contexto que
pide a la sesión correr una skill y escribir un marcador con timestamp,
para saber cuándo volver a recordarlo. Comitear y subir el marcador era
una instrucción de texto aparte ("si añade patrones nuevos... comitea y
sube"): en el caso común (sin patrones nuevos) nunca se disparaba, el
marcador solo tocaba el disco del contenedor y se perdía al reciclarse,
y el recordatorio se repetía en cada arranque sin avanzar los 7 días.
Forzar "SIEMPRE comitea y sube" seguía dependiendo de que la sesión no
se saltara el segundo paso (una sesión interrumpida reproducía el bug) y
acumulaba PRs casi duplicados. Solo quedó determinista cuando
`mark-permission-scan.sh` comitea y sube el marcador él mismo, con
reintento tras rebase si el push choca.

**Comprobación:** si un hook necesita que un estado sobreviva al reciclado
del contenedor (marcador, contador...), pregunta desde el diseño: ¿quién
garantiza que llega a git? Si la respuesta es "una instrucción en el
texto inyectado que la sesión debe recordar ejecutar", es la misma
familia de bug: muévelo al script que escribe el estado (o a un hook
determinista), no a una instrucción de la que dependa que el modelo no
se distraiga, se interrumpa o decida que "ya lo hizo" sin comprobarlo.

## Antes de pedir o lanzar la revisión externa

Repasa estos 11 puntos uno por uno contra el diff, con al menos un
comando ejecutado en vivo por punto que lo confirme (no solo "leído y
parece bien"), para que cada ronda de revisión encuentre menos.
