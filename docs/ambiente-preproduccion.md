# Ambiente de pruebas / preproducción: parámetros de configuración

Proyecto: aplicación Laravel 11 (PHP 8.2) · Autor: Nepomuceno Hernández José Eduardo (222210599, IDGS-102)

## Parámetros

| Componente | Parámetro configurado | Observación |
|---|---|---|
| Sistema operativo | Ubuntu 24.04 LTS (runner de GitHub Actions o máquina virtual de pruebas) | No se usa un servidor de producción real |
| PHP | 8.2 o superior (`composer.json`: `^8.2`) | El workflow usa PHP 8.2 |
| Composer | 2.x | En el servidor solo se necesita si se reinstalan dependencias; el paquete ya trae `vendor/` de producción |
| Extensiones PHP | mbstring, xml, pdo, pdo_sqlite (o pdo_mysql), openssl, tokenizer, ctype, json, fileinfo | El script `instalar-preproduccion.sh` las verifica |
| Servidor web | Nginx (ver `docs/nginx-preproduccion.conf`) o Apache, con la raíz en `public/` | En el runner se usa `php artisan serve` para la prueba de humo |
| Base de datos | SQLite de pruebas (`database/database.sqlite`); opcional MySQL `laravel_preprod` | Independiente de cualquier base de producción |
| Variables de entorno | `.env` propio generado desde `.env.preproduccion.example` | `APP_ENV=staging`, `APP_DEBUG=false`, `APP_KEY` generada en el ambiente |
| Permisos | `storage/` y `bootstrap/cache/` con escritura para el usuario del servidor web (`chmod -R ug+rwX`; propietario `www-data` en un servidor real) | Lo aplica el script de instalación |
| Entorno en GitHub | Environment `preproduccion` (Settings > Environments) | Permite agregar aprobaciones y variables propias del ambiente |

## Procedimiento de instalación (máquina virtual o servidor de pruebas)

```bash
# 1. Descargar el artefacto desde GitHub Actions y descomprimirlo
mkdir -p /var/www/preproduccion
tar -xzf laravel-release-<version>.tar.gz -C /var/www/preproduccion

# 2. Preparar el ambiente (crea .env, APP_KEY, permisos, migraciones y cachés)
bash /var/www/preproduccion/laravel-release/scripts/instalar-preproduccion.sh \
     /var/www/preproduccion/laravel-release --smoke

# 3. (Servidor real) propietario y servidor web
sudo chown -R www-data:www-data /var/www/preproduccion/laravel-release/storage \
                                /var/www/preproduccion/laravel-release/bootstrap/cache
```

Las credenciales reales (por ejemplo `DB_USERNAME` y `DB_PASSWORD` de MySQL) se escriben solo en el `.env` del servidor
o en los *secrets/variables* del Environment de GitHub; nunca en el repositorio ni en el artefacto.
