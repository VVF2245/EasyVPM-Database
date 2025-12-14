DELIMITER //

CREATE OR REPLACE PROCEDURE registrar_usuario (
    IN p_nombre VARCHAR(255),
    IN p_correo VARCHAR(255),
    IN p_contrasena VARCHAR(255),
    IN p_fechaNacimiento DATE,
    IN p_esTecnico TINYINT(1)
)
BEGIN
    DECLARE v_usuarioId INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error al registrar usuario';
    END;

    START TRANSACTION;

    INSERT INTO Usuarios (nombre, correo, contrasena)
    VALUES (p_nombre, p_correo, p_contrasena);

    SET v_usuarioId = LAST_INSERT_ID();

    IF p_fechaNacimiento IS NOT NULL THEN
        INSERT INTO Clientes (usuarioId, fechaNacimiento, alquilerActivo, borrado)
        VALUES (v_usuarioId, p_fechaNacimiento, 0, 0);

    ELSEIF p_esTecnico = 1 THEN
        INSERT INTO Tecnicos_Mantenimiento (usuarioId, fechaFinUltimoServicio, borrado)
        VALUES (v_usuarioId, NULL, 0);
    END IF;

    COMMIT;
END //

DELIMITER ;

DELIMITER //

CREATE OR REPLACE PROCEDURE eliminar_usuario_soft (
    IN p_usuarioId INT
)
BEGIN
    DECLARE v_esCliente INT;
    DECLARE v_esTecnico INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error al eliminar usuario';
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_esCliente
    FROM Clientes
    WHERE usuarioId = p_usuarioId;

    SELECT COUNT(*) INTO v_esTecnico
    FROM Tecnicos_Mantenimiento
    WHERE usuarioId = p_usuarioId;

    IF v_esCliente = 0 AND v_esTecnico = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuario no es cliente ni técnico';
    END IF;

    IF v_esCliente > 0 THEN
        UPDATE Clientes SET borrado = 1 WHERE usuarioId = p_usuarioId;
    END IF;

    IF v_esTecnico > 0 THEN
        UPDATE Tecnicos_Mantenimiento SET borrado = 1 WHERE usuarioId = p_usuarioId;
    END IF;

    COMMIT;
END //

DELIMITER ;

DELIMITER //

