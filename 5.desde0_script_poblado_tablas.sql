'Se han puesto las contraseñas con un hash de BcryptGenerator. Las contraseñas no se meten tal cual a la BBDD y las reglas de negocio de estas deberían estar fuera (longitud y etc)'
INSERT INTO Usuarios (correo, contraseña, nombre) VALUES
('ana@hotmail.com',      '$2a$12$OmDnsaGjXSVbxEu6z33QUOw11WIUuFGk8lRh1vmgNatDdBchdIium',      'Ana Torres'),
('luis@gmail.com',       '$2a$12$wntX/gxexnKFT8GbXxBYi.KmgDs3WCsuCMk2JHj3OvTLJE1q1YKDq',     'Luis Martínez'),
('carlos@gmail.com',     '$2a$12$4hzpkDHlZXZGwHqkniH9h.qKMAupvj7a9InLLrRmA9BRVyhLZHmCq',   'Carlos Pérez'),
('laura@hotmail.com',     '$2a$12$wWUFBJwaiTaLJ5OOlEYDIuYL3KgSXPsbfDMNlfXkZly7WCAejiUC2',    'Laura Gómez'),
('jorge@gmail.com',      '$2a$12$cUb3ISV/w2yx8LNS/1QKE.d/diXREhqmIqR0BL2ADqHzQQKxV7mL6',    'Jorge Medina'),
('sofia@gmail.com',      '$2a$12$Y7rd3mmwQdT24ZaXcNy6Q.JzxrfS971qG2Em7mLcstCftDR/O2jjq',    'Sofía Requena'),
('tecnico1@empresa.com', '$2a$12$x6YIqdu52sa8FjBDTWoB..yfYnLlAahLuVxHcO/FPKDkT6CoVzWjW',      'Mario López'),
('tecnico2@empresa.com', '$2a$12$gIoTiMZcOt5JJwDEPLdh9.s2uqbOR0JCxrK2wvlt8oLeYHRHbSMtu',      'Lucía Navarro'),
('tecnico3@empresa.com', '$2a$12$dprYIR4UG3G7YguteFUVC.PPIDRyGPafQ7qwwbop4pwZJj0FC3a1.',      'Sergio Vidal');

INSERT INTO Clientes (usuarioId, tarifaActual, fechaNacimiento, alquilerActivo, borrado) VALUES
(1, 'Básica',  '1995-04-12', FALSE, FALSE),
(2, 'Premium', '1992-07-21', FALSE, FALSE),
(3, 'Básica',  '2000-02-10', FALSE, FALSE),
(4, 'Básica',  '1988-11-05', FALSE, FALSE),
(5, 'Premium', '1999-06-18', FALSE, FALSE),
(6, 'Básica',  '1996-09-02', FALSE, FALSE);

INSERT INTO Tecnicos_Mantenimiento (usuarioId, fechaFinUltimoServicio, borrado) VALUES
(7, NULL, FALSE),
(8, NULL, FALSE),
(9, NULL, FALSE);

INSERT INTO Estaciones (nombre, numeroVehiculos, borrado) VALUES
('Plaza Nueva', 0, FALSE),
('Alameda de Hércules', 0, FALSE),
('Triana', 0, FALSE),
('Universidad de Sevilla', 0, FALSE),
('Nervión', 0, FALSE);

INSERT INTO Enganches (estacionId, numero, estado, borrado) VALUES
(1, 1, 'LIBRE', FALSE),
(1, 2, 'OCUPADO', FALSE),
(1, 3, 'LIBRE', FALSE),

(2, 1, 'LIBRE', FALSE),
(2, 2, 'LIBRE', FALSE),

(3, 1, 'OCUPADO', FALSE),
(3, 2, 'LIBRE', FALSE),

(4, 1, 'LIBRE', FALSE),
(4, 2, 'LIBRE', FALSE),
(4, 3, 'LIBRE', FALSE);

INSERT INTO Vehiculos (estado, kilometraje, numeroUsos, localizacion, borrado) VALUES

-- Bicicletas en estaciones de Sevilla
('DISPONIBLE',  12.50,  3,  'Estación Plaza Nueva', FALSE),
('DISPONIBLE',  34.20,  5,  'Estación Plaza Nueva', FALSE),
('DISPONIBLE',   5.80,  1,  'Estación Alameda de Hércules', FALSE),
('DISPONIBLE',  20.60,  2,  'Estación Triana', FALSE),
('DISPONIBLE',  15.30,  3,  'Estación Triana', FALSE),
('DISPONIBLE',   9.99,  1,  'Estación Universidad de Sevilla', FALSE),
('DISPONIBLE',  25.00,  4,  'Estación Universidad de Sevilla', FALSE),

