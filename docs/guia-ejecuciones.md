# Guía para provocar las 6 ejecuciones del pipeline

Trabaja siempre sobre la rama `main` y revisa cada resultado en la pestaña **Actions** del repositorio.
Después de cada push espera a que termine la ejecución, toma las capturas y anota los valores
(en el **Resumen** de cada ejecución aparece la tabla de métricas).

## Subida inicial (ejecución 1, exitosa)
```bash
git init
git branch -M main
git remote add origin https://github.com/laluTsX/Actividad-10-CI-Pipline.git
git add .
git commit -m "feat: proyecto Laravel con pipeline de CI"
git push -u origin main
```

## Ejecución 2 (fallida: pruebas)
En `routes/web.php` cambia `'status' => 'ok'` por `'status' => 'error'`.
```bash
git commit -am "test: provocar fallo en /health"
git push
```
Esperado: falla la etapa de integración/regresión, 10 de 11 pruebas (90.91 %).

## Ejecución 3 (exitosa: corrección)
Regresa el valor a `'ok'`.
```bash
git commit -am "fix: restaurar respuesta de /health"
git push
```

## Ejecución 4 (fallida: análisis estático)
Crea `app/Helpers/Formato.php` con este contenido (sin formato a propósito):
```php
<?php
namespace App\Helpers;
class Formato{
public static function nombre($n){return strtoupper($n);}
}
```
```bash
git add . && git commit -m "style: archivo sin formato" && git push
```
Esperado: falla la etapa 1 (Pint); las etapas 2 a 4 se omiten.

## Ejecución 5 (exitosa: corrección)
```bash
git rm app/Helpers/Formato.php
git commit -m "fix: eliminar archivo sin formato" && git push
```

## Ejecución 6 (exitosa: pipeline mejorado)
```bash
cp docs/workflow-mejorado/ci.yml .github/workflows/ci.yml
git commit -am "ci: agregar cache de Composer y concurrencia" && git push
```
Para ver el efecto real de la caché, haz un commit trivial adicional (por ejemplo, un cambio en este README) y compara la duración.

## Datos a registrar en la tabla del documento
Estado, duración, aprobadas/fallidas, porcentaje, etapa con error, tiempo de corrección
(hora de la ejecución exitosa menos hora de la fallida) y tiempo de respuesta promedio.
