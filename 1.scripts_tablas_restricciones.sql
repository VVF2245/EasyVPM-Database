CREATE TABLE Usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    correo VARCHAR(255) UNIQUE NOT NULL,
    contraseña VARCHAR(255) NOT NULL CHECK (CHAR_LENGTH(contraseña) >= 8),
    nombre VARCHAR(255) NOT NULL
);

CREATE TABLE Clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuarioId INT NOT NULL,
    tarifaActual VARCHAR(50) NOT NULL,
    fechaNacimiento DATE NOT NULL,
    alquilerActivo BOOLEAN NOT NULL, 'derivado, trigger hecho'
    borrado BOOLEAN NOT NULL,
    FOREIGN KEY (usuarioId) REFERENCES Usuarios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT NoMinimoEdad CHECK(fechaNacimiento <= (CURDATE() - INTERVAL 12 YEAR))
);

CREATE TABLE Tecnicos_Mantenimiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuarioId INT NOT NULL,
    fechaFinUltimoServicio DATE NOT NULL, 'derivado, trigger hecho'
    borrado BOOLEAN NOT NULL,
    FOREIGN KEY (usuarioId) REFERENCES Usuarios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

'Quito el enum por la explicación que dio Damián en clase y porque con el trigger del atributo derivado ya aparecerán los estados que digamos'
CREATE TABLE Vehiculos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estado VARCHAR(50) NOT NULL, 'derivado, trigger hecho'
    kilometraje DECIMAL(5,2) NOT NULL DEFAULT 0.00, 'derivado, trigger hecho'
    numeroUsos INT NOT NULL DEFAULT 0, 'derivado, trigger hecho'
    localizacion VARCHAR(200), 'derivado, trigger hecho'
    borrado BOOLEAN NOT NULL
);

CREATE TABLE Bicicletas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    vehiculoId INT NOT NULL,
    tipoBici VARCHAR(50) NOT NULL,
    FOREIGN KEY (vehiculoId) REFERENCES Vehiculos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Patinetes_Electricos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    vehiculoId INT NOT NULL,
    autonomiaBateria DECIMAL(4,1) NOT NULL,
    FOREIGN KEY (vehiculoId) REFERENCES Vehiculos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Estaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) UNIQUE NOT NULL,
    numeroVehiculos INT NOT NULL, 'NUMERO VEHICULOS DERIVADA FALTA TRIGGER'
    borrado BOOLEAN NOT NULL
);

CREATE TABLE Enganches (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estacionId INT NOT NULL,
    numero INT NOT NULL,
    estado VARCHAR(50) NOT NULL, 'derivado, trigger hecho'
    borrado BOOLEAN NOT NULL,
    FOREIGN KEY (estacionId) REFERENCES Estaciones(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT uq_estacion_numero UNIQUE (estacionId, numero)
);

CREATE TABLE Alquileres (
    id INT PRIMARY KEY AUTO_INCREMENT,
    clienteId INT NOT NULL,
    vehiculoId INT NOT NULL,
    engancheInicioId INT NOT NULL,
    engancheFinId INT,
    fechaHoraInicio DATETIME NOT NULL,
    fechaHoraFin DATETIME CHECK (fechaHoraFin IS NULL OR fechaHoraFin > fechaHoraInicio),
    distanciaRecorrida DECIMAL(5,2),
    costo DECIMAL(5, 2) NOT NULL CHECK (costo >= 0), 'derivada, trigger hecho'
    lugarInicio VARCHAR(200) NOT NULL, 'derivada, trigger hecho'
    lugarFin VARCHAR(200), 'derivada, trigger hecho'
    FOREIGN KEY (clienteId) REFERENCES Clientes(id)
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
    id INT PRIMARY KEY AUTO_INCREMENT,
    alquilerId INT,
    vehiculoId INT NOT NULL,
    puntuacion INT NOT NULL CHECK (puntuacion BETWEEN 1 AND 5),
    comentario VARCHAR(500),
    FOREIGN KEY (alquilerId) REFERENCES Alquileres(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
    FOREIGN KEY (vehiculoId) REFERENCES Vehiculos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Reparaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tecnicoId INT,
    vehiculoId INT NOT NULL,
    fechaInicio DATE NOT NULL,
    fechaFin DATE CHECK(fechaFin >= fechaInicio),
    detalles VARCHAR(1000) NOT NULL,
    FOREIGN KEY (tecnicoId) REFERENCES Tecnicos_Mantenimiento(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (vehiculoId) REFERENCES Vehiculos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
);

CREATE TABLE Pagos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    clienteId INT NOT NULL,
    alquilerId INT,
    tipoPago VARCHAR(50) NOT NULL, 'derivada'
    cantidad DECIMAL(5, 2) NOT NULL CHECK (cantidad >= 0),
    fecha DATE NOT NULL,
    FOREIGN KEY (clienteId) REFERENCES Clientes(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (alquilerId) REFERENCES Alquileres(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
