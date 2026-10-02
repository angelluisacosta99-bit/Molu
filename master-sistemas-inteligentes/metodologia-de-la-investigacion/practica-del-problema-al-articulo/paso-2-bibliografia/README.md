# Paso 2 — Búsqueda bibliográfica y referencias.bib

Entrega en Studium: archivo `.bib` validado con al menos 8 citas en BibTeX
(apertura 29-sep-2026, cierre 30-oct-2026 15:00).

## Cadenas de búsqueda (Scopus / Web of Science / IEEE Xplore)

1. `("quality of transmission" OR QoT) AND ("machine learning" OR "random forest") AND ("optical network*" OR DWDM)`
2. `("lightpath" AND "QoT" AND classif*)`
3. `("railway" OR "railroad") AND ("optical transport network" OR DWDM) AND ("machine learning")` ← comprobar el vacío
4. `("QoT" AND dataset)`

Scopus y WoS: desde la red de la USAL o con su VPN.

## Los 10 artículos del `referencias.bib` final (exportados de Web of Science; sin retracciones según Crossref)

| Clave | Por qué está |
|---|---|
| morais2018 | ML para estimar QoT en redes DWDM (el más cercano al tema) |
| rottondi2018 | Random Forest entrenado con datos sintéticos (precedente directo) |
| pointurier2021 | Revisión de ML para QoT: marco general |
| kozdrowski2021 | ML con datos reales de un operador DWDM; desbalance de clases |
| aladin2020 | Estimación y pronóstico de QoT; efecto de reducir variables |
| allogba2022 | Tutorial de estimación y pronóstico de QoT |
| yu2019 | Transferencia de modelos entre redes |
| samadi2017 | Trabajo pionero de ML para QoT en WDM |
| igarashi2024 | QoT en sistemas IM/DD (como la red ferroviaria de 10 Gbit/s) |
| dicicco2023 | Pronóstico de QoT con incertidumbre (márgenes) |

Detalle de cada uno en `notas-de-lectura.md`.

## Cómo pasarlo por Zotero (lo que pide la tarea)

1. Instalar Zotero (zotero.org) y su conector para el navegador.
2. En Zotero: botón de la varita («Añadir elemento por identificador») y pegar cada DOI.
3. Seleccionar los 10 → clic derecho → «Exportar elementos…» → formato BibTeX → `referencias.bib`.

## Archivos de esta carpeta
- `referencias.bib`: versión de trabajo para el artículo (exportación de WoS con claves renombradas y el DOI de Samadi añadido; validado con pybtex). Lo entregado en Studium fue la exportación corta sin tocar, renombrada.
- `savedrecs-wos-corto-original.bib`: exportación corta de WoS sin tocar (lo que se entregó).
- `savedrecs-wos-original.bib`: exportación completa de WoS (con resúmenes y referencias citadas).
- `wos-export-2026-09-29.txt`: 50 registros de la búsqueda hecha en clase, de la que se eligieron los 10.
- `referencias-borrador-crossref.bib`: primer borrador generado por DOI desde Crossref, sustituido por la búsqueda en WoS; validado con pybtex (10 entradas).
- `ficha-actualizada-entregada-paso-2.pdf`: la ficha del Paso 1 revisada por Angel
  (29-sep), que entregó junto al Paso 2. Cambios frente a la del Paso 1: pregunta e
  hipótesis ya alineadas con el experimento («con mayor acierto que un modelo lineal
  sencillo»), limitación de datos sintéticos y referencias [1] Pointurier 2021,
  [2] Mata et al. 2018 (ICTON, DOI 10.1109/ICTON.2018.8473819, verificado en Crossref)
  y [3] Kozdrowski et al. **Ojo para el artículo:** la frase «incluso con modelos
  entrenados con datos sintéticos [3]» cita a Kozdrowski, que usa datos **reales**;
  el precedente con datos sintéticos es Rottondi 2018. Mata 2018 no está en
  `referencias.bib` (habrá que añadirlo si se cita). Kozdrowski: año 2021 (vol. 23;
  en línea desde el 22-dic-2020), como en el `.bib`.
- `notas-de-lectura.md`: resumen de los 10 artículos y lecciones para el diseño experimental.
