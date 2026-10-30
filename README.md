# Actividad 10: Seguimiento de pruebas y mejora del CI Pipeline

Aplicación Laravel 11 (PHP 8.2) con un pipeline de integración continua en GitHub Actions.

**Etapas del pipeline** (`.github/workflows/ci.yml`):

1. Análisis estático: `php -l` y Laravel Pint
2. Pruebas unitarias (PHPUnit, suite `Unit`)
3. Pruebas de integración y regresión (PHPUnit, suite `Feature`)
4. Pruebas de rendimiento en entorno controlado (servidor local del runner)
5. Resumen de métricas y reportes como artefactos

## Ejecutar localmente
```bash
composer install
cp .env.example .env && php artisan key:generate
touch database/database.sqlite
vendor/bin/pint --test
vendor/bin/phpunit
```

Guía para provocar las ejecuciones exitosas y fallidas: `docs/guia-ejecuciones.md`.
