### Corregir entregable 3:
RG  MAL 
1 general para 4 funcionales 
RF: Gestion de patienetes, etc(grandes entidades)

Pruebas aceptacion(PA) sin nombre
Mas conciso pruebas de aceptacion(ser concretos)
PA DE NEGOCIO quitarlas y  ponerlas en RF que afecten

proceso de alquiler no es funcional(creacion de alquiler)
cobro automatico  es RN y pa(no es pantalla y las pantallas  son R.funcionales SIEMPRE)

Borrar notificacion mantenimiento(valoracion dejarla)
regla de negocio que permita dejar estrellas sin comentario
Reparacion de enganche lo quitamos mejor(distinta info, se complica)
Valoracion al Alquiler, no al vehiculo. Quitar valoracion de enganche

Requisito info concreto, guardar info de cosas, nombres relevantes, etc-> modelo conceptual
sacar entero del parrafo que pongamos(multiples vehiculos * vehiculos por ejemplo)

Mantenimiento obligatorio cambiar nombre a: "No podra alquilarse un vehiculo con mas de X km desde la ultima fecha de revision" HECHA

R de cambio de estado de vehiculo y de estacion mal, PA Bien

Lo unico de historia de usuario tiene que ser RG y RF.

CONTROL DE PERMISOS TAMPOCO ESTA BIEN
PA de RF si no se puede comprobar de alguna manera(por ejemplo, la disponibilidad no) lo quitamos.

Fiabilidad en RF ya esta.

Modelado conceptual: clase no, usar Entidad. herencia no definida pues falta solapamiento. HECHA 
quitar tipos de atributos, fechaHora en vez de tiempo en  el nombre HECHA 
relacion entre alquiler-estacion(inicio y fin) HECHA
localizacion  es RN
Enganche  relacion con Alquiler, no en Vehiculo HECHA
