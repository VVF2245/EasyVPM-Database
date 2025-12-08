[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/ENtV2bNj)
# Título Proyecto

## Miembros del grupo L6-VVF2245

1. Flores Cañabate, Julián
1. Hernández Cuadrado, Luis
1. Noguera Talavera, Sergio
1. Bader Abuhar, Morad

## 1. Introducción al problema

- Descripción del problema para poner en contexto el proyecto, incluyendo información sobre los clientes y usuarios, la situación actual, problemas, expectativas, etc. Se valorará la presencia de información multimedia (fotos, gráficos, documentos escaneados, etc.).

EasyVPM es una empresa dedicada al alquiler de vehículos de movilidad personal que actualmente gestiona los alquileres de forma manual, mediante papeleo y procesos poco eficientes.
Ante su crecimiento, la empresa busca modernizarse implantando una plataforma centralizada que facilite la gestión de usuarios, vehículos y estaciones.
Además, EasyVPM quiere mejorar su imagen y atraer nuevos clientes mediante una aplicación sencilla, moderna y fácil de usar, que ofrezca una experiencia ágil tanto para la empresa como para los usuarios.

<img src="imagenes/imagen_transicion.png" alt="Objetivo de EasyVPM" width="40%"><br>
<em>Objetivo de EasyVPM</em>

## 2. Glosario de términos

**Incidencia:** Registro de un fallo o anomalía detectada en un vehículo o estación, que requiere revisión o intervención por parte del equipo técnico.  <br>
**Mantenimiento pendiente:** Estado en el que se encuentra un VMP cuando ha alcanzado el nº de kilómetros o viajes definidos entre mantenimientos, indicando que requieren una revisión antes de continuar en servicio. <br>
**Redistribución:** Movimiento de VMPs entre estaciones para equilibrar la disponibilidad.  <br>
**Reseña:** Evaluación proporcionada por un usuario sobre su experiencia con un vehículo mediante calificación y comentario.  <br>
**Tiempo de espera:** Tiempo mínimo que tiene que pasar entre cada viaje.  <br>
**Tipo de tarifa:** Clasificación del modo de pago, que puede ser por suscripción (mensual, anual) o por pago individual de cada trayecto.  <br>
**VMP (Vehículo de Movilidad Personal):** Medio de transporte ligero, destinado a una sola persona (patinetes, monociclos, etc.).  <br>
**Zona de cobertura:** Área geógrafica dentro de la cual el servicio está disponible y se pueden realizar alquileres.<br>

<img src="imagenes/estacion_vpm.png" alt="Estación de VMP" width="50%"><br>
<em>Estación de EasyVPM</em>

<img src="imagenes/reseña_vpm.png" alt="Reseña de VMP" width="50%"><br>
<em>Reseña de EasyVPM</em>

## 3. Visión general del sistema

### 3.1. Requisitos generales

#### R.G.0.1 Gestión de cuentas
Como administrador de EasyVPM,<br>
quiero que el sistema gestione y almacene información de los usuarios,<br>
para poder identificar y administrar adecuadamente a quienes utilizan la plataforma.

### R.G.02. Gestión integral de la flota de vehículos
Como administrador del sistema,<br>
quiero gestionar la información y el estado de los vehículos registrados en la plataforma,<br>
para mantener actualizada y controlada la flota disponible para el servicio.

### R.G.03. Gestión de estaciones
Como administrador del sistema,<br>
quiero que se gestionen las estaciones y sus enganches asociados,<br>
para controlar la disponibilidad y distribución de los vehículos en cada ubicación.

### R.G.04. Gestión del proceso de alquiler
Como usuario del sistema,<br>
quiero realizar el proceso completo de alquiler y devolución de vehículos,<br>
para poder utilizar el servicio de movilidad de forma autónoma.

### R.G.05. Gestión de pagos
Como usuario del sistema,<br>
quiero realizar los pagos de mis alquileres y que el sistema registre dicha información,<br>
para garantizar que mis transacciones quedan correctamente reflejadas.

### R.G.06. Mantenimiento de los vehículos
Como técnico de mantenimiento de EasyVPM,<br>
quiero que el sistema registre información sobre las reparaciones efectuadas en los vehículos,<br>
para asegurar un seguimiento adecuado de su estado y funcionamiento.

### R.G.07 Valoraciones de los vehículos
Como usuario del sistema,<br>
quiero poder valorar los vehículos tras su uso,<br>
para contribuir a informar sobre su estado y ayudar a detectar incidencias.




### 3.2. Usuarios del sistema

El sistema de EasyVPM contará con los siguientes tipos de usuarios: 

**Clientes**
   * Se registran para alquilar vehículos, consultar estaciones y disponibilidad, iniciar y finalizar alquileres, y proporcionar valoraciones. 

**Administradores**
   * Gestionan usuarios, vehículos y estaciones, supervisan incidencias y mantenimiento, y generan informes para la empresa. 

