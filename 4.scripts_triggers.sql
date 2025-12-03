DELIMITER //
CREATE TRIGGER pagos_borrar AFTER UPDATE ON Pagos
FOR EACH ROW
BEGIN
    -- si las dos claves foráneas quedan NULL se borra la fila
    IF NEW.clienteId IS NULL AND NEW.alquilerId IS NULL THEN
        DELETE FROM Pagos WHERE id = NEW.id;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER alquileres_borrar AFTER UPDATE ON Alquileres
FOR EACH ROW
BEGIN
    -- si estas dos claves foráneas quedan NULL se borra la fila
    IF NEW.clienteId IS NULL AND NEW.vehiculoId IS NULL THEN
        DELETE FROM Alquileres WHERE id = NEW.id;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER reparaciones_borrar AFTER UPDATE ON Reparaciones
FOR EACH ROW
BEGIN
    -- si las dos claves foráneas quedan NULL se borra la fila
    IF NEW.tecnicoId IS NULL AND NEW.vehiculoId IS NULL THEN
        DELETE FROM Reparaciones WHERE id = NEW.id;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER no_eliminar_usuario BEFORE DELETE ON Usuarios
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

DELIMITER //
CREATE TRIGGER un_vehiculo_por_usuario BEFORE INSERT ON Alquileres
FOR EACH ROW
BEGIN
    IF NEW.clienteId IS NOT NULL AND NEW.fechaHoraFin IS NULL THEN
        IF EXISTS (
            SELECT 1
            FROM Alquileres
            WHERE clienteId = NEW.clienteId AND fechaHoraFIN IS NULL
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El cliente ya tiene un alquiler activo';
        END IF;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER limite_usos_kilometraje AFTER UPDATE ON Vehiculos
FOR EACH ROW
BEGIN
    IF NEW.numeroUsos > 50 OR NEW.kilometraje > 500.00 THEN
        UPDATE Vehiculos
        SET estado = 'mantenimiento pendiente'
        WHERE id = NEW.id;
    END IF;
END //
DELIMITER ;