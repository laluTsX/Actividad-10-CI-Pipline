#!/usr/bin/env bash
# Valida un artefacto de liberación (Actividad 12, Parte 4).
#
# Uso: scripts/validar-artefacto.sh <laravel-release-X.Y.Z.tar.gz>
# Genera reports/validacion-artefacto.md y termina con código 1 si algo falla.
set -uo pipefail

PAQUETE="${1:?Indica el archivo .tar.gz del artefacto}"
REPORTE="reports/validacion-artefacto.md"
mkdir -p reports
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

FALLOS=0
{
  echo "## Validación del artefacto"
  echo
  echo "Archivo: \`$(basename "$PAQUETE")\`"
  echo
  echo "| Verificación | Resultado |"
  echo "|---|---|"
} > "$REPORTE"

registrar() { # $1 = descripción, $2 = 0 (ok) / 1 (falla)
  if [ "$2" -eq 0 ]; then
    echo "| $1 | OK |" >> "$REPORTE"; echo "[OK]    $1"
  else
    echo "| $1 | FALLO |" >> "$REPORTE"; echo "[FALLO] $1"; FALLOS=$((FALLOS + 1))
  fi
}

# 1. Integridad (si existe el archivo .sha256 junto al paquete)
if [ -f "${PAQUETE}.sha256" ]; then
  ( cd "$(dirname "$PAQUETE")" && sha256sum -c "$(basename "$PAQUETE").sha256" >/dev/null 2>&1 )
  registrar "Suma SHA-256 coincide con la publicada" $?
fi

# 2. El paquete se puede descomprimir
tar -xzf "$PAQUETE" -C "$TMP"; registrar "El paquete se descomprime correctamente" $?
RAIZ="$TMP/laravel-release"

# 3. Archivos y carpetas necesarios
for ruta in artisan composer.json composer.lock vendor/autoload.php bootstrap/app.php \
            public/index.php routes/web.php app config database/migrations resources/views \
            storage bootstrap/cache .env.example .env.preproduccion.example VERSION RELEASE-INFO.txt \
            scripts/instalar-preproduccion.sh; do
  [ -e "$RAIZ/$ruta" ]; registrar "Contiene: ${ruta}" $?
done

# 4. Archivos que NO deben estar
for ruta in .env .git tests node_modules phpunit.xml reports; do
  [ ! -e "$RAIZ/$ruta" ]; registrar "No incluye: ${ruta}" $?
done
[ -z "$(find "$RAIZ/storage/logs" -type f -name '*.log' 2>/dev/null)" ]; registrar "No incluye logs en storage/logs" $?
[ -z "$(find "$RAIZ" -path "$RAIZ/vendor" -prune -o -name '*.sqlite' -print 2>/dev/null)" ]; registrar "No incluye bases de datos SQLite" $?

# 5. Solo dependencias de producción
[ ! -d "$RAIZ/vendor/phpunit/phpunit" ]; registrar "vendor/ sin PHPUnit (dependencia de desarrollo)" $?
[ ! -d "$RAIZ/vendor/laravel/pint" ]; registrar "vendor/ sin Laravel Pint (dependencia de desarrollo)" $?

# 6. Sin credenciales ni información sensible (se excluye vendor/)
PATRONES='AKIA[0-9A-Z]{16}|-----BEGIN (RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----|ghp_[A-Za-z0-9]{36}|^APP_KEY=base64:|^DB_PASSWORD=.+'
if grep -rIEl --exclude-dir=vendor -e "$PATRONES" "$RAIZ" >/dev/null 2>&1; then
  grep -rIEl --exclude-dir=vendor -e "$PATRONES" "$RAIZ" | sed "s#$RAIZ/#   - #" >&2
  registrar "Sin llaves, tokens ni contraseñas en archivos del proyecto" 1
else
  registrar "Sin llaves, tokens ni contraseñas en archivos del proyecto" 0
fi

echo >> "$REPORTE"
if [ "$FALLOS" -eq 0 ]; then
  echo "**Resultado: ARTEFACTO VÁLIDO**" >> "$REPORTE"; echo "Resultado: ARTEFACTO VÁLIDO"
else
  echo "**Resultado: ARTEFACTO NO VÁLIDO (${FALLOS} fallos)**" >> "$REPORTE"; echo "Resultado: ARTEFACTO NO VÁLIDO (${FALLOS} fallos)"
fi
[ -n "${GITHUB_STEP_SUMMARY:-}" ] && cat "$REPORTE" >> "$GITHUB_STEP_SUMMARY"
exit $(( FALLOS > 0 ? 1 : 0 ))