**Técnicos de mantenimiento**
   * Reciben notificaciones de incidencias, actualizan el estado de los vehículos y realizan reparaciones. 
   
## 4. Catálogo de requisitos

### 4.1. Requisitos funcionales

#### R.F.01. Registro de usuario
Como administrador de EasyVPM, <br>
quiero que mis clientes y técnicos de mantenimiento se puedan registrar al sistema,<br>
para poder acceder al servicio de alquiler.

**P.A.01.**
- El registro solicita nombre, correo, contraseña
- Si la cuenta corresponde a un cliente, también deberá proporcionar su fecha de nacimiento.
- Se comprueba que la contraseña tiene más de 8 dígitos.
- El sistema verifica que el correo no esté duplicado.
- Se envía un correo de confirmación al completar el registro.
- Se debe aplicar la regla de negocio R.N.04.

#### R.F.02. Eliminación de la cuenta
Como cliente de EasyVPM, <br>
quiero poder eliminar mi cuenta asi como mis datos asociados,<br>
para poder tener control sobre mi informacion personal y asegurar mi privacidad.

**P.A.02**
- El cliente le da al boton de eliminar cuenta dentro de la seccion: Mi cuenta.
- El sistema le mandara un código de autenticación a su correo asociado.
- Si no le llega puede solicitar que se lo reenvien otra vez.
- El cliente pondrá el código correspondiente en la aplicacion.
- Si coincide se le pondra el mensaje "Eliminacion completada" y el sistema borrara su cuenta y datos.
- Si no, le saldra mensaje de error y se le pedirá de nuevo el código.
- En el sistema realmente se hace un soft delete y se activa la cuenta como "borrada" para no tenerla en cuenta para las estadísticas ni recuentos.
- Se debe aplicar la regla de negocio R.N.01.

#### R.F.03. Actualización de datos de la cuenta
Como usuario de EasyVPM,<br>
quiero poder modificar mis datos personales desde mi perfil,<br>
para mantener mi información actualizada y correcta en el sistema.

**P.A.03**
- El usuario selecciona la opción editar perfil en la seccion: Mi cuenta.
- Si el usuario es cliente, también puede actualizar la fecha de nacimiento y su tarifa contratada.
- Si el usuario modifica el correo electrónico, el sistema envía un código de verificación al nuevo correo.
- Si el usuario modifica la contraseña, el sistema exige que tenga al menos 8 caracteres.
- Los cambios no se guardan hasta que el usuario confirme.
- Si el correo introducido ya existe en otra cuenta, el sistema muestra un mensaje indicando que está duplicado.
- Al completar la actualización, el sistema muestra el mensaje "Datos actualizados correctamente"


#### R.F.04. Recuperación de contraseña
Como cliente de EasyVPM,<br>
quiero poder recuperar mi contraseña si la olvido,<br>
para no perder el acceso a mi cuenta.

**P.A.04.**
- El usuario introduce su correo electrónico registrado y recibe un enlace temporal de autenticación.
- El enlace dura solo 24 horas o hasta utilizarlo.
- El sistema obliga al usuario a establecer una nueva contraseña antes de poder a acceder.

#### R.F.05. Consulta de información personal
Como cliente de EasyVPM,<br>
quiero consultar mis datos personales,<br>
para verificar que mi información está correcta.

**P.A.05.**
- EL usuario accede a la sección Mi cuenta.
- El sistema muestra nombre, correo.
- Si es cliente muestra también fecha de nacimiento, tarifa actual y si tiene algún alquiler activo.
- Si es técnico de mantenimiento muestra además la fecha del último servicio realizado.

#### R.F.06. Registro de vehículos
Como administrador de EasyVPM,<br>
quiero poder registrar nuevos vehículos en el sistema,<br>
para incorporarlos a la flota disponible para alquiler.

**P.A.06**
- Se solicita el tipo de vehículo (bicicleta, patinete eléctrico, ...)
- Se registran los atributos correspondientes
- Para bicicletas: tipoBici
- Para patinetes eléctricos: autonomiaBateria
- Se registran los atributos generales del vehículo: estado inicial, localización, kilometraje inicial, número de usos inicial y borrado = FALSE.
- El sistema le crea automáticamente un identificador único (autoincrement)

#### R.F.07 Eliminación de vehículos
Como administrador de EasyVPM,<br>
quiero poder eliminar vehículos de la flota,<br>
para mantener actualizada la disponibilidad de la plataforma.

**P.A.07**
- El administrador selecciona el vehículo que desea eliminar.
- El sistema comprueba que no esté asociado a un alquiler activo.
- Si no está en uso, se marca como borrado = TRUE (soft delete)
- Si el vehículo tiene alquileres históricos o registros de reparaciones, estos permanecen por si acaso.

#### R.F.08. Actualización de valores de un vehículo
Como administrador de EasyVPM,<br>
quiero poder modificar los datos de los vehículos,<br>
para mantener la información actualizada sobre la flota.

**P.A.08.**
- Se selecciona el vehículo a actualizar.
- Se pueden modificar los atributos: estado, localización, kilometraje y número de usos.
- Para las bicicletas, tipoBici y para los patinetes eléctricos, autonomiaBateria.
- El sistema valida que los valores sean consistentes (por ejemplo, kilometraje >=0, número de usos >= o).
- Se actualizan las estaciones y enganches si procede.

#### R.F.09. Lista vehículos para mantenimiento
Como técnico de mantenimiento de EasyVPM,<br>
quiero poder consultar qué vehículos están con estado mantenimiento_pendiente o averiado,<br>
para poder planificar su revisión y reparación de forma eficiente.

**P.A.09.**
- Filtrar vehículos por estado: mantenimiento_pendiente y averiado.
- Mostrar información: id del vehículo, tipo, localización, número de usos, kilometraje.
- Excluir vehículos borrados.
- Permitir ordenar por kilometraje o número de usos para priorizar los vehículos más necesitados de revisión.

#### R.F.10. Lista de vehículos disponibles por estación
Como cliente de EasyVPM,<br>
quiero poder consultar qué vehículos en una estación concreta,<br>
para poder elegir uno que pueda recoger ahí fácilmente.

**P.A.10.**
- Filtrar vehículos por estado: disponible
- Filtrar por la estación seleccionada por el cliente.
- Mostrar información: id del vehículo, tipo (bicicleta o patinete), autonomía (si es patinete), tipo de bicicleta (si es bicicleta) localización exacta
- Excluir vehículos borrados

#### R.F.11. Registro de estaciones
Como administrador de EasyVPM,<br>
quiero poder registrar nuevas estaciones en el sistema,<br>
para ampliar la cobertura del servicio de alquiler.

**P.A.11.**
- Solicitar nombre único de la estación
- Inicializar el número de vehículos a 0.
- Marcar la estación como no borrada.

#### R.F.12. Actualización de estación
Como administrador de EasyVPM,<br>
quiero poder modificar los datos de las estaciones existentes,<br>
para mantener la información actualizada.

**P.A.12.**
- Permitir actualizar nombre y estado de borrado.
- Validar que el nombre no se duplique con otra estación activa.

#### R.F.13. Eliminación de estación
Como administrador de EasyVPM,<br>
quiero poder eliminar estaciones del sistema,<br>
para mantener la base de datos limpia y solo con estaciones activas.

**P.A.13.**
- Marcar la estación como borrada (soft delete).
- Evitar la eliminación si existen enganches con vehículos activos asociados.
- Actualizar automáticamente la disponibilidad de enganches y vehículos asociados.

#### R.F.14. Consulta de estaciones
Como cliente de EasyVPM,<br>
quiero poder consultar todas las estaciones disponibles,<br>
para saber dónde puedo recoger o devolver un vehículo.

**P.A.13.**
- Mostrar información: nombre de la estación, número de vehículos disponibles y localización.
- Excluir estaciones marcadas como borradas

#### R.F.15. Registro de enganche
Como administrador de EasyVPM,<br>
quiero poder registrar nuevos enganches en las estaciones,<br>
para organizar la colocación de los vehículos.

**P.A.14.**
- Solicitar número de enganche dentro de la estación.
- Inicializar estado del enganche como "libre".
- Evitar duplicados de número de enganche en la misma estación.

#### R.F.16. Actualización de enganche
Como administrador de EasyVPM,<br>
quiero poder actualizar el estado de un enganche,<br>
para reflejar si está ocupado o libre.

**P.A.15.**
- Permitir cambiar el estado y la estación asociada.
- Actualizar automáticamente el número de vehículos de la estación asociada.

#### R.F.17. Eliminación de enganche
Como administrador de EasyVPM,<br>
quiero poder eliminar enganches del sistema,<br>
para reorganizar la estación y gestionar la disponibilidad de espacios.

**P.A.17.**
- Marcar el enganche como borrado (soft delete) en lugar de eliminar del todo.
- Evitar la eliminación si hay un vehículo asignado o un alquiler activo en el enganche.
- Actualizar automáticamente el número de vehículos disponibles de la estación asociada.

#### R.F.18. Consulta de enganches
Como cliente de EasyVPM,<br>
quiero poder consultar los enganches disponibles en una estación,<br>
para saber dónde puedo dejar un vehículo al finalizar el alquiler.

**P.A.16.**
- Mostrar enganches libres por estación.
- Excluir enganches borrados
- Ordenar por número de enganche

#### R.F.19. Creación de Alquiler
Como cliente, <br>
quiero iniciar un alquiler seleccionando un vehículo disponible en una estación,<br>
para poder usarlo inmediatamente.

