---
name: humanizer
description: Use when Angel asks to "humanizar" un texto para un blog, post en redes o mensaje bajo su propio nombre — hacer que no suene a chatbot. NO usar en trabajos de universidad/máster ni en el TFM (fuera de alcance a propósito, ver nota abajo). Triggers: "humanízalo", "que no suene a IA", "/humanizer".
version: 1.2.0
user-invocable: true
license: MIT (adaptado y ampliado a partir de varios skills open-source, ver fuentes)
---

> **Fuentes** (todas MIT/open-source, leídas y adaptadas a mano — nunca
> instaladas vía `npx`/CLI, cero código de terceros ejecutado):
> - https://github.com/blader/humanizer — los 25 patrones base.
> - https://github.com/conorbronsdon/avoid-ai-writing — perfil de voz
>   y el ciclo de "iterar hasta converger".
> - https://github.com/lguz/humanize-writing-skill — el marco de
>   3 pasadas (vocabulario → estructura → textura humana) y la idea de
>   niveles de palabras prohibidas.
> - Todas citan como referencia de fondo el ensayo de Wikipedia
>   "Signs of AI writing" (no se pudo acceder directamente por proxy de
>   red, referenciado de segunda mano vía las tres fuentes de arriba).
>
> Escaneado el 2026-09-09 con `unicodedata` (caracteres ocultos, de
> control, homóglifos): 0 encontrados, en cada revisión.
>
> **Alcance a propósito, no me lo vuelvas a pedir para trabajos
> académicos:** este skill es para contenido bajo el nombre de Angel
> sin evaluación de por medio (posts de blog, redes, mensajes). Angel y
> yo ya hablamos de esto — para trabajos de máster/TFM la respuesta
> sigue siendo no, es fraude académico, no una cuestión de estilo.

# Humanizer: reescribir para que no suene a IA (solo blog/redes/mensajes)

Reescribe texto generado por IA para que suene natural, sin cambiar el
contenido factual. Identifica patrones estructurales que un modelo usa
por defecto y los elimina. Idea central: cada frase que se conserve
debe aportar algo nuevo al lector, y los patrones pesan más cuando
aparecen juntos.

## Perfil de voz (opcional)

Si Angel no indica nada, usar por defecto un tono **cálido pero
profesional** — encaja con su perfil de profesor de español. Si pide
otro, el que indique gana sobre el default:

- **cercano/casual** — conversacional, primera persona, contracciones.
- **profesional** — medido, formal, propio de una plataforma seria.
- **cálido** (default) — cercano, empático, conexión humana — el que
  mejor encaja con captar alumnos.
- **directo** — sin rodeos, afirmaciones seguras, cero relleno.

## Proceso en 3 pasadas

1. **Quitar vocabulario de IA** — sustituir palabras sobreusadas (ver
   lista de abajo) por su equivalente concreto y directo.
2. **Romper estructuras de IA** — eliminar los 25 patrones catalogados
   más abajo (negación en espejo, tríadas, preguntas retóricas
   forzadas, revelaciones dramáticas de cierre).
3. **Añadir textura humana** — variar la longitud de las frases,
   permitir contracciones/coloquialismos donde encajen, no cerrar cada
   idea con un lazo perfecto (una idea humana a veces queda abierta).

## Iterar hasta converger

Por defecto, hacer **dos pasadas como máximo**:
1. Primera pasada: aplicar el proceso de arriba sobre todo el texto.
2. Segunda pasada: revisar el resultado buscando patrones que hayan
   sobrevivido (transiciones recicladas, vaguedad residual, un cierre
   dramático que se coló).

No hacer una tercera pasada por defecto — a partir de ahí el coste de
regenerar no suele encontrar nada nuevo. Si Angel pide explícitamente
"sigue afinando", repetir el ciclo desde cero (no se acumula sobre la
segunda pasada). Indicar siempre si convergió en 1 o 2 pasadas.

## Los 25 patrones (5 categorías)

