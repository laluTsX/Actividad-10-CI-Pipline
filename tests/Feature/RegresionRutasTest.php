<?php

namespace Tests\Feature;

use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

/**
 * Pruebas de regresión / aceptación: las rutas ya entregadas deben seguir
 * respondiendo igual después de cada cambio.
 */
class RegresionRutasTest extends TestCase
{
    public static function rutasPublicas(): array
    {
        return [
            'pagina de inicio' => ['/'],
            'health check' => ['/health'],
        ];
    }

    #[DataProvider('rutasPublicas')]
    public function test_public_routes_respond_successfully(string $ruta): void
    {
        $this->get($ruta)->assertOk();
    }

    public function test_unknown_route_returns_404(): void
    {
        $this->get('/ruta-que-no-existe')->assertNotFound();
    }
}
