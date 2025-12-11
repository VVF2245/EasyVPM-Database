-- top 5 vehiculos mas usados por los clientes
-- lista reparaciones de un tecnico
-- agrupar reparaciones por vehiculo



CREATE OR REPLACE VIEW vw_listaReparacionesTecnico AS
SELECT u.nombre, COUNT (r.id) AS listaReparaciones
FROM Usuarios u
JOIN Tecnicos_Mantenimiento t ON u.id = t.usuarioId
LEFT JOIN Reparaciones r ON t.id = r.tecnicoId
GROUP BY u.id, u.nombre;


CREATE OR REPLACE VIEW vw_listaReparacionesVehiculo AS
SELECT v.id, COUNT (Reparaciones.id) AS listaReparaciones
FROM Vehiculos v
LEFT JOIN Reparaciones r ON v.id = r.vehiculoId
GROUP BY v.id;


CREATE OR REPLACE VIEW vw_top5vehiculosMasUsados AS
SELECT v.id AS vehiculoId
FROM Vehiculos v
JOIN Alquileres a ON v.id = a.vehiculoId
GROUP BY v.id
ORDER BY COUNT(a.id) DESC
LIMIT 5;


-- esto se filtra con un SELECT * FROM vw_info_usuario WHERE usuarioId = @usuarioId
CREATE OR REPLACE VIEW vw_info_usuario AS
SELECT
    u.id AS usuarioId, u.nombre, u.correo, 
    c.fechaNacimiento, c.tarifaActual, c.alquilerActivo,
    t.fechaFinUltimoServicio
FROM Usuarios u
LEFT JOIN Clientes c ON u.id = c.usuarioId
LEFT JOIN Tecnicos_Mantenimiento t ON u.id = t.usuarioId;


-- no pregunto si es bicicleta o patinete porque realmente no me hace falta saberlo para esta consulta
CREATE OR REPLACE VIEW vw_vehiculosMantenimiento AS
SELECT v.id AS vehiculoId, v.estado, v.localizacion, v.numeroUsos, v.kilometraje
FROM Vehiculos v
WHERE v.estado IN ('mantenimiento_pendiente', 'averiado') AND v.borrado = FALSE;


-- aquí pregunto si es bicicleta o patinete porque al cliente si que le puede interesar a la hora de alquilar
-- para filtrar por estación se hace un WHERE localizacion LIKE '%nombreEstacion%' 
CREATE OR REPLACE VIEW vw_vehiculosDisponibles AS
SELECT v.id AS vehiculoId, v.estado, v.localizacion, v.numeroUsos, v.kilometraje,
    CASE
        WHEN b.vehiculoId IS NOT NULL THEN 'Bicicleta'
        WHEN p.vehiculoId IS NOT NULL THEN 'Patinete eléctrico'
        ELSE 'Desconocido'
    END AS tipoVehiculo,
    b.tipoBici,
    p.autonomiaBateria
FROM Vehiculos v
LEFT JOIN Bicicletas b ON v.id = b.vehiculoId
LEFT JOIN Patinetes_Electricos p ON v.id = p.vehiculoId
WHERE v.estado == 'disponible' AND v.borrado = FALSE;


-- te agrupa por estaciones y te muestra el número de enganches y de huecos que tiene cada estación
-- se puede hacer un SELECT(*) FROM vw_estacionesDisponibilidad WHERE nombreEstacion = '@estacionNombre';
CREATE OR REPLACE VIEW vw_estacionesDisponibilidad AS
SELECT e.nombre AS nombreEstacion, e.numeroVehiculos AS vehiculosDisponibles, 
    SUM( IF( en.estado = 'libre', 1, 0)) AS enganchesLibres

FROM Estaciones e
LEFT JOIN Enganches en ON en.estacionId = e.id AND en.borrado = FALSE
WHERE e.borrado = FALSE
GROUP BY e.id, e.nombre;


-- te agrupa por estaciones y te muestra los enganches libres donde puedes dejar el vehículo
-- se puede hacer un SELECT (*) FROM vw_enganchesLibresPorEstacion WHERE nombreEstacion = '@estacionNombre';
CREATE OR REPLACE VIEW vw_enganchesLibresPorEstacion AS
SELECT e.nombre AS nombreEstacion, en.numero AS enganchesLibres
FROM Estaciones e
JOIN Enganches en AS en ON en.estacionId = e.id
WHERE e.borrado = FALSE AND en.borrado = FALSE AND en.estado = 'libre'
ORDER BY e.nombre, en.numero ASC;