**A. Puesta en escena en vez de afirmar directamente** (5)
1. Contraste "no es X, es Y" forzado.
2. Fragmentos dramáticos de una línea como cierre.
3. Frases hechas huecas ("al final del día", "la realidad es que...").
4. "Run-ups" — un preámbulo largo antes de decir lo importante.
5. Objeciones que se plantean pero nunca se resuelven.

**B. Ritmo por regla, no por oído** (6)
6. Tríadas forzadas ("claro, directo y efectivo").
7. Aperturas de párrafo repetidas (mismo arranque una y otra vez).
8. Guiones/rayas usados como conector en exceso.
9. Calificadores apilados ("realmente muy claramente importante").
10. Guiones innecesarios entre palabras que no los necesitan.
11. Construcciones pasivas que esconden quién hace la acción.
   *(añadido de otras fuentes: preguntas retóricas forzadas como
   apertura — "¿Te has preguntado alguna vez...?" — y estructuras
   espejo entre frases consecutivas.)*

**C. Inflación y autoridad prestada** (7)
12. Vocabulario sobreusado ("clave", "fundamental", "panorama").
13. Importancia inflada de algo que no la tiene.
14. Asociaciones vagas ("estudios demuestran...", sin decir cuáles).
15. Participios superficiales que suenan a informe corporativo.
16. Lenguaje de anuncio/venta en vez de explicación directa.
17. Experiencia/autoridad fingida ("como experto en...").
18. Cópulas con relleno ("es importante señalar que", "cabe destacar").

**D. Formato por regla** (3)
19. Negrita decorativa sin necesidad real.
20. Títulos cargados de emojis.
21. Comillas tipográficas curvas donde no aportan nada.

**E. Restos de chat y borrador** (4)
22. Envoltorios de chatbot ("¡Por supuesto! Aquí tienes...").
23. Avisos de límite de conocimiento que en realidad son una excusa.
24. Encabezados repetidos que ya dice el título.
25. Referencias a versiones/fechas que ya no aplican.

## Vocabulario prohibido (por niveles)

**Nivel 1 — cortar siempre, sin excepción:** clave, fundamental,
panorama, sin duda, cabe destacar, es importante señalar, en
definitiva/en resumen (como cierre automático), no solo... sino
también (como muletilla), landscape/pivotal/leverage/delve/tapestry/
seamless/robust si aparecen calcados del inglés.

**Nivel 2 — sospechoso, revisar caso a caso:** clave (como adjetivo
suelto: "un factor clave" a veces sí es preciso), transformador,
holístico, robusto, alineado, potenciar (irónico dado el nombre del
skill — vale si describe algo real, no como relleno).

## Tics específicos en español (no está en las fuentes originales,
añadido por mí)

- **"No solo... sino también"** como muletilla de cierre de párrafo.
- **"En definitiva" / "en resumen" / "al final del día"** como cierre
  automático que no resume nada nuevo.
- **"Cabe destacar que" / "es importante mencionar que" / "sin duda"**
  como relleno antes de una frase que iría mejor directa.
- **Enumeraciones de tres adjetivos** calcadas del inglés ("claro,
  conciso y efectivo") — en español suenan a lista de la compra.
- **"¡Claro! Aquí tienes..."** o "espero que esto te sea de ayuda" —
  residuo de chatbot, se quita siempre en texto publicado bajo el
  nombre de Angel.
- **Sustantivos abstractos en cascada** ("la optimización de la
  metodología de enseñanza") en vez del verbo directo ("optimizar cómo
  enseño").

## Flujo de trabajo final

1. Marcar los tics por orden de fuerza (los patrones que aparecen
   juntos delatan más que uno suelto).
2. Aplicar el proceso de 3 pasadas con el perfil de voz que corresponda.
3. Reescribir preservando todos los datos y afirmaciones factuales —
   nunca inventar ni quitar información real al "humanizar".
4. Segunda pasada de revisión (ver "Iterar hasta converger").
5. Si Angel da 2-3 párrafos propios como muestra de su voz, usarlos
   como referencia de tono antes de dar el texto final.
6. Indicar al final cuántas pasadas hicieron falta y qué patrones se
   quitaron, para que Angel vea el criterio aplicado, no solo el
   resultado.
