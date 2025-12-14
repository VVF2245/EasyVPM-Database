-- 1. Registrar usuario con correo duplicado
CALL registrar_usuario(
    'Usuario Repetido',
    'juan@mail.com',
    'password123',
    '1990-01-01',
    0
);

-- 2. Cliente menor de 12 años (trigger)
CALL registrar_usuario(
    'Niño',
    'nino@mail.com',
    'password123',
    CURDATE(),
    0
);

-- 3. Iniciar alquiler con vehículo NO disponible
CALL iniciar_alquiler(2, 3, 2);

-- 4. Iniciar alquiler con enganche NO ocupado
CALL iniciar_alquiler(2, 2, 2);

-- 5. Finalizar alquiler con fecha inválida
CALL finalizar_alquiler(
    1,
    NOW() - INTERVAL 1 DAY,
    2,
    3.5
);

--  6. Eliminar cliente con alquiler activo (trigger)
UPDATE Clientes SET borrado = 1 WHERE usuarioId = 1;

-- 7. Reparar vehículo que no está en mantenimiento
CALL reparar_vehiculo(5, 2);

-- 8. Pagar mensualidad duplicada
INSERT INTO Pagos (clienteId, tipoPago, cantidad, fecha)
VALUES (2, 'mensualidad', 5.99, CURDATE());

CALL pago_mensual(2);

-- 9. Mover vehículo a enganche ocupado
CALL mover_vehiculo(2, 4);