-- se puede filtrar por SELECT(*) FROM vw_historialAlquileres WHERE correo = '@Usuarios.correo' 
-- AND fechaHoraInicio BETWEEN '2025-01-01' AND '2025-02-02';
CREATE OR REPLACE VIEW vw_historialAlquileres AS
SELECT u.correo, a.id, a.vehiculoId, a.fechaHoraInicio, 
    TIMESTAMPDIFF(MINUTE, a.fechaHoraInicio, a.fechaHoraFin) AS duracion, a.costo
FROM Alquileres a
JOIN Clientes c ON a.clienteId = c.id
JOIN Usuarios u ON c.usuarioId = u.id
ORDER BY u.correo, a.id


CREATE OR REPLACE VIEW vw_vehiculosEnUso AS
SELECT a.id, a.clienteId, a.vehiculoId, e.nombre, a.engancheInicioId, a.fechaHoraInicio
FROM Alquileres a
JOIN Enganches en ON a.engancheInicioId = en.id
JOIN Estaciones e ON en.estacionId = e.id
WHERE a.fechaHoraFin IS NULL;


CREATE OR REPLACE VIEW vw_reparacionesActivas AS
SELECT r.id AS reparacionId, r.vehiculoId, r.tecnicoId, u.nombre AS nombreTecnico, r.fechaInicio
FROM Reparaciones r
JOIN Vehiculos v ON r.vehiculoId = v.id
JOIN Tecnicos_Mantenimiento t ON r.tecnicoId = t.id
JOIN Usuarios u ON t.usuarioId = u.id
WHERE r.fechaFin IS NULL AND v.borrado = FALSE
ORDER BY r.fechaInicio ASC;


-- se puede filtrar con un SELECT(*) FROM vw_historialReparaciones WHERE nombreTecnico ='@NombreTecnico'
-- AND fechaInicio BETWEEN '2025-01-01' AND '2025-02-02';
CREATE OR REPLACE VIEW vw_historialReparaciones AS
SELECT r.fechaInicio, r.fechaFin, r.tecnicoId, u.nombre AS nombreTecnico, r.detalles
FROM Reparaciones r
JOIN Tecnicos_Mantenimiento t ON r.tecnicoId = t.id
JOIN Usuarios u ON t.usuarioId = u.id
WHERE r.fechaFin IS NOT NULL
ORDER BY r.fechaInicio ASC;


-- se puede filtrar por vehiculo haciendo un SELECT(*) FROM vw_valoracionesVehiculos WHERE vehiculoId = @vehiculoId;
-- se puede ordenar por fecha o por puntuacion: SELECT(*) FROM vw_promedioValoraciones ORDER BY fecha;
--                                              SELECT(*) FROM vw_promedioValoraciones ORDER BY puntuacion DESC;
CREATE OR REPLACE VIEW vw_valoracionesVehiculos AS
SELECT v.id AS valoracionId, v.vehiculoId, a.clienteId, u.nombre AS nombreCliente, 
    a.fechaHoraFin AS fecha, v.puntuacion, v.comentario
FROM Valoraciones v
JOIN Alquileres a ON v.alquilerId = a.id
JOIN Clientes c ON a.clienteId = c.id
JOIN Usuarios u ON c.usuarioId = u.id
ORDER BY v.vehiculoId;


-- se puede filtrar por valoraciones bajas: SELECT(*) FROM vw_promedioValoraciones WHERE promedioPuntuacion < 3;
CREATE OR REPLACE VIEW vw_promedioValoraciones AS
SELECT v.vehiculoId, COUNT(*) AS totalValoraciones, AVG(v.puntuacion) AS promedioPuntuacion
FROM Valoraciones v
GROUP BY v.vehiculoId;


-- se le hace un: SELECT(*) FROM vw_valoracionesCliente WHERE clienteId = @clienteId
CREATE OR REPLACE VIEW vw_valoracionesCliente AS
SELECT v.id AS valoracionId, a.clienteId, a.fechaHoraFin AS fecha, v.vehiculoId, v.puntuacion, v.comentario
FROM Valoraciones v
JOIN Alquileres a ON v.alquilerId = a.id
ORDER BY a.clienteId, a.fechaHoraFin DESC;


-- se le puede hacer un: SELECT(*) FROM vw_pagos WHERE clienteId = @clienteId
CREATE OR REPLACE VIEW vw_pagos AS
SELECT p.id AS pagoId, p.clienteId, u.nombre AS nombreCliente, p.alquilerId, p.tipoPago, p.cantidad, p.fecha
FROM Pagos p
JOIN Clientes c ON p.clienteId = c.id
JOIN Usuarios u ON c.usuarioId = u.id
ORDER BY p.clienteId;