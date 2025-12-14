-- Caso positivo
-- START TRANSACTION;
-- SELECT * FROM Alquileres
-- CALL finalizar_alquiler(1, '2025-03-18 9:45:00',4, 3.20);
-- SELECT * FROM Alquileres
-- ROLLBACK;

-- Caso negativo
-- START TRANSACTION;
-- SELECT * FROM Alquileres
-- CALL finalizar_alquiler(1, "2025-03-18 8:45:00",3, 3.20);
-- SELECT * FROM Alquileres;

--Procedimiento de creacion de un usuario(sea cliente o tecnico)
DELIMITER //
CREATE PROCEDURE registrar_usuario (
    IN p_nombre VARCHAR(255),
    IN p_correo VARCHAR(255),
    IN p_contrasena VARCHAR(255),

    -- datos cliente (son ocpionales)
    IN p_fechaNacimiento DATE,

    IN p_esTecnico BOOLEAN
)
BEGIN
    DECLARE v_usuarioId INT;

    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error al registrar usuario';
    END;

    START TRANSACTION;

    INSERT INTO Usuarios (nombre, correo, contraseña)
    VALUES (p_nombre, p_correo, p_contrasena);

    SET v_usuarioId = LAST_INSERT_ID();

    IF p_fechaNacimiento IS NOT NULL THEN
        INSERT INTO Clientes (
            usuarioId, fechaNacimiento, alquilerActivo, borrado
        )
        VALUES (
            v_usuarioId, p_fechaNacimiento, FALSE, FALSE
        );

    ELSE IF p_esTecnico = TRUE THEN
        INSERT INTO Tecnicos_Mantenimiento (
            usuarioId, fechaFinUltimoServicio, borrado
        )
        VALUES (
            v_usuarioId, NULL, FALSE
        );
    END IF;

    -- si no es ninguna es administrador

    COMMIT;
END //
DELIMITER ;


-- lo hemos hecho con la intención de que no se le haga soft delete a los administradores (no son ni clientes ni técnicos)
DELIMITER //
CREATE PROCEDURE eliminar_usuario_soft (
    IN p_usuarioId INT
)
BEGIN
    DECLARE v_esCliente INT DEFAULT 0;
    DECLARE v_esTecnico INT DEFAULT 0;

    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error al eliminar usuario';
    END;

    START TRANSACTION;

    -- Comprobar si es cliente
    SELECT COUNT(*) INTO v_esCliente
    FROM Clientes
    WHERE usuarioId = p_usuarioId;

    -- Comprobar si es técnico
    SELECT COUNT(*) INTO v_esTecnico
    FROM Tecnicos_Mantenimiento
    WHERE usuarioId = p_usuarioId;

    -- Validación
    IF v_esCliente = 0 AND v_esTecnico = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario no existe como cliente ni técnico';
    END IF;

    -- Soft delete según tipo
    IF v_esCliente > 0 THEN
        UPDATE Clientes
        SET borrado = TRUE
        WHERE usuarioId = p_usuarioId;
    END IF;

    IF v_esTecnico > 0 THEN
        UPDATE Tecnicos_Mantenimiento
        SET borrado = TRUE
        WHERE usuarioId = p_usuarioId;
    END IF;

    COMMIT;
END //

DELIMITER ;


