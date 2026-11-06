# Guía de la Actividad 12 (paso a paso)

## 1. Subir los cambios y generar el artefacto
```bash
git add .
git commit -m "feat: liberacion de artefactos y entrega a preproduccion"
git push
```
En **Actions** se ejecutan tres jobs en orden: `ci` -> `release` -> `preproduccion`.
Toma captura de la ejecución completa (3 jobs en verde) y del **Summary**.

## 2. Descargar el artefacto
Actions > entra a la ejecución > sección **Artifacts** (al final de la página) > descarga
`laravel-release-1.0.0-rc.N`. Es un .zip que contiene el `.tar.gz` y el `.sha256`. Descomprime el .zip.

## 3. Verificar el contenido (PowerShell o Git Bash, en la carpeta de la descarga)
```powershell
# Lista de archivos del paquete
tar -tzf laravel-release-1.0.0-rc.N.tar.gz | more

# Archivos necesarios (debe mostrar resultados)
tar -tzf laravel-release-1.0.0-rc.N.tar.gz | Select-String "artisan|vendor/autoload.php|public/index.php|bootstrap/app.php"

# NO debe haber .env (sin resultados; .env.example y .env.preproduccion.example sí pueden aparecer)
tar -tzf laravel-release-1.0.0-rc.N.tar.gz | Select-String -Pattern "/\.env$"

# NO debe haber dependencias de desarrollo ni pruebas (sin resultados)
tar -tzf laravel-release-1.0.0-rc.N.tar.gz | Select-String "vendor/phpunit/phpunit|laravel-release/tests/"

# Integridad: compara este hash con el del archivo .sha256
Get-FileHash laravel-release-1.0.0-rc.N.tar.gz -Algorithm SHA256
```
En Git Bash cambia `Select-String` por `grep -E` y `Get-FileHash` por `sha256sum`.

## 4. Instalar en el ambiente de pruebas (tu equipo con PHP 8.2+)
```powershell
mkdir pruebas-preprod
tar -xzf laravel-release-1.0.0-rc.N.tar.gz -C pruebas-preprod
cd pruebas-preprod\laravel-release
copy .env.preproduccion.example .env
php artisan key:generate
type nul > database\database.sqlite
php artisan migrate --force
php artisan serve
```
Abre http://127.0.0.1:8000/health (debe responder `{"status":"ok",...}`). Toma captura.
(En Git Bash/WSL basta: `bash scripts/instalar-preproduccion.sh . --smoke`.)

## 5. Versión final con etiqueta (opcional, genera GitHub Release)
```bash
git tag v1.0.0
git push origin v1.0.0
```
Resultado: artefacto `laravel-release-1.0.0` y un Release en la pestaña **Releases** con el paquete adjunto.

## 6. Evidencias a capturar
Ejecución con 3 jobs en verde · Artifacts de la ejecución · Summary de validación ·
contenido del paquete (comandos del paso 3) · `/health` en el ambiente de pruebas · Release (si usas la etiqueta).
