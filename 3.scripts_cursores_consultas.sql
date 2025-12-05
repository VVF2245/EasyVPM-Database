-- top 5 vehiculos mas usados por los clientes
-- lista reparaciones de un tecnico
-- agrupar reparaciones por vehiculo



CREATE OR REPLACE VIEW AS listaReparacionesTecnico
SELECT Usuarios.nombre, COUNT (Reparaciones.id) listaReparaciones
FROM Usuarios
JOIN TecnicosMantenimiento ON Usuarios.id=TecnicosMantenimiento.usuarioId
JOIN Reparaciones ON tecnicoMantenimiento.id=Reparaciones.tecnicoId
GROUP BY Usuarios.id;

CREATE OR REPLACE VIEW AS listaReparacionesVehiculo
SELECT Vehiculos.id, COUNT (Reparaciones.id) listaReparaciones
FROM Vehiculos
JOIN Reparaciones ON tVehiculo.id=Reparaciones.vehiculoId
GROUP BY Vehiculos.id;

CREATE OR REPLACE VIEW AS top5vehiculosMasUsados
SELECT Vehiculos.id FROM Vehiculos
JOIN Alquileres ON Vehiculos.id=Alquileres.vehiculoId
GROUP BY Vehiculos.id
ORDER BY COUNT(Alquileres.id) DESC
LIMIT 5;

