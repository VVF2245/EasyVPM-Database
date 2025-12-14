
-- 1 Registrar un CLIENTE correctamente

CALL registrar_usuario(
    'Cliente Nuevo',
    'cliente_nuevo@mail.com',
    'password123',
    '1998-06-15',
    0
);


-- 2 Registrar un TÉCNICO correctamente

CALL registrar_usuario(
    'Tecnico Nuevo',
    'tecnico_nuevo@mail.com',
    'password123',
    NULL,
    1
);


-- 3 Editar perfil (correo y contraseña)

CALL editar_perfil_inicio(
    1,
    'juan_nuevo@mail.com',
    'password456',
    NULL
);


-- 4 Registrar una BICICLETA

CALL registrarVehiculo(
    'bicicleta',
    'disponible',
    'Estación Centro Enganche 2',
    'montaña',
    NULL
);


-- 5 Registrar un PATINETE ELÉCTRICO

CALL registrarVehiculo(
    'patinete',
    'disponible',
    'Estación Norte Enganche 2',
    NULL,
    30.0
);


-- 6 Iniciar un alquiler correctamente
--    (cliente SIN alquiler activo,
--     vehículo disponible,
--     enganche OCUPADO)

CALL iniciar_alquiler(
    2,  -- clienteId
    2,  -- vehiculoId
    4   -- engancheInicioId (ocupado)
);


-- 7 Finalizar alquiler correctamente
--   genera pago automático

CALL finalizar_alquiler(
    2,                                
    NOW(),
    2,                                
    4.75                              
);


-- 8 Pagar mensualidad correctamente

CALL pago_mensual(3);


-- 9 Iniciar alquiler con mensualidad activa
--     coste 0 al finalizar

CALL iniciar_alquiler(
    3,
    2,
    2
);

CALL finalizar_alquiler(
    3,
    NOW(),
    3,
    2.10
);


--  10 Reparación completa de vehículo



INSERT INTO Reparaciones (
    tecnicoId,
    vehiculoId,
    fechaInicio,
    detalles
)
VALUES (
    5,
    3,
    CURDATE(),
    'Revisión general'
);

-- Finalizar reparación (trigger cambia estado a reparado)
UPDATE Reparaciones
SET fechaFin = CURDATE()
WHERE vehiculoId = 3;


--  11 Mover vehículo a enganche libre

CALL mover_vehiculo(
    2,  -- vehiculoId
    2   -- enganche libre
);


--  12 Eliminación lógica correcta (sin alquiler activo)


CALL eliminar_usuario_soft(4);
