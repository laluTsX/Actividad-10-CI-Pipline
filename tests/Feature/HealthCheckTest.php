<?php

namespace Tests\Feature;

use Tests\TestCase;

class HealthCheckTest extends TestCase
{
    public function test_health_endpoint_returns_ok_status(): void
    {
        $response = $this->getJson('/health');

        $response->assertStatus(200)
            ->assertJson(['status' => 'ok']);
    }

    public function test_health_endpoint_includes_application_name(): void
    {
        $response = $this->getJson('/health');

        $response->assertJsonStructure(['status', 'app']);
    }
}
