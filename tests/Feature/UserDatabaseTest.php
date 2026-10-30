<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

/**
 * Pruebas de integración: modelo + base de datos (SQLite en memoria).
 */
class UserDatabaseTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_be_persisted_in_database(): void
    {
        $user = User::factory()->create(['email' => 'alumno@utvt.edu.mx']);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'email' => 'alumno@utvt.edu.mx',
        ]);
    }

    public function test_user_password_is_stored_hashed(): void
    {
        $user = User::factory()->create(['password' => 'secreto123']);

        $this->assertNotSame('secreto123', $user->password);
        $this->assertTrue(Hash::check('secreto123', $user->password));
    }
}
