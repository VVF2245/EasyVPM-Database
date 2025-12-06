--el requisito de edad lo ponemos como trigger porque a heidisql no le gusta operar con curdate()
DELIMITER //

CREATE TRIGGER trg_cliente_edad_minima
BEFORE INSERT ON Clientes
FOR EACH ROW
BEGIN
    IF NEW.fechaNacimiento > (CURDATE() - INTERVAL 12 YEAR) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente debe tener al menos 12 años';
    END IF;
END//

DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_B_insert_alquileres_validar_inicio
BEFORE INSERT ON Alquileres
FOR EACH ROW
BEGIN
    IF NEW.clienteId IS NOT NULL AND NEW.fechaHoraFin IS NULL THEN
        DECLARE activo BOOLEAN;

        SELECT alquilerActivo
        INTO activo
        FROM Clientes
        WHERE id = NEW.clienteId

        IF activo = TRUE THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El cliente ya tiene un alquiler activo';
        END IF;

        --comprobar que el vehículo está disponible
        DECLARE v_estado VARCHAR(255);

        SELECT estado
        INTO v_estado
        FROM Vehiculos
        WHERE id = NEW.vehiculoId;
        IF v_estado != 'disponible' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El vehículo no está disponible para alquilar';
        END IF;

        -- Obtener localización enganche inicio alquiler
        DECLARE v_estacionInicio VARCHAR(255);
        DECLARE v_numInicio INT;

        SELECT Estaciones.nombre, Enganches.numero
        INTO v_estacionInicio, v_numInicio
        FROM Enganches
        JOIN Estaciones ON Enganches.estacionId = Estaciones.id
        WHERE Enganches.id = NEW.engancheInicioId;

        UPDATE Alquileres
        SET lugarInicio = CONCAT('Estación ', v_estacionInicio, ' Enganche ', v_numInicio)
        WHERE id = NEW.id;
    END IF;
END //
DELIMITER ;


DELIMITER //
--se crea alquiler, vehiculo pasa a "en uso" y el enganche a "disponible"
CREATE TRIGGER trg_A_insert_alquileres 
AFTER INSERT ON Alquileres
FOR EACH ROW
BEGIN
    IF NEW.fechaHoraFin IS NULL THEN

        --no hay localización gps del vehículo al desengancharlo, por eso NULL
        UPDATE Vehiculos
        SET estado = 'en_uso',
            localizacion = NULL
        WHERE id = NEW.vehiculoId;

        UPDATE Enganches
        SET estado = 'libre'
        WHERE id = NEW.engancheInicioId;

        UPDATE Clientes
        SET alquilerActivo = TRUE
        WHERE id = NEW.clienteId;
    END IF;
END//

DELIMITER ;

DELIMITER //
--calculo del cobro 
CREATE TRIGGER trg_B_update_Alquileres
BEFORE UPDATE ON Alquileres
FOR EACH ROW
BEGIN
    -- Solo calcular si se está finalizando el alquiler
    IF OLD.fechaHoraFin IS NULL AND NEW.fechaHoraFin IS NOT NULL THEN
        
        DECLARE minutos INT;
        DECLARE tarifa DECIMAL(5,2) DEFAULT 0.20;   -- tarifa base por minuto
        DECLARE fechaMensualidad DATE;

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
        WHERE id = NEW.clienteId

        -- Poner la localización final del alquiler
        DECLARE v_estacionFin VARCHAR(255);
        DECLARE v_numFin INT;

        SELECT Estaciones.nombre, Enganches.numero
        INTO v_estacionFin, v_numFin
        FROM Enganches
        JOIN Estaciones ON Enganches.estacionId = Estaciones.id
        WHERE Enganches.id = NEW.engancheFinId;

        UPDATE Alquileres
        SET lugarFin = CONCAT('Estacion ', v_estacionFin, ' Enganche ', v_numFin)
        WHERE id = NEW.id;

    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_A_update_alquiler
AFTER UPDATE ON Alquileres
FOR EACH ROW
BEGIN
    IF NEW.fechaHoraFin IS NOT NULL AND OLD.fechaHoraFin IS NULL THEN

        -- El enganche pasa a "ocupado"
        UPDATE Enganches
        SET estado = 'ocupado'
        WHERE id = NEW.engancheFinId;

        -- Obtener datos del enganche final
        DECLARE v_estacion VARCHAR(255);
        DECLARE v_numEnganche INT;

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

        DECLARE v_usos INT;
        DECLARE v_km DECIMAL(5,2);

        SELECT numeroUsos, kilometraje
        INTO v_usos, v_km
        FROM Vehiculos
        WHERE id = NEW.vehiculoId

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
--cuando se registra una reparacion vehiculo pasa a "en_mantenimiento"
CREATE TRIGGER trg_A_insert_reparaciones_vehiculo
AFTER INSERT ON Reparaciones
FOR EACH ROW
BEGIN
    UPDATE Vehiculos
    SET estado = 'en_mantenimiento', 
    kilometros=0.0,
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
        WHERE id = NEW.tecnicoId;
    END IF;
END //
DELIMITER ;


DELIMITER //
CREATE TRIGGER trg_B_delete_usuarios_no_eliminar
BEFORE DELETE ON Usuarios
FOR EACH ROW
BEGIN
    -- comprobar si tiene algún alquiler activo
    IF EXISTS (
        SELECT 1
        FROM Clientes
        JOIN Alquileres ON alquileres.clienteId = clientes.id
        WHERE clientes.usuarioId = OLD.id AND Alquileres.fechaHoraFin IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar un usuario que tenga un alquiler activo';
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

