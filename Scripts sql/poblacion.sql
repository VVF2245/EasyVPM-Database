
-- USUARIOS

INSERT INTO Usuarios (nombre, correo, contrasena) VALUES
('Juan Pérez', 'juan@mail.com', 'password123'),
('Ana López', 'ana@mail.com', 'password123'),
('Carlos Ruiz', 'carlos@mail.com', 'password123'),
('Laura Gómez', 'laura@mail.com', 'password123'),
('Pedro Técnico', 'tecnico@mail.com', 'password123');


-- CLIENTES (edad >= 12, trigger OK)

INSERT INTO Clientes (usuarioId, fechaNacimiento, alquilerActivo, borrado) VALUES
(1, '1995-05-10', 0, 0),
(2, '2000-03-22', 0, 0),
(3, '1988-11-01', 0, 0),
(4, '1999-07-15', 0, 0);

-- TÉCNICOS

INSERT INTO Tecnicos_Mantenimiento (usuarioId, fechaFinUltimoServicio, borrado)
VALUES (5, NULL, 0);


-- ESTACIONES

INSERT INTO Estaciones (nombre, numeroVehiculos, borrado) VALUES
('Estación Centro', 0, 0),
('Estación Norte', 0, 0);


-- ENGANCHES

INSERT INTO Enganches (estacionId, numero, estado, borrado) VALUES
(1, 1, 'ocupado', 0),
(1, 2, 'libre', 0),
(1, 3, 'libre', 0),
(2, 1, 'ocupado', 0),
(2, 2, 'libre', 0);


-- VEHÍCULOS

INSERT INTO Vehiculos (estado, kilometraje, numeroUsos, localizacion, borrado) VALUES
('disponible', 10, 5, 'Estación Centro Enganche 1', 0),
('disponible', 20, 8, 'Estación Norte Enganche 1', 0),
('mantenimiento_pendiente', 600, 55, 'Taller', 0);


-- BICICLETAS / PATINETES

INSERT INTO Bicicletas (vehiculoId, tipoBici)
VALUES (1, 'urbana');

INSERT INTO Patinetes_Electricos (vehiculoId, autonomiaBateria)
VALUES (2, 25.0);


-- ALQUILER ACTIVO

INSERT INTO Alquileres (
    clienteId, vehiculoId, engancheInicioId,
    fechaHoraInicio, costo, lugarInicio
)
VALUES (
    1, 1, 1,
    NOW() - INTERVAL 30 MINUTE, 0, 'Estación Centro'
);

UPDATE Clientes SET alquilerActivo = 1 WHERE usuarioId = 1;
UPDATE Vehiculos SET estado = 'en uso' WHERE id = 1;
UPDATE Enganches SET estado = 'libre' WHERE id = 1;