--Modificar usuario
DELIMITER //
CREATE PROCEDURE editar_perfil_inicio (
    IN p_usuarioId INT,
    IN p_nuevoCorreo VARCHAR(255),
    IN p_nuevaContrasena VARCHAR(255),
    IN p_nuevaFechaNacimiento DATE
)
BEGIN
    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error al editar perfil';
    END;

    START TRANSACTION;

    -- Correo duplicado
    IF p_nuevoCorreo IS NOT NULL AND EXISTS (
        SELECT 1 FROM Usuarios
        WHERE correo = p_nuevoCorreo
          AND id <> p_usuarioId
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El correo ya existe';
    END IF;

    -- Usuarios
    UPDATE Usuarios
    SET
        --Nota: coalesce lo que hace es coger el primer valor no null de la lista que se le pasa, si el usuario no modifica la contraseña pues se queda la antigua
        correo = COALESCE(p_nuevoCorreo, correo), 
        contraseña = COALESCE(p_nuevaContrasena, contraseña)
    WHERE id = p_usuarioId;

    -- Clientes (solo si existe)
    UPDATE Clientes
    SET
        fechaNacimiento = COALESCE(p_nuevaFechaNacimiento, fechaNacimiento)
    WHERE usuarioId = p_usuarioId;

    COMMIT;
END //
DELIMITER ;


--Un mismo procedimiento para patinetes y bicis
DELIMITER//
CREATE PROCEDURE registrarVehiculo (
    IN p_tipoVehiculo VARCHAR(20), -- 'bicicleta' | 'patinete'
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
        SET MESSAGE_TEXT = 'Error al registrar el vehículo';
    END;

    START TRANSACTION;

    -- Inserción en Vehiculos (atributos generales)
    INSERT INTO Vehiculos (
        estado, kilometraje, numeroUsos, localizacion, borrado
    )
    VALUES (
        p_estado, 0.00, 0, p_localizacion, FALSE
    );

    SET v_vehiculoId = LAST_INSERT_ID();

    -- Inserción según tipo
    IF p_tipoVehiculo = 'bicicleta' THEN
        INSERT INTO Bicicletas (vehiculoId, tipoBici)
        VALUES (v_vehiculoId, p_tipoBici);

    ELSEIF p_tipoVehiculo = 'patinete' THEN
        INSERT INTO Patinetes_Electricos (vehiculoId, autonomiaBateria)
        VALUES (v_vehiculoId, p_autonomiaBateria);

    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tipo de vehículo no válido';
    END IF;

    COMMIT;
END//
--eliminacion vehiculo(no tengo en cuenta el alquiler porque de eso se encarga el trigger)
DELIMITER //

CREATE PROCEDURE eliminarVehiculo (
    IN p_vehiculoId INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error al eliminar el vehículo';
    END;

    START TRANSACTION;

    UPDATE Vehiculos
    SET borrado = TRUE
    WHERE id = p_vehiculoId;

    COMMIT;
END//

DELIMITER ;
--registrar una estacion
DELIMITER//
CREATE OR REPLACE PROCEDURE registro_estacion(
    IN p_nombre VARCHAR(200)
)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error al registrar el vehículo';
    END;
    START TRANSACTION;

    INSERT INTO Estaciones(nombre, numeroVehiculos, borrado)
    VALUES(p_nombre, 0,FALSE);

    COMMIT;
    END//
DELIMITER;
--modificar una estacion(solo se permite modificar el nombre)
CREATE OR REPLACE PROCEDURE modificar_estacion(
    IN p_id INT,
    IN p_nombre VARCHAR(255),
)
    BEGIN
    -- Handler de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error al actualizar la estación';
    END;

    START TRANSACTION;

    -- Actualización de la estación
    UPDATE Estaciones
    SET 
        nombre = p_nombre,
    WHERE id = p_id;

    COMMIT;
END//
DELIMITER;

DELIMITER //
CREATE OR REPLACE PROCEDURE eliminar_estacion(
    IN p_id INT
)
-- Handler de errores
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Error al eliminar la estacion';
END;
START TRANSACTION;
    UPDATE Estaciones
    SET borrado = TRUE
    WHERE id = p_id;

    COMMIT;
END //  
DELIMITER ;

DELIMITER //

CREATE PROCEDURE iniciar_alquiler (
    IN p_clienteId INT,
    IN p_vehiculoId INT,
    IN p_engancheInicioId INT
)
BEGIN
    DECLARE v_estadoVehiculo VARCHAR(50);
    DECLARE v_estadoEnganche VARCHAR(50);

    /* 1. Validar que el cliente no tenga alquiler activo */
    IF EXISTS (
        SELECT 1
        FROM Alquileres
        WHERE clienteId = p_clienteId
          AND fechaHoraFin IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El cliente ya tiene un alquiler activo';
    END IF;

    /* 2. Validar que el vehículo esté disponible */
    SELECT estado
    INTO v_estadoVehiculo
    FROM Vehiculos
    WHERE id = p_vehiculoId
      AND borrado = FALSE;

    IF v_estadoVehiculo IS NULL OR v_estadoVehiculo <> 'disponible' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El vehículo no está disponible';
    END IF;

    /* 3. Validar que el enganche esté ocupado */
    SELECT estado
    INTO v_estadoEnganche
    FROM Enganches
    WHERE id = p_engancheInicioId
      AND borrado = FALSE;

    IF v_estadoEnganche IS NULL OR v_estadoEnganche <> 'ocupado' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El enganche no tiene un vehículo disponible';
    END IF;

    /* 4. Insertar alquiler */
    INSERT INTO Alquileres (
        clienteId,
        vehiculoId,
        engancheInicioId,
        fechaHoraInicio,
        costo,
        lugarInicio
    ) VALUES (
        p_clienteId,
        p_vehiculoId,
        p_engancheInicioId,
        NOW(),
        0,
        'Estación de inicio'
    );

    /* 5. Actualizar estados */
    UPDATE Vehiculos
    SET estado = 'en uso'
    WHERE id = p_vehiculoId;

    UPDATE Enganches
    SET estado = 'libre'
    WHERE id = p_engancheInicioId;

END//

DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE finalizar_alquiler(
    IN p_alquilerId INT,
    IN p_fechaFin DATETIME,
    IN p_engancheFinId INT,
    IN p_distanciaRecorrida DECIMAL (5,2)
)
BEGIN
    -- Declaracion de variables 
    DECLARE v_clienteId INT;
    DECLARE v_fechaInicio DATETIME;
    DECLARE V_minutos INT;
    DECLARE v_costo DECIMAL (5,2);
    DECLARE v_fechaMensualidad DATETIME;
    DECLARE v_estacionFin VARCHAR(255);
    DECLARE v_numFin INT;
    DECLARE v_vehiculoId INT;
    DECLARE v_usos INT;
    DECLARE v_kmTotal DECIMAL (10,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERROR AL FINALIZAR ALQUILER';
    END;

    START TRANSACTION;
    -- 1. Obtener datos actuales del alquiler y vehiculo
    SELECT vehiculoId, fechaHoraInicio, clienteId 
    INTO v_vehiculoId, v_fechaInicio, v_clienteId
    FROM Alquileres 
    WHERE Alquileres.id = p_alquilerId;

    -- Validar fecha
    SET v_minutos = TIMESTAMPDIFF(MINUTE, v_fechaInicio, p_fechaFin);
    IF v_minutos < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha fin no puede ser anterior a la inicio';
    END IF;

    -- 2. Calculo del cobro
    -- Buscamos fechas de mensualidad activa
    SELECT fecha INTO v_fechaMensualidad
    FROM Pagos
    WHERE clienteId = v_clienteId AND tipoPago ='mensualidad'
    ORDER BY fecha DESC LIMIT 1;

    -- Validar Mensualidad
    IF v_fechaMensualidad IS NOT NULL AND
    v_fechaMensualidad >= DATE_SUB(p_fechaFin, INTERVAL 30 DAY) THEN
        SET v_costo = 0;
    ELSE 
        SET v_costo = v_minutos* 0.20; --Tarifa Base
    END IF;

    -- 3. Obtener datos localizacion final
    SELECT Estaciones.nombre, Enganches.numero
    INTO v_estacionFin, v_numFin
    FROM Enganches 
    JOIN Estaciones ON Enganches.estacionId = Estaciones.id
    WHERE Enganches.id = p_engancheFinId;

    -- 4. Actualizar alquiler
    UPDATE Alquileres
    SET fechaHoraFin = p_fechaFin,
        engancheFinId = p_engancheFinId,
        distanciaRecorrida = p_distanciaRecorrida,
        costo = v_costo,
        lugarFin = CONCAT('Estación ', v_estacionFin, ' Enganche ', v_numFin)
    WHERE id = p_alquilerId;

    -- 5. Actualizar cliente y enganche
    UPDATE Clientes
        SET alquilerActivo = FALSE
        WHERE usuarioId = v_clienteId;
    UPDATE Enganches
        SET estado ='ocupado'
    WHERE id = p_engancheFinId;

    --6. Actualizar Vehiculos
    UPDATE Vehiculos
        SET numeroUsos = numeroUsos + 1,
        kilometraje = kilometraje + p_distanciaRecorrida,
        localizacion = CONCAT('Estacion ', v_estacionFin, ' Enganche ', v_numFin)
        WHERE id = v_vehiculoId;

    SELECT numeroUsos, kilometraje INTO v_usos, v_kmTotal
    FROM Vehiculos WHERE id = v_vehiculoId;

    -- Actualizar estado vehiculo
    UPDATE Vehiculos
        SET estado = IF(v_usos>50 OR v_kmTotal >500.00, 
        'mantenimiento_pendiente', 'disponible')
        WHERE id = v_vehiculoId;

    INSERT INTO Pagos(clienteId, alquilerId, tipoPago, cantidad, fecha)
    VALUES (v_clienteId, p_alquilerId, 'cargo_automatico', v_costo, CURDATE());

    COMMIT;

END //
DELIMITER ;

--SELECT * FROM vw_enganchesLibresPorEstacion
--SELECT * FROM vw_vehiculosDisponibles

-- Caso positivo(id enganche libre)
-- Caso negativo(id enganche ocupado)
-- START TRANSACTION;
-- SELECT * FROM Vehiculos;
-- SELECT * FROM Enganches;
-- CALL mover_vehiculo(...)
-- SELECT v.localizacion FROM Vehiculos v 
-- JOIN Enganches e ON v.localizacion.contains(e.numero) WHERE v.id=...;
-- ROLLBACK;

DELIMITER //
CREATE OR REPLACE PROCEDURE mover_vehiculo(
    IN p_vehiculoId INT,
    IN p_nuevoEngancheId INT
)
BEGIN
    DECLARE v_engancheActualId INT;
    DECLARE v_estadoEnganche VARCHAR(50);
    DECLARE v_estacionNombre VARCHAR(255);
    DECLARE v_estacionId INT;
    DECLARE v_numEnganche INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error al mover el vehículo';
    END;

    START TRANSACTION;

    -- Obtener el enganche actual del vehículo (si tiene)
    SELECT e.id
    INTO v_engancheActualId
    FROM Enganches e
    JOIN Alquileres a ON a.vehiculoId = p_vehiculoId
    WHERE a.engancheFinId = e.id
    ORDER BY a.fechaHoraFin DESC
    LIMIT 1;

    -- Verificar que el nuevo enganche está libre
    SELECT estado, numero, estacionId
    INTO v_estadoEnganche, v_numEnganche, v_estacionId
    FROM Enganches
    WHERE id = p_nuevoEngancheId
    LIMIT 1;

    IF v_estadoEnganche != 'libre' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El enganche destino no está libre';
    END IF;

    -- Actualizar enganche antiguo a libre (si existía)
    IF v_engancheActualId IS NOT NULL THEN
        UPDATE Enganches
        SET estado = 'libre'
        WHERE id = v_engancheActualId;
    END IF;

    -- Actualizar enganche nuevo a ocupado
    UPDATE Enganches
    SET estado = 'ocupado'
    WHERE id = p_nuevoEngancheId;

    -- guardar nombre nueva estación
    SELECT e.nombre
    INTO v_estacionNombre
    FROM Estaciones e
    JOIN Enganches en ON en.estacionId = e.id
    WHERE en.id = p_nuevoEngancheId
    LIMIT 1;

    -- Actualizar vehículo
    UPDATE Vehiculos
    SET localizacion = CONCAT('Estación ', v_estacionNombre, ' Enganche ', v_numEnganche)
    WHERE id = p_vehiculoId;

    COMMIT;
END //
DELIMITER ;

-- Usuario empieza a pagar mensualidad

-- Caso positivo
-- START TRANSACTON;
-- CALL pago_mensual(1);
-- SELECT * FROM Pagos;
-- ROLLBACK;

-- Caso negativo
-- START TRANSACTION;
-- CALL pago_mensual(2);
-- SELECT * FROM Pagos;


DELIMITER //
CREATE OR REPLACE  PROCEDURE pago_mensual(
    IN p_usuarioId INT
)
BEGIN
    DECLARE v_clienteId INT;
    DECLARE v_cantidad DECIMAL(5,2);
    DECLARE v_pagosActivos INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error inesperado al registrar el pago';
    END;

    SET v_cantidad = 5.99;

    START TRANSACTION;

    SELECT id INTO v_clienteId
    FROM Clientes
    WHERE usuarioId = p_usuarioId AND borrado = FALSE
    FOR UPDATE;

    IF v_clienteId IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario no es cliente válido';
    END IF;

    SELECT COUNT(*) INTO v_pagosActivos
    FROM Pagos
    WHERE clienteId = v_clienteId 
        AND tipoPago = 'mensualidad'
        AND TIMESTAMPDIFF(DAY, fecha, CURDATE()) < 30
    FOR UPDATE;

    IF v_pagosActivos > 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente ya tiene una mensualidad activa';
    END IF;

    INSERT INTO Pagos (clienteId, tipoPago, cantidad, fecha)
    VALUES (v_clienteId, 'mensualidad', v_cantidad, CURDATE());

    COMMIT;
END //
DELIMITER ;

-- El soft delete se hace con procedimiento para evitar inconsistencias
-- Caso positivo
-- START TRANSACTION;
-- SELECT borrado FROM Vehiculos WHERE id = 1
-- CALL soft_delete_vehiculo(1)
-- SELECT borrado FROM Vehiculos WHERE id = 1
-- ROLLBACK;

--Caso negativo
-- START TRANSACTION;
-- SELECT borrado FROM Vehiculos WHERE id = 1
-- CALL soft_delete_vehiculo(1)
-- SELECT borrado FROM Vehiculos WHERE id = 1
-- CALL soft_delete_vehiculo(1)

DELIMITER //
CREATE OR REPLACE PROCEDURE soft_delete_vehiculo(
    IN p_vehiculoId INT
)
BEGIN
    DECLARE v_estado VARCHAR(50);
    DECLARE v_borrado BOOLEAN;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error al borrar el vehículo';
    END;

    START TRANSACTION;

    SELECT estado, borrado
    INTO v_estado, v_borrado
    FROM Vehiculos
    WHERE id = p_vehiculoId
    FOR UPDATE;

    IF v_borrado = TRUE THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El vehículo ya está borrado';
    END IF;

    IF v_estado = 'en_uso' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede borrar un vehículo en uso';
    END IF;

    UPDATE Vehiculos
    SET borrado = TRUE
    WHERE id = p_vehiculoId;

    COMMIT;
END //
DELIMITER ;
