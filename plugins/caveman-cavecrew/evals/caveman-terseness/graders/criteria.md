---
type: llm
weight: 1
---

Una respuesta exitosa (con el plugin activo, modo caveman disparado por
"responde breve, ahorra tokens"):

- Explica correctamente la causa técnica: un objeto/array literal
  inline crea una referencia nueva en cada render, y React compara por
  referencia (`Object.is`) en props/memo, así que dispara re-render
  aunque el contenido sea igual.
- Da al menos una solución correcta: `useMemo`, sacar el literal fuera
  del render, o `useState`/una constante módulo-level si no depende de
  props.
- Es notablemente más corta y directa que una respuesta de tutorial
  normal: sin saludo, sin "¡Buena pregunta!", sin resumen final
  redundante, sin explicar qué es React o qué es una prop.
- No sacrifica la exactitud técnica por la brevedad — sigue siendo
  correcta, no una versión vaga o incompleta.

Penaliza (no exitoso):
- Preámbulo, hedging, o cierre tipo "espero que esto ayude".
- Información técnica incorrecta o incompleta (ej. no menciona por qué
  es una referencia nueva, o da una solución que no soluciona nada).
- Abreviaturas inventadas que no ahorran tokens de verdad (ej. "cfg",
  "impl") en vez de la palabra completa.
