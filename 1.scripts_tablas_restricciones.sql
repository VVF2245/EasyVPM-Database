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
    fechaNacimiento DATE NOT NULL 
    CONSTRAINT "No cumple el minimo de edad requerido" CHECK(fechaNacimiento <= (CURDATE() - INTERVAL 12 YEAR)),
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

'Quito el enum por la explicación que dio Damián en clase y porque con el trigger del atributo derivado ya aparecerán los estados que digamos'
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
    nombre VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE Enganches (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estacionId INT NOT NULL,
    numero INT NOT NULL,
    estado VARCHAR(50) NOT NULL,
    FOREIGN KEY (estacionId) REFERENCES Estaciones(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT uq_estacion_numero UNIQUE (estacionId, numero)
);


'''
Está puesto el SET NULL para que el borrar una entidad relacionada
con alquiler no borre el alquiler. Esto es por si por ejemplo un vehículo
se queda obsoleto y lo borran de la base de datos, pero quieres
seguir teniendo registro de qué alquiler ha realizado el usuario.

PREGUNTAR A DAMIÁN PORQUE HE PUESTO EL SET NULL para seguir esta lógica.
'''
CREATE TABLE Alquileres (
    id INT PRIMARY KEY AUTO_INCREMENT,
    clienteId INT,
    vehiculoId INT,
    engancheInicioId INT,
    engancheFinId INT,
    fechaHoraInicio DATETIME NOT NULL,
    fechaHoraFin DATETIME CHECK (fechaHoraFin IS NULL OR fechaHoraFin > fechaHoraInicio),
    distanciaRecorrida DECIMAL(5,2),
    costo DECIMAL(5, 2) NOT NULL CHECK (costo >= 0),
    lugarInicio VARCHAR(200) NOT NULL,
    lugarFin VARCHAR(200),
    FOREIGN KEY (clienteId) REFERENCES Clientes(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (vehiculoId) REFERENCES Vehiculos(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (engancheInicioId) REFERENCES Enganches(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (engancheFinId) REFERENCES Enganches(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);


'''
Está puesto ON DELETE SET NULL en alquilerId porque aunque borren un
alquiler a lo mejor te sigue haciendo falta el comentario que han hecho sobre
el vehículo. Por ejemplo, si está en mal estado y por alguna razón
borran el alquiler se borraría la valoración y no sabrían que el vehículo
necesita mantenimiento.

Está puesto ON DELETE CASCADE en vehiculoId porque las valoraciones son
irrelevantes si se elimina x vehículo al que referencian. No es necesario
saber que x vehículo tiene una rueda pinchada si ya se ha borrado de la base
de datos.
'''
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

'''
Está puesto ON DELETE SET NULL en tecnicoId porque si se borra un técnico
de mantenimiento a lo mejor queremos seguir sabiendo qué reparaciones se han hecho
a un vehículo específico.
De la misma manera está puesto ON DELETE SET NULL el vehiculoId, por si hace falta
un recuento de qué reparaciones ha hecho x técnico de mantenimiento.

Preguntar a Damián porque he puesto las FK como opcionales para seguir esta lógica.
'''
CREATE TABLE Reparaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tecnicoId INT,
    vehiculoId INT,
    fechaInicio DATE NOT NULL,
    fechaFin DATE CHECK(fechaFin >= fechaInicio),
    detalles VARCHAR(1000) NOT NULL,
    FOREIGN KEY (tecnicoId) REFERENCES Tecnicos_Mantenimiento(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (vehiculoId) REFERENCES Vehiculos(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
);

'''
Está puesto el ON DELETE SET NULL por si se borra un cliente o
se borra un alquiler, que no se borren los pagos por si es necesario
dejarlos registrados (política de empresa o declarar ganancias).

PREGUNTAR DAMIÁN PORQUE HE PUESTO SET NULL para seguir esta lógica
'''
CREATE TABLE Pagos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    clienteId INT,
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
