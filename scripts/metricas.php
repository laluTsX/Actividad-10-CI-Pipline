<?php

/**
 * Genera la tabla de métricas del pipeline (formato Markdown) y la escribe en
 * el resumen de la ejecución de GitHub Actions ($GITHUB_STEP_SUMMARY).
 *
 * Lee: reports/unit.xml, reports/feature.xml (JUnit), reports/rendimiento.txt
 * y las variables de entorno con el resultado de cada etapa.
 */
$totalPruebas = 0;
$fallidas = 0;
$omitidas = 0;

foreach (['reports/unit.xml', 'reports/feature.xml'] as $archivo) {
    if (! is_file($archivo)) {
        continue;
    }
    $xml = simplexml_load_file($archivo);
    $suite = $xml->testsuite;
    $totalPruebas += (int) $suite['tests'];
    $fallidas += (int) $suite['failures'] + (int) $suite['errors'];
    $omitidas += (int) $suite['skipped'];
}

$aprobadas = $totalPruebas - $fallidas - $omitidas;
$porcentaje = $totalPruebas > 0 ? round(($aprobadas / $totalPruebas) * 100, 2) : 0;

$etapas = [
    'Análisis estático' => getenv('RES_ESTATICO') ?: 'skipped',
    'Pruebas unitarias' => getenv('RES_UNITARIAS') ?: 'skipped',
    'Pruebas de integración/regresión' => getenv('RES_FEATURE') ?: 'skipped',
    'Pruebas de rendimiento' => getenv('RES_RENDIMIENTO') ?: 'skipped',
];

$etapasConError = [];
foreach ($etapas as $nombre => $resultado) {
    if ($resultado === 'failure') {
        $etapasConError[] = $nombre;
    }
}

$estado = $etapasConError === [] ? 'EXITOSA' : 'FALLIDA';
$duracion = time() - (int) (getenv('INICIO_PIPELINE') ?: time());

$rendimiento = [];
if (is_file('reports/rendimiento.txt')) {
    foreach (file('reports/rendimiento.txt', FILE_IGNORE_NEW_LINES) as $linea) {
        [$clave, $valor] = array_pad(explode('=', $linea, 2), 2, '');
        $rendimiento[$clave] = $valor;
    }
}

$md = "## Métricas del pipeline\n\n";
$md .= "| Métrica | Resultado |\n|---|---|\n";
$md .= "| Estado de ejecución | {$estado} |\n";
$md .= "| Duración del pipeline | {$duracion} s |\n";
$md .= "| Pruebas aprobadas | {$aprobadas} |\n";
$md .= "| Pruebas fallidas | {$fallidas} |\n";
$md .= "| Total de pruebas ejecutadas | {$totalPruebas} |\n";
$md .= "| Porcentaje de pruebas aprobadas | {$porcentaje}% |\n";
$md .= '| Errores por etapa | '.($etapasConError === [] ? 'Ninguno' : implode(', ', $etapasConError))." |\n";
$md .= '| Tiempo de respuesta (promedio) | '.($rendimiento['promedio_ms'] ?? 'N/D')." ms |\n";
$md .= '| Tiempo de respuesta (p95) | '.($rendimiento['p95_ms'] ?? 'N/D')." ms |\n";
$md .= "\n_Tiempo de corrección: se calcula comparando la hora de la ejecución fallida con la de la ejecución corregida._\n";

echo $md;

if ($destino = getenv('GITHUB_STEP_SUMMARY')) {
    file_put_contents($destino, $md, FILE_APPEND);
}
