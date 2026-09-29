# Paso 2 — Búsqueda bibliográfica y referencias.bib

Entrega en Studium: archivo `.bib` validado con al menos 8 citas en BibTeX
(apertura 29-sep-2026, cierre 30-oct-2026 15:00).

## Cadenas de búsqueda (Scopus / Web of Science / IEEE Xplore)

1. `("quality of transmission" OR QoT) AND ("machine learning" OR "random forest") AND ("optical network*" OR DWDM)`
2. `("lightpath" AND "QoT" AND classif*)`
3. `("railway" OR "railroad") AND ("optical transport network" OR DWDM) AND ("machine learning")` ← comprobar el vacío
4. `("QoT" AND dataset)`

Scopus y WoS: desde la red de la USAL o con su VPN.

## Los 10 artículos (metadatos de Crossref; sin retracciones según Crossref y Scite, 2026-09-29)

| Clave | Por qué está |
|---|---|
| pointurier2021 | Revisión de ML para QoT: marco general |
| musumeci2019 | Revisión muy citada de ML en redes ópticas |
| mata2018survey | Revisión de IA en redes ópticas (Univ. Valladolid) |
| mata2018icton | Random Forest para clasificar lightpaths (~99,9 %) |
| rottondi2018 | Clasificador de QoT entrenado con datos sintéticos |
| kozdrowski2020 | ML con datos reales de un operador DWDM |
| fu2021 | QoT con ML + ecuación de propagación (datos simulados) |
| damico2020 | ML en el controlador de una línea óptica real |
| bergk2021 | Colección pública de datasets de QoT |
| santos2024 | Dataset experimental público para ML en comunicaciones ópticas |

## Cómo pasarlo por Zotero (lo que pide la tarea)

1. Instalar Zotero (zotero.org) y su conector para el navegador.
2. En Zotero: botón de la varita («Añadir elemento por identificador») y pegar cada DOI.
3. Seleccionar los 10 → clic derecho → «Exportar elementos…» → formato BibTeX → `referencias.bib`.

`referencias.bib` = exportación final de Web of Science (10 registros, claves renombradas, DOI de Samadi añadido; validado con pybtex). `savedrecs-wos-original.bib` = exportación sin tocar. `referencias-borrador-crossref.bib` = borrador anterior generado por DOI,
validada con pybtex (10 entradas, sin errores).
