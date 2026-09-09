---
name: humanizer
description: Use when Angel asks to "humanizar" a text, make it sound less like AI/a chatbot wrote it, or remove AI writing tells before publishing something under his own name (blog posts, emails, messages to alumnos). Triggers: "humanízalo", "que no suene a IA", "/humanizer".
version: 1.1.0
user-invocable: true
license: MIT (adaptado y ampliado de github.com/blader/humanizer)
---

> Adaptado del skill open-source `blader/humanizer` (MIT,
> https://github.com/blader/humanizer). Copiado y reescrito a mano en
> este repo — nunca instalado vía `npx skills add` — para no ejecutar
> código de terceros sin revisar; este archivo es solo texto de
> instrucciones, sin scripts ni dependencias.
>
> Escaneado el 2026-09-09: 0 caracteres Unicode ocultos, de control o
> homóglifos en el archivo (comprobado con `unicodedata`, ver commit).
>
> Ampliado respecto al original en dos cosas: (1) los 25 patrones
> nombrados uno a uno en vez de solo por categoría — el original los
> lista así en su `README.md`, no en el `SKILL.md` que se copia al
> instalar; (2) una sección de tics específicos del **español**, porque
> el original está pensado sobre todo para inglés (dashes, "pivotal",
> "landscape" no tienen equivalente literal en como escribe una IA en
> español).

# Humanizer: reescribir para que no suene a IA

Reescribe texto generado por IA para que suene natural, sin cambiar el
contenido factual. Identifica patrones estructurales que un modelo usa
por defecto y los elimina. Idea central: cada frase que se conserve
debe aportar algo nuevo al lector, y los patrones pesan más cuando
aparecen juntos — los hábitos estructurales (puesta en escena, ritmo
forzado, inflación) delatan más que el vocabulario suelto.

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

## Tics específicos en español (añadido, no está en el original)

El original se escribió pensando en inglés. En español, una IA (yo
incluido) tiende a estos vicios en concreto — revisar estos además de
los 25 de arriba:

- **"No solo... sino también"** como muletilla de todo párrafo de
  cierre, en vez de decirlo directo.
- **"En definitiva" / "en resumen" / "al final del día"** como cierre
  automático de cada sección, aunque no resuma nada nuevo.
- **"Cabe destacar que" / "es importante mencionar que" / "sin duda"**
  como relleno antes de una frase que estaría mejor sin el preámbulo.
- **Enumeraciones de tres adjetivos** calcadas del inglés ("claro,
  conciso y efectivo") que en español suenan más a lista de la compra
  que a prosa.
- **"¡Claro! Aquí tienes..."** o "Espero que esto te sea de ayuda" al
  final — residuo de chatbot, se quita siempre en un texto que se va a
  publicar bajo el nombre de Angel.
- **Sustantivos abstractos en cascada** ("la optimización de la
  metodología de enseñanza") en vez del verbo directo ("optimizar cómo
  enseño").

## Flujo de trabajo

1. Marcar los tics por orden de fuerza (los patrones que aparecen
   juntos delatan más que uno suelto).
2. Reescribir preservando todos los datos y afirmaciones factuales —
   nunca inventar ni quitar información real al "humanizar".
3. Revisar que no queden patrones sin tratar.
4. Si Angel da 2-3 párrafos propios como muestra de su voz, usarlos
   como referencia de tono antes de dar el texto final; si no, variar
   la longitud de frase y evitar que el resultado suene a plantilla.
