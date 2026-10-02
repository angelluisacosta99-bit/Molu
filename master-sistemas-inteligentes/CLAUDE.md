# Reglas para los trabajos del máster (MUSI)

## Regla inquebrantable: citar cada tabla y figura en el texto ANTES de que aparezca

Toda tabla, figura, gráfica, dibujo o esquema de cualquier entregable
(fichas, resúmenes, artículo LNCS, póster, memoria del TFM, presentación)
debe estar **citado por su número en el texto antes de su posición**, con
una frase que diga qué muestra. Por ejemplo: «En la Tabla 1 se recogen las
métricas...», «La Fig. 2 compara...». Luego va la tabla/figura con su
número y su pie.

- Sin excepciones. Una tabla o figura sin cita previa quita puntos
  (lo exige la prof. Vivian López Batista, Metodología de la
  Investigación, 2026-09-30) y es buena práctica en todo el máster.
- Numeración correlativa (Tabla 1, 2...; Fig. 1, 2...), y que el número
  citado coincida con el del pie.
- En LaTeX: `\label{}` en cada tabla/figura y citarla con `\ref{}` en un
  párrafo anterior al entorno `table`/`figure`. Tras compilar, comprobar
  que no hay `??` y que ningún flotante cae antes de su primera cita.
- Antes de dar por terminado un entregable, repasarlo buscando cada
  «Tabla N» / «Fig. N» y verificar que su primera mención está antes que
  el elemento.
