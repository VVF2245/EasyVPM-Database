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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=
        'ERROR AL FINALIZAR ALQUILER';
    END;

    START TRANSACTION;
    -- 1. Obtener datos actuales del alquiler y vehiculo
    SELECT vehiculoId, fechaHoraInicio, clienteId 
    INTO v_vehiculoId, v_fechaInicio, v_clienteId
    FROM Alquileres 
    WHERE Alquileres.id=p_alquilerId;

    -- Validar fecha
    SET v_minutos = TIMESTAMPDIFF(MINUTE, v_fechaInicio, p_fechaFin);
    IF v_minutos < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=
        'La fecha fin no puede ser anterior a la inicio';
    END IF;

    -- 2. Calculo del cobro
    -- Buscamos fechas de mensualidad activa
    SELECT fecha INTO v_fechaMensualidad
    FROM Pagos
    WHERE clienteId = v_clienteId AND tipoPago='mensualidad'
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
        WHERE id = v_clienteId;
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
    WHERE id = p_nuevoEngancheId;

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

    -- Actualizar vehículo
    UPDATE Vehiculos
    SET localizacion = CONCAT('Estación ', v_estacionNombre, ' Enganche ', v_numEnganche)
    WHERE id = p_vehiculoId;
END //
DELIMITER ;