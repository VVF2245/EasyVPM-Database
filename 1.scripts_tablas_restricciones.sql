CREATE TABLE Usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    correo VARCHAR(255) UNIQUE NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    CHECK (CHAR_LENGTH(contrasena) >= 8)
);

CREATE TABLE Clientes (
    usuarioId INT PRIMARY KEY,
    fechaNacimiento DATE NOT NULL,
    alquilerActivo TINYINT(1) NOT NULL, -- 'derivado'
    borrado TINYINT(1) NOT NULL,
    FOREIGN KEY (usuarioId) REFERENCES Usuarios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Tecnicos_Mantenimiento (
    usuarioId INT PRIMARY KEY,
    fechaFinUltimoServicio DATE, -- 'derivado'
    borrado TINYINT(1) NOT NULL,
    FOREIGN KEY (usuarioId) REFERENCES Usuarios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Quito el enum por la explicación que dio Damián en clase (que a lo mejor los de EasyVPM quieren añadir estados)
-- y porque con el trigger del atributo derivado ya aparecerán los estados que digamos'
CREATE TABLE Vehiculos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estado VARCHAR(50) NOT NULL, -- 'derivado'
    kilometraje DECIMAL(7,2) NOT NULL DEFAULT 0.00, -- 'derivado'
    numeroUsos INT NOT NULL DEFAULT 0, -- 'derivado'
    localizacion VARCHAR(200), -- 'derivado'
    borrado BOOLEAN NOT NULL
);

CREATE TABLE Bicicletas (
    vehiculoId INT PRIMARY KEY,
    tipoBici VARCHAR(50) NOT NULL,
    FOREIGN KEY (vehiculoId) REFERENCES Vehiculos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Patinetes_Electricos (
    vehiculoId INT PRIMARY KEY,
    autonomiaBateria DECIMAL(4,1) NOT NULL,
    FOREIGN KEY (vehiculoId) REFERENCES Vehiculos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Estaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) UNIQUE NOT NULL,
    numeroVehiculos INT NOT NULL, -- 'derivado'
    borrado TINYINT(1) NOT NULL
);

CREATE TABLE Enganches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estacionId INT NOT NULL,
    numero INT NOT NULL,
    estado VARCHAR(50) NOT NULL, -- 'derivado'
    borrado TINYINT(1) NOT NULL,
    UNIQUE (estacionId, numero),
    FOREIGN KEY (estacionId) REFERENCES Estaciones(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE Alquileres (
    id INT AUTO_INCREMENT PRIMARY KEY,
    clienteId INT NOT NULL,
    vehiculoId INT NOT NULL,
    engancheInicioId INT NOT NULL,
    engancheFinId INT DEFAULT NULL,
    fechaHoraInicio DATETIME NOT NULL,
    fechaHoraFin DATETIME,
    distanciaRecorrida DECIMAL(7,2),
    costo DECIMAL(7, 2) NOT NULL, -- 'derivada'
    lugarInicio VARCHAR(200) NOT NULL, -- 'derivada'
    lugarFin VARCHAR(200) DEFAULT NULL, -- 'derivada'
    CHECK (fechaHoraFin IS NULL OR fechaHoraFin > fechaHoraInicio),
    CHECK (costo >= 0),
    FOREIGN KEY (clienteId) REFERENCES Clientes(usuarioId)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (vehiculoId) REFERENCES Vehiculos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (engancheInicioId) REFERENCES Enganches(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (engancheFinId) REFERENCES Enganches(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Valoraciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    alquilerId INT,
    vehiculoId INT NOT NULL,
    puntuacion INT NOT NULL,
    comentario VARCHAR(500),
    CHECK (puntuacion BETWEEN 1 AND 5),
    FOREIGN KEY (alquilerId) REFERENCES Alquileres(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (vehiculoId) REFERENCES Vehiculos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Reparaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tecnicoId INT,
    vehiculoId INT NOT NULL,
    fechaInicio DATE NOT NULL,
    fechaFin DATE,
    detalles VARCHAR(1000) NOT NULL,
    CHECK (fechaFin IS NULL OR fechaFin >= fechaInicio),
    FOREIGN KEY (tecnicoId) REFERENCES Tecnicos_Mantenimiento(usuarioId)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (vehiculoId) REFERENCES Vehiculos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Pagos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    clienteId INT NOT NULL,
    alquilerId INT,
    tipoPago VARCHAR(50) NOT NULL, 
    cantidad DECIMAL(7,2) NOT NULL, -- 'derivado'
    fecha DATE NOT NULL,
    CHECK (cantidad >= 0),
    FOREIGN KEY (clienteId) REFERENCES Clientes(usuarioId)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (alquilerId) REFERENCES Alquileres(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