-- Vehículo recién añadido al sistema
('DISPONIBLE',   2.50,   1,  'Estación Plaza Nueva', FALSE);

INSERT INTO Bicicletas (vehiculoId, tipoBici) VALUES
(1, 'Urbana'),
(2, 'Montaña'),
(4, 'Urbana'),
(6, 'Eléctrica'),
(7, 'Urbana'),
(9, 'Montaña'),
(12, 'Urbana');

INSERT INTO Patinetes_Electricos (vehiculoId, autonomiaBateria) VALUES
(3, 35.5),
(5, 20.0),
(8, 27.3),
(10, 40.0),
(11, 15.5);

INSERT INTO Alquileres (
    clienteId,
    vehiculoId,
    engancheInicioId,
    engancheFinId,
    fechaHoraInicio,
    fechaHoraFin,
    distanciaRecorrida,
    costo,
    lugarInicio,
    lugarFin
)
VALUES
(1, 3,  1, 4, '2025-03-18 09:10:00', NULL, 3.20, 4.80, 'Plaza Nueva', NULL),

(2, 1,  4, 7, '2025-03-18 10:00:00', '2025-03-18 10:22:00', 2.10, 3.15, 'Alameda de Hércules', 'Triana'),

(3, 8,  7, 2, '2025-03-18 11:00:00', NULL,             1.40, 2.10, 'Triana', 'En curso'),

(4, 6,  2, 9, '2025-03-18 12:15:00', '2025-03-18 12:45:00', 4.00, 6.00, 'Alameda de Hércules', 'Universidad de Sevilla'),

(5, 10, 9, 1, '2025-03-19 08:20:00', '2025-03-19 09:00:00', 5.40, 8.10, 'Universidad de Sevilla', 'Plaza Nueva'),

(6, 11, 4, NULL, '2025-03-19 09:30:00', NULL,            0.80, 1.20, 'Alameda de Hércules', 'En curso'),

(1, 2,  1, 5, '2025-03-19 18:10:00', '2025-03-19 18:25:00', 1.60, 2.40, 'Plaza Nueva', 'Nervión'),

(2, 7,  7, 1, '2025-03-20 09:40:00', '2025-03-20 10:10:00', 3.60, 5.40, 'Triana', 'Plaza Nueva');

INSERT INTO Valoraciones (alquilerId, vehiculoId, puntuacion, comentario) VALUES
(1, 3, 5, 'Viaje perfecto por el centro de Sevilla'),
(2, 1, 4, 'Buen estado de la bici, aunque con algo de tráfico'),
(4, 6, 5, 'Muy cómoda para ir hasta la universidad'),
(5, 10, 3, 'La batería podría durar un poco más'),
(7, 2, 4, 'Rápido y cómodo para moverme por Nervión'),
(8, 7, 5, 'Muy buena experiencia cruzando el río');

INSERT INTO Reparaciones (
    tecnicoId,
    vehiculoId,
    fechaInicio,
    fechaFin,
    detalles
)
VALUES
(1, 5,  '2025-03-10', '2025-03-12', 'Sustitución de batería dañada por calor'),
(2, 11, '2025-03-11', '2025-03-13', 'Cambio de frenos'),
(3, 3,  '2025-03-15', '2025-03-16', 'Mantenimiento general'),
(1, 6,  '2025-03-17', '2025-03-17', 'Ajuste de cadena'),
(2, 8,  '2025-03-18', NULL,         'Revisión de motor eléctrico');

INSERT INTO Pagos (clienteId, alquilerId, tipoPago, cantidad, fecha) VALUES
(1, 1, 'Tarjeta', 4.80, '2025-03-18'),
(2, 2, 'PayPal',  3.15, '2025-03-18'),
(4, 4, 'Tarjeta', 6.00, '2025-03-18'),
(5, 5, 'Bizum',   8.10, '2025-03-19'),
(1, 7, 'Tarjeta', 2.40, '2025-03-19'),
(2, 8, 'Efectivo', 5.40, '2025-03-20');
