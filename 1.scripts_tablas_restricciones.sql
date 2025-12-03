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
    fechaNacimiento DATE NOT NULL CHECK(fechaNacimiento <= (CURDATE() - INTERVAL 12 YEAR)),
    FOREIGN KEY (usuarioId) REFERENCES Usuarios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Tecnicos_Mantenimiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuarioId INT NOT NULL,
    fechaUltimoServicio DATE NOT NULL,
    FOREIGN KEY (usuarioId) REFERENCES Usuarios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Pagos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    clienteId INT NOT NULL,
    alquilerId INT,
    tipoPago VARCHAR(50) NOT NULL,
    cantidad DECIMAL(5, 2) NOT NULL CHECK (cantidad >= 0),
    fecha DATE NOT NULL,
    FOREIGN KEY (clienteId) REFERENCES Clientes(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (alquilerId) REFERENCES Alquileres(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE Vehiculos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estado VARCHAR(50) NOT NULL,
    kilometraje DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    numeroUsos INT NOT NULL DEFAULT 0,
    localizacion VARCHAR(200)
);

CREATE TABLE Bicicletas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    vehiculoId INT NOT NULL,
    tipoBici VARCHAR(50),
    FOREIGN KEY (vehiculoId) REFERENCES Vehiculos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Patinetes_Electricos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    vehiculoId INT NOT NULL,
    autonomiaBateria DECIMAL(4,1),
    FOREIGN KEY (vehiculoId) REFERENCES Vehiculos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Estaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre UNIQUE NOT NULL
);

CREATE TABLE Enganches (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estacionId INT NOT NULL,
    numero VARCHAR(50) NOT NULL,
    estado VARCHAR(50) NOT NULL
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
    fechaHoraFin DATETIME,
    distanciaRecorrida DECIMAL(5,2),
    costo DECIMAL(5, 2) NOT NULL CHECK (cantidad >= 0),
    lugarInicio VARCHAR(200) NOT NULL,
    lugarFin VARCHAR(200),
    FOREIGN KEY (clienteId) REFERENCES Clientes(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (vehiculoId) REFERENCES Vehiculos(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE Valoraciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    alquilerId INT NOT NULL,
    vehiculoId INT NOT NULL,
    puntuacion INT NOT NULL,
    comentario VARCHAR(500),
    FOREIGN KEY (alquilerId) REFERENCES Alquileres(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (vehiculoId) REFERENCES Vehiculos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Reparaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tecnicoId INT NOT NULL,
    vehiculoId INT NOT NULL,
    fecha DATE NOT NULL,
    detalles VARCHAR(1000) NOT NULL,
    FOREIGN KEY (tecnicoId) REFERENCES Tecnicos_Mantenimiento(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (vehiculoId) REFERENCES Vehiculos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
);