**P.A.19.**
- El sistema valida que el vehículo esté en estado "disponible".
- Se comprueba que el cliente no tenga otro alquiler activo.
- Se registra fecha y hora de inicio, vehículo, estación de inicio y enganche asociado.
- El sistema cambia el estado del vehículo a "en_uso".
- El sistema cambia el estado del enganche donde estaba el vehículo a "libre".

#### R.F.20. Finalización del alquiler
Como cliente de EasyVPM,<br>
quiero finalizar mi alquiler dejando el vehículo en un enganche libre,<br>
para cerrar el servicio y que se me cobre lo correspondiente.

**P.A.20.**
- El cliente selecciona un enganche libre de la estación donde devuelve el vehículo
- El sistema registra fecha y hora de finalización.
- Se calcula el coste total según la duración y la tarifa activa.
- El vehículo pasa a estado "disponible".
- El enganche donde se deja el vehículo pasa a "ocupado".
- Se genera el pago asociado al alquiler.

#### R.F.21. Historial de alquileres
Como cliente de EasyVPM,<br>
quiero consultar mis alquileres anteriores,<br>
para revisar mis usos.

**P.A.21.**
- Se listan los alquileres realizados del cliente.
- Se muestra vehículo, fechas de inicio y fin, duración y coste total.
- Se permite filtrar por rango de fechas.

#### R.F.22. Consulta de vehículos en alquiler
Como administrador de EasyVPM,<br>
quiero consultar todos los vehículos que están actualmente en uso,<br>
para monitorear su uso.

**P.A.22.**
- Se listan alquileres que no hayan terminado.
- Se muestra cliente, vehículo, estación y enganche de salida, fecha y hora de inicio.
- Se puede filtrar por estación, tipo de vehículo o cliente.

#### R.F.23. Registro de pago
Como cliente de EasyVPM,<br>
quiero poder pagar mi mensualidad de forma manual desde la aplicación,<br>
para renovar mi tarifa y seguir gozando de sus beneficios.

**P.A.23.**
- El cliente accede a la sección de pagos -> mensualidad.
- El sistema muestra el importe de la mensualidad y la fecha de vencimiento.

#### R.F.24. Consulta de pagos (cliente)
Como cliente de EasyVPM,<br>
quiero consultar mis pagos realizados,<br>
para tener control sobre mis gastos.

**P.A.24.**
- Se listan pagos realizados del cliente.
- Se muestra fecha, importe, tipo de pago y alquiler asociado.
- Se permite filtrar por rango de fechas o tipo de pago.

#### R.F.25. Consulta de pagos (administrador)
Como administrador de EasyVPM,<br>
quiero consultar todos los pagos registrados,<br>
para controlar la facturación del sistema.

**P.A.25.**
- Se listan pagos de todos los clientes.
- Se permite filtrar por cliente, fecha, tipo de pago o importe.

#### R.F.26. Inicio de reparación
Como técnico de mantenimiento de EasyVPM,<br>
quiero poder registrar el inicio de una reparación,<br>
para indicar que estoy trabajando en un vehículo y sacarlo del servicio.

**P.A.26.**
- El técnico selecciona un vehículo con estado "averiado" o "mantenimiento_pendiente".
- El sistema crea un registro de reparación con técnico responsable, fecha de inicio.
- El estado del vehículo pasa automáticamente a "en_reparación".
- El sistema impide iniciar una reparación si un vehículo está alquilado o ya está en reparación.

#### R.F.27. Finalización de reparación
COmo técnico de mantenimiento,<br>
quiero poder marcar una reparación como finalizada,<br>
para que el vehículo vuelva al servicio cuando esté en condiciones.

**P.A.27.**
- El técnico selecciona una reparación activa.
- Se añade la fecha de finalización de la reparación y se indica detalladamente qué le sucedía al vehículo y lo que le ha hecho.
- El vehículo cambia su estado a "reparado" para que pasen a recogerlo y recoloquen.

#### R.F.28. Consulta de reparaciones activas
Como técnico de mantenimiento,<br>
quiero consultar las reparaciones que estén actualmente sin terminar,<br>
para organizar mi trabajo del día.

**P.A.28.**
- El sistema muestra las reparaciones sin fecha de fin.
- Se incluye vehículo, técnico asignado, fecha de inicio.
- Se puede ordenar por antigüedad.
- No se muestran reparaciones de vehículos borrados.

#### R.F.29 Historial de reparaciones
Como técnico de EasyVPM,<br>
quiero ver el historial completo de reparaciones de un vehículo,<br>
para conocer sus averías anteriores.

**P.A.29.**
- Se muestran registros ya finalizados.
- Se incluye fecha de inicio, fecha de fin, técnico, descripción del problema.
- Permite filtrar por técnico o intervalo de fechas.

#### R.F.30. Registro de valoración
Como cliente de EasyVPM,<br>
quiero poder enviar una valoración sobre su vehículo después de usarlo,<br>
para indicar la calidad del servicio y el estado del vehículo.

