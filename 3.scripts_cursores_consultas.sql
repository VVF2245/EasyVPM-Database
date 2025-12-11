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