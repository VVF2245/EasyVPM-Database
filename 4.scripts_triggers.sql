

-- Caso positivo
-- START TRANSACTION;
-- INSERT INTO Usuarios (correo, contraseña, nombre) VALUES
-- ('german@gmail.com',       '$2a$12$wntX/gxexnKFT8GbXxBYi.KmgDs3WCsuCMk25673OvTLJE1q1YKDq',     'Germán Martín'),

-- INSERT INTO Clientes (fechaNacimiento, alquilerActivo, borrado) VALUES
-- ('Básica',  '1995-04-12', FALSE, FALSE);

-- SELECT * FROM Usuarios;
-- SELECT * FROM Clientes;
-- ROLLBACK;

-- Caso negativo
-- START TRANSACTION;
-- INSERT INTO Usuarios (correo, contraseña, nombre) VALUES
-- ('german@gmail.com',       '$2a$12$wntX/gxexnKFT8GbXxBYi.KmgDs3WCsuCMk25673OvTLJE1q1YKDq',     'Germán Martín'),

-- INSERT INTO Clientes (fechaNacimiento, alquilerActivo, borrado) VALUES
-- ('Básica',  '2020-04-12', FALSE, FALSE);

-- SELECT * FROM Usuarios;
-- SELECT * FROM Clientes;
-- ROLLBACK;

-- el requisito de edad lo ponemos como trigger porque a heidisql no le gusta operar con curdate()
DELIMITER //
CREATE TRIGGER trg_cliente_edad_minima
BEFORE INSERT ON Clientes
FOR EACH ROW
BEGIN
    IF TIMESTAMPDIFF(YEAR, NEW.fechaNacimiento, CURDATE()) <12 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente debe tener al menos 12 años';
    END IF;
END //
DELIMITER ;


DELIMITER //