**P.A.30.**
- El cliente solo puede valorar un vehículo si ha completado un alquiler del mismo.
- Se recoge una puntuación (1-5) y un comentario opcional.
- El sistema verifica que no haya una valoración duplicada para ese mismo alquiler.
- Si la puntuación es <=2 el sistema cambia el estado del vehículo a averiado automáticamente.
- La valoración queda registrada con fecha y hora.

#### R.F.31. Consulta de valoraciones de un vehículo
Como técnico de mantenimiento de EasyVPM,<br>
quiero consultar todas las valoraciones de un vehículo,<br>
para tener una visión del estado percibido por los clientes.

**P.A.31.**
- Se muestran las valoraciones incluyendo cliente, fecha, puntuación y comentario.
- Se puede ordenar por fecha o puntuación.
- Permite filtrar por puntuación baja (1-2) para detectar problemas urgentes.

#### R.F.32. Promedio de valoraciones de un vehículo
Como administrador de EasyVPM,<br>
quiero consultar la valoración media de cada vehículo,<br>
para evaluar su aceptación y rendimiento.

**P.A.32.**
- El sistema calcula el promedio de puntuaciones de todas las valoraciones.
- Muestra número total de valoraciones y media de puntuación.
- Se puede filtrar por vehículos mejor o peor valorados.

#### R.F.33. Historial personal de valoraciones
Como cliente de EasyVPM,<br>
quiero consultar las valoraciones que he enviado,<br>
para revisar mi historial de opiniones.

**P.A.33.**
- Muestra las valoraciones realizadas por el cliente.
- Incluye fecha, vehículo, puntuación y comentario (opcional).
- Permite filtrar por fecha o vehículo.



### 4.1.1. Requisitos de información

#### R.I.01. Información sobre los usuarios
Como administrador de EasyVPM,<br>
quiero conocer el nombre, correo y contraseña de los usuarios.
Si es un cliente quiero saber la tarifa contratada actualmente, su fecha de nacimiento y si tiene un alquiler activo. 
Si es técnico de mantenimiento quiero saber cuándo terminó su último servicio.

#### R.I.02. Información sobre los vehículos
Como administrador de EasyVPM,<br>
quiero conocer el estado de los vehículos, el kilometraje y el número de usos desde el último mantenimiento y su localización actual. Si es una bicicleta quiero saber qué tipo de bicicleta es, individual, tándem, etc. Si es un patinete eléctrico quiero saber qué autonomía tiene su batería.

#### R.I.03. Información sobre estaciones
Como administrador de EasyVPM,<br>
quiero conocer el nombre de las estaciones y el número de vehículos disponibles que tienen actualmente. Además quiero saber qué enganches tiene cada estación junto con el estado en el que se encuentra cada uno (libre, ocupado, etc.). Los enganches tienen que tener un número identificativo visible para los usuarios (distinto del ID interno del sistema),
para que se pueda registrar en qué enganche exacto se encuentra cada vehículo.

#### R.I.04. Información sobre alquileres
Como administrador de EasyVPM,<br>
quiero conocer la fecha y hora de inicio y fin de los alquileres, la distancia recorrida con el vehículo, el costo de dicho alquiler y el lugar de inicio y fin del viaje.

### R.I.05. Información sobre pagos
Como administrador de EasyVPM,<br>
quiero saber qué tipo de pago se ha realizado, la cantidad abonada y la fecha del pago,<br>
para poder llevar un control adecuado de la actividad económica del sistema.

#### R.I.06. Información sobre el mantenimiento
Como técnico de mantenimiento de EasyVPM,<br>
quiero conocer la fecha de inicio y fin de las reparaciones realizadas y alguna información detallada sobre estas. 

### R.I.07. Información sobre valoraciones
Como técnico de mantenimiento,<br>
quiero conocer las valoraciones que se les ponen a los vehículos, en forma de puntuación y un comentario opcional,<br>
para saber si algún vehículo necesita mantenimiento.


### 4.1.2. Reglas de negocio

#### R.N.01. No eliminar usuarios que tengan alquiler activo
Como administrador de EasyVPM, <br>
quiero que el cliente no pueda eliminar su cuenta de la aplicación<br>
mientras esté alquilando un vehículo,<br>
para asegurar la devolución del vehículo y el registro del pago.

#### R.N.02. Evitar que los usuarios alquilen 2 vehículos simultáneamente
Como administardor de EasyVPM, <br>
quiero que el cliente no pudea alquilar más de un vehículo a la vez,<br>
para evitar la falta de disponibilidad de vehículos.

#### R.N.03. No podra alquilarse un vehiculo con mas de 500 km o 50 alquileres desde la ultima fecha de revision <br>
Como administrador de EasyVPM,<br>
quiero que todos los vehículos que hayan superado<br>
50 alquileres o 500 km recorridos deben pasar por revisión,<br>
para asegurar la seguridad y calidad del servicio.

