# Práctica "Del Problema Científico al Artículo en LaTeX"

Práctica por etapas de Metodología de la Investigación (prof. Vivian López
Batista, curso 2026-2027). Entrega final (artículo LNCS + póster):
**30 de noviembre de 2026**.

Tema: estimación de la calidad de transmisión (QoT) con aprendizaje
automático en la red DWDM ferroviaria Moscú-Kazánskaya – Riazán, a partir
del trabajo de fin de grado de Angel (RUT MIIT, 2026).

| Paso | Contenido | Estado |
|---|---|---|
| 1 | Ficha: problema, pregunta, objetivos, hipótesis (PDF 1 pág.) | `paso-1-planteamiento/` |
| 2 | Búsqueda bibliográfica, `referencias.bib` (8-10 artículos) | `paso-2-bibliografia/` |
| 3 | Diseño experimental: dataset, ≥1 tabla, ≥1 figura | `paso-3-experimento/` |
| 4 | Redacción inversa ("método de la Casa") | pendiente |
| 5 | Maquetación en Overleaf con plantilla LNCS + póster | pendiente (plantilla de clase en `plantilla-lncs/`) |

La ficha se edita en `ficha-paso-1.html` y se regenera el PDF con Chromium:

    /opt/pw-browsers/chromium --headless --no-sandbox --no-pdf-header-footer \
      --print-to-pdf=ficha-paso-1.pdf "file://$PWD/ficha-paso-1.html"

Referencias de la ficha verificadas con Scite y Crossref (2026-09-28).
