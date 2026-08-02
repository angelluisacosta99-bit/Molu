# Materiales

Ejercicios, fichas y recursos ligeros (Markdown, PDFs pequeños) que usas
en las clases. Organiza por nivel o por tema según prefieras, por ejemplo:

```
materiales/
├── a1/
├── a2/
├── b1/
└── quizlet/
```

## Plantillas de Quizlet (`quizlet/`)

Plantillas de tarjetas para Quizlet, **genéricas y reutilizables para
cualquier alumno** (no van dentro de la carpeta de un alumno concreto,
ni deben incluir su nombre). Un archivo por unidad/capítulo del libro
correspondiente.

Convención de nombres: `libro-y-nivel_unidadX.md` (ej.
`nuevo-espanol-en-marcha-1_unidad1.md`).

Cada plantilla incluye:

- Tablas de referencia por categoría (vocabulario, gramática, etc.),
  con la traducción en el idioma nativo por defecto de tus alumnos
  (ruso). Si algún alumno tiene otro idioma nativo, adapta esa columna
  antes de importar.
- Un bloque final ya formateado para pegar directamente en el
  importador de Quizlet (Crear set → Importar): tabulador entre
  término y definición, salto de línea entre tarjetas.

Para usarla con un alumno: copia el bloque de importación en un set
nuevo de Quizlet y compártelo con él. El archivo en sí queda igual
para reutilizarlo con el siguiente alumno.
