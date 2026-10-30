#!/usr/bin/env bash
# Prueba de rendimiento ligera para un ENTORNO DE PRUEBA CONTROLADO (localhost).
# NO usar contra producción ni contra servidores sin autorización.
#
# Uso: scripts/performance-test.sh [URL] [PETICIONES] [UMBRAL_PROMEDIO_MS]
set -euo pipefail

URL="${1:-http://127.0.0.1:8000/health}"
REQUESTS="${2:-50}"
MAX_AVG_MS="${3:-500}"
OUT_DIR="reports"
OUT_FILE="${OUT_DIR}/rendimiento.txt"

mkdir -p "$OUT_DIR"
: > "$OUT_DIR/tiempos.txt"

echo "Prueba de rendimiento -> ${URL} (${REQUESTS} peticiones, umbral promedio ${MAX_AVG_MS} ms)"

for _ in $(seq 1 "$REQUESTS"); do
  # time_total en segundos -> milisegundos
  curl -s -o /dev/null -w '%{time_total}\n' "$URL" | awk '{ printf "%.2f\n", $1 * 1000 }' >> "$OUT_DIR/tiempos.txt"
done

AVG=$(awk '{ s += $1 } END { printf "%.2f", s / NR }' "$OUT_DIR/tiempos.txt")
MAX=$(sort -n "$OUT_DIR/tiempos.txt" | tail -1)
P95=$(sort -n "$OUT_DIR/tiempos.txt" | awk '{ a[NR] = $1 } END { i = int(NR * 0.95); if (i < 1) i = 1; print a[i] }')

{
  echo "url=${URL}"
  echo "peticiones=${REQUESTS}"
  echo "promedio_ms=${AVG}"
  echo "p95_ms=${P95}"
  echo "maximo_ms=${MAX}"
  echo "umbral_ms=${MAX_AVG_MS}"
} > "$OUT_FILE"

cat "$OUT_FILE"

if awk -v avg="$AVG" -v max="$MAX_AVG_MS" 'BEGIN { exit !(avg > max) }'; then
  echo "FALLO: el tiempo promedio (${AVG} ms) supera el umbral (${MAX_AVG_MS} ms)"
  exit 1
fi

echo "OK: tiempo promedio dentro del umbral"