CREATE TRIGGER trg_no_elim_cli_alq
BEFORE UPDATE ON Clientes
FOR EACH ROW
BEGIN
    -- Solo cuando se intenta hacer soft delete
    IF OLD.borrado = FALSE AND NEW.borrado = TRUE THEN

        -- Comprobar alquiler activo
        IF EXISTS (
            SELECT 1
            FROM Alquileres
            WHERE Alquileres.clienteId = OLD.usuarioId
              AND Alquileres.fechaHoraFin IS NULL
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'No se puede eliminar un cliente con un alquiler activo';
        END IF;

    END IF;
END //
DELIMITER;

--Este trigger es para evitar que se haga un DELETE real, sin el aunque tengamos que no se pueda hacer soft delete con cliente activo se sigue pudiendo eliminar totalmente a un cliente
CREATE TRIGGER trg_clientes_no_delete_con_alquiler
BEFORE DELETE ON Clientes
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Alquileres
        WHERE Alquileres.clienteId = OLD.usuarioId
          AND Alquileres.fechaHoraFin IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'No se puede eliminar un cliente con alquiler activo';
    END IF;
END;

DELIMITER //

CREATE TRIGGER trg_no_elim_veh_alq
BEFORE UPDATE ON Vehiculos
FOR EACH ROW
BEGIN
    -- Solo cuando se intenta hacer soft delete
    IF OLD.borrado = FALSE AND NEW.borrado = TRUE THEN

        -- Comprobar alquiler activo
        IF EXISTS (
            SELECT 1
            FROM Alquileres
            WHERE Alquileres.vehiculoId = OLD.id
              AND Alquileres.fechaHoraFin IS NULL
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'No se puede eliminar un vehículo con un alquiler activo';
        END IF;

    END IF;
END//

DELIMITER ;

-- de la misma manera que con los clientes voy a hacer un 2º trigger para asegurarme de que no se hace un DELETE real con los vehiculos en alquiler
DELIMITER//
CREATE TRIGGER trg_no_delete_veh_alq
BEFORE DELETE ON Vehiculos
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 
    FROM ALQUILERES
    WHERE Alquileres.vehiculoId=OLD.id
        AND Alquileres.fechaHoraFin is NULL
    )THEN 
        SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'No se puede eliminar un vehículo con un alquiler activo';
    END IF;
END//
DELIMITER;

DELIMITER//
CREATE TRIGGER trg_no_borrado_estacion_enganches
BEFORE UPDATE ON Estaciones
FOR EACH ROW 
    -- Solo cuando se intenta hacer soft delete
    IF OLD.borrado = FALSE AND NEW.borrado = TRUE THEN

    IF EXISTS(
    SELECT 1
    FROM Enganches
    WHERE Enganches.estacionId=OLD.id
    )THEN
        SIGNAL SQLSTATE '45000'
                SET MESAGGE_TEXT='No se puede eliminar una estacion con un enganche activo';
    END IF;
END//
DELIMITER;


DELIMITER//
CREATE TRIGGER trg_no_DELETE_estacion_enganches
BEFORE DELETE ON Estaciones
FOR EACH ROW 

    IF EXISTS(
    SELECT 1
    FROM Enganches
    WHERE Enganches.estacionId=OLD.id
    )THEN
        SIGNAL SQLSTATE '45000'
                SET MESAGGE_TEXT='No se puede eliminar una estacion con un enganche activo';
    END IF;
END//
DELIMITER;
DELIMITER //
    
CREATE TRIGGER trg_B_insert_alquileres_validar_inicio
BEFORE INSERT ON Alquileres
FOR EACH ROW
BEGIN
    DECLARE activo BOOLEAN;
    DECLARE v_estado VARCHAR(255);
    DECLARE v_estacionInicio VARCHAR(255);
    DECLARE v_numInicio INT;
    IF NEW.clienteId IS NOT NULL AND NEW.fechaHoraFin IS NULL THEN

        SELECT alquilerActivo
        INTO activo
        FROM Clientes
        WHERE usuarioId = NEW.clienteId;

        IF activo = TRUE THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El cliente ya tiene un alquiler activo';
        END IF;

        -- comprobar que el vehículo está disponible

        SELECT estado
        INTO v_estado
        FROM Vehiculos
        WHERE id = NEW.vehiculoId;
        IF v_estado != 'disponible' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El vehículo no está disponible para alquilar';
        END IF;

        -- Obtener localización enganche inicio alquiler

        SELECT Estaciones.nombre, Enganches.numero
        INTO v_estacionInicio, v_numInicio
        FROM Enganches
        JOIN Estaciones ON Enganches.estacionId = Estaciones.id
        WHERE Enganches.id = NEW.engancheInicioId;

        SET NEW.lugarInicio = CONCAT('Estación ', v_estacionInicio, ' Enganche ', v_numInicio);
    END IF;
END //
DELIMITER ;


DELIMITER //
-- se crea alquiler, vehiculo pasa a "en uso" y el enganche a "disponible"
CREATE TRIGGER trg_A_insert_alquileres 
AFTER INSERT ON Alquileres
FOR EACH ROW
BEGIN
    IF NEW.fechaHoraFin IS NULL THEN

        -- no hay localización gps del vehículo al desengancharlo, por eso NULL
        UPDATE Vehiculos
        SET estado = 'en_uso',
            localizacion = NULL
        WHERE id = NEW.vehiculoId;

        UPDATE Enganches
        SET estado = 'libre'
        WHERE id = NEW.engancheInicioId;

        UPDATE Clientes
        SET alquilerActivo = TRUE
        WHERE usuarioId = NEW.clienteId;
    END IF;
END//

DELIMITER ;

DELIMITER //
-- calculo del cobro 
CREATE TRIGGER trg_B_update_Alquileres
BEFORE UPDATE ON Alquileres
FOR EACH ROW
BEGIN
    DECLARE minutos INT;
    DECLARE tarifa DECIMAL(5,2);
    DECLARE fechaMensualidad DATE;
    DECLARE v_estacionFin VARCHAR(255);
    DECLARE v_numFin INT;

    SET tarifa = 0.20;   -- tarifa base por minuto

    -- Solo calcular si se está finalizando el alquiler
    IF OLD.fechaHoraFin IS NULL AND NEW.fechaHoraFin IS NOT NULL THEN

        -- Buscar la última mensualidad del cliente
        SELECT fecha
        INTO fechaMensualidad
        FROM Pagos
        WHERE clienteId = NEW.clienteId
          AND tipoPago != 'mensualidad'
        ORDER BY fecha DESC
        LIMIT 1;

        -- Si existe mensualidad y sigue activa entonces costo gratuito
        IF fechaMensualidad IS NOT NULL 
           AND fechaMensualidad >= DATE_SUB(NEW.fechaHoraFin, INTERVAL 30 DAY) THEN
            
            SET NEW.costo = 0;

        ELSE
            -- Calcular tiempo en minutos
            SET minutos = TIMESTAMPDIFF(MINUTE, OLD.fechaHoraInicio, NEW.fechaHoraFin);

            IF minutos < 0 THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'La fecha de fin debe ser posterior a la de inicio.';
            END IF;

            -- Calcular costo normal
            SET NEW.costo = minutos * tarifa;
        END IF;

        -- poner que el cliente ya no tiene un alquiler activo
        UPDATE Clientes
        SET alquilerActivo = FALSE
        WHERE usuarioId = NEW.clienteId;

        -- Poner la localización final del alquiler

        SELECT Estaciones.nombre, Enganches.numero
        INTO v_estacionFin, v_numFin
        FROM Enganches
        JOIN Estaciones ON Enganches.estacionId = Estaciones.id
        WHERE Enganches.id = NEW.engancheFinId;

        UPDATE Alquileres
        SET NEW.lugarFin = CONCAT('Estacion ', v_estacionFin, ' Enganche ', v_numFin);

    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_A_update_alquiler
AFTER UPDATE ON Alquileres
FOR EACH ROW
BEGIN
    -- Obtener datos del enganche final
    DECLARE v_estacion VARCHAR(255);
    DECLARE v_numEnganche INT;

    DECLARE v_usos INT;
    DECLARE v_km DECIMAL(5,2);

    IF NEW.fechaHoraFin IS NOT NULL AND OLD.fechaHoraFin IS NULL THEN

        -- El enganche pasa a "ocupado"
        UPDATE Enganches
        SET estado = 'ocupado'
        WHERE id = NEW.engancheFinId;

        SELECT Estaciones.nombre, Enganches.numero
        INTO v_estacion, v_numEnganche
        FROM Enganches
        JOIN Estaciones ON Enganches.estacionId = Estaciones.id
        WHERE Enganches.id = NEW.engancheFinId;

        -- Aumentar contadores del vehículo
        UPDATE Vehiculos
        SET 
            numeroUsos = numeroUsos + 1,
            kilometraje = kilometraje + NEW.distanciaRecorrida,
            localizacion = CONCAT('Estación ', v_estacion, ' Enganche ', v_numEnganche)
        WHERE id = NEW.vehiculoId;


        SELECT numeroUsos, kilometraje
        INTO v_usos, v_km
        FROM Vehiculos
        WHERE id = NEW.vehiculoId;

        IF v_usos > 50 OR v_km > 500.00 THEN
            UPDATE Vehiculos
            SET estado = 'mantenimiento_pendiente'
            WHERE id = NEW.vehiculoId;
        
        -- Si no supera límites → disponible
        ELSE
            UPDATE Vehiculos
            SET estado = 'disponible'
            WHERE id = NEW.vehiculoId;
        END IF;

        --registro automatico del pago
        INSERT INTO Pagos (clienteId, alquilerId, tipoPago, cantidad, fecha)
        VALUES (
            NEW.clienteId,
            NEW.id,
            'cargo_automático',
            NEW.costo,
            CURDATE()
        );

    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_A_update_enganches_actualizar_estacion
AFTER UPDATE ON Enganches
FOR EACH ROW
BEGIN
    IF OLD.estado != NEW.estado OR OLD.estacionId != NEW.estacionId THEN

        -- Recalcular para la estacion antigua si ha habido cambio de estación
        IF OLD.estacionId != NEW.estacionId THEN
            UPDATE Estaciones
            SET numeroVehiculos = (
                SELECT COUNT(*)
                FROM Enganches
                WHERE estacionId = OLD.estacionId AND estado = 'ocupado'
            )
            WHERE id = OLD.estacionId;
        END IF;

        -- Recalcular para la estación antigua o si no ha habido cambio de estación
        UPDATE Estaciones
        SET numeroVehiculos = (
            SELECT COUNT(*)
            FROM Enganches
            WHERE estacionId = NEW.estacionId AND estado = 'ocupado'
        )
        WHERE id = NEW.estacionId;

    END IF;
END //
DELIMITER ;

DELIMITER //
-- para que se actualice el número de vehículos en la estación si se crean enganches nuevos
CREATE TRIGGER trg_A_insert_enganches_actualizar_estacion
AFTER INSERT ON Enganches
FOR EACH ROW
BEGIN
    UPDATE Estaciones
    SET numeroVehiculos = (
        SELECT COUNT(*)
        FROM Enganches
        WHERE estacionId = NEW.estacionId AND estado = 'ocupado'
    )
    WHERE id = NEW.estacionId;
END //
DELIMITER ;


DELIMITER //
-- para que se actualice el número de vehículos en la estación si se borran enganches
CREATE TRIGGER trg_A_delete_enganches_actualizar_estacion
AFTER DELETE ON Enganches
FOR EACH ROW
BEGIN
    UPDATE Estaciones
    SET numeroVehiculos = (
        SELECT COUNT(*)
        FROM Enganches
        WHERE estacionId = OLD.estacionId AND estado = 'ocupado'
    )
    WHERE id = OLD.estacionId;
END //
DELIMITER ;

DELIMITER //
--cuando se registra una reparacion vehiculo pasa a "en_mantenimiento"
CREATE TRIGGER trg_A_insert_reparaciones_vehiculo
AFTER INSERT ON Reparaciones
FOR EACH ROW
BEGIN
    UPDATE Vehiculos
    SET estado = 'en_mantenimiento', 
    kilometraje=0.0,
    numeroUsos=0
    WHERE Vehiculos.id = NEW.vehiculoId;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_A_update_reparaciones
AFTER UPDATE ON Reparaciones
FOR EACH ROW
BEGIN
    
    IF NEW.fechaFin IS NOT NULL AND OLD.fechaFin IS NULL THEN
        --cuando se termina la reparacion el vehiculo pasa a "reparado"
        UPDATE Vehiculos
        SET estado = 'reparado'
        WHERE id = NEW.vehiculoId;

        UPDATE Tecnicos_Mantenimiento
        SET fechaFinUltimoServicio = NEW.fechaFin
        WHERE usuarioId = NEW.tecnicoId;
    END IF;
END //
DELIMITER ;

--si se registra una valoracion muy baja el vehiculo pasa a "averiado"
DELIMITER //

CREATE TRIGGER trg_A_insert_valoracion
AFTER INSERT ON Valoraciones
FOR EACH ROW
BEGIN
    --si un vehiculo tiene una valoracion igual o menor a 2 pasa su estado a averiado para que lo revisen urgentemente
    IF NEW.puntuacion <= 2 THEN
        UPDATE Vehiculos
        SET estado = 'averiado'
        WHERE id = NEW.vehiculoId;
    END IF;
END //
DELIMITER ;