**P.A.03.**
- Cada vez que un cliente finalize un alquiler, se registrará el uso de ese VMP, asi como los kilometros realizados, y se sumarán al total de usos y kilometros de ese vehículo.
- Cuando se supere los 50 usos o 500 km se cambiará el estado del VMP (estado: mantenimiento pendiente) y se avisará a los técnicos de mantenimiento para que revisen el VMP. Después, se reiniciará el número de usos y kilometros y volverá a estar disponible.

#### R.N.04. Edad mínima obligatoria <br>
Como administrador de EasyVPM,<br>
quiero que solo los usuarios mayores de 12 años<br>
puedan utilizar EasyVPM y alquilar un vehiculo<br>
para garantizar la seguridad de los menores.

**P.A.04.**
- Cuando los usuarios se registran por primera vez en EasyVPM, se les pedirá que indiquen su edad.
- Si el usuario tiene más de 12 años, la creación de la cuenta será un éxito y se le informará.
- Si el usuario tiene 12 años o menos, saldrá un mensaje de error donde se indica que no se pudo crear la cuenta porque no se cumple la edad mínima de uso de EasyVPM.

#### R.N.05. Cambio de estado vehículo <br>
Como administrador de EasyVPM,<br>
quiero que el sistema cambie automáticamente el estado de los vehículos,<br>
para que el cliente y el técnico de mantenimiento sepa desde la app cómo se encuentran los vehículos.

**P.A.05.**
- Si un vehículo se encuentra en buen estado aparacerá como "disponible" desde que su último usuario lo coloque en una estación.
- Si un vehículo está en mal estado aparecerá como "averiado" desde que lo informe un trabajador o cliente.
- Si un vehículo está en uso aparecerá como "en uso" desde que alguien lo alquile.
- Si un vehículo alcanza los 50 alquileres o 500 km aparecerá como "mantenimiento pendiente".
- Si un técnico de mantenimiento se lleva un vehículo aparece como "en mantenimiento".
- Si un vehículo está en el almacen tras haberse reparado y está esperando que sea redistribuido aparece como "reparado".

#### R.N.06. Cambio de estado enganche <br>
Como administrador de EasyVPM,<br>
quiero que el sistema cambie automáticamente el estado de los enganches,<br>
para que el cliente y el técnico de mantenimiento sepa desde la app en qué estado se encuentran.

**P.A.06.**
- Si un enganche se encuentra libre aparece como "libre" desde que alguien desengancha el vehículo de él.
- Si un enganche se encuentra ocupado aparece como "ocupado" desde que alguien enganche un vehículo en él.
- Si un enganche se estropea o hay algún motivo temporal que afecta a la zona (por ejemplo hay celebración con carrozas y prohíben la circulación de VMPs) el enganche aparece como "fuera de servicio".

#### R.N.07. Control de roles y permisos <br>
Como administrador de EasyVPM,<br>
quiero que el sistema tenga definido de forma clara los permisos de acceso según el tipo de usuario,
para evitar que haya accesos indebidos a funciones críticas.

**P.A.07.**
- Los clientes solo pueden acceder a funciones de consulta (estaciones, disponibilidad, historial) y alquiler.
- Los administradores pueden gestionar todo el sistema.
- Los técnicos solo pueden visualizar y actualizar el estado de incidencias o mantenimiento de vehículos.
- Cualquier intento de acceder a una función no permitida debe mostrar un mensaje de "Acceso no autorizado".

#### R.N.08. Cobro automático
Como administrador, <br>
quiero que el sistema calcule y cobre automáticamente el importe<br>
del alquiler según el tiempo de uso, <br>
para evitar pagos manuales o errores y así mejorar la experiencia<br>
de usuario. <br>

#### R.N.09. Precio Alquiler con Mensualidad
Como administrador de EasyVPM,<br>
quiero que el sistema ponga un alquiler gratuito si ya se ha<br> realizado un pago mensual.

#### R.N.10. Cantidad a pagar
Como administrador de EasyVPM,<br>
quiero que si la tarifa del cliente es individual, que se le <br>
cobre el coste del alquiler, y si la tarifa es mensual, que pueda<br> realizar el pago correspondiente al mes.

### 4.2. Mapa de historias de usuario (opcional)

<img src="mapa_historias/mapa_historias.png"  width="150%"><br>

### 4.3. Requisitos no funcionales (opcional)

#### R.N.F.01. Escalabilidad del sistema
Como administrador de EasyVPM, <br>
quiero que el sistema permita incorporar hasta 1000 usuarios y vehículos simúltaneos <br>
para poder ampliar el servicio sin afectar el rendimiento del sistema.

