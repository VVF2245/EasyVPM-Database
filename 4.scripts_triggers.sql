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