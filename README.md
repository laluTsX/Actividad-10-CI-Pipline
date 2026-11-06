# Laravel CI/CD: pruebas, liberación de artefactos y preproducción

Aplicación Laravel 11 (PHP 8.2) con pipeline en GitHub Actions (`.github/workflows/ci.yml`).
Autor: Nepomuceno Hernández José Eduardo · 222210599 · IDGS-102

## Etapas del pipeline

1. **ci**: análisis estático, pruebas unitarias, integración/regresión y rendimiento (Actividad 10).
2. **release**: instala dependencias de producción, genera `laravel-release-<versión>.tar.gz` + SHA-256 y lo publica como artefacto (Actividad 12).
3. **preproduccion**: descarga el artefacto, lo valida, lo instala en el ambiente de pruebas y prueba `/health`.

## Versionado

SemVer. El archivo `VERSION` guarda la base (`1.0.0`). Cada push a `main` genera `1.0.0-rc.<n.º de ejecución>`.
Al subir una etiqueta `vX.Y.Z` se genera la versión final y un GitHub Release.

## Ejecutar localmente

```bash
composer install
cp .env.example .env && php artisan key:generate
touch database/database.sqlite
php vendor/bin/pint --test
php vendor/bin/phpunit
```

Más información: `docs/ambiente-preproduccion.md`, `docs/guia-actividad-12.md` y `docs/guia-ejecuciones.md`.