**P.A.01.**
- Registrar nuevos usuarios y verificar que pueden acceder y utilizar todas sus funciones.
- Añadir nuevos vehículos y comprobar que se pueden registrar y alquilar correctamente.
- Simular un incremento significativo de usuarios activos y comprobar que no provoque un fallo en el sistema y que el rendimiento de este sigue siendo aceptable.

#### R.N.F.02. Disponibilidad razonable <br>
Como cliente de EasyVPM, <br>
quiero que la aplicación este disponible en todo momento, <br>
para poder acceder al servicio sin interrupciones y aprovecharla al máximo.

**P.A.02.**
- La aplicación debe estar disponible al menos el 90% del tiempo (exceptuando mantenimientos).
- Comprobar que la aplicación se puede acceder en distintos momentos del día.
- Simular simultaneidad de accesos de distintos usuarios para verificar que el sistema permanece operativo.
- Intentar acceder al sistema durante un mantenimiento programado y comprobar que se muestra el correspondiente aviso.

#### R.N.F.03. Seguridad de la información
Como administrador de EasyVPM, <br>
quiero que los datos de usuarios, pagos y vegículos estén protegidos,<br>
para cumplir con la normativa de protección de datos y evitar accesos no autorizados.

**P.A.03.**
- Intentar acceder al sistema con un usuario no registrado y comprobar que el acceso es denegado.
- Intentar acceder al sistema con un usuario registrado, pero sin permisos suficientes y comprobar que no puede realizar acciones restringidas.
- Verificar que los datos sensibles (como credenciales y métodos de pago) están cifrados y no pueden leerse directamente desde la base de datos.
- Comprobar que todos los intentos de acceso (exitosos y fallidos) queden registrados, diferenciando los legítimos de los fraudulentos.
- Los datos sensibles (pagos, correos, etc.) se transmiten por HTTPS.
- Intentar acceder a una función restringida muestra un mensaje de “Acceso no autorizado”.

#### R.N.F.04. Fiabilidad operaciones críticas
Como cliente de EasyVPM, <br>
quiero que las funciones críticas como el registro del pago funcionen correctamente, <br>
para confiar en el sistema y evitar errores o pérdidas de datos.

**P.A.04.**
- En caso de error durante el pago o el alquiler, el sistema debe mostrar un mensaje claro.
- Verificar que los registros de alquiler, inicio y fin de viaje se guardan correctamente aun en caso de interrupción de red.
- Las operaciones completadas deben quedar registradas en el sistema sin duplicados.

#### R.N.F.05. Compatibilidad técnica del sistema
Como responsable TIC de EasyVPM, <br>
quiero que el sistema funcione correctamente en distintos entornos (Android, iOS y navegadores web modernos), <br>
para asegurar la accesibilidad del servicio a la mayoría de usuarios.

**P.A.05.**
- La app debe ser usable desde Android (versión 11 o superior) e iOS (versión 14 o superior).
- Debe tener accesi funcional básico desde navegadores web modernos (Chrome, Edge, Safari, Firefox).
- Verificar que los usuarios pueden iniciar sesión, alquilar vehículos y consultar estaciones sin ningún problema desde estas plataformas.
- Las pantallas deben adaptarse a distintos tamaños de dispositivos.


-- fin entregable 1 --

## 5. Modelo conceptual

### 5.1. Diagramas de clases UML

- con restricciones.

<img src="modelos_conceptuales/DiagramaClases.png" width="60%"><br>


### 5.2. Escenarios de prueba

- con descripción textual y diagrama de objetos UML.

<img src="modelos_conceptuales/EscenarioPruebas.png" width="90%"><br>


## 6. Matrices de trazabilidad

- Matriz de trazabilidad entre los elementos del modelo conceptual y los requisitos.

|       | EntidadX   | AsociaciónX  | RestricciónX  | Entidad2 ...   | 
|:------|:-----------|:-----------|:-----------|:-----------|
| RI-1  | X          | X          | X          | X          |
| RI-2  |            | X          |            | X          |
| RF-1  |            | X          |            | X          |
| RF-2  | X          |            | X          | X          |
| RN-1  |            | X          |            |            |
| RN-2  | X          | X          | X          |            |
| ...   |            |            |            |            |


