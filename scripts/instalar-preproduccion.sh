#!/usr/bin/env bash
# Prepara la aplicación ya descomprimida en el ambiente de pruebas/preproducción.
#
# Uso: instalar-preproduccion.sh [directorio_de_la_app] [--smoke]
#   --smoke  levanta el servidor temporalmente y consulta /health
set -euo pipefail

APP_DIR="${1:-.}"
SMOKE="${2:-}"
cd "$APP_DIR"

echo "==> PHP: $(php -r 'echo PHP_VERSION;')"
php -r 'foreach (["mbstring","xml","pdo","pdo_sqlite","openssl","tokenizer","ctype","json","fileinfo"] as $e) { if (!extension_loaded($e)) { fwrite(STDERR, "Falta la extensión PHP: $e\n"); exit(1); } }'

echo "==> Variables de entorno independientes (.env de preproducción)"
[ -f .env ] || cp .env.preproduccion.example .env
php artisan key:generate --force

echo "==> Permisos de storage/ y bootstrap/cache/"
mkdir -p storage/logs storage/framework/{cache/data,sessions,views} bootstrap/cache
chmod -R ug+rwX storage bootstrap/cache

echo "==> Base de datos de pruebas"
if grep -q '^DB_CONNECTION=sqlite' .env; then
  DB_FILE="$(grep -E '^DB_DATABASE=' .env | cut -d= -f2- || true)"
  DB_FILE="${DB_FILE:-database/database.sqlite}"
  case "$DB_FILE" in /*) ;; *) DB_FILE="$PWD/$DB_FILE" ;; esac
  mkdir -p "$(dirname "$DB_FILE")"; touch "$DB_FILE"
  sed -i "s#^DB_DATABASE=.*#DB_DATABASE=${DB_FILE}#" .env
fi
php artisan migrate --force

echo "==> Optimización para el ambiente"
php artisan config:cache
php artisan view:cache

echo "==> Versión de Laravel / de la aplicación"
php artisan --version
echo "Versión liberada: $(cat VERSION)"

if [ "$SMOKE" = "--smoke" ]; then
  echo "==> Prueba de humo (/health)"
  php artisan serve --host=127.0.0.1 --port=8001 >/tmp/preprod-server.log 2>&1 &
  PID=$!
  trap 'kill $PID 2>/dev/null || true' EXIT
  sleep 4
  RESP="$(curl -s -o /tmp/health.json -w '%{http_code}' http://127.0.0.1:8001/health)"
  echo "HTTP ${RESP}: $(cat /tmp/health.json)"
  [ "$RESP" = "200" ] && grep -q '"status":"ok"' /tmp/health.json
fi
echo "==> Instalación en preproducción completada"
