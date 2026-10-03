# Trabajo final de la asignatura (cierre: 30 de noviembre de 2026, 23:00)

## Enunciado (Studium, literal)

Tarea «Envío del trabajo Primera Convocatoria»: *Entrega de un artículo
científico y un póster.* Instrucciones:

> Cada alumno debe entregar dos trabajos:
>
> 1) Debes entregar un artículo en Inglés o en Castellano, empleando la
> plantilla de Lecture Notes. Para ello puedes copiar un artículo existente,
> porque lo que nos interesa es que el alumno se enfrente al trabajo con
> Latex, pero serán más valorados los artículos originales. En el artículo
> debemos tener gráficos, tablas, que nos permitan ver el trabajo con los
> recursos de Latex. Debemos incorporar la bibliografía correspondiente.
>
> 2) Debemos crear una plantilla para la creación de posters. Para ello puedes
> utilizar alguna de las 5 plantillas suministradas o bien buscar alguna otra
> plantilla en internet. Nos interesa que las plantillas sean muy ricas en
> color, muy vistosas. Además hay que adaptarlas como si fueran para el
> departamento. Tenéis que tener en cuenta la imagen corporativa de la
> Universidad. La bibliografía es interesante incorporarla también.
>
> El envío se realizará con la tarea habilitada para ello. Se debe enviar un
> comprimido único con el nombre del alumno (con los ficheros de cada una de
> las opciones en directorios que lo identifiquen) con todos los ficheros
> fuente empleados en latex, así como el pdf o ps resultado.

## Plan

Base: el artículo del Paso 5 (`../paso-5-latex/`), que se entrega tal cual en
el Paso 5. La versión del trabajo final lo amplía con dos análisis de
robustez (`analisis_sensibilidad.py` → `resultados/sensibilidad.txt`):

1. **Ruido de medida de la potencia recibida** (σ = 0,5; 1,0; 1,5; 2,0 dB).
2. **Umbral de decisión** (barrido 0,1-0,9 y punto de operación con la misma
   sensibilidad que la logística, elegido en el entrenamiento).

Artículo del trabajo final: `articulo/` (copia del Paso 5 en la que
`main.tex` ya es el original y se edita a mano, sin `generar_tex.py`).
Añade a la versión del Paso 5: un párrafo de métodos de robustez, la
Tabla 3 (ruido de medida), la Fig. 4 (`figuras/fig4_umbral`, compromiso
no detectados / falsas alarmas al mover el umbral), y los cambios
correspondientes en resumen, aportaciones, discusión y conclusiones.
Resultado clave: a igual sensibilidad los tres modelos se igualan
(RF 4/91, XGB 3/117, RL 3/88 FN/FP en la prueba).

Pendiente: póster (plantilla moderna adaptada a la imagen de la USAL y
del Departamento de Informática y Automática).