CREATE OR REPLACE PROCEDURE editar_perfil_inicio (
    IN p_usuarioId INT,
    IN p_nuevoCorreo VARCHAR(255),
    IN p_nuevaContrasena VARCHAR(255),
    IN p_nuevaFechaNacimiento DATE
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error al editar perfil';
    END;

    START TRANSACTION;

    IF p_nuevoCorreo IS NOT NULL AND EXISTS (
        SELECT 1 FROM Usuarios
        WHERE correo = p_nuevoCorreo AND id <> p_usuarioId
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Correo duplicado';
    END IF;

    UPDATE Usuarios
    SET correo = COALESCE(p_nuevoCorreo, correo),
        contrasena = COALESCE(p_nuevaContrasena, contrasena)
    WHERE id = p_usuarioId;

    UPDATE Clientes
    SET fechaNacimiento = COALESCE(p_nuevaFechaNacimiento, fechaNacimiento)
    WHERE usuarioId = p_usuarioId;

    COMMIT;
END //

DELIMITER ;

DELIMITER //

CREATE OR REPLACE PROCEDURE registrarVehiculo (
    IN p_tipoVehiculo VARCHAR(20),
    IN p_estado VARCHAR(50),
    IN p_localizacion VARCHAR(200),
    IN p_tipoBici VARCHAR(50),
    IN p_autonomiaBateria DECIMAL(4,1)
)
BEGIN
    DECLARE v_vehiculoId INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error al registrar vehículo';
    END;

    START TRANSACTION;

    INSERT INTO Vehiculos (estado, kilometraje, numeroUsos, localizacion, borrado)
    VALUES (p_estado, 0, 0, p_localizacion, 0);

    SET v_vehiculoId = LAST_INSERT_ID();

    IF p_tipoVehiculo = 'bicicleta' THEN
        INSERT INTO Bicicletas (vehiculoId, tipoBici)
        VALUES (v_vehiculoId, p_tipoBici);

    ELSEIF p_tipoVehiculo = 'patinete' THEN
        INSERT INTO Patinetes_Electricos (vehiculoId, autonomiaBateria)
        VALUES (v_vehiculoId, p_autonomiaBateria);

    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tipo de vehículo inválido';
    END IF;

    COMMIT;
END //

DELIMITER ;

DELIMITER //

CREATE OR REPLACE PROCEDURE iniciar_alquiler (
    IN p_clienteId INT,
    IN p_vehiculoId INT,
    IN p_engancheInicioId INT
)
BEGIN
    DECLARE v_estadoVehiculo VARCHAR(50);
    DECLARE v_estadoEnganche VARCHAR(50);

    START TRANSACTION;

    SELECT estado INTO v_estadoVehiculo
    FROM Vehiculos
    WHERE id = p_vehiculoId AND borrado = 0
    FOR UPDATE;

    IF v_estadoVehiculo <> 'disponible' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vehículo no disponible';
    END IF;

    SELECT estado INTO v_estadoEnganche
    FROM Enganches
    WHERE id = p_engancheInicioId AND borrado = 0
    FOR UPDATE;

    IF v_estadoEnganche <> 'ocupado' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Enganche inválido';
    END IF;

    INSERT INTO Alquileres (
        clienteId, vehiculoId, engancheInicioId,
        fechaHoraInicio, costo, lugarInicio
    )
    VALUES (
        p_clienteId, p_vehiculoId, p_engancheInicioId,
        NOW(), 0, 'Estación de inicio'
    );

    UPDATE Vehiculos SET estado = 'en uso' WHERE id = p_vehiculoId;
    UPDATE Enganches SET estado = 'libre' WHERE id = p_engancheInicioId;
    UPDATE Clientes SET alquilerActivo = 1 WHERE usuarioId = p_clienteId;

    COMMIT;
END //

DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE finalizar_alquiler(
    IN p_alquilerId INT,
    IN p_fechaFin DATETIME,
    IN p_engancheFinId INT,
    IN p_distanciaRecorrida DECIMAL(5,2)
)
BEGIN
    DECLARE v_clienteId INT;
    DECLARE v_fechaInicio DATETIME;
    DECLARE v_minutos INT;
    DECLARE v_costo DECIMAL(7,2);
    DECLARE v_fechaMensualidad DATE;
    DECLARE v_estacion VARCHAR(255);
    DECLARE v_numEnganche INT;
    DECLARE v_vehiculoId INT;
    DECLARE v_usos INT;
    DECLARE v_kmTotal DECIMAL(10,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR AL FINALIZAR ALQUILER';
    END;

    START TRANSACTION;

    SELECT vehiculoId, fechaHoraInicio, clienteId
    INTO v_vehiculoId, v_fechaInicio, v_clienteId
    FROM Alquileres WHERE id = p_alquilerId FOR UPDATE;

    SET v_minutos = TIMESTAMPDIFF(MINUTE, v_fechaInicio, p_fechaFin);
    IF v_minutos < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fecha fin inválida';
    END IF;

    SELECT fecha INTO v_fechaMensualidad
    FROM Pagos
    WHERE clienteId = v_clienteId AND tipoPago = 'mensualidad'
    ORDER BY fecha DESC LIMIT 1;

    IF v_fechaMensualidad IS NOT NULL
       AND v_fechaMensualidad >= DATE_SUB(p_fechaFin, INTERVAL 30 DAY) THEN
        SET v_costo = 0;
    ELSE
        SET v_costo = v_minutos * 0.20;
    END IF;

    SELECT e.nombre, en.numero
    INTO v_estacion, v_numEnganche
    FROM Enganches en
    JOIN Estaciones e ON e.id = en.estacionId
    WHERE en.id = p_engancheFinId;

    UPDATE Alquileres
    SET fechaHoraFin = p_fechaFin,
        engancheFinId = p_engancheFinId,
        distanciaRecorrida = p_distanciaRecorrida,
        costo = v_costo,
        lugarFin = CONCAT('Estación ', v_estacion, ' Enganche ', v_numEnganche)
    WHERE id = p_alquilerId;

    UPDATE Clientes SET alquilerActivo = 0 WHERE usuarioId = v_clienteId;

    UPDATE Enganches SET estado = 'ocupado' WHERE id = p_engancheFinId;

    UPDATE Vehiculos
    SET numeroUsos = numeroUsos + 1,
        kilometraje = kilometraje + p_distanciaRecorrida,
        localizacion = CONCAT('Estación ', v_estacion, ' Enganche ', v_numEnganche)
    WHERE id = v_vehiculoId;

    SELECT numeroUsos, kilometraje
    INTO v_usos, v_kmTotal
    FROM Vehiculos WHERE id = v_vehiculoId;

    UPDATE Vehiculos
    SET estado = IF(v_usos > 50 OR v_kmTotal > 500,
                    'mantenimiento_pendiente', 'disponible')
    WHERE id = v_vehiculoId;

    INSERT INTO Pagos (clienteId, alquilerId, tipoPago, cantidad, fecha)
    VALUES (v_clienteId, p_alquilerId, 'cargo_automatico', v_costo, CURDATE());

    COMMIT;
END//
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE reparar_vehiculo (
    IN p_tecnicoId INT,
    IN p_vehiculoId INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Tecnicos_Mantenimiento
        WHERE usuarioId = p_tecnicoId AND borrado = 0
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Técnico no válido';
    END IF;

    UPDATE Vehiculos
    SET estado = 'reparado'
    WHERE id = p_vehiculoId
      AND estado = 'en_mantenimiento'
      AND borrado = 0;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vehículo no estaba en mantenimiento';
    END IF;

    UPDATE Tecnicos_Mantenimiento
    SET fechaFinUltimoServicio = CURDATE()
    WHERE usuarioId = p_tecnicoId;
END//
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE pago_mensual(
    IN p_usuarioId INT
)
BEGIN
    DECLARE v_clienteId INT;
    DECLARE v_pagosActivos INT;

    SELECT usuarioId INTO v_clienteId
    FROM Clientes
    WHERE usuarioId = p_usuarioId AND borrado = 0;

    IF v_clienteId IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No es cliente válido';
    END IF;

    SELECT COUNT(*) INTO v_pagosActivos
    FROM Pagos
    WHERE clienteId = v_clienteId
      AND tipoPago = 'mensualidad'
      AND TIMESTAMPDIFF(DAY, fecha, CURDATE()) < 30;

    IF v_pagosActivos > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mensualidad ya activa';
    END IF;

    INSERT INTO Pagos (clienteId, tipoPago, cantidad, fecha)
    VALUES (v_clienteId, 'mensualidad', 5.99, CURDATE());
END//

DELIMITER ;

DELIMITER //

CREATE OR REPLACE PROCEDURE mover_vehiculo(
    IN p_vehiculoId INT,
    IN p_nuevoEngancheId INT
)
BEGIN
    DECLARE v_estadoEnganche VARCHAR(50);
    DECLARE v_estacion VARCHAR(255);
    DECLARE v_numEnganche INT;

    START TRANSACTION;

    SELECT estado, numero INTO v_estadoEnganche, v_numEnganche
    FROM Enganches
    WHERE id = p_nuevoEngancheId
    FOR UPDATE;

    IF v_estadoEnganche <> 'libre' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Enganche no libre';
    END IF;

    SELECT e.nombre INTO v_estacion
    FROM Estaciones e
    JOIN Enganches en ON en.estacionId = e.id
    WHERE en.id = p_nuevoEngancheId;

    UPDATE Enganches SET estado = 'ocupado' WHERE id = p_nuevoEngancheId;

    UPDATE Vehiculos
    SET localizacion = CONCAT('Estación ', v_estacion, ' Enganche ', v_numEnganche)
    WHERE id = p_vehiculoId;

    COMMIT;
END //

DELIMITER ;