| ID Requisito                                          | Usuario | Cliente | TécnicoMantenimiento | Vehículo | Bicicleta | PatineteEléctrico | Estación | Alquiler | Valoración | Restricciones / Asociaciones                               |
| :---------------------------------------------------- | :------ | :------ | :------------------- | :------- | :-------- | :---------------- | :------- | :------- | :--------- | :--------------------------------------------------------- |
| **R.F.01 Registro de usuario**                        | X       | X       |                      |          |           |                   |          |          |            | Verifica correo único, edad mínima (R.N.04)                |
| **R.F.02 Proceso de alquiler**                        | X       | X       |                      | X        | X         | X                 | X        | X        |            | Solo un alquiler activo (R.N.02)                           |
| **R.F.03 Cobro automático**                           | X       | X       |                      | X        |           |                   | X        | X        |            | No eliminar usuario con alquiler activo (R.N.01)           |
| **R.F.04 Recuperar contraseña**                       | X       | X       |                      |          |           |                   |          |          |            | Enlace temporal 24h                                        |
| **R.F.05 Consulta de estaciones cercanas**            | X       | X       |                      |          |           |                   | X        |          |            | Muestra vehículos disponibles (relación Estación–Vehículo) |
| **R.F.06 Disponibilidad de vehículos**                | X       | X       |                      | X        | X         | X                 | X        |          |            | Estado en tiempo real (R.N.05, R.N.06)                     |
| **R.F.07 Valoración de vehículo o estación**          | X       | X       |                      | X        | X         | X                 | X        |          | X          | Asociación Cliente–Valoración–Vehículo/Estación            |
| **R.I.01 Información administrativa**                 | X       |         |                      | X        | X         | X                 | X        | X        | X          | Permite CRUD de usuarios, vehículos, estaciones            |
| **R.I.02 Información usuario**                        | X       | X       |                      | X        | X         | X                 | X        | X        | X          | Muestra historial de alquileres y reseñas                  |
| **R.I.03 Información mantenimiento**                  |         |         | X                    | X        | X         | X                 | X        |          |            | Asociación TécnicoMantenimiento–Vehículo                   |
| **R.N.01 No eliminar usuario con alquiler activo**    | X       | X       |                      | X        |           |                   |          | X        |            | Restricción sobre asociación Usuario–Alquiler              |
| **R.N.02 Evitar 2 alquileres simultáneos**            | X       | X       |                      | X        |           |                   |          | X        |            | Restricción 1..1 Cliente–Alquiler                          |
| **R.N.03 Mantenimiento obligatorio 50 usos / 500 km** |         |         | X                    | X        | X         | X                 |          |          |            | Restricción sobre atributo kilometraje y númeroUsos        |
| **R.N.04 Edad mínima obligatoria**                    | X       | X       |                      |          |           |                   |          |          |            | Restricción sobre atributo edad del Usuario                |
| **R.N.05 Cambio automático estado vehículo**          |         |         | X                    | X        | X         | X                 | X        |          |            | Asociación TécnicoMantenimiento–Vehículo                   |
| **R.N.06 Cambio automático estado estación**          |         |         |                      |          |           |                   | X        | X        |            | Asociación Estación–Vehículo                               |
| **R.N.07 Control de roles y permisos**                | X       | X       | X                    |          |           |                   |          |          |            | Diferencia Cliente / Técnico / Admin                       |
| **R.N.F.01 Escalabilidad**                            | X       | X       | X                    | X        | X         | X                 | X        | X        | X          | General, afecta a todas las entidades                      |
| **R.N.F.02 Disponibilidad razonable**                 | X       | X       | X                    | X        | X         | X                 | X        | X        | X          | General, servicio activo ≥90%                              |
| **R.N.F.03 Seguridad información**                    | X       | X       | X                    |          |           |                   |          |          |            | Cifrado de datos, HTTPS                                    |
| **R.N.F.04 Fiabilidad operaciones críticas**          | X       | X       | X                    | X        |           |                   | X        | X        |            | Registro íntegro ante fallos                               |
| **R.N.F.05 Compatibilidad técnica**                   | X       | X       | X                    |          |           |                   |          |          |            | Interfaz multiplataforma Android/iOS/Web                   |




-- fin entregable 2 --

## 7. Modelo relacional en 3FN

- Relaciones obtenidas al aplicar la transformación del modelo conceptual.

### 7.1.  Justificación de la estrategia de transformación de jerarquías

- si se identificaron jerarquías en el MC.


### 8. Matriz de trazabilidad MC/SQL (opcional):

- Restricciones sobre el MC / Elementos del modelo tecnológico (SQL) (Triggers, checks, etc.)
- Incluir Reglas de negocio — Constraints/Triggers en las matrices de trazabilidad para el entregable 3

|       | EntidadX   | AsociaciónX  | RestricciónX  | Entidad2 ...   | 
|:-------|:-------|:-------|:-------|:-------|
| TABLA-1 |        |        |        |        |
| TABLA-2 |        |        |        |        |
| TABLA-3 |        |        |        |        |
| TABLA-4 |        |        |        |        |
| TRIG-1 |        |        |        |        |
| TRIG-2 | X      | X      |        | X      |
| TRIG-3 |        | X      |        | X      |
| TRIG-4 |        |        | X      |        |
| CONST-1 |        |        |        |        |
| CONST-2 | X      | X      |        | X      |
| CONST-3 |        | X      |        | X      |
| CONST-4 |        |        | X      |        |

Se consideran todo tipo de constraints declarativas (aquellas definidas durante el CREATE TABLE).
-- fin entregable 3 --

## Referencias


