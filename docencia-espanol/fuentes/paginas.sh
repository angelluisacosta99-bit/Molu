#!/usr/bin/env bash
#
# Saca de un PDF todo lo que hace falta para transcribir un capítulo: el texto en orden de
# lectura, la página renderizada como imagen (para MIRARLA), y las imágenes incrustadas.
#
# Existe porque el conector de Google Drive solo devuelve el texto del PDF, ya aplanado y a
# veces desordenado, y su descarga del archivo entero falla. Con el PDF adjuntado al chat
# —que sí llega al disco— estas tres cosas salen en un comando.
#
# Uso:  ./paginas.sh <archivo.pdf> <primera> [última] [carpeta-salida]
#
# Ejemplo (unidad 6B del cuaderno de A1, que está en la página 29):
#   ./paginas.sh /root/.claude/uploads/<sesión>/xxx-cuaderno.pdf 29
#
# Lo que deja en la carpeta de salida:
#   texto.txt         pdftotext -layout, que respeta columnas y tablas
#   pagina-NN.jpg     la página tal cual se ve, para abrirla con la herramienta Read
#   incrustada-*.png  las imágenes que el PDF lleva dentro, a su resolución original
#
# IMPORTANTE, y es la razón principal de que exista este script: **mira siempre la página
# renderizada antes de dar un capítulo por cerrado**, aunque el texto se haya extraído
# perfectamente. Hay contenido que el texto no puede representar y que cambia las
# respuestas: las líneas de un ejercicio de relacionar, los ítems que el libro ya trae
# resueltos, las respuestas rodeadas, las flechas. En la unidad 6B se transcribió el
# ejercicio 1 con diez huecos cuando el libro trae el primero resuelto — con una línea
# dibujada de «Pon» a «g la televisión», invisible en el texto extraído. Se descubrió al
# ver la foto de la página, no antes.

set -euo pipefail

PDF="${1:-}"
DESDE="${2:-}"
HASTA="${3:-${2:-}}"
OUT="${4:-}"

if [ -z "$PDF" ] || [ -z "$DESDE" ]; then
  echo "uso: paginas.sh <archivo.pdf> <primera> [última] [carpeta-salida]" >&2
  exit 1
fi
if [ ! -f "$PDF" ]; then
  echo "no existe el archivo: $PDF" >&2
  exit 1
fi

# Por defecto se escribe fuera del repo: son páginas de un libro con copyright, material de
# trabajo intermedio. Lo que se archiva en fuentes/ es la transcripción, nunca el escaneo.
if [ -z "$OUT" ]; then
  OUT="${TMPDIR:-/tmp}/paginas-$(basename "${PDF%.*}")-$DESDE-$HASTA"
fi
mkdir -p "$OUT"

echo "PDF:      $PDF"
pdfinfo "$PDF" 2>/dev/null | grep -E '^(Pages|Page size)' || true
echo "Páginas:  $DESDE-$HASTA"
echo "Salida:   $OUT"
echo

# 0. Diagnóstico previo, tomado de la skill /mnt/skills/public/pdf-reading (ver SKILL.md).
#    Dice de antemano qué esperar del texto, en vez de descubrirlo al leerlo mal.
FUENTES=$(pdffonts "$PDF" 2>/dev/null | tail -n +3 || true)
if [ -z "$FUENTES" ]; then
  echo "· pdffonts: SIN FUENTES → escaneado / solo imagen."
  echo "  pdftotext no va a devolver nada: transcribe mirando pagina-*.jpg."
else
  echo "· pdffonts: $(echo "$FUENTES" | wc -l) fuente(s)"
  if echo "$FUENTES" | grep -qE 'Custom|Identity-H'; then
    echo "  ⚠ encoding Custom/Identity-H → el texto extraído PUEDE salir con caracteres"
    echo "    cambiados aunque parezca correcto. Comprueba contra pagina-*.jpg antes de"
    echo "    copiar nada. (Visto de verdad: pdftotext devolvía «tъ»/«йl» donde la página"
    echo "    ponía «tú»/«él».)"
  fi
fi

# Adjuntos incrustados: raros en un libro, pero si los hay suelen traer justo lo que se
# estaba buscando por otro lado, y comprobarlo cuesta un comando.
ADJ=$(pdfdetach -list "$PDF" 2>/dev/null | head -1 || true)
# El patrón va anclado al principio a propósito: sin anclar, "10 embedded files" contiene
# "0 embedded files" y los adjuntos de todos los múltiplos de 10 se silenciarían.
case "$ADJ" in
  "0 embedded files"*|"") ;;
  *) echo "· pdfdetach: $ADJ  → extráelos con: pdfdetach -saveall -o <dir> \"$PDF\"" ;;
esac
echo

# 1. Texto en orden de lectura. -layout es la diferencia entre una tabla legible y una
#    ristra de celdas sueltas; sin él, una página con un gráfico incrustado mezcla las
#    etiquetas del gráfico con el cuerpo del texto (pasó con el plano de metro de la 6A).
pdftotext -layout -f "$DESDE" -l "$HASTA" "$PDF" "$OUT/texto.txt"
echo "· texto.txt        $(wc -l < "$OUT/texto.txt") líneas"

# 2. La página como imagen. 150 ppp basta para leer un cuaderno de ejercicios y mantiene el
#    archivo pequeño; sube a 200-300 solo si hay letra muy menuda.
pdftoppm -jpeg -r 150 -f "$DESDE" -l "$HASTA" "$PDF" "$OUT/pagina"
for f in "$OUT"/pagina-*.jpg; do
  [ -e "$f" ] || continue
  echo "· $(basename "$f")   $(du -h "$f" | cut -f1)  ← ÁBRELA con Read"
done

# 3. Imágenes incrustadas, si las hay. Evitan tener que pedirle una foto al profesor: salen
#    a resolución original y sin el pulso de la cámara.
pdfimages -f "$DESDE" -l "$HASTA" -png "$PDF" "$OUT/incrustada" 2>/dev/null || true
n=$(find "$OUT" -name 'incrustada-*.png' | wc -l)
if [ "$n" -gt 0 ]; then
  echo "· $n imagen(es) incrustada(s):"
  # La ruta va por argv, no interpolada dentro del literal de Python: un apóstrofo en el
  # nombre del archivo o de la carpeta rompería la cadena y el tamaño saldría como "?".
  find "$OUT" -name 'incrustada-*.png' | sort | while read -r f; do
    echo "    $(basename "$f")  $(python3 -c "
import sys
from PIL import Image
im = Image.open(sys.argv[1]); print('%dx%d' % im.size)" "$f" 2>/dev/null || echo '?')"
  done
else
  # Que no haya ninguna no significa que la página no tenga dibujos: pueden ser vectores,
  # que forman parte del contenido de la página y no de una imagen embebida. Se recortan
  # entonces del render con PIL.
  echo "· sin imágenes incrustadas (si la página tiene dibujos, serán vectoriales:"
  echo "  recórtalos del render con PIL en vez de buscarlos aquí)"
fi

echo
echo "Recuerda: lee pagina-*.jpg antes de cerrar el capítulo. El texto no muestra las"
echo "líneas de relacionar, los ítems ya resueltos ni nada dibujado a mano."
