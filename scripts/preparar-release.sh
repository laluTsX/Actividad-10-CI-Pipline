#!/usr/bin/env bash
# Prepara el paquete de liberación del proyecto (Actividad 12).
#
# Uso: scripts/preparar-release.sh <version>
# Requisito: haber ejecutado antes
#   composer install --no-dev --prefer-dist --optimize-autoloader
# para que vendor/ contenga solo dependencias de producción.
set -euo pipefail

VERSION="${1:?Indica la versión. Ejemplo: scripts/preparar-release.sh 1.0.0}"
DIST="dist"
STAGE="${DIST}/stage/laravel-release"
PAQUETE="${DIST}/laravel-release-${VERSION}.tar.gz"

AUTOR="${RELEASE_AUTOR:-Nepomuceno Hernández José Eduardo}"
MATRICULA="${RELEASE_MATRICULA:-222210599}"
GRUPO="${RELEASE_GRUPO:-IDGS-102}"
COMMIT="${GITHUB_SHA:-$(git rev-parse HEAD 2>/dev/null || echo desconocido)}"
RUN="${GITHUB_RUN_NUMBER:-local}"

echo "==> Preparando versión ${VERSION}"
rm -rf "$DIST"
mkdir -p "$STAGE"

echo "==> Copiando archivos necesarios (filtro: scripts/release-filter.txt)"
rsync -a --filter='merge scripts/release-filter.txt' ./ "$STAGE/"

echo "==> Recreando estructura de storage/ y bootstrap/cache/"
mkdir -p "$STAGE"/storage/logs \
         "$STAGE"/storage/framework/cache/data \
         "$STAGE"/storage/framework/sessions \
         "$STAGE"/storage/framework/views \
         "$STAGE"/bootstrap/cache

echo "==> Escribiendo VERSION y RELEASE-INFO.txt"
echo "$VERSION" > "$STAGE/VERSION"
cat > "$STAGE/RELEASE-INFO.txt" <<INFO
Proyecto:   Actividad 12 - Liberación de artefactos (Laravel)
Versión:    ${VERSION}
Commit:     ${COMMIT}
Ejecución:  #${RUN}
Fecha UTC:  $(date -u +'%Y-%m-%d %H:%M:%S')
Autor:      ${AUTOR}
Matrícula:  ${MATRICULA}
Grupo:      ${GRUPO}
INFO

echo "==> Generando ${PAQUETE}"
tar -czf "$PAQUETE" -C "${DIST}/stage" laravel-release
( cd "$DIST" && sha256sum "laravel-release-${VERSION}.tar.gz" > "laravel-release-${VERSION}.tar.gz.sha256" )
rm -rf "${DIST}/stage"

echo "==> Paquete listo:"
ls -lh "$DIST"
