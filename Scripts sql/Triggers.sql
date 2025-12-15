DELIMITER //

CREATE TRIGGER trg_no_dos_aquileres
BEFORE INSERT ON Alquileres
FOR EACH ROW
BEGIN 
    DECLARE alquileres_activos INT;

    SELECT COUNT(*) INTO alquileres_activos
    FROM Alquileres
    WHERE clienteId=NEW.clienteId AND fechaFin IS NULL;

    IF alquileres_activos > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'No se puede tener más de 1 alquiler activo';
    END IF;
END//

DELIMITER ;
    
CREATE TRIGGER trg_cliente_edad_minima
BEFORE INSERT ON Clientes
FOR EACH ROW
BEGIN
    IF TIMESTAMPDIFF(YEAR, NEW.fechaNacimiento, CURDATE()) < 12 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente debe tener al menos 12 años';
    END IF;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_no_elim_cli_alq
BEFORE UPDATE ON Clientes
FOR EACH ROW
BEGIN
    IF OLD.borrado = 0 AND NEW.borrado = 1 THEN
        IF EXISTS (
            SELECT 1
            FROM Alquileres
            WHERE clienteId = OLD.usuarioId
              AND fechaHoraFin IS NULL
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar un cliente con un alquiler activo';
        END IF;
    END IF;
END//

CREATE TRIGGER trg_no_delete_cli_alq
BEFORE DELETE ON Clientes
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Alquileres
        WHERE clienteId = OLD.usuarioId
          AND fechaHoraFin IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar un cliente con alquiler activo';
    END IF;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_no_elim_veh_alq
BEFORE UPDATE ON Vehiculos
FOR EACH ROW
BEGIN
    IF OLD.borrado = 0 AND NEW.borrado = 1 THEN
        IF EXISTS (
            SELECT 1
            FROM Alquileres
            WHERE vehiculoId = OLD.id
              AND fechaHoraFin IS NULL
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar un vehículo con un alquiler activo';
        END IF;
    END IF;
END//

CREATE TRIGGER trg_no_delete_veh_alq
BEFORE DELETE ON Vehiculos
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Alquileres
        WHERE vehiculoId = OLD.id
          AND fechaHoraFin IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar un vehículo con alquiler activo';
    END IF;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_no_borrado_estacion_enganches
BEFORE UPDATE ON Estaciones
FOR EACH ROW
BEGIN
    IF OLD.borrado = 0 AND NEW.borrado = 1 THEN
        IF EXISTS (
            SELECT 1
            FROM Enganches
            WHERE estacionId = OLD.id
              AND estado = 'ocupado'
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar una estación con enganches ocupados';
        END IF;
    END IF;
END//

CREATE TRIGGER trg_no_delete_estacion_enganches
BEFORE DELETE ON Estaciones
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Enganches
        WHERE estacionId = OLD.id
          AND estado = 'ocupado'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar la estación con enganches ocupados';
    END IF;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_A_insert_enganches_actualizar_estacion
AFTER INSERT ON Enganches
FOR EACH ROW
BEGIN
    UPDATE Estaciones
    SET numeroVehiculos = (
        SELECT COUNT(*)
        FROM Enganches
        WHERE estacionId = NEW.estacionId
          AND estado = 'ocupado'
    )
    WHERE id = NEW.estacionId;
END//

CREATE TRIGGER trg_A_update_enganches_actualizar_estacion
AFTER UPDATE ON Enganches
FOR EACH ROW
BEGIN
    UPDATE Estaciones
    SET numeroVehiculos = (
        SELECT COUNT(*)
        FROM Enganches
        WHERE estacionId = NEW.estacionId
          AND estado = 'ocupado'
    )
    WHERE id = NEW.estacionId;
END//

CREATE TRIGGER trg_A_delete_enganches_actualizar_estacion
AFTER DELETE ON Enganches
FOR EACH ROW
BEGIN
    UPDATE Estaciones
    SET numeroVehiculos = (
        SELECT COUNT(*)
        FROM Enganches
        WHERE estacionId = OLD.estacionId
          AND estado = 'ocupado'
    )
    WHERE id = OLD.estacionId;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_A_insert_reparaciones_vehiculo
AFTER INSERT ON Reparaciones
FOR EACH ROW
BEGIN
    UPDATE Vehiculos
    SET estado = 'en_mantenimiento',
        kilometraje = 0,
        numeroUsos = 0
    WHERE id = NEW.vehiculoId;
END//

CREATE TRIGGER trg_A_update_reparaciones
AFTER UPDATE ON Reparaciones
FOR EACH ROW
BEGIN
    IF NEW.fechaFin IS NOT NULL AND OLD.fechaFin IS NULL THEN
        UPDATE Vehiculos
        SET estado = 'reparado'
        WHERE id = NEW.vehiculoId;

        UPDATE Tecnicos_Mantenimiento
        SET fechaFinUltimoServicio = NEW.fechaFin
        WHERE usuarioId = NEW.tecnicoId;
    END IF;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_A_insert_valoracion
AFTER INSERT ON Valoraciones
FOR EACH ROW
BEGIN
    IF NEW.puntuacion <= 2 THEN
        UPDATE Vehiculos
        SET estado = 'mantenimiento_pendiente'
        WHERE id = NEW.vehiculoId;
    END IF;
END//

DELIMITER